import 'package:flutter/cupertino.dart';

enum ProcedureType {
  warmUp("Warm Up", "W", CupertinoColors.activeOrange),
  working("Working", "", CupertinoColors.activeBlue),
  failure("Failure", "F", CupertinoColors.systemRed),
  drop("Drop Set", "D", CupertinoColors.activeGreen);

  const ProcedureType(this.name, this.label, this.color);

  final String name;
  final String label;
  final CupertinoDynamicColor color;
}

class ProcedureDto {
  int repCount = 0;
  int weight = 0;
  ProcedureType type = ProcedureType.working;

  ProcedureDto();

  @override
  String toString() {
    return 'ProcedureDto{repCount: $repCount, weight: $weight}';
  }
}
