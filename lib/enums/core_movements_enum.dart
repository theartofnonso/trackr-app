enum CoreMovement {

  push("Push"), pull("Pull"), hinge("Hinge"), squat("Squat"), lunge("Lunge"), rotation("Rotation"), gait("Gait"), other("Other");

  const CoreMovement(this.name);

  final String name;

  static CoreMovement fromString(String string) {
    return CoreMovement.values.firstWhere((value) => value.name.toLowerCase() == string.toLowerCase());
  }

}