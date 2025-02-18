
import 'package:tracker_app/dtos/set_dtos/set_dto.dart';

import '../../enums/exercise_type_enums.dart';

class RepsSetDto extends SetDto {
  final int _reps;

  const RepsSetDto({required reps, super.checked = false, super.rpeRating = 4, super.isWorkingSet})
      : _reps = reps;

  int get reps => _reps;

  @override
  ExerciseType get type => ExerciseType.bodyWeight;

  @override
  RepsSetDto copyWith({int? reps, bool? checked, int? rpeRating}) {
    return RepsSetDto(reps: reps ?? _reps, checked: checked ?? super.checked, rpeRating: rpeRating ?? super.rpeRating);
  }

  @override
  bool isEmpty() {
    return _reps == 0;
  }

  @override
  bool isNotEmpty() {
    return _reps > 0;
  }

  @override
  String summary() {
    return "x$reps";
  }

  @override
  String toString() {
    return 'RepsSetDTO{reps: $_reps, checked: ${super.checked}, type: $type, rpeRating: ${super.rpeRating}';
  }
}