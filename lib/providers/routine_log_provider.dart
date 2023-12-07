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

import '../dtos/exercise_log_dto.dart';
import '../models/RoutineLog.dart';
import '../utils/general_utils.dart';

class RoutineLogProvider with ChangeNotifier {

  Map<String, List<ExerciseLogDto>> _exerciseLogs = {};

  List<RoutineLog> _logs = [];

  UnmodifiableMapView<String, List<ExerciseLogDto>> get exerciseLogs => UnmodifiableMapView(_exerciseLogs);

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

  void listRoutineLogs() async {
    final routineLogOwner = user();
    final request = ModelQueries.list(RoutineLog.classType, where: RoutineLog.USER.eq(routineLogOwner.id));
    final response = await Amplify.API.query(request: request).response;

    final routineLogs = response.data?.items;
    if (routineLogs != null) {
      _logs = routineLogs.whereType<RoutineLog>().toList();
      _logs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();
    }
    _loadExerciseLogs();
  }

  void _loadExerciseLogs() {

    Map<String, List<ExerciseLogDto>> map = {};

    for (RoutineLog log in _logs) {
      final decodedExerciseLogs = log.procedures.map((json) => ExerciseLogDto.fromJson(routineLog: log, json: jsonDecode(json))).toList();
      for (ExerciseLogDto exerciseLog in decodedExerciseLogs) {
        final exerciseId = exerciseLog.exercise.id;
        final exerciseLogs = map[exerciseId] ?? [];
        exerciseLogs.add(exerciseLog);
        exerciseLogs.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        map.putIfAbsent(exerciseId, () => exerciseLogs);
      }
    }

    _exerciseLogs = map;
  }

  RoutineLog? lastLog(String id) {
    return _logs.firstWhereOrNull((log) => log.routine?.id == id);
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

  Future<void> saveRoutineLog(
      {required BuildContext context,
      required String name,
      required String notes,
      required List<ExerciseLogDto> procedures,
      required TemporalDateTime startTime,
      TemporalDateTime? createdAt,
      required Routine? routine}) async {
    final proceduresJson = procedures.map((procedure) => procedure.toJson()).toList();

    final routineProcedures = procedures
        .map(
            (procedure) => procedure.copyWith(sets: procedure.sets.map((set) => set.copyWith(checked: false)).toList()))
        .map((procedure) => procedure.toJson())
        .toList();

    final logToCreate = RoutineLog(
        name: name,
        notes: notes,
        procedures: proceduresJson,
        startTime: startTime,
        endTime: TemporalDateTime.now(),
        createdAt: createdAt ?? TemporalDateTime.now(),
        updatedAt: TemporalDateTime.now(),
        routine: routine?.copyWith(procedures: routineProcedures, user: user()),
        user: user());

    try {
      final request = ModelMutations.create(logToCreate);
      final response = await Amplify.API.mutate(request: request).response;
      final createdLog = response.data;
      if (createdLog != null) {
        _addToLogs(createdLog);
        if(context.mounted) {
          final updatedRoutine = routine?.copyWith(procedures: routineProcedures);
          if(updatedRoutine != null) {
            Provider.of<RoutineProvider>(context, listen: false).updateRoutine(routine: updatedRoutine);
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
      }
    }
  }

  void cacheRoutineLog(
      {required String name,
      required String notes,
      required List<ExerciseLogDto> procedures,
      required TemporalDateTime startTime,
      TemporalDateTime? createdAt,
      required Routine? routine,
      bool shouldNotifyListeners = false}) {
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
    if (shouldNotifyListeners) {
      notifyListeners();
    }
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

  List<SetDto> wherePastSets({required Exercise exercise}) {
    final exerciseLogs = _exerciseLogs[exercise.id] ?? [];
    return exerciseLogs.reversed.expand((log) => log.sets).toList();
  }

  List<SetDto> setDtosForMuscleGroupWhereDateRange({required MuscleGroupFamily muscleGroupFamily, required DateTimeRange range}) {
    bool hasMatchingBodyPart(ExerciseLogDto exerciseLogDto) {
      final primaryMuscle = MuscleGroup.fromString(exerciseLogDto.exercise.primaryMuscle);
      return primaryMuscle.family == muscleGroupFamily;
    }

    // return _exerciseLogs
    //     .where((log) => logany(hasMatchingBodyPart))
    //     .where((log) => log.createdAt.getDateTimeInUtc().isBetweenRange(range: range))
    //     .expand((log) => log.procedures.where(hasMatchingBodyPart))
    //     .map((json) => ExerciseLogDto.fromJson(jsonDecode(json)))
    //     .expand((procedure) => procedure.sets)
    //     .toList();
    return [];
  }

  List<RoutineLog> logsWhereDate({required DateTime dateTime}) {
    return _logs.where((log) => log.createdAt.getDateTimeInUtc().isSameDateAs(dateTime)).toList();
  }

  RoutineLog? logWhereDate({required DateTime dateTime}) {
    return _logs.firstWhereOrNull((log) => log.createdAt.getDateTimeInUtc().isSameDateAs(dateTime));
  }

  List<ExerciseLogDto> logsWhereDateRange({required DateTimeRange range, required Exercise exercise}) {
    final values = _exerciseLogs[exercise.id] ?? [];
    return values.where((log) => log.createdAt.getDateTimeInUtc().isBetweenRange(range: range)).toList();
  }

  void reset() {
    _logs.clear();
    notifyListeners();
  }
}
