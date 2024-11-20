import 'package:tracker_app/dtos/exercise_dto.dart';

enum ExerciseEquipment implements ExerciseConfig {
  barbell("Barbell", "Classic for heavy lifts like squats, deadlifts, and bench press."),
  ezBar("EZ Bar", "Perfect for curls and tricep extensions with a natural grip."),
  dumbbell("Dumbbells", "Versatile weights for targeted strength training."),
  band("Band", "Resistance bands for mobility, strength, and rehabilitation."),
  rope("Rope", "Ideal for tricep pushdowns, cable exercises, or battle rope training."),
  trapBar("Trap-Bar", "Great for deadlifts with a neutral grip to reduce strain."),
  vBarHandle("V-Bar", "Used for close-grip rows or pull-downs on a cable machine."),
  tBarHandle("T-Bar", "For powerful back-focused rows using a T-bar setup."),
  straightBarHandle("Straight Bar", "For cable exercises like bicep curls or tricep pushdowns."),
  plyoBox("Plyo Box", "Essential for box jumps, step-ups, or dynamic plyometric exercises."),
  parallelBars("Parallel Bars", "Used for dips, L-sits, or bodyweight training."),
  straightBar("Straight Bar", "Simple and effective for pull-ups or other bodyweight moves."),
  kettleBell("Kettle Bell", "Dynamic weight for swings, snatches, and functional training."),
  assistedMachine("Assisted Machine", "Provides support for exercises like pull-ups or dips."),
  machine("Machine", "Targeted strength training with guided movements."),
  hackSquatMachine("Hack Squat Machine", "Please provide a description here"),
  smithMachine("Smith Machine", "Stabilized barbell for squats, presses, and safer lifts."),
  cableMachine("Cable Machine", "Versatile for isolation and functional exercises"),
  plate("Plate", "Add resistance to barbells or use for loaded carries."),
  none("No Equipment", "No equipment needed—perfect for bodyweight exercises.");

  const ExerciseEquipment(this.name, this.description);

  @override
  final String name;

  @override
  final String description;

  static ExerciseEquipment fromString(String string) {
    return values.firstWhere((value) => value.name.toLowerCase() == string.toLowerCase());
  }
}
