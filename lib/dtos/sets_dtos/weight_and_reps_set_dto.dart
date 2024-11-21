import 'package:tracker_app/dtos/sets_dtos/set_dto.dart';
import 'package:tracker_app/utils/general_utils.dart';

import '../../enums/exercise/set_type_enums.dart';

class WeightAndRepsSetDTO extends SetDTO {
  final double _weight;
  final int _reps;

  const WeightAndRepsSetDTO({required double weight, required int reps, required super.checked})
      : _weight = weight,
        _reps = reps;

  double get weight => weightWithConversion(value: _weight);

  int get reps => _reps;

  @override
  SetType get type => SetType.weightsAndReps;

  @override
  WeightAndRepsSetDTO copyWith({double? weight, int? reps, bool? checked}) {
    return WeightAndRepsSetDTO(weight: weight ?? _weight, reps: reps ?? _reps, checked: checked ?? super.checked);
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
    return 'WeightAndRepsSetDTO{weight: $_weight, reps: $_reps, checked: ${super.checked}, type: $type}';
  }
}
