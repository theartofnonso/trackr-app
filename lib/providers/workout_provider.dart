import 'dart:collection';

import 'package:flutter/cupertino.dart';
import '../dtos/exercise_in_workout_dto.dart';
import '../dtos/workout_dto.dart';

class WorkoutProvider with ChangeNotifier {

  final List<WorkoutDto> _workouts = [];

  UnmodifiableListView<WorkoutDto> get workouts => UnmodifiableListView(_workouts);

  void createWorkout({required String name, required String notes, required List<ExerciseInWorkoutDto> exercises}) {
    final workout = WorkoutDto(id: "id_${DateTime.now().millisecondsSinceEpoch}",name: name, notes: notes, exercises: [...exercises]);
    _workouts.add(workout);
    notifyListeners();
  }

  void updateWorkout({required String id, required String name, required String notes, required List<ExerciseInWorkoutDto> exercises}) {
    final index = _indexWhereWorkout(id: id);
    _workouts[index] = WorkoutDto(id: id, name: name, notes: notes, exercises: [...exercises]);
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


