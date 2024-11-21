import 'package:tracker_app/dtos/abstract_class/exercise_dto.dart';

import 'exercise_configuration_key.dart';

enum ExerciseUpperBodyModality implements ExerciseConfigValue {
  unilateral(displayName: "Single Arm", description: "Perform exercises one side at a time."),
  bilateral(displayName: "Both Arms", description: "Engage both arms together.");

  const ExerciseUpperBodyModality({required this.displayName, required this.description});

  @override
  final String displayName;

  @override
  final String description;

  static ExerciseUpperBodyModality _fromString(String string) {
    return values.firstWhere((value) => value.name.toLowerCase() == string.toLowerCase());
  }

  static ExerciseUpperBodyModality fromJson(Map<String, dynamic> json) {
    final name = json["name"];
    return ExerciseUpperBodyModality._fromString(name);
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
