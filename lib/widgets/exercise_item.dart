
import '../dtos/exercise_dto.dart';

class ExerciseItem {

  bool? isSelected;
  final Exercise exercise;

  ExerciseItem({this.isSelected = false, required this.exercise});
}
