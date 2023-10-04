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

class Exercise {
  final String name;
  final BodyPart bodyPart;

  Exercise(this.name, this.bodyPart);


}
