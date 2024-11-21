import 'package:tracker_app/dtos/exercise_dto.dart';

enum ExerciseEquipment implements ExerciseConfig {
  barbell(name: "Barbell", description: "Classic for heavy lifts like squats, deadlifts, and bench press."),
  ezBar(name: "EZ Bar", description: "Perfect for curls and tricep extensions with a natural grip."),
  dumbbell(name: "Dumbbells", description: "Versatile weights for targeted strength training."),
  band(name: "Band", description: "Resistance bands for mobility, strength, and rehabilitation."),
  rope(name: "Rope", description: "Ideal for tricep pushdowns, cable exercises, or battle rope training."),
  trapBar(name: "Trap-Bar", description: "Great for deadlifts with a neutral grip to reduce strain."),
  vBarHandle(name: "V-Bar", description: "Used for close-grip rows or pull-downs on a cable machine."),
  tBarHandle(name: "T-Bar", description: "For powerful back-focused rows using a T-bar setup."),
  straightBarHandle(name: "Straight Bar", description: "For cable exercises like bicep curls or tricep pushdowns."),
  plyoBox(name: "Plyo Box", description: "Essential for box jumps, step-ups, or dynamic plyometric exercises."),
  parallelBars(name: "Parallel Bars", description: "Used for dips, L-sits, or bodyweight training."),
  straightBar(name: "Straight Bar", description: "Simple and effective for pull-ups or other bodyweight moves."),
  kettleBell(name: "Kettle Bell", description: "Dynamic weight for swings, snatches, and functional training."),
  assistedMachine(name: "Assisted Machine", description: "Provides support for exercises like pull-ups or dips."),
  machine(name: "Machine", description: "Targeted strength training with guided movements."),
  hackSquatMachine(name: "Hack Squat Machine", description: "Please provide a description here"),
  smithMachine(name: "Smith Machine", description: "Stabilized barbell for squats, presses, and safer lifts."),
  cableMachine(name: "Cable Machine", description: "Versatile for isolation and functional exercises"),
  plate(name: "Plate", description: "Add resistance to barbells or use for loaded carries."),
  none(name: "No Equipment", description: "No equipment needed—perfect for bodyweight exercises.");

  const ExerciseEquipment({required this.name, required this.description});

  @override
  final String name;

  @override
  final String description;

  static ExerciseEquipment fromString(String string) {
    return values.firstWhere((value) => value.toString().toLowerCase() == string.toLowerCase());
  }

  static ExerciseEquipment fromJson(Map<String, dynamic> json) {
    final name = json["name"];
    return ExerciseEquipment.fromString(name);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "type": "ExerciseEquipment",
      'name': name,
      'description': description,
    };
  }
}
