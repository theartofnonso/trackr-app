import 'dart:convert';

import 'package:tracker_app/dtos/set_dto.dart';

class DurationNumPair extends SetDto {
  final Duration value1;
  final num value2;
  final Duration cachedDuration;

  DurationNumPair({this.value1 = Duration.zero, this.value2 = 0, this.cachedDuration = Duration.zero, super.type, super.checked});

  @override
  DurationNumPair copyWith({Duration? value1, num? value2, Duration? cachedDuration, SetType? type, bool? checked}) {
    return DurationNumPair(
      value1: value1 ?? this.value1,
      value2: value2 ?? this.value2,
      cachedDuration: cachedDuration ?? this.cachedDuration,
      type: type ?? this.type,
      checked: checked ?? this.checked,
    );
  }

  @override
  String toJson() {
    return jsonEncode({"value1": value1.inMilliseconds, "value2": value2 ,"cachedDuration": cachedDuration.inMilliseconds, "type": type.label, "checked": checked});
  }

  factory DurationNumPair.fromJson(Map<String, dynamic> json) {
    final value1 = Duration(milliseconds: json["value1"]);
    final value2 = json["value2"];
    final cachedDuration = Duration(milliseconds:  json["cachedDuration"]);
    final type = SetType.fromString(json["type"]);
    final checked = json["checked"];
    return DurationNumPair(value1: value1, value2: value2, cachedDuration: cachedDuration, type: type, checked: checked);
  }

  @override
  String toString() {
    return 'SetDto{value1: $value1, value2: $value2, cachedDuration: $cachedDuration, type: $type, checked: $checked}';
  }
}
