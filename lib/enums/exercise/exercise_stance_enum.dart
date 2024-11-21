import '../../dtos/exercises/exercise_dto.dart';
import 'exercise_configuration_key.dart';

enum ExerciseStance implements ExerciseConfig {
  seated(displayName: "Seated", description: "Perform exercises while seated, focusing on stability and controlled movement."),
  standing(displayName: "Standing", description: "Engage your core and balance with exercises done while standing upright."),
  kneeling(displayName: "Kneeling", description: "A stance where the body is supported on the knees."),
  bentOver(
      displayName: "Bent Over",
      description: "A position where the torso is leaned forward, typically at a 45-degree angle or parallel to the ground."
  ),
  hanging(displayName: "Hanging",
      description:  "A stance where the body is suspended from a fixed bar or support, engaging the upper body and core to maintain stability."),
  lying(displayName: "Lying", description: "Target muscles effectively with exercises performed while lying down.");

  @override
  final String displayName;

  @override
  final String description;

  const ExerciseStance({required this.displayName, required this.description});

  static ExerciseStance _fromString(String string) {
    return values.firstWhere((value) => value.name.toLowerCase() == string.toLowerCase());
  }

  static ExerciseStance fromJson(Map<String, dynamic> json) {
    final name = json["name"];
    return ExerciseStance._fromString(name);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "type": ExerciseConfigurationKey.stance,
      'name': name,
      'displayName': displayName,
      'description': description,
    };
  }
}
