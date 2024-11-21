import 'package:tracker_app/dtos/abstract_class/exercise_dto.dart';
import 'package:tracker_app/enums/exercise/exercise_configuration_key.dart';

enum ExerciseEquipment implements ExerciseConfigValue {
  barbell(displayName: "Barbell", description: "Classic for heavy lifts like squats, deadlifts, and bench press."),
  ezBar(displayName: "EZ Bar", description: "Perfect for curls and tricep extensions with a natural grip."),
  dumbbell(displayName: "Dumbbells", description: "Versatile weights for targeted strength training."),
  band(displayName: "Band", description: "Resistance bands for mobility, strength, and rehabilitation."),
  rope(displayName: "Rope", description: "Ideal for tricep pushdowns, cable exercises, or battle rope training."),
  trapBar(displayName: "Trap-Bar", description: "Great for deadlifts with a neutral grip to reduce strain."),
  vBarHandle(displayName: "V-Bar", description: "Used for close-grip rows or pull-downs on a cable machine."),
  tBarHandle(displayName: "T-Bar", description: "For powerful back-focused rows using a T-bar setup."),
  straightBarHandle(
      displayName: "Straight Bar", description: "For cable exercises like bicep curls or tricep pushdowns."),
  plyoBox(displayName: "Plyo Box", description: "Essential for box jumps, step-ups, or dynamic plyometric exercises."),
  parallelBars(displayName: "Parallel Bars", description: "Used for dips, L-sits, or bodyweight training."),
  straightBar(displayName: "Straight Bar", description: "Simple and effective for pull-ups or other bodyweight moves."),
  kettleBell(displayName: "Kettle Bell", description: "Dynamic weight for swings, snatches, and functional training."),
  assistedMachine(
      displayName: "Assisted Machine", description: "Provides support for exercises like pull-ups or dips."),
  machine(displayName: "Machine", description: "Targeted strength training with guided movements."),
  hackSquatMachine(displayName: "Hack Squat Machine", description: "Please provide a description here"),
  smithMachine(displayName: "Smith Machine", description: "Stabilized barbell for squats, presses, and safer lifts."),
  cableMachine(displayName: "Cable Machine", description: "Versatile for isolation and functional exercises"),
  plate(displayName: "Plate", description: "Add resistance to barbells or use for loaded carries."),
  none(displayName: "No Equipment", description: "No equipment needed—perfect for bodyweight exercises.");

  const ExerciseEquipment({required this.displayName, required this.description});

  @override
  final String displayName;

  @override
  final String description;

  static ExerciseEquipment _fromString(String string) {
    return values.firstWhere((value) => value.name.toLowerCase() == string.toLowerCase());
  }

  static ExerciseEquipment fromJson(Map<String, dynamic> json) {
    final name = json["name"];
    return ExerciseEquipment._fromString(name);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "type": ExerciseConfigurationKey.equipment.name,
      'name': name,
      'displayName': displayName,
      'description': description,
    };
  }
}
