import 'dart:convert';

import 'package:tracker_app/dtos/set_dto.dart';

class WeightDistanceDto extends SetDto {
  final double weight;
  final int distance;

  WeightDistanceDto({this.weight = 0, this.distance = 0, super.type, super.checked});

  @override
  WeightDistanceDto copyWith({double? weight, int? distance, SetType? type, bool? checked}) {
    return WeightDistanceDto(
      weight: weight ?? this.weight,
      distance: distance ?? this.distance,
      type: type ?? this.type,
      checked: checked ?? this.checked,
    );
  }

  @override
  String toJson() {
    return jsonEncode({"weight": weight, "distance": distance, "type": type.label, "checked": checked});
  }

  factory WeightDistanceDto.fromJson(Map<String, dynamic> json) {
    final weight = json["weight"];
    final distance = json["distance"];
    final typeString = json["type"];
    final type = SetType.fromString(typeString);
    final checked = json["checked"];
    return WeightDistanceDto(weight: weight, distance: distance, type: type, checked: checked);
  }

  @override
  String toString() {
    return 'SetDto{weight: $weight, distance: $distance, type: $type, checked: $checked}';
  }
}
