import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/models/Routine.dart';
import 'package:tracker_app/shared_prefs.dart';

import '../dtos/procedure_dto.dart';
import '../models/RoutineLog.dart';

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
      _cachedLog = RoutineLog.fromJson(jsonDecode(cache));
    }
  }

  void saveRoutineLog(
      {required String name,
      required String notes,
      required List<ProcedureDto> procedures,
      required DateTime startTime,
      required Routine routine}) async {
    final proceduresJson = procedures.map((procedure) => procedure.toJson()).toList();

    final logToSave = RoutineLog(
        name: name,
        notes: notes,
        procedures: proceduresJson,
        startTime: TemporalDateTime.fromString("${startTime.toLocal().toIso8601String()}Z"),
        endTime: TemporalDateTime.fromString("${DateTime.now().toIso8601String()}Z"),
        createdAt: TemporalDateTime.now(),
        updatedAt: TemporalDateTime.now(),
        routine: routine);
    if (routine.name.isEmpty) {
      await Amplify.DataStore.save<Routine>(routine);
    }
    await Amplify.DataStore.save<RoutineLog>(logToSave);
    _logs.insert(0, logToSave);
    clearCachedLog();
    notifyListeners();
  }

  void cacheRoutineLog(
      {required String name,
      required String notes,
      required List<ProcedureDto> procedures,
      required DateTime startTime,
      required Routine routine}) {
    _cachedLog = RoutineLog(
        id: "cache_log_${DateTime.now().millisecondsSinceEpoch.toString()}",
        name: name,
        notes: notes,
        routine: routine,
        procedures: procedures.map((procedure) => procedure.toJson()).toList(),
        startTime: TemporalDateTime.fromString("${startTime.toLocal().toIso8601String()}Z"),
        endTime: TemporalDateTime.fromString("${DateTime.now().toIso8601String()}Z"),
        createdAt: TemporalDateTime.fromString("${DateTime.now().toIso8601String()}Z"),
        updatedAt: TemporalDateTime.fromString("${DateTime.now().toIso8601String()}Z"));
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

  RoutineLog? whereRoutineLog({required String id}) {
    return _logs.firstWhereOrNull((log) => log.id == id);
  }
}
