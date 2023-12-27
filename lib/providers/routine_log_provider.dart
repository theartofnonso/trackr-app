import 'dart:convert';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/models/ModelProvider.dart';
import 'package:tracker_app/providers/user_provider.dart';
import 'package:tracker_app/shared_prefs.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';

import '../dtos/exercise_log_dto.dart';
import '../enums/exercise_type_enums.dart';
import '../utils/general_utils.dart';

const emptyTemplateId = "empty_template_id";

class RoutineLogProvider with ChangeNotifier {
  Map<String, List<ExerciseLogDto>> _exerciseLogsById = {};

  Map<ExerciseType, List<ExerciseLogDto>> _exerciseLogsByType = {};

  List<RoutineLog> _logs = [];

  Map<DateTimeRange, List<RoutineLog>> _weekToLogs = {};

  Map<DateTimeRange, List<RoutineLog>> _monthToLogs = {};

  UnmodifiableMapView<String, List<ExerciseLogDto>> get exerciseLogsById => UnmodifiableMapView(_exerciseLogsById);

  UnmodifiableMapView<ExerciseType, List<ExerciseLogDto>> get exerciseLogsByType =>
      UnmodifiableMapView(_exerciseLogsByType);

  UnmodifiableListView<RoutineLog> get logs => UnmodifiableListView(_logs);

  UnmodifiableMapView<DateTimeRange, List<RoutineLog>> get weekToLogs => UnmodifiableMapView(_weekToLogs);

  UnmodifiableMapView<DateTimeRange, List<RoutineLog>> get monthToLogs => UnmodifiableMapView(_monthToLogs);

  void listLogs() async {
    _logs = await Amplify.DataStore.query(RoutineLog.classType);
    _logs.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    _normaliseLogs();
    notifyListeners();
  }

  void _orderExercises() {
    List<ExerciseLogDto> exerciseLogs = _logs
        .map((log) => log.exerciseLogs.map((json) => ExerciseLogDto.fromJson(routineLog: log, json: jsonDecode(json))))
        .expand((exerciseLogs) => exerciseLogs)
        .toList();
    _exerciseLogsById = groupBy(exerciseLogs, (exerciseLog) => exerciseLog.exercise.id);
    _exerciseLogsByType = groupBy(exerciseLogs, (exerciseLog) {
      final exerciseTypeString = exerciseLog.exercise.type;
      final exerciseType = ExerciseType.fromString(exerciseTypeString);
      return exerciseType;
    });
  }

  void _loadWeekToLogs() {
    if (_logs.isEmpty) {
      return;
    }

    final weekToLogs = <DateTimeRange, List<RoutineLog>>{};

    DateTime startDate = logs.first.createdAt.getDateTimeInUtc();
    List<DateTimeRange> weekRanges = generateWeekRangesFrom(startDate);

    // Map each DateTimeRange to RoutineLogs falling within it
    for (var weekRange in weekRanges) {
      List<RoutineLog> routinesInWeek = logs
          .where((log) =>
              log.createdAt.getDateTimeInUtc().isAfter(weekRange.start) &&
              log.createdAt.getDateTimeInUtc().isBefore(weekRange.end.add(const Duration(days: 1))))
          .toList();
      weekToLogs[weekRange] = routinesInWeek;
    }

    _weekToLogs = weekToLogs;
  }

  void _loadMonthToLogs() {
    if (_logs.isEmpty) {
      return;
    }

    final monthToLogs = <DateTimeRange, List<RoutineLog>>{};

    DateTime startDate = logs.first.createdAt.getDateTimeInUtc();
    List<DateTimeRange> monthRanges = generateMonthRangesFrom(startDate);

    // Map each DateTimeRange to RoutineLogs falling within it
    for (var monthRange in monthRanges) {
      List<RoutineLog> routinesInMonth = logs
          .where((log) =>
              log.createdAt.getDateTimeInUtc().isAfter(monthRange.start) &&
              log.createdAt.getDateTimeInUtc().isBefore(monthRange.end.add(const Duration(days: 1))))
          .toList();
      monthToLogs[monthRange] = routinesInMonth;
    }
    _monthToLogs = monthToLogs;
  }

  void _normaliseLogs() {
    _orderExercises();
    _loadWeekToLogs();
    _loadMonthToLogs();
  }

