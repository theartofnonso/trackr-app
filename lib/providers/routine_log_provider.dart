import 'dart:collection';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/cupertino.dart';

import '../models/RoutineLog.dart';

class RoutineLogProvider with ChangeNotifier {
  final List<RoutineLog> _logs = [];

  UnmodifiableListView<RoutineLog> get logs => UnmodifiableListView(_logs);

  RoutineLogProvider() {
    _listRoutinesLogs();
  }

  void _listRoutinesLogs() async {
    final logs = await Amplify.DataStore.query(RoutineLog.classType);
    _logs.addAll(logs);
    notifyListeners();
  }

  void logRoutine({required String routineId, required DateTime startTime}) {
    final log = RoutineLog(routineId: routineId, startTime: TemporalDateTime.fromString(startTime.toIso8601String()), endTime: TemporalDateTime.now());
    _logs.add(log);
    notifyListeners();
  }

  // void updateRoutine({required String id, required String name, required String notes, required List<ProcedureDto> exercises}) {
  //   final index = _indexWhereRoutine(id: id);
  //   _logs[index] = RoutineDto(id: id, name: name, notes: notes, procedures: [...exercises]);
  //   notifyListeners();
  // }
  //
  // void removeRoutine({required String id}) {
  //   final index = _indexWhereRoutine(id: id);
  //   _logs.removeAt(index);
  //   notifyListeners();
  // }
  //
  // int _indexWhereRoutine({required String id}) {
  //   return _logs.indexWhere((routine) => routine.id == id);
  // }
}