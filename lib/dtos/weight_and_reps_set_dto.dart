import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/utils/general_utils.dart';

class WeightAndRepsSetDTO extends SetDTO {
  final double _weight;
  final int _reps;

  const WeightAndRepsSetDTO({required double weight, required int reps, required super.checked})
      : _weight = weight,
        _reps = reps;

  double get weight => weightWithConversion(value: _weight);

  int get reps => _reps;

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
    return 'WeightAndRepsSetDTO{weight: $_weight, reps: $_reps, checked: ${super.checked}}';
  }
}
