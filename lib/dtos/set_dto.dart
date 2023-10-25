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
}

class SetDto {
  final int rep;
  final int weight;
  final SetType type;
  final bool checked;

  SetDto({this.rep = 0, this.weight = 0, this.type = SetType.working, this.checked = false});

  SetDto copyWith({int? rep, int? weight, SetType? type, bool? checked}) {
    return SetDto(
      rep: rep ?? this.rep,
      weight: weight ?? this.weight,
      type: type ?? this.type,
      checked: checked ?? this.checked,
    );
  }

  String toJson() {
    return jsonEncode({
      "rep" : rep,
      "weight" : weight,
      "type" : type.label,
      "checked" : checked
    });
  }

  factory SetDto.fromJson(Map<String, dynamic> json) {
    final rep = json["rep"];
    final weight = json["weight"];
    final typeLabel = json["type"];
    final type = SetType.values.firstWhere((type) => type.label == typeLabel);
    final checked = json["checked"];
    return SetDto(rep: rep, weight: weight, type: type, checked: checked);
  }

  @override
  String toString() {
    return 'SetDto{rep: $rep, weight: $weight}';
  }
}
