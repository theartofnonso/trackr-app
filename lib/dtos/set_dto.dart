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
  final int reps;
  final double weight;
  final SetType type;
  final bool checked;

  SetDto({this.reps = 0, this.weight = 0, this.type = SetType.working, this.checked = false});

  SetDto copyWith({int? reps, double? weight, SetType? type, bool? checked}) {
    return SetDto(
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      type: type ?? this.type,
      checked: checked ?? this.checked,
    );
  }

  String toJson() {
    return jsonEncode({
      "reps" : reps,
      "weight" : weight,
      "type" : type.label,
      "checked" : checked
    });
  }

  factory SetDto.fromJson(Map<String, dynamic> json) {
    final reps = json["reps"];
    final weight = json["weight"];
    final typeLabel = json["type"];
    final type = SetType.values.firstWhere((type) => type.label == typeLabel);
    final checked = json["checked"];
    return SetDto(reps: reps, weight: weight, type: type, checked: checked);
  }

  @override
  String toString() {
    return 'SetDto{reps: $reps, weight: $weight}';
  }
}
