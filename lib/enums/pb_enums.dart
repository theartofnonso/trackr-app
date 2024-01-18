enum PBType {
  weight("Weight", "Heaviest Weight Lifted"),
  volume("Volume", "Most Volume Lifted"),
  duration("Duration", "Longest Duration");

  const PBType(this.name, this.description);

  final String name;
  final String description;
}