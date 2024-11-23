import '../exercise_log_dto.dart';

class ExerciseLogViewModel {
  final ExerciseLogDTO exerciseLog;
  final ExerciseLogDTO? superSet;

  ExerciseLogViewModel({required this.exerciseLog, required this.superSet});
}