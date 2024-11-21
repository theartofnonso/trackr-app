import 'package:tracker_app/dtos/abstract_class/exercise_dto.dart';

import 'exercise_configuration_key.dart';

enum ExerciseMovement implements ExerciseConfigValue {
  internalRotation(
      displayName: "Internal",
      description: "A movement pattern where the limb rotates towards the midline of the body."),
  externalRotation(
      displayName: "External",
      description: "A movement pattern where the limb rotates away from the midline of the body."),
  lateral(
      displayName: "Lateral",
      description:
          "Lateral movements work the sides of your body, engaging muscles like deltoids and obliques to improve balance and coordination."),
  front(
      displayName: "Front",
      description:
          "Front movements involve pushing or pulling weights directly in front of your body, targeting muscles like chest, shoulders, and arms."),
  reverse(
      displayName: "Reverse",
      description:
          "Reverse movements engage muscles on the back of your body, such as rear delts, traps, and lats, to improve posture and pulling strength."),
  highToLow(
      displayName: "High to low",
      description:
          "A movement pattern where the resistance starts above shoulder level and is brought downwards, targeting muscles with a downward force trajectory."),
  lowToHigh(
      displayName: "Low to high",
      description:
          "A movement pattern where the resistance starts below shoulder level and is lifted upwards, engaging muscles with an upward force trajectory.");

  const ExerciseMovement({required this.displayName, required this.description});

  @override
  final String displayName;

  @override
  final String description;

  static ExerciseMovement _fromString(String string) {
    return values.firstWhere((value) => value.name.toLowerCase() == string.toLowerCase());
  }

  static ExerciseMovement fromJson(Map<String, dynamic> json) {
    final name = json["name"];
    return ExerciseMovement._fromString(name);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "type": ExerciseConfigurationKey.movement.name,
      'name': name,
      'displayName': displayName,
      'description': description,
    };
  }
}
