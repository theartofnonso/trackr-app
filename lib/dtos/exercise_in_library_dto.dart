
import 'exercise_dto.dart';

class ExerciseInLibraryDto {

  bool? isSelected;
  final ExerciseDto exercise;

  ExerciseInLibraryDto({this.isSelected = false, required this.exercise});
}
