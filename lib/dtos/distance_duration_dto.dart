import 'dart:convert';

import 'package:tracker_app/dtos/set_dto.dart';

class DistanceDurationDto extends SetDto {
  final int distance;
  final Duration duration;

  DistanceDurationDto({this.distance = 0, this.duration = Duration.zero, type, checked}) : super(type: type, checked: checked);

  @override
  DistanceDurationDto copyWith({int? distance, Duration? duration, SetType? type, bool? checked}) {
    return DistanceDurationDto(
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      type: type ?? this.type,
      checked: checked ?? this.checked,
    );
  }

  @override
  String toJson() {
    return jsonEncode({"distance": distance, "duration": duration.inMilliseconds, "type": type.label, "checked": checked});
  }

  factory DistanceDurationDto.fromJson(Map<String, dynamic> json) {
    final distance = json["distance"];
    final durationInMilliseconds = json["duration"];
    final duration = Duration(milliseconds: durationInMilliseconds);
    final typeString = json["type"];
    final type = SetType.fromString(typeString);
    final checked = json["checked"];
    return DistanceDurationDto(distance: distance, duration: duration, type: type, checked: checked);
  }

  @override
  String toString() {
    return 'SetDto{distance: $distance, duration: $duration, type: $type, checked: $checked}';
  }
}
