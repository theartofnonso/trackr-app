enum ExerciseEquipment {
  barbell("Barbell"),
  ezBar("EZ Bar"),
  dumbbell("Dumbbell"),
  band("Band"),
  rope("Rope"),
  trapBar("Trap-Bar"),
  vBarHandle("V-Bar"),
  tBarHandle("T-Bar"),
  straightBarHandle("Straight Bar"),
  plyoBox("Plyo Box"),
  parallelBars("Parallel Bars"),
  straightBar("Straight Bar"),
  kettleBell("Kettle Bell"),
  assistedMachine("Assisted Machine"),
  machine("Machine"),
  smithMachine("Smith Machine"),
  cableMachine("Cable Machine"),
  plate("Plate"),
  none("None"),;

  const ExerciseEquipment(this.name);

  final String name;

  static ExerciseEquipment fromString(String string) {
    return ExerciseEquipment.values.firstWhere((value) => value.name.toLowerCase() == string.toLowerCase());
  }
}
