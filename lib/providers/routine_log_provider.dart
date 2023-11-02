import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/models/BodyPart.dart';
import 'package:tracker_app/models/Routine.dart';
import 'package:tracker_app/shared_prefs.dart';
import 'package:tracker_app/utils/datetime_utils.dart';

import '../dtos/procedure_dto.dart';
import '../models/RoutineLog.dart';
import 'exercise_provider.dart';

class RoutineLogProvider with ChangeNotifier {
  List<RoutineLog> _logs = [];

  RoutineLog? _cachedLog;

  UnmodifiableListView<RoutineLog> get logs => UnmodifiableListView(_logs);

  RoutineLog? get cachedLog => _cachedLog;

  set cachedLog(RoutineLog? value) {
    _cachedLog = value;
    notifyListeners();
  }

  void notifyAllListeners() {
    if (_cachedLog != null) {
      notifyListeners();
    }
  }

  void clearCachedLog() {
    if (_cachedLog != null) {
      _cachedLog = null;
      SharedPrefs().cachedRoutineLog = "";
      notifyListeners();
    }
  }

  void listRoutineLogs(BuildContext context) async {
    _logs = await Amplify.DataStore.query(RoutineLog.classType,
        sortBy: [QuerySortBy(order: QuerySortOrder.descending, field: RoutineLog.CREATEDAT.fieldName)]);
    notifyListeners();
  }

  void retrieveCachedRoutineLog(BuildContext context) {
    final cache = SharedPrefs().cachedRoutineLog;
    if (cache.isNotEmpty) {
      final temp = jsonDecode(cache) as Map<String, dynamic>;
      temp.update("routine", (value) {
        return {"serializedData": value};
      });
      _cachedLog = RoutineLog.fromJson(temp);
    }
  }

  void saveRoutineLog(
      {required String name,
      required String notes,
      required List<ProcedureDto> procedures,
      required TemporalDateTime startTime,
      TemporalDateTime? createdAt,
      required Routine routine}) async {
    final proceduresJson = procedures.map((procedure) => procedure.toJson()).toList();

    final logToSave = RoutineLog(
        name: name,
        notes: notes,
        procedures: proceduresJson,
        startTime: startTime,
        endTime: TemporalDateTime.now(),
        createdAt: createdAt ?? TemporalDateTime.now(),
        updatedAt: TemporalDateTime.now(),
        routine: routine);

    /// [RoutineLog] requires and instance of [Routine]
    /// If [RoutineLog] is from a non-existing [Routine], persist new one
    if (routine.name.isEmpty) {
      await Amplify.DataStore.save<Routine>(routine);
    }
    await Amplify.DataStore.save<RoutineLog>(logToSave);
    _logs.add(logToSave);
    _logs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    clearCachedLog();
    notifyListeners();
  }

  void cacheRoutineLog(
      {required String name,
      required String notes,
      required List<ProcedureDto> procedures,
      required TemporalDateTime startTime,
      TemporalDateTime? createdAt,
      required Routine routine}) {
    _cachedLog = RoutineLog(
        id: "cache_log_${DateTime.now().millisecondsSinceEpoch.toString()}",
        name: name,
        notes: notes,
        routine: routine,
        procedures: procedures.map((procedure) => procedure.toJson()).toList(),
        startTime: startTime,
        endTime: TemporalDateTime.now(),
        createdAt: createdAt ?? TemporalDateTime.now(),
        updatedAt: TemporalDateTime.now());
    final cachedLogDto = _cachedLog;
    if (cachedLogDto != null) {
      SharedPrefs().cachedRoutineLog = jsonEncode(_cachedLog);
    }
  }

  void updateLog({required RoutineLog log}) async {
    await Amplify.DataStore.save<RoutineLog>(log);
    final index = _indexWhereRoutineLog(id: log.id);
    _logs[index] = log;
    notifyListeners();
  }

  void removeLog({required String id}) async {
    final index = _indexWhereRoutineLog(id: id);
    final logToBeRemoved = _logs.removeAt(index);
    await Amplify.DataStore.delete<RoutineLog>(logToBeRemoved);
    notifyListeners();
  }

  int _indexWhereRoutineLog({required String id}) {
    return _logs.indexWhere((log) => log.id == id);
  }

  RoutineLog whereRoutineLog({required String id}) {
    return _logs.firstWhere((log) => log.id == id);
  }

  List<ProcedureDto> whereProcedureDtos({required ProcedureDto procedureDto}) {
    // This list will hold all matching ProcedureDtos.
    List<ProcedureDto> matchedDtos = [];

    // Iterate through each log.
    for (var log in logs) {
      // Decode all procedures once instead of doing it multiple times.
      List<ProcedureDto> decodedProcedures =
          log.procedures.map((json) => ProcedureDto.fromJson(jsonDecode(json))).toList();

      // Use where to filter out procedures with different exerciseId.
      List<ProcedureDto> filteredProcedures =
          decodedProcedures.where((procedure) => procedure.exerciseId == procedureDto.exerciseId).toList();

      // If there are any matches, add them to the final list.
      if (filteredProcedures.isNotEmpty) {
        matchedDtos.addAll(filteredProcedures);
      }
    }

    return matchedDtos;
  }

  List<SetDto> whereSetDtos({required BodyPart bodyPart, required BuildContext context}) {
    final exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);

    bool hasMatchingBodyPart(String procedureJson) {
      final procedure = ProcedureDto.fromJson(jsonDecode(procedureJson));
      return exerciseProvider.whereExercise(exerciseId: procedure.exerciseId).bodyPart == bodyPart;
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
    return values.where((log) => log.createdAt.getDateTimeInUtc().isBetweenRange(range: range.endInclusive())).toList();
  }

  List<RoutineLog> routineLogsSince(int days, {List<RoutineLog>? logs}) {
    final values = logs ?? _logs;
    DateTime now = DateTime.now();
    DateTime then = now.subtract(Duration(days: days));
    final dateRange = DateTimeRange(start: then, end: now);
    return values
        .where((log) => log.createdAt.getDateTimeInUtc().isBetweenRange(range: dateRange.endInclusive()))
        .toList();
  }
}
