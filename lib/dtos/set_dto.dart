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

  @override
  String toString() {
    return 'SetDto{rep: $rep, weight: $weight}';
  }
}
