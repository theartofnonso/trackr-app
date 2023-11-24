import 'dart:convert';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/models/Exercise.dart';
import 'package:tracker_app/models/Routine.dart';
import 'package:tracker_app/providers/routine_provider.dart';
import 'package:tracker_app/shared_prefs.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';

import '../dtos/procedure_dto.dart';
import '../models/RoutineLog.dart';
import '../utils/general_utils.dart';

class RoutineLogProvider with ChangeNotifier {
  List<RoutineLog> _logs = [];

  UnmodifiableListView<RoutineLog> get logs => UnmodifiableListView(_logs);

  RoutineLog? _cachedLog;

  RoutineLog? get cachedLog => _cachedLog;

  List<RoutineLog> _cachedPendingLogs = [];

  List<RoutineLog> get cachedPendingLogs => _cachedPendingLogs;

  void clearCachedLog() {
    _cachedLog = null;
    SharedPrefs().cachedRoutineLog = "";
    notifyListeners();
  }

  void clearCachedPendingLogs() {
    _cachedPendingLogs = [];
    SharedPrefs().cachedPendingRoutineLogs = [];
    notifyListeners();
  }

  void listRoutineLogs(BuildContext context) async {
    final routineLogOwner = user();
    final request = ModelQueries.list(RoutineLog.classType, where: RoutineLog.USER.eq(routineLogOwner.id));
    final response = await Amplify.API.query(request: request).response;

    final routineLogs = response.data?.items;
    if (routineLogs != null) {
      _logs = routineLogs.whereType<RoutineLog>().toList();
      _logs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();
    }
  }

  Future<List<RoutineLog>> listRoutineLogsForRoutine({required String id}) async {
    List<RoutineLog> logs = [];

    final routineLogOwner = user();
    final request = ModelQueries.list(RoutineLog.classType, where: RoutineLog.ROUTINE.eq(id).and(RoutineLog.USER.eq(routineLogOwner.id)));
    final response = await Amplify.API.query(request: request).response;

    final routineLogs = response.data?.items;
    if (routineLogs != null) {
      logs = routineLogs.whereType<RoutineLog>().toList();
    }
    return logs;
  }

  Map<String, dynamic> _fixJson(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    json.update("routine", (value) {
      return {"serializedData": value};
    });
    // json.update("user", (value) {
    //   return {"serializedData": value};
    // });
    return json;
  }

  void retrieveCachedRoutineLog(BuildContext context) {
    final cachedLog = SharedPrefs().cachedRoutineLog;
    if (cachedLog.isNotEmpty) {
      final json = _fixJson(cachedLog);
      _cachedLog = RoutineLog.fromJson(json);
    }
  }

  void retrieveCachedPendingRoutineLog(BuildContext context) {
    final cachedLogs = SharedPrefs().cachedPendingRoutineLogs;
    if (cachedLogs.isNotEmpty) {
      _cachedPendingLogs = cachedLogs.map((log) {
        final json = _fixJson(log);
        return RoutineLog.fromJson(json);
      }).toList();
    }
  }

  void saveRoutineLog(
      {required BuildContext context,
      required String name,
      required String notes,
      required List<ProcedureDto> procedures,
      required TemporalDateTime startTime,
      TemporalDateTime? createdAt,
      required Routine? routine}) async {
    clearCachedLog();

    final proceduresJson = procedures.map((procedure) => procedure.toJson()).toList();

    final logToCreate = RoutineLog(
        name: name,
        notes: notes,
        procedures: proceduresJson,
        startTime: startTime,
        endTime: TemporalDateTime.now(),
        createdAt: createdAt ?? TemporalDateTime.now(),
        updatedAt: TemporalDateTime.now(),
        routine: routine?.copyWith(procedures: proceduresJson),
        user: user());

    print("${routine?.name} - Before attempting to create log");

    try {
      final request = ModelMutations.create(logToCreate);
      final response = await Amplify.API.mutate(request: request).response;
      final createdLog = response.data;
      if (createdLog != null) {
        _addToLogs(createdLog);
        if (routine != null) {
          if (context.mounted) {
            print("${routine.name} - after attempting to create log");
            Provider.of<RoutineProvider>(context, listen: false)
                .updateRoutine(routine: routine.copyWith(procedures: proceduresJson));
          }
        }
      }
    } on ApiException catch (_) {
      _cachePendingLogs(logToCreate);
    }
  }

