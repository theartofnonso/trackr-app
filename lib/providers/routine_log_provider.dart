import 'dart:collection';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/cupertino.dart';

import '../dtos/procedure_dto.dart';
import '../dtos/routine_log_dto.dart';
import '../models/RoutineLog.dart';

class RoutineLogProvider with ChangeNotifier {
  final List<RoutineLogDto> _logs = [];

  UnmodifiableListView<RoutineLogDto> get logs => UnmodifiableListView(_logs);

  void listRoutineLogs(BuildContext context) async {
    final logs = await Amplify.DataStore.query(RoutineLog.classType);
    final routineLogDtos = logs.map((log) => log.toRoutineLogDto(context)).toList();
    _logs.addAll(routineLogDtos);
    notifyListeners();
  }

  void logRoutine({required BuildContext context, required String name, required String notes, required List<ProcedureDto> procedures, required TemporalDateTime startTime}) async {
    final proceduresJson = procedures.map((procedure) => procedure.toJson()).toList();
    final logToSave = RoutineLog(name: name, notes: notes, procedures: proceduresJson, startTime: startTime, endTime: TemporalDateTime.now(), createdAt: TemporalDateTime.now(), updatedAt: TemporalDateTime.now());
    await Amplify.DataStore.save<RoutineLog>(logToSave);
    if(context.mounted) {
      _logs.add(logToSave.toRoutineLogDto(context));
    }
    notifyListeners();
  }

  void updateLog({required RoutineLogDto dto}) async{
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