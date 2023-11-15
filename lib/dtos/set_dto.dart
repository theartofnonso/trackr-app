
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

abstract class SetDto {
  final String id;
  final SetType type;
  final bool checked;

  SetDto({required this.id, this.type = SetType.working, this.checked = false});

  SetDto copyWith({SetType? type, bool? checked}) {
    throw UnimplementedError('copyWith must be implemented in subclasses');
  }

  String toJson() {
    throw UnimplementedError('toJson must be implemented in subclasses');
  }
}
