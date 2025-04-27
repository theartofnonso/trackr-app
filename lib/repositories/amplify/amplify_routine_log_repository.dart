import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:sahha_flutter/sahha_flutter.dart';
import 'package:tracker_app/dtos/appsync/routine_log_dto.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/models/ModelProvider.dart';
import 'package:tracker_app/utils/exercise_logs_utils.dart';
import 'package:tracker_app/utils/routine_utils.dart';

import '../../dtos/appsync/exercise_dto.dart';
import '../../dtos/exercise_log_dto.dart';
import '../../dtos/set_dtos/set_dto.dart';
import '../../enums/posthog_analytics_event.dart';
import '../../logger.dart';
import '../../shared_prefs.dart';
import '../../utils/date_utils.dart';
import '../../utils/notifications_utils.dart';
import '../../utils/sahha_utils.dart';

class AmplifyRoutineLogRepository {
  final logger = getLogger(className: "AmplifyRoutineLogRepository");

  List<RoutineLogDto> _logs = [];

  UnmodifiableListView<RoutineLogDto> get logs => UnmodifiableListView(_logs);

  Map<String, List<ExerciseLogDto>> _exerciseLogsByExerciseId = {};

  UnmodifiableMapView<String, List<ExerciseLogDto>> get exerciseLogsByExerciseId =>
      UnmodifiableMapView(_exerciseLogsByExerciseId);

  Map<MuscleGroup, List<ExerciseLogDto>> _exerciseLogsByMuscleGroup = {};

  UnmodifiableMapView<MuscleGroup, List<ExerciseLogDto>> get exerciseLogsByMuscleGroup =>
      UnmodifiableMapView(_exerciseLogsByMuscleGroup);

  void _groupExerciseLogsById() {
    _exerciseLogsByExerciseId = groupExerciseLogsByExerciseId(routineLogs: _logs);
  }

  void _groupExerciseLogsByMuscleGroup() {
    _exerciseLogsByMuscleGroup = groupExerciseLogsByMuscleGroup(routineLogs: _logs);
  }

  void loadLogStream({required List<RoutineLog> logs}) {
    _logs = logs.map((log) => RoutineLogDto.toDto(log)).toList();
    _syncTrainingReminders();
    _groupExerciseLogsById();
    _groupExerciseLogsByMuscleGroup();
  }

  /// Everytime we sync logs, we refresh the training reminders
  /// First we cancel all notifications previously set when we supported daily notifications,
  /// then pending workout sessions and
  /// also, stale training reminders, because training frequency changes
  /// Finally, schedule notification reminders for those dates and time

  void _syncTrainingReminders() {
    if (logs.isEmpty) return;

    if (Platform.isIOS) {
      final dateRange = theLastYearDateTimeRange();
      final weeksInLastYear = generateWeeksInRange(range: dateRange);

      List<DateTime> historicTrainingTimes = [];
      for (final week in weeksInLastYear) {
        final startOfWeek = week.start;
        final endOfWeek = week.end;

        final weeklyLogs = _logs.where((log) => log.createdAt.isBetweenInclusive(from: startOfWeek, to: endOfWeek));

        final weeklyLogsTimes = weeklyLogs.map((log) {
          final createdAt = log.createdAt;
          final logDuration = log.duration();
          return createdAt.subtract(logDuration);
        });

        historicTrainingTimes.addAll(weeklyLogsTimes);
      }
      FlutterLocalNotificationsPlugin().cancelAll();

      schedulePreferredTrainingReminders(historicDateTimes: historicTrainingTimes);
    }
  }

