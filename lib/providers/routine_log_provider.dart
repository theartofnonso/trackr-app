import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:tracker_app/shared_prefs.dart';

import '../dtos/procedure_dto.dart';
import '../dtos/routine_log_dto.dart';
import '../models/RoutineLog.dart';

class RoutineLogProvider with ChangeNotifier {
  final List<RoutineLogDto> _logs = [];

  RoutineLogDto? _cachedLogDto;

  UnmodifiableListView<RoutineLogDto> get logs => UnmodifiableListView(_logs);

  RoutineLogDto? get cachedLogDto => _cachedLogDto;

  set cachedLogDto(RoutineLogDto? value) {
    _cachedLogDto = value;
    notifyListeners();
  }

  void notifyAllListeners() {
    if(_cachedLogDto != null) {
      notifyListeners();
    }
  }

  void listRoutineLogs(BuildContext context) async {
    final logs = await Amplify.DataStore.query(RoutineLog.classType,
        sortBy: [QuerySortBy(order: QuerySortOrder.descending, field: RoutineLog.CREATEDAT.fieldName)]);
    final routineLogDtos = logs.map((log) => log.toRoutineLogDto(context)).toList();
    _logs.clear();
    _logs.addAll(routineLogDtos);
    notifyListeners();
  }

  void retrieveCachedRoutineLog(BuildContext context) {
    final cache = SharedPrefs().cachedRoutineLog;
    if(cache.isNotEmpty) {
      _cachedLogDto = RoutineLogDto.fromJson(jsonDecode(cache), context);
    }
  }

  void logRoutine(
      {required BuildContext context,
      required String name,
      required String notes,
      required List<ProcedureDto> procedures,
      required DateTime startTime}) async {
    final proceduresJson = procedures.map((procedure) => procedure.toJson()).toList();

    final logToSave = RoutineLog(
        name: name,
        notes: notes,
        procedures: proceduresJson,
        startTime: TemporalDateTime.fromString("${startTime.toIso8601String()}Z"),
        endTime: TemporalDateTime.fromString("${DateTime.now().toIso8601String()}Z"),
        createdAt: TemporalDateTime.now(),
        updatedAt: TemporalDateTime.now());
    await Amplify.DataStore.save<RoutineLog>(logToSave);
    if (context.mounted) {
      _logs.insert(0, logToSave.toRoutineLogDto(context));
    }
    if (_cachedLogDto != null) {
      _cachedLogDto = null;
      SharedPrefs().cachedRoutineLog = "";
    }
    notifyListeners();
  }

  void cacheRoutine(
      {required String name,
      required String notes,
      required List<ProcedureDto> procedures,
      required DateTime startTime}) {
    _cachedLogDto = RoutineLogDto(
        id: "cache_log_${DateTime.now().millisecondsSinceEpoch.toString()}",
        name: name,
        notes: notes,
        procedures: procedures,
        startTime: startTime,
        endTime: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now());
    final cachedLogDto = _cachedLogDto;
    if(cachedLogDto != null) {
      SharedPrefs().cachedRoutineLog = cachedLogDto.toJson();
    }
  }

  void updateLog({required RoutineLogDto dto}) async {
    final routineLog = dto.toRoutineLog();
    await Amplify.DataStore.save<RoutineLog>(routineLog);
    final index = _indexWhereRoutineLog(id: dto.id);
    _logs[index] = dto;
    notifyListeners();
  }

  void removeLog({required String id}) async {
    final index = _indexWhereRoutineLog(id: id);
    final logToBeRemoved = _logs.removeAt(index);
    await Amplify.DataStore.delete<RoutineLog>(logToBeRemoved.toRoutineLog());
    notifyListeners();
  }

  int _indexWhereRoutineLog({required String id}) {
    return _logs.indexWhere((log) => log.id == id);
  }

  RoutineLogDto? whereRoutineLog({required String id}) {
    return _logs.firstWhereOrNull((log) => log.id == id);
  }
}
