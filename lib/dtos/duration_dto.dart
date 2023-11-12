import 'dart:convert';

import 'package:tracker_app/dtos/set_dto.dart';

class DurationDto extends SetDto {
  final Duration duration;
  final Duration cachedDuration;

  DurationDto({this.duration = Duration.zero, this.cachedDuration = Duration.zero, super.type, super.checked});

  @override
  DurationDto copyWith({Duration? duration, Duration? cachedDuration, SetType? type, bool? checked}) {
    return DurationDto(
      duration: duration ?? this.duration,
      cachedDuration: cachedDuration ?? this.cachedDuration,
      type: type ?? this.type,
      checked: checked ?? this.checked,
    );
  }

  @override
  String toJson() {
    return jsonEncode({"duration": duration.inMilliseconds, "cachedDuration": cachedDuration.inMilliseconds, "type": type.label, "checked": checked});
  }

  factory DurationDto.fromJson(Map<String, dynamic> json) {
    final durationInMilliseconds = json["duration"];
    final cachedDurationInMilliseconds = json["cachedDuration"];
    final duration = Duration(milliseconds: durationInMilliseconds);
    final cachedDuration = Duration(milliseconds: cachedDurationInMilliseconds);
    final typeString = json["type"];
    final type = SetType.fromString(typeString);
    final checked = json["checked"];
    return DurationDto(duration: duration, cachedDuration: cachedDuration, type: type, checked: checked);
  }

  @override
  String toString() {
    return 'SetDto{duration: $duration, cachedDuration: $cachedDuration, type: $type, checked: $checked}';
  }
}
