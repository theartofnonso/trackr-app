import 'dart:convert';

import 'package:tracker_app/dtos/set_dto.dart';

class WeightRepsDto extends SetDto {
  final int reps;
  final double weight;

  WeightRepsDto({this.reps = 0, this.weight = 0, type, checked}) : super(type: type, checked: checked);

  @override
  WeightRepsDto copyWith({int? reps, double? weight, SetType? type, bool? checked}) {
    return WeightRepsDto(
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      type: type ?? this.type,
      checked: checked ?? this.checked,
    );
  }

  @override
  String toJson() {
    return jsonEncode({"reps": reps, "weight": weight, "type": type.label, "checked": checked});
  }

  factory WeightRepsDto.fromJson(Map<String, dynamic> json) {
    final reps = json["reps"];
    final weight = json["weight"];
    final typeString = json["type"];
    final type = SetType.fromString(typeString);
    final checked = json["checked"];
    return WeightRepsDto(reps: reps, weight: weight, type: type, checked: checked);
  }

  @override
  String toString() {
    return 'SetDto{reps: $reps, weight: $weight, type: $type, checked: $checked}';
  }
}
