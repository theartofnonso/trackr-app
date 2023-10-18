import 'dart:collection';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:tracker_app/models/Routine.dart';
import '../dtos/procedure_dto.dart';

class RoutineProvider with ChangeNotifier {
  final List<Routine> _routines = [];

  UnmodifiableListView<Routine> get routines => UnmodifiableListView(_routines);

  RoutineProvider() {
    _listRoutines();
  }

  void _listRoutines() async {
    final routines = await Amplify.DataStore.query(Routine.classType);
    _routines.addAll(routines);
    notifyListeners();
  }

  void saveRoutine({required String name, required String notes, required List<ProcedureDto> procedures}) async {
    final proceduresJson = procedures.map((procedure) => procedure.toJson()).toList();
    final routineToSave = Routine(name: name, procedures: proceduresJson, notes: notes);
    await Amplify.DataStore.save<Routine>(routineToSave);
    _routines.add(routineToSave);
    notifyListeners();
  }

  void updateRoutine(
      {required String id, required String name, required String notes, required List<ProcedureDto> exercises}) {
    final index = _indexWhereRoutine(id: id);
    //_routines[index] = RoutineDto(id: id, name: name, notes: notes, procedures: [...exercises]);
    notifyListeners();
  }

  void removeRoutine({required String id}) {
    final index = _indexWhereRoutine(id: id);
    _routines.removeAt(index);
    notifyListeners();
  }

  int _indexWhereRoutine({required String id}) {
    return _routines.indexWhere((routine) => routine.id == id);
  }

  Routine whereRoutine({required String id}) {
    return _routines.firstWhere((routine) => routine.id == id);
  }
}
