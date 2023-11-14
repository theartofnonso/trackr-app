import 'dart:convert';

import 'package:tracker_app/dtos/set_dto.dart';

/// Dto for the following Exercise Types:
/// [ExerciseType.weightAndReps]
/// [ExerciseType.weightedBodyWeight]
/// [ExerciseType.bodyWeightAndReps]
/// [ExerciseType.assistedBodyWeight]
/// [ExerciseType.weightAndDistance]
/// All the above weight [double] as a common value, hence why we group them in one class
class WeightedSetDto extends SetDto {
  /// The first value is always the weight
  final double weight;
  final num other;

  WeightedSetDto({this.weight = 0, this.other = 0, super.type, super.checked});

  @override
  WeightedSetDto copyWith({double? weight, num? other, SetType? type, bool? checked}) {
    return WeightedSetDto(
      weight: weight ?? this.weight,
      other: other ?? this.other,
      type: type ?? this.type,
      checked: checked ?? this.checked,
    );
  }

  @override
  String toJson() {
    return jsonEncode({"weight": weight, "other": other, "type": type.label, "checked": checked});
  }

  factory WeightedSetDto.fromJson(Map<String, dynamic> json) {
    final weight = json["weight"];
    final other = json["other"];
    final typeString = json["type"];
    final type = SetType.fromString(typeString);
    final checked = json["checked"];
    return WeightedSetDto(weight: weight, other: other, type: type, checked: checked);
  }

  @override
  String toString() {
    return 'SetDto{weight: $weight, other: $other, type: $type, checked: $checked}';
  }
}
