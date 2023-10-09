enum BodyPart {
  chest("Chest"),
  shoulders("Shoulders"),
  back("Back"),
  biceps("Biceps"),
  triceps("Triceps"),
  forearms("Forearms"),
  abs("Abs"),
  legs("Legs"),
  glutes("Glutes"),
  calves("Calves");

  final String label;

  const BodyPart(this.label);
}

class ExerciseDto {
  final String name;
  final BodyPart bodyPart;

  ExerciseDto(this.name, this.bodyPart);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseDto &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          bodyPart == other.bodyPart;

  @override
  int get hashCode => name.hashCode ^ bodyPart.hashCode;

  @override
  String toString() {
    return 'ExerciseDto{name: $name, bodyPart: $bodyPart}';
  }
}