  void _cachePendingLogs(RoutineLog pendingLog) {
    _cachedPendingLogs.add(pendingLog);
    final pendingLogs = SharedPrefs().cachedPendingRoutineLogs;
    final jsonLog = jsonEncode(pendingLog);
    pendingLogs.add(jsonLog);
    SharedPrefs().cachedPendingRoutineLogs = pendingLogs;
    notifyListeners();
  }

  void retryPendingRoutineLogs(BuildContext context) async {
    final cachedPendingRoutineLogs = SharedPrefs().cachedPendingRoutineLogs;
    for (int index = 0; index < _cachedPendingLogs.length; index++) {
      final pendingLog = _cachedPendingLogs[index];
      final request = ModelMutations.create(pendingLog);
      final response = await Amplify.API.mutate(request: request).response;
      final createdLog = response.data;
      if (createdLog != null) {
        /// Remove from caches i.e both [_cachedPendingLogs] and [SharedPrefs().cachedPendingRoutineLogs]
        _cachedPendingLogs.removeAt(index);
        cachedPendingRoutineLogs.removeAt(index);
        SharedPrefs().cachedPendingRoutineLogs = cachedPendingRoutineLogs;

        /// Add to logs
        _addToLogs(createdLog);

        /// Update routine
        if (context.mounted) {
          final routine = createdLog.routine;
          if (routine != null) {
            Provider.of<RoutineProvider>(context, listen: false)
                .updateRoutine(routine: routine.copyWith(procedures: createdLog.procedures));
          }
        }
      }
    }
  }

  void cacheRoutineLog(
      {required String name,
      required String notes,
      required List<ProcedureDto> procedures,
      required TemporalDateTime startTime,
      TemporalDateTime? createdAt,
      required Routine? routine}) {
    final currentTime = TemporalDateTime.now();

    final procedureJsons = procedures.map((procedure) => procedure.toJson()).toList();

    final cachedLog = RoutineLog(
        name: name,
        notes: notes,
        routine: routine,
        procedures: procedureJsons,
        startTime: startTime,
        endTime: currentTime,
        createdAt: createdAt ?? currentTime,
        updatedAt: currentTime,
        user: user());
    _cachedLog = cachedLog;
    SharedPrefs().cachedRoutineLog = jsonEncode(cachedLog);
    notifyListeners();
  }

  void _addToLogs(RoutineLog log) {
    _logs.add(log);
    _logs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }

  Future<void> updateLog({required RoutineLog log}) async {
    final request = ModelMutations.update(log);
    final response = await Amplify.API.mutate(request: request).response;
    final updatedLog = response.data;
    if (updatedLog != null) {
      final index = _indexWhereRoutineLog(id: log.id);
      _logs[index] = log;
      notifyListeners();
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
      notifyListeners();
    }
  }

  int _indexWhereRoutineLog({required String id}) {
    return _logs.indexWhere((log) => log.id == id);
  }

  RoutineLog? whereRoutineLog({required String id}) {
    return _logs.firstWhereOrNull((log) => log.id == id);
  }

  List<ProcedureDto> _proceduresForExercise({required Exercise exercise}) {
    final mostRecentLog = _logs.firstWhereOrNull((log) {
      final decodedProcedures = log.procedures.map((json) => ProcedureDto.fromJson(jsonDecode(json))).toList();
      List<ProcedureDto> filteredProcedures =
          decodedProcedures.where((procedure) => procedure.exercise.id == exercise.id).toList();
      return filteredProcedures.isNotEmpty;
    });

    if (mostRecentLog != null) {
      return mostRecentLog.procedures
          .map((json) => ProcedureDto.fromJson(jsonDecode(json)))
          .where((procedure) => procedure.exercise.id == exercise.id)
          .toList();
    } else {
      return [];
    }
  }

