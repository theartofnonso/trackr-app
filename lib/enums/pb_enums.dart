enum PBType {
  weight("Weight", "Heaviest Weight Lifted"),
  volume("Volume", "Most Volume Lifted"),
  duration("Duration", "Longest Duration"),
  reps("reps", "Most reps");

  const PBType(this.name, this.description);

  final String name;
  final String description;
}