import 'dart:collection';

import 'package:flutter/cupertino.dart';
import '../dtos/procedure_dto.dart';
import '../dtos/routine_dto.dart';

class RoutineProvider with ChangeNotifier {

  final List<RoutineDto> _routines = [];

  UnmodifiableListView<RoutineDto> get routines => UnmodifiableListView(_routines);

  void createRoutine({required String name, required String notes, required List<ProcedureDto> exercises}) {
    final routine = RoutineDto(id: "id_${DateTime.now().millisecondsSinceEpoch}",name: name, notes: notes, procedures: [...exercises]);
    _routines.add(routine);
    notifyListeners();
  }

  void updateRoutine({required String id, required String name, required String notes, required List<ProcedureDto> exercises}) {
    final index = _indexWhereRoutine(id: id);
    _routines[index] = RoutineDto(id: id, name: name, notes: notes, procedures: [...exercises]);
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
}


