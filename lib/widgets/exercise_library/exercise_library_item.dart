
import '../../dtos/exercise_dto.dart';

class ExerciseLibraryItem {

  bool? isSelected;
  final Exercise exercise;

  ExerciseLibraryItem({this.isSelected = false, required this.exercise});
}
