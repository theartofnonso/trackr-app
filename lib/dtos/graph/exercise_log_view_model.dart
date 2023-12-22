import '../exercise_log_dto.dart';

class ExerciseLogViewModel {
  final ExerciseLogDto exerciseLog;
  final ExerciseLogDto? superSet;

  ExerciseLogViewModel({required this.exerciseLog, required this.superSet});
}