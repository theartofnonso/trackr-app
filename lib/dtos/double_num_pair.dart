import 'dart:convert';

import 'package:tracker_app/dtos/set_dto.dart';

/// Dto for the following Exercise Types:
/// [ExerciseType.weightAndReps]
/// [ExerciseType.weightedBodyWeight]
/// [ExerciseType.bodyWeightAndReps]
/// [ExerciseType.assistedBodyWeight]
/// [ExerciseType.weightAndDistance]
/// All the above weight [double] as a common value, hence why we group them in one class
class DoubleNumPair extends SetDto {
  /// The first value is always the weight
  final double value1;
  final num value2;

  DoubleNumPair({this.value1 = 0, this.value2 = 0, super.type, super.checked});

  @override
  DoubleNumPair copyWith({double? value1, num? value2, SetType? type, bool? checked}) {
    return DoubleNumPair(
      value1: value1 ?? this.value1,
      value2: value2 ?? this.value2,
      type: type ?? this.type,
      checked: checked ?? this.checked,
    );
  }

  @override
  String toJson() {
    return jsonEncode({"value1": value1, "value2": value2, "type": type.label, "checked": checked});
  }

  factory DoubleNumPair.fromJson(Map<String, dynamic> json) {
    final value1 = json["value1"];
    final value2 = json["value2"];
    final type = SetType.fromString(json["type"]);
    final checked = json["checked"];
    return DoubleNumPair(value1: value1, value2: value2, type: type, checked: checked);
  }

  @override
  String toString() {
    return 'SetDto{value1: $value1, value2: $value2, type: $type, checked: $checked}';
  }
}