  void getSahhaReadinessScore() async {
    try {
      final value = await SahhaFlutter.getScores(
          types: [SahhaScoreType.readiness],
          startDateTime: DateTime.now().subtract(const Duration(hours: 24)),
          endDateTime: DateTime.now());
      final score = extractReadinessScore(jsonString: value);
      SharedPrefs().readinessScore = score;
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  Future<RoutineLogDto> saveLog({required RoutineLogDto logDto, TemporalDateTime? datetime}) async {
    final now = datetime ?? TemporalDateTime.now();

    final logToCreate =
        RoutineLog(data: jsonEncode(logDto), createdAt: now, updatedAt: now, owner: SharedPrefs().userId);

    await Amplify.DataStore.save<RoutineLog>(logToCreate);

    logger.i("save log: ${logDto.name}");

    Posthog().capture(eventName: PostHogAnalyticsEvent.logRoutine.displayName, properties: logDto.toJson());

    final updatedRoutineLogWithId = logDto.copyWith(id: logToCreate.id);
    final updatedRoutineWithExerciseIds = updatedRoutineLogWithId.copyWith(
        exerciseLogs:
            updatedRoutineLogWithId.exerciseLogs.map((log) => log.copyWith(routineLogId: logToCreate.id)).toList());

    return updatedRoutineWithExerciseIds;
  }

  Future<void> updateLog({required RoutineLogDto log}) async {
    final result = (await Amplify.DataStore.query(
      RoutineLog.classType,
      where: RoutineLog.ID.eq(log.id),
    ));

    if (result.isNotEmpty) {
      final oldLog = result.first;
      final startTime = TemporalDateTime.withOffset(log.startTime, Duration.zero);
      final updatedAt = TemporalDateTime.withOffset(log.updatedAt, Duration.zero);
      final newLog = oldLog.copyWith(data: jsonEncode(log), createdAt: startTime, updatedAt: updatedAt);
      await Amplify.DataStore.save<RoutineLog>(newLog);
      logger.i("update log: ${log.name}");
    }
  }

  Future<void> removeLog({required RoutineLogDto log}) async {
    final result = (await Amplify.DataStore.query(
      RoutineLog.classType,
      where: RoutineTemplate.ID.eq(log.id),
    ));

    if (result.isNotEmpty) {
      final oldTemplate = result.first;
      await Amplify.DataStore.delete<RoutineLog>(oldTemplate);
      logger.i("remove log: ${log.name}");
    }
  }

  /// Helper methods

  RoutineLogDto? logWhereId({required String id}) {
    return _logs.firstWhereOrNull((log) => log.id == id);
  }

  List<SetDto> wherePrevSetsForExercise({required ExerciseDto exercise}) {
    final exerciseLogs = _exerciseLogsByExerciseId[exercise.id]?.reversed ?? [];
    return exerciseLogs
        .expand((exerciseLog) => exerciseLog.sets)
        .where((set) => set.isNotEmpty() && set.checked)
        .toList();
  }

  List<SetDto> whereRecentSetsForExercise({required ExerciseDto exercise}) {
    final exerciseLogs = _exerciseLogsByExerciseId[exercise.id]?.reversed ?? [];
    final completedExercises = loggedExercises(exerciseLogs: exerciseLogs.toList());
    return completedExercises.isNotEmpty ? completedExercises.first.sets : [];
  }

  List<SetDto> whereSetsForExerciseBefore({required ExerciseDto exercise, required DateTime date}) {
    final exerciseLogs = _exerciseLogsByExerciseId[exercise.id]?.where((log) => log.createdAt.isBefore(date)) ?? [];
    final completedExercises = loggedExercises(exerciseLogs: exerciseLogs.toList());
    return completedExercises.isNotEmpty ? completedExercises.first.sets : [];
  }

  List<ExerciseLogDto> whereExerciseLogsBefore({required ExerciseDto exercise, required DateTime date}) {
    final exerciseLogs =
        _exerciseLogsByExerciseId[exercise.id]?.where((log) => log.createdAt.isBefore(date)).toList() ?? [];
    final completedExercises = loggedExercises(exerciseLogs: exerciseLogs.toList());
    return completedExercises;
  }

  /// RoutineLog for the following [DateTime]
  /// Day, Month and Year - Looking for a log in the same day, hence the need to match the day, month and year
  /// Month and Year - Looking for a log in the same month day, hence the need to match the month and year
  /// Year - Looking for a log in the same year, hence the need to match the year
  RoutineLogDto? whereLogIsSameDay({required DateTime dateTime}) {
    return _logs.firstWhereOrNull((log) => log.createdAt.isSameDayMonthYear(dateTime));
  }

  RoutineLogDto? whereLogIsSameMonth({required DateTime dateTime}) {
    return _logs.firstWhereOrNull((log) => log.createdAt.isSameMonthYear(dateTime));
  }

  RoutineLogDto? whereLogIsSameYear({required DateTime dateTime}) {
    return _logs.firstWhereOrNull((log) => log.createdAt.isSameYear(dateTime));
  }

  /// RoutineLogs for the following [DateTime]
  /// Day, Month and Year - Looking for logs in the same day, hence the need to match the day, month and year
  /// Month and Year - Looking for logs in the same month day, hence the need to match the month and year
  /// Year - Looking for logs in the same year, hence the need to match the year
  List<RoutineLogDto> whereLogsIsSameDay({required DateTime dateTime}) {
    return _logs.where((log) => log.createdAt.isSameDayMonthYear(dateTime)).toList();
  }

  List<RoutineLogDto> whereLogsIsSameMonth({required DateTime dateTime}) {
    return _logs.where((log) => log.createdAt.isSameMonthYear(dateTime)).toList();
  }

  List<RoutineLogDto> whereLogsIsSameYear({required DateTime dateTime}) {
    return _logs.where((log) => log.createdAt.isSameYear(dateTime)).toList();
  }

  List<RoutineLogDto> whereLogsIsWithinRange({required DateTimeRange range}) {
    return _logs.where((log) => log.createdAt.isBetweenInclusive(from: range.start, to: range.end)).toList();
  }

  List<RoutineLogDto> whereLogsWithTemplateId({required String templateId}) {
    return _logs.where((log) => log.templateId == templateId).toList();
  }

  List<RoutineLogDto> whereLogsWithTemplateName({required String templateName}) {
    return _logs.where((log) => log.name == templateName).toList();
  }

  List<RoutineLogDto> whereRoutineLogsBefore({required String templateId, required DateTime date}) {
    return _logs.where((log) => log.templateId == templateId && log.createdAt.isBefore(date)).toList();
  }

  void clear() {
    _logs.clear();
    _exerciseLogsByExerciseId.clear();
  }
}
