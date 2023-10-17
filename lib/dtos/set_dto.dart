import 'package:flutter/cupertino.dart';

enum SetType {
  warmUp("Warm Up", "W", CupertinoColors.activeOrange),
  working("Working", "", CupertinoColors.activeBlue),
  failure("Failure", "F", CupertinoColors.systemRed),
  drop("Drop Set", "D", CupertinoColors.activeGreen);

  const SetType(this.name, this.label, this.color);

  final String name;
  final String label;
  final CupertinoDynamicColor color;
}

class SetDto {
  int rep = 0;
  int weight = 0;
  SetType type = SetType.working;
  bool checked = false;

  SetDto();

  @override
  String toString() {
    return 'SetDto{repCount: $rep, weight: $weight}';
  }
}
