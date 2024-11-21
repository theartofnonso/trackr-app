import 'package:tracker_app/enums/exercise/exercise_configuration_key.dart';

import '../../dtos/exercises/exercise_dto.dart';

enum ExerciseSeatingPosition implements ExerciseConfig {
  incline(displayName: "Incline", description: "Performed at an upward angle to target the upper portion of muscles."),
  decline(displayName: "Decline", description: "Performed at a downward angle to focus on the lower portion of muscles."),
  neutral(displayName: "Neutral", description: "Performed in a flat position for balanced muscle engagement.");

  const ExerciseSeatingPosition({required this.displayName, required this.description});

  @override
  final String displayName;

  @override
  final String description;

  static ExerciseSeatingPosition _fromString(String string) {
    return values.firstWhere((value) => value.name.toLowerCase() == string.toLowerCase());
  }

  static ExerciseSeatingPosition fromJson(Map<String, dynamic> json) {
    final name = json["name"];
    return ExerciseSeatingPosition._fromString(name);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "type": ExerciseConfigurationKey.seatingPosition.name,
      'name': name,
      'displayName': displayName,
      'description': description,
    };
  }
}
