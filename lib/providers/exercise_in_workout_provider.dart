import 'package:flutter/cupertino.dart';
import '../dtos/exercise_in_workout_dto.dart';
import '../dtos/workout_dto.dart';

class ExerciseInWorkoutProvider with ChangeNotifier {

  final List<WorkoutDto> _workouts = [];

  List<WorkoutDto> get workouts => _workouts;

  void createWorkout({required String name, required String notes, required List<ExerciseInWorkoutDto> exercises}) {
    final workout = WorkoutDto(name: name, notes: notes, exercises: [...exercises]);
    _workouts.add(workout);
    notifyListeners();
  }

  void updateWorkout({required String id,required String name, required String notes, required List<ExerciseInWorkoutDto> exercises}) {
    final index = _workouts.indexWhere((workout) => workout.id == id);
    _workouts[index] = WorkoutDto(name: name, notes: notes, exercises: [...exercises]);
    notifyListeners();
  }

}


