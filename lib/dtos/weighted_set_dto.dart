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
  final num first;
  final num second;

  WeightedSetDto({this.first = 0, this.second = 0, super.type, super.checked});

  @override
  WeightedSetDto copyWith({num? first, num? second, SetType? type, bool? checked}) {
    return WeightedSetDto(
      first: first ?? this.first,
      second: second ?? this.second,
      type: type ?? this.type,
      checked: checked ?? this.checked,
    );
  }

  @override
  String toJson() {
    return jsonEncode({"first": first, "second": second, "type": type.label, "checked": checked});
  }

  factory WeightedSetDto.fromJson(Map<String, dynamic> json) {
    final first = json["first"];
    final second = json["second"];
    final typeString = json["type"];
    final type = SetType.fromString(typeString);
    final checked = json["checked"];
    return WeightedSetDto(first: first, second: second, type: type, checked: checked);
  }

  @override
  String toString() {
    return 'SetDto{second: $first, second: $second, type: $type, checked: $checked}';
  }
}
