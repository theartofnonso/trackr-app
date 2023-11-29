import 'dart:convert';

import 'package:flutter/material.dart';

enum SetType {
  warmUp("Warm Up", "WM", Colors.orange),
  working("Working", "WK", Colors.white),
  failure("Failure", "FL", Colors.red),
  drop("Drop", "DP", Colors.green);

  const SetType(this.name, this.label, this.color);

  final String name;
  final String label;
  final Color color;

  static SetType fromString(String string) {
    return SetType.values.firstWhere((value) => value.label == string);
  }
}

class SetDto {
  final String id;
  final int index;
  final num value1;
  final num value2;
  final SetType type;
  final bool checked;

   SetDto(this.index, this.value1, this.value2, this.type, this.checked) : id = "${type.label}$index";

  SetDto copyWith({int? index, num? value1, num? value2, SetType? type, bool? checked}) {
    return SetDto(index ?? this.index, value1 ?? this.value1, value2 ?? this.value2, type ?? this.type, checked ?? this.checked);
  }

  String toJson() {
    return jsonEncode({"index": index, "value1": value1, "value2": value2, "type": type.label, "checked": checked});
  }

  factory SetDto.fromJson(Map<String, dynamic> json) {
    final index = json["index"];
    final value1 = json["value1"];
    final value2 = json["value2"];
    final type = SetType.fromString(json["type"]);
    final checked = json["checked"];
    return SetDto(index, value1, value2, type, checked);
  }

  bool isEmpty() {
    return value1 + value2 == 0;
  }

  bool isNotEmpty() {
    return value1 + value2 > 0;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetDto &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          value1 == other.value1 &&
          value2 == other.value2 &&
          type == other.type &&
          checked == other.checked;

  @override
  int get hashCode => id.hashCode ^ value1.hashCode ^ value2.hashCode ^ type.hashCode ^ checked.hashCode;

  @override
  String toString() {
    return 'SetDto{index: $index, id: $id, value1: $value1, value2: $value2, type: $type, checked: $checked}';
  }
}
