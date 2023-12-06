import 'package:tracker_app/dtos/exercise_log_dto.dart';

extension ExerciseLogDtoExtension on ExerciseLogDto {

  ExerciseLogDto refreshSets() {
    return copyWith(sets: sets.map((set) => set.copyWith(checked: false)).toList());
  }
}