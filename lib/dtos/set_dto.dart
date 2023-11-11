
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
  final SetType type;
  final bool checked;

  SetDto({this.type = SetType.working, this.checked = false});

  @override
  String toString() {
    return 'SetDto{type: $type, checked: $checked}';
  }

  SetDto copyWith({SetType? type, bool? checked}) {
    return SetDto(
      type: type ?? this.type,
      checked: checked ?? this.checked,
    );
  }

  String toJson() {
    return jsonEncode({"type": type.label, "checked": checked});
  }
}
