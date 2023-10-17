import 'dart:collection';

import 'package:flutter/cupertino.dart';
import '../dtos/procedure_dto.dart';
import '../dtos/routine_dto.dart';

class WorkoutProvider with ChangeNotifier {

  final List<RoutineDto> _workouts = [];

  UnmodifiableListView<RoutineDto> get workouts => UnmodifiableListView(_workouts);

  void createWorkout({required String name, required String notes, required List<ProcedureDto> exercises}) {
    final workout = RoutineDto(id: "id_${DateTime.now().millisecondsSinceEpoch}",name: name, notes: notes, procedures: [...exercises]);
    _workouts.add(workout);
    notifyListeners();
  }

  void updateWorkout({required String id, required String name, required String notes, required List<ProcedureDto> exercises}) {
    final index = _indexWhereWorkout(id: id);
    _workouts[index] = RoutineDto(id: id, name: name, notes: notes, procedures: [...exercises]);
    notifyListeners();
  }

  void removeWorkout({required String id}) {
    final index = _indexWhereWorkout(id: id);
    _workouts.removeAt(index);
    notifyListeners();
  }

  int _indexWhereWorkout({required String id}) {
    return _workouts.indexWhere((workout) => workout.id == id);
  }
}


