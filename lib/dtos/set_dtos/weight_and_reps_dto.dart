
import 'package:tracker_app/dtos/set_dtos/set_dto.dart';
import 'package:tracker_app/utils/general_utils.dart';

import '../../enums/exercise_type_enums.dart';


class WeightAndRepsSetDto extends SetDto {
  final double _weight;
  final int _reps;

  const WeightAndRepsSetDto({required double weight, required int reps, super.checked = false, super.rpeRating = 4, super.isWorkingSet})
      : _weight = weight,
        _reps = reps;

  double get weight => weightWithConversion(value: _weight);

  int get reps => _reps;

  @override
  ExerciseType get type => ExerciseType.weights;

  @override
  WeightAndRepsSetDto copyWith({double? weight, int? reps, bool? checked, int? rpeRating}) {
    return WeightAndRepsSetDto(weight: weight ?? _weight, reps: reps ?? _reps, checked: checked ?? super.checked, rpeRating: rpeRating ?? super.rpeRating);
  }

  @override
  bool isEmpty() {
    return _weight * _reps == 0;
  }

  @override
  bool isNotEmpty() {
    return _weight * _reps > 0;
  }

  double volume() {
    final convertedWeight = weightWithConversion(value: _weight);
    return (convertedWeight * _reps);
  }

  @override
  String summary() {
    return "$weight${weightLabel()} x $reps";
  }

  @override
  String toString() {
    return 'WeightAndRepsSetDTO{weight: $_weight, reps: $_reps, checked: ${super.checked}, type: $type}, rpeRating: ${super.rpeRating}';
  }
}