import 'dart:async';
import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/appsync/routine_log_dto.dart';
import 'package:tracker_app/dtos/exercise_variant_dto.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/utils/routine_utils.dart';

import '../../dtos/abstract_class/exercise_dto.dart';
import '../../dtos/exercise_log_dto.dart';
import '../../dtos/milestones/days_milestone_dto.dart';
import '../../dtos/milestones/hours_milestone_dto.dart';
import '../../dtos/milestones/milestone_dto.dart';
import '../../dtos/milestones/reps_milestone.dart';
import '../../dtos/milestones/weekly_milestone_dto.dart';
import '../../dtos/sets_dtos/set_dto.dart';
import '../../enums/exercise/exercise_configuration_key.dart';
import '../../models/RoutineLog.dart';
import '../../models/RoutineTemplate.dart';
import '../../shared_prefs.dart';

class AmplifyRoutineLogRepository {
  List<RoutineLogDto> _logs = [];

  UnmodifiableListView<RoutineLogDto> get logs => UnmodifiableListView(_logs);

  List<Milestone> _milestones = [];

  UnmodifiableListView<Milestone> get milestones => UnmodifiableListView(_milestones);

  List<Milestone> _newMilestones = [];

  UnmodifiableListView<Milestone> get newMilestones => UnmodifiableListView(_newMilestones);

  Map<String, List<ExerciseLogDTO>> _exerciseLogsByExerciseId = {};

  UnmodifiableMapView<String, List<ExerciseLogDTO>> get exerciseLogsByExerciseId => UnmodifiableMapView(_exerciseLogsByExerciseId);

  void _groupExerciseLogs() {
    _exerciseLogsByExerciseId = groupExerciseLogsByExerciseId(routineLogs: _logs);
  }

  void loadLogStream({required List<RoutineLog> logs}) {
    _logs = logs.map((log) => RoutineLogDto.toDto(log)).toList();
    _groupExerciseLogs();
    _calculateMilestones();
  }

  Future<RoutineLogDto> saveLog({required RoutineLogDto logDto, TemporalDateTime? datetime}) async {
    // Capture current list of completed milestones
    final previousMilestones = completedMilestones().toSet();

    final now = datetime ?? TemporalDateTime.now();

    final logToCreate =
        RoutineLog(data: jsonEncode(logDto), createdAt: now, updatedAt: now, owner: SharedPrefs().userId);

    await Amplify.DataStore.save<RoutineLog>(logToCreate);

    final updatedRoutineLogWithId = logDto.copyWith(id: logToCreate.id, owner: logToCreate.owner);
    final updatedRoutineWithExerciseIds = updatedRoutineLogWithId.copyWith(
        exerciseLogs:
            updatedRoutineLogWithId.exerciseLogs.map((log) => log.copyWith(routineLogId: logToCreate.id)).toList());

    // Capture recent list of milestones
    _calculateMilestones();

    // Capture recent list of completed milestones
    final updatedMilestones = completedMilestones().toSet();

    // Get newly achieved milestone
    _newMilestones = updatedMilestones.difference(previousMilestones).toList();

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
    }
  }

  void cacheLog({required RoutineLogDto logDto}) {
    SharedPrefs().cachedRoutineLog = jsonEncode(logDto,
        toEncodable: (Object? value) =>
            value is RoutineLogDto ? value.toJson() : throw UnsupportedError('Cannot convert to JSON: $value'));
  }

  RoutineLogDto? cachedRoutineLog() {
    RoutineLogDto? routineLog;
    final cache = SharedPrefs().cachedRoutineLog;
    if (cache.isNotEmpty) {
      final json = jsonDecode(cache);
      return RoutineLogDto.fromCachedLog(json: json);
    }
    return routineLog;
  }

  void _calculateMilestones() {
    List<Milestone> milestones = [];

    final logsForTheYear = whereLogsIsSameYear(dateTime: DateTime.now().withoutTime());

    /// Add Weekly Challenges
    final weeklyMilestones = WeeklyMilestone.loadMilestones(logs: logsForTheYear);
    for (final milestone in weeklyMilestones) {
      milestones.add(milestone);
    }

    /// Add Days Challenges
    final daysMilestones = DaysMilestone.loadMilestones(logs: logsForTheYear);
    for (final milestone in daysMilestones) {
      milestones.add(milestone);
    }

    /// Add Reps Milestones
    final repsMilestones = RepsMilestone.loadMilestones(logs: logsForTheYear);
    for (final milestone in repsMilestones) {
      milestones.add(milestone);
    }

    /// Add Hours Milestones
    final hoursMilestones = HoursMilestone.loadMilestones(logs: logsForTheYear);
    for (final milestone in hoursMilestones) {
      milestones.add(milestone);
    }

    milestones.sort((a, b) => a.name.compareTo(b.name));

    _milestones = milestones;
  }

  /// Helper methods

  RoutineLogDto? logWhereId({required String id}) {
    return _logs.firstWhereOrNull((log) => log.id == id);
  }

  List<SetDTO> whereSetsForExercise({required ExerciseVariantDTO exerciseVariant}) {
    final exerciseLogs = _exerciseLogsByExerciseId[exerciseVariant.name]?.reversed ?? [];
    return exerciseLogs.isNotEmpty ? exerciseLogs.first.sets : [];
  }

  List<SetDTO> whereSetsForExerciseBefore({required ExerciseDTO exercise, required DateTime date}) {
    final exerciseLogs = _exerciseLogsByExerciseId[exercise.name]?.where((log) => log.createdAt.isBefore(date)) ?? [];
    return exerciseLogs.isNotEmpty ? exerciseLogs.first.sets : [];
  }

  List<ExerciseLogDTO> whereExerciseLogsBefore({required ExerciseVariantDTO exerciseVariant, required DateTime date}) {
    return _exerciseLogsByExerciseId[exerciseVariant.name]?.where((log) => log.createdAt.isBefore(date)).toList() ?? [];
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

  /// ExerciseLog
  List<ExerciseLogDTO> filterExerciseLogsByIdAndConfigurations({required String exerciseId, required Map<ExerciseConfigurationKey, ExerciseConfigValue> configurations}) {
    final exerciseLogs = _exerciseLogsByExerciseId[exerciseId] ?? [];

    return exerciseLogs.where((log) {
      final Map<ExerciseConfigurationKey, ExerciseConfigValue> logConfigurations =
          log.exerciseVariant.configurations;

      // Check if all criteria configurations match the log's configurations
      for (final key in configurations.keys) {
        final ExerciseConfigValue? logValue = logConfigurations[key];
        final ExerciseConfigValue criteriaValue = configurations[key]!;

        if (logValue == null || logValue != criteriaValue) {
          return false; // This log does not match the criteria
        }
      }
      return true; // All criteria configurations match
    }).toList();
  }

  /// Milestones
  UnmodifiableListView<Milestone> pendingMilestones() =>
      UnmodifiableListView(_milestones.where((milestone) => milestone.progress.$1 < 1));

  UnmodifiableListView<Milestone> completedMilestones() =>
      UnmodifiableListView(milestones.where((milestone) => milestone.progress.$1 == 1));

  void clear() {
    _logs.clear();
    _exerciseLogsByExerciseId.clear();
    _milestones.clear();
    _newMilestones.clear();
  }
}
