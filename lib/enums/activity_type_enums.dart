class ActivityType {
  final String category;
  final String name;
  final String description;

  const ActivityType._(this.category, this.name, this.description);

  // Factory methods for different categories
  static const ActivityType football = ActivityType._("Team Sports", "Football / Soccer", "A team-based sport focused on ball control and strategy.");
  static const ActivityType basketball = ActivityType._("Team Sports", "Basketball", "A team sport where the objective is to shoot a ball through a hoop.");
  static const ActivityType boxing = ActivityType._("Combat Sports", "Boxing", "A combat sport involving striking with fists.");
  static const ActivityType running = ActivityType._("Endurance Sports", "Running", "A cardiovascular activity focusing on endurance and speed.");
  static const ActivityType swimming = ActivityType._("Water Sports", "Swimming", "An activity that engages the entire body in water.");

  // Add more activity types...

  // Method to get all activities by category
  static List<ActivityType> byCategory(String category) {
    return ActivityType.values.where((activity) => activity.category == category).toList();
  }

  // Method to return all available activities
  static List<ActivityType> get values => [
    football,
    basketball,
    boxing,
    running,
    swimming,
    // Add more as needed...
  ];

  // Optional method to create an ActivityType from a string
  static ActivityType fromString(String name) {
    return values.firstWhere((activity) => activity.name.toLowerCase() == name.toLowerCase());
  }
}