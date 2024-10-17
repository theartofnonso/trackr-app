enum TrainingPosition {

  shortened("Shortened"), lengthened("Lengthened"), none("None");

  const TrainingPosition(this.name);

  final String name;

  static TrainingPosition fromString(String string) {
    return TrainingPosition.values.firstWhere((value) => value.name == string);
  }

}