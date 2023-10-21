import 'dart:collection';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/cupertino.dart';

import '../dtos/procedure_dto.dart';
import '../dtos/routine_log_dto.dart';
import '../models/RoutineLog.dart';

class RoutineLogProvider with ChangeNotifier {
  final List<RoutineLogDto> _logs = [];

  RoutineLogDto? _cacheLogDto;

  UnmodifiableListView<RoutineLogDto> get logs => UnmodifiableListView(_logs);

  RoutineLogDto? get cacheLogDto => _cacheLogDto;

  set cacheLogDto(RoutineLogDto? value) {
    _cacheLogDto = value;
    notifyListeners();
  }

  void notifyAllListeners() {
    notifyListeners();
  }

  void listRoutineLogs(BuildContext context) async {
    final logs = await Amplify.DataStore.query(RoutineLog.classType);
    final routineLogDtos = logs.map((log) => log.toRoutineLogDto(context)).toList();
    _logs.addAll(routineLogDtos);
    notifyListeners();
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
        createdAt: TemporalDateTime.fromString("${startTime.toIso8601String()}Z"),
        updatedAt: TemporalDateTime.now());
    await Amplify.DataStore.save<RoutineLog>(logToSave);
    if (context.mounted) {
      _logs.add(logToSave.toRoutineLogDto(context));
    }
    _cacheLogDto ??= null;
    notifyListeners();
  }

  void cacheRoutine(
      {required String name,
      required String notes,
      required List<ProcedureDto> procedures,
      required DateTime startTime}) {
    _cacheLogDto = RoutineLogDto(
        id: "cache_log_${DateTime.now().millisecondsSinceEpoch.toString()}",
        name: name,
        notes: notes,
        procedures: procedures,
        startTime: startTime,
        endTime: DateTime.now(),
        createdAt: startTime,
        updatedAt: DateTime.now());
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
    return _logs.indexWhere((routine) => routine.id == id);
  }
}
