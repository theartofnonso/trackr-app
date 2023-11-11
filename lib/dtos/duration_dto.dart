import 'dart:convert';

import 'package:tracker_app/dtos/set_dto.dart';

class DurationDto extends SetDto {
  final Duration duration;

  DurationDto({this.duration = Duration.zero, super.type, super.checked});

  @override
  DurationDto copyWith({Duration? duration, SetType? type, bool? checked}) {
    return DurationDto(
      duration: duration ?? this.duration,
      type: type ?? this.type,
      checked: checked ?? this.checked,
    );
  }

  @override
  String toJson() {
    return jsonEncode({"duration": duration.inMilliseconds, "type": type.label, "checked": checked});
  }

  factory DurationDto.fromJson(Map<String, dynamic> json) {
    final durationInMilliseconds = json["duration"];
    final duration = Duration(milliseconds: durationInMilliseconds);
    final typeString = json["type"];
    final type = SetType.fromString(typeString);
    final checked = json["checked"];
    return DurationDto(duration: duration, type: type, checked: checked);
  }

  @override
  String toString() {
    return 'SetDto{duration: $duration, type: $type, checked: $checked}';
  }
}