  List<SetDto> wherePastSets({required Exercise exercise}) {
    final procedures = _proceduresForExercise(exercise: exercise);
    return procedures.expand((procedure) => procedure.sets).where((set) => set.isNotEmpty()).toList();
  }

  List<SetDto> setDtosForMuscleGroupWhereDateRange(
      {required MuscleGroupFamily muscleGroupFamily, required DateTimeRange range}) {
    bool hasMatchingBodyPart(String procedureJson) {
      final procedure = ProcedureDto.fromJson(jsonDecode(procedureJson));
      final primaryMuscle = MuscleGroup.fromString(procedure.exercise.primaryMuscle);
      return primaryMuscle.family == muscleGroupFamily;
    }

    return logs
        .where((log) => log.procedures.any(hasMatchingBodyPart))
        .where((log) => log.createdAt.getDateTimeInUtc().isBetweenRange(range: range))
        .expand((log) => log.procedures.where(hasMatchingBodyPart))
        .map((json) => ProcedureDto.fromJson(jsonDecode(json)))
        .expand((procedure) => procedure.sets)
        .toList();
  }

  List<SetDto> whereSetDtosForMuscleGroupSince({required MuscleGroupFamily muscleGroupFamily, required int since}) {
    DateTime now = DateTime.now();
    DateTime then = now.subtract(Duration(days: since));
    final dateRange = DateTimeRange(start: then, end: now);

    bool hasMatchingBodyPart(String procedureJson) {
      final procedure = ProcedureDto.fromJson(jsonDecode(procedureJson));
      final primaryMuscle = MuscleGroup.fromString(procedure.exercise.primaryMuscle);
      return primaryMuscle.family == muscleGroupFamily;
    }

    return logs
        .where((log) => log.procedures.any(hasMatchingBodyPart))
        .where((log) => log.createdAt.getDateTimeInUtc().isBetweenRange(range: dateRange))
        .expand((log) => log.procedures.where(hasMatchingBodyPart))
        .map((json) => ProcedureDto.fromJson(jsonDecode(json)))
        .expand((procedure) => procedure.sets)
        .toList();
  }

  List<SetDto> whereSetDtosForMuscleGroup({required MuscleGroupFamily muscleGroupFamily}) {
    bool hasMatchingBodyPart(String procedureJson) {
      final procedure = ProcedureDto.fromJson(jsonDecode(procedureJson));
      final primaryMuscle = MuscleGroup.fromString(procedure.exercise.primaryMuscle);
      return primaryMuscle.family == muscleGroupFamily;
    }

    return logs
        .where((log) => log.procedures.any(hasMatchingBodyPart))
        .expand((log) => log.procedures.where(hasMatchingBodyPart))
        .map((json) => ProcedureDto.fromJson(jsonDecode(json)))
        .expand((procedure) => procedure.sets)
        .toList();
  }

  List<RoutineLog> routineLogsWhereDate({required DateTime dateTime}) {
    return _logs.where((log) => log.createdAt.getDateTimeInUtc().isSameDateAs(dateTime)).toList();
  }

  RoutineLog? routineLogWhereDate({required DateTime dateTime}) {
    return _logs.firstWhereOrNull((log) => log.createdAt.getDateTimeInUtc().isSameDateAs(dateTime));
  }

  List<RoutineLog> routineLogsWhereDateRange(DateTimeRange range, {List<RoutineLog>? logs}) {
    final values = logs ?? _logs;
    return values.where((log) => log.createdAt.getDateTimeInUtc().isBetweenRange(range: range)).toList();
  }

  List<RoutineLog> routineLogsSince(int days, {List<RoutineLog>? logs}) {
    final values = logs ?? _logs;
    DateTime now = DateTime.now();
    DateTime then = now.subtract(Duration(days: days));
    final dateRange = DateTimeRange(start: then, end: now);
    return values.where((log) => log.createdAt.getDateTimeInUtc().isBetweenRange(range: dateRange)).toList();
  }

  void reset() {
    _logs.clear();
    notifyListeners();
  }

  void onNotifyListeners() {
    notifyListeners();
  }
}
