import 'package:tracker_app/dtos/abstract_class/exercise_dto.dart';

import 'exercise_configuration_key.dart';

enum ExerciseLowerBodyModality implements ExerciseConfigValue {
  unilateral(displayName: "Single Leg", description: "Perform exercises one side at a time."),
  bilateral(displayName: "Both Legs", description: "Engage both legs together.");

  const ExerciseLowerBodyModality({required this.displayName, required this.description});

  @override
  final String displayName;

  @override
  final String description;

  static ExerciseLowerBodyModality _fromString(String string) {
    return values.firstWhere((value) => value.name.toLowerCase() == string.toLowerCase());
  }

  static ExerciseLowerBodyModality fromJson(Map<String, dynamic> json) {
    final name = json["name"];
    return ExerciseLowerBodyModality._fromString(name);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "type": ExerciseConfigurationKey.lowerBodyModality.name,
      'name': name,
      'displayName': displayName,
      'description': description,
    };
  }
}
