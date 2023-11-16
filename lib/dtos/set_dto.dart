import 'dart:convert';

import 'package:flutter/material.dart';

enum SetType {
  warmUp("Warm Up", "W", Colors.orange),
  working("Working", "WK", Colors.white),
  failure("Failure", "F", Colors.red),
  drop("Drop Set", "D", Colors.green);

  const SetType(this.name, this.label, this.color);

  final String name;
  final String label;
  final Color color;

  static SetType fromString(String string) {
    return SetType.values.firstWhere((value) => value.label == string);
  }
}

class SetDto {
  /// The first value is always the weight
  final num value1;
  final num value2;
  final SetType type;
  final bool checked;

  SetDto(this.value1, this.value2, this.type, this.checked);

  SetDto copyWith({num? value1, num? value2, SetType? type, bool? checked}) {
    return SetDto(value1 ?? this.value1, value2 ?? this.value2, type ?? this.type, checked ?? this.checked);
  }

  String toJson() {
    return jsonEncode({"value1": value1, "value2": value2, "type": type.label, "checked": checked});
  }

  factory SetDto.fromJson(Map<String, dynamic> json) {
    final value1 = json["value1"];
    final value2 = json["value2"];
    final type = SetType.fromString(json["type"]);
    final checked = json["checked"];
    return SetDto(value1, value2, type, checked);
  }

  @override
  String toString() {
    return 'SetDto{value1: $value1, value2: $value2, type: $type, checked: $checked}';
  }
}