  Future<RoutineLog?> saveRoutineLog(
      {required BuildContext context,
      required String name,
      required String notes,
      required List<ExerciseLogDto> exerciseLogs,
      required TemporalDateTime startTime,
      required RoutineTemplate? template}) async {
    RoutineLog? logToCreate;

    final user = Provider.of<UserProvider>(context, listen: false).user;

    if (user != null) {
      final now = TemporalDateTime.now();

      final exerciseLogJsons = exerciseLogs.map((log) => log.toJson()).toList();

      logToCreate = RoutineLog(
          name: name,
          notes: notes,
          exerciseLogs: exerciseLogJsons,
          startTime: startTime,
          endTime: now,
          createdAt: now,
          updatedAt: now,
          template: template,
          user: user);

      try {
        await Amplify.DataStore.save(logToCreate);
        _logs.add(logToCreate);
        _logs.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        _normaliseLogs();
        notifyListeners();
      } on DataStoreException catch (error) {
        print('Error saving RoutineLog: ${error.message}');
      }
    }

    return logToCreate;
  }

  void cacheRoutineLog(
      {required BuildContext context,
      required String name,
      required String notes,
      required List<ExerciseLogDto> procedures,
      required TemporalDateTime startTime,
      TemporalDateTime? createdAt,
      required RoutineTemplate? template}) async {
    final user = Provider.of<UserProvider>(context, listen: false).user;

    if (user != null) {
      final currentTime = TemporalDateTime.now();

      final exerciseLogJson = procedures.map((procedure) => procedure.toJson()).toList();

      final logToCache = RoutineLog(
          name: name,
          notes: notes,
          template: template,
          exerciseLogs: exerciseLogJson,
          startTime: startTime,
          endTime: currentTime,
          createdAt: createdAt ?? currentTime,
          updatedAt: currentTime,
          user: user);
      SharedPrefs().cachedRoutineLog = jsonEncode(logToCache);
    }
  }

  Future<void> removeLog({required String id}) async {
    final index = _indexWhereRoutineLog(id: id);
    final logToBeRemoved = _logs[index];
    final request = ModelMutations.delete(logToBeRemoved);
    final response = await Amplify.API.mutate(request: request).response;
    final deletedLog = response.data;
    if (deletedLog != null) {
      final index = _indexWhereRoutineLog(id: id);
      _logs.removeAt(index);
      _normaliseLogs();
      notifyListeners();
    }
  }

  int _indexWhereRoutineLog({required String id}) {
    return _logs.indexWhere((log) => log.id == id);
  }

  RoutineLog? whereRoutineLog({required String id}) {
    return _logs.firstWhereOrNull((log) => log.id == id);
  }

  List<SetDto> wherePastSets({required Exercise exercise}) {
    final exerciseLogs = _exerciseLogsById[exercise.id]?.reversed.toList() ?? [];
    return exerciseLogs.isNotEmpty ? exerciseLogs.first.sets : [];
  }

  List<SetDto> setsForMuscleGroupWhereDateRange(
      {required MuscleGroupFamily muscleGroupFamily, required DateTimeRange range}) {
    bool hasMatchingBodyPart(ExerciseLogDto log) {
      final primaryMuscle = MuscleGroup.fromString(log.exercise.primaryMuscle);
      return primaryMuscle.family == muscleGroupFamily;
    }

    List<List<ExerciseLogDto>> allLogs = _exerciseLogsById.values.toList();

    return allLogs.flattened
        .where((log) => hasMatchingBodyPart(log))
        .where((log) => log.createdAt.getDateTimeInUtc().isBetweenRange(range: range))
        .expand((log) => log.sets)
        .toList();
  }

  bool isLatestLogForTemplate({required String templateId, required logId}) {
    final logsForTemplate = _logs.lastWhereOrNull((log) => log.template?.id == templateId);
    if (logsForTemplate == null) {
      return false;
    } else {
      return logsForTemplate.id == logId;
    }
  }

  List<RoutineLog> logsWhereDate({required DateTime dateTime}) {
    return _logs.where((log) => log.createdAt.getDateTimeInUtc().isSameDateAs(dateTime)).toList();
  }

  RoutineLog? logWhereDate({required DateTime dateTime}) {
    return _logs.firstWhereOrNull((log) => log.createdAt.getDateTimeInUtc().isSameDateAs(dateTime));
  }

  List<ExerciseLogDto> exerciseLogsWhereDateRange({required DateTimeRange range, required Exercise exercise}) {
    final values = _exerciseLogsById[exercise.id] ?? [];
    return values.where((log) => log.createdAt.getDateTimeInUtc().isBetweenRange(range: range)).toList();
  }

  List<RoutineLog> logsWhereDateRange({required DateTimeRange range}) {
    return _logs.where((log) => log.createdAt.getDateTimeInUtc().isBetweenRange(range: range)).toList();
  }

  void reset() {
    _logs.clear();
    notifyListeners();
  }
}
