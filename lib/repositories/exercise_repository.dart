import 'package:collection/collection.dart';
import 'package:tracker_app/enums/exercise/core_movements_enum.dart';
import 'package:tracker_app/enums/exercise/exercise_equipment_enum.dart';
import 'package:tracker_app/enums/exercise/exercise_metrics_enums.dart';
import 'package:tracker_app/enums/exercise/exercise_modality_enum.dart';
import 'package:tracker_app/enums/exercise/exercise_position_enum.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';

import '../dtos/exercise_dto.dart';
import '../enums/exercise/exercise_stance_enum.dart';

class ExerciseRepository {
  final List<ExerciseDTO> _exercises = [];

  UnmodifiableListView<ExerciseDTO> get exercises => UnmodifiableListView(_exercises);

  void loadExercises() {
    _loadBicepsExercises();
    _loadQuadricepsExercises();
    _loadHamstringExercises();
    _loadTricepsExercises();

    _exercises.sort((a, b) => a.name.compareTo(b.name));
  }

  void _loadBicepsExercises() async {
    final bicepExercise = ExerciseDTO(
        name: "Bicep Curls",
        description: "Focuses on building overall biceps mass with weights.",
        metrics: [ExerciseMetric.weights],
        modes: [ExerciseModality.unilateral, ExerciseModality.bilateral],
        positions: ExercisePosition.values,
        stances: ExerciseStance.values,
        equipment: [
          ExerciseEquipment.dumbbell,
          ExerciseEquipment.barbell,
          ExerciseEquipment.ezBar,
          ExerciseEquipment.cableMachine,
          ExerciseEquipment.machine,
          ExerciseEquipment.band,
          ExerciseEquipment.kettleBell
        ],
        primaryMuscleGroups: [MuscleGroup.biceps],
        secondaryMuscleGroups: [MuscleGroup.forearms],
        movement: CoreMovement.pull);

    _exercises.add(bicepExercise);
  }

  void _loadQuadricepsExercises() {
    final squatsExercise = ExerciseDTO(
        name: "Squats",
        description: "A squat targeting the quadriceps, glutes, and hamstrings.",
        metrics: [ExerciseMetric.weights, ExerciseMetric.reps],
        modes: [ExerciseModality.bilateral],
        positions: [ExercisePosition.neutral],
        stances: [ExerciseStance.standing],
        equipment: [
          ExerciseEquipment.barbell,
          ExerciseEquipment.machine,
          ExerciseEquipment.smithMachine,
          ExerciseEquipment.none
        ],
        primaryMuscleGroups: [MuscleGroup.quadriceps],
        secondaryMuscleGroups: [MuscleGroup.hamstrings, MuscleGroup.glutes],
        movement: CoreMovement.squat);

    final lungesExercise = ExerciseDTO(
        name: "Lunges",
        description: "An exercise emphasizing quadriceps, hamstrings, and glutes during lunging.",
        metrics: [ExerciseMetric.weights, ExerciseMetric.reps],
        modes: [ExerciseModality.unilateral],
        positions: [ExercisePosition.neutral],
        stances: [ExerciseStance.standing],
        equipment: [ExerciseEquipment.barbell, ExerciseEquipment.dumbbell, ExerciseEquipment.none],
        primaryMuscleGroups: [MuscleGroup.quadriceps],
        secondaryMuscleGroups: [MuscleGroup.hamstrings, MuscleGroup.glutes],
        movement: CoreMovement.squat);

    final legPressesExercise = ExerciseDTO(
        name: "Leg Presses",
        description: "A machine-based exercise that targets the quadriceps, glutes, and hamstrings.",
        metrics: [ExerciseMetric.weights],
        modes: [ExerciseModality.unilateral, ExerciseModality.bilateral],
        positions: [ExercisePosition.neutral],
        stances: [ExerciseStance.standing],
        equipment: [
          ExerciseEquipment.machine,
        ],
        primaryMuscleGroups: [MuscleGroup.quadriceps],
        secondaryMuscleGroups: [MuscleGroup.hamstrings, MuscleGroup.glutes],
        movement: CoreMovement.squat);

    final legExtensionsExercise = ExerciseDTO(
        name: "Leg Extensions",
        description: "An isolation exercise for strengthening the quadriceps using a leg extension machine.",
        metrics: [ExerciseMetric.weights],
        modes: [ExerciseModality.unilateral, ExerciseModality.bilateral],
        positions: [ExercisePosition.neutral],
        stances: [ExerciseStance.seated],
        equipment: [ExerciseEquipment.machine],
        primaryMuscleGroups: [MuscleGroup.quadriceps],
        secondaryMuscleGroups: [MuscleGroup.hamstrings, MuscleGroup.glutes],
        movement: CoreMovement.hinge);

    final stepUpsExercise = ExerciseDTO(
        name: "Step Ups",
        description:
            "Works the quadriceps and glutes by stepping onto an elevated platform, enhancing lower body strength.",
        metrics: [ExerciseMetric.reps, ExerciseMetric.weights],
        modes: [ExerciseModality.unilateral],
        positions: [ExercisePosition.neutral],
        stances: [ExerciseStance.standing],
        equipment: [ExerciseEquipment.dumbbell, ExerciseEquipment.kettleBell, ExerciseEquipment.none],
        primaryMuscleGroups: [MuscleGroup.quadriceps],
        secondaryMuscleGroups: [MuscleGroup.hamstrings, MuscleGroup.glutes],
        movement: CoreMovement.lunge);

    final splitSquatsExercise = ExerciseDTO(
        name: "Split Squats",
        description: "A single-leg squat variation that isolates the quadriceps and glutes.",
        metrics: [ExerciseMetric.reps, ExerciseMetric.weights],
        modes: [ExerciseModality.unilateral],
        positions: [ExercisePosition.neutral],
        stances: [ExerciseStance.standing],
        equipment: [ExerciseEquipment.barbell, ExerciseEquipment.kettleBell, ExerciseEquipment.none],
        primaryMuscleGroups: [MuscleGroup.quadriceps],
        secondaryMuscleGroups: [MuscleGroup.hamstrings, MuscleGroup.glutes],
        movement: CoreMovement.squat);

    _exercises.add(squatsExercise);
    _exercises.add(lungesExercise);
    _exercises.add(legPressesExercise);
    _exercises.add(legExtensionsExercise);
    _exercises.add(stepUpsExercise);
    _exercises.add(splitSquatsExercise);
  }

  void _loadHamstringExercises() {
    final goodMorningExercise = ExerciseDTO(
        name: "Good Morning",
        description: "Targets the hamstrings and lower back with a hinge motion, building posterior chain strength.",
        metrics: [ExerciseMetric.weights],
        modes: [ExerciseModality.bilateral],
        positions: [ExercisePosition.neutral],
        stances: [ExerciseStance.standing],
        equipment: [
          ExerciseEquipment.barbell,
        ],
        primaryMuscleGroups: [MuscleGroup.hamstrings],
        secondaryMuscleGroups: [MuscleGroup.glutes, MuscleGroup.back, MuscleGroup.abs],
        movement: CoreMovement.hinge);

    final deadliftsExercise = ExerciseDTO(
        name: "Deadlifts",
        description: "Targets the hamstrings and lower back with a hinge motion, building posterior chain strength.",
        metrics: [ExerciseMetric.weights],
        modes: [ExerciseModality.unilateral, ExerciseModality.bilateral],
        positions: [ExercisePosition.neutral],
        stances: [ExerciseStance.standing],
        equipment: [
          ExerciseEquipment.band,
          ExerciseEquipment.barbell,
          ExerciseEquipment.dumbbell,
          ExerciseEquipment.kettleBell,
          ExerciseEquipment.smithMachine
        ],
        primaryMuscleGroups: [MuscleGroup.hamstrings],
        secondaryMuscleGroups: [MuscleGroup.glutes, MuscleGroup.back, MuscleGroup.abs, MuscleGroup.forearms],
        movement: CoreMovement.hinge);

    final hamstringCurlExercise = ExerciseDTO(
        name: "Hamstring Curls",
        description:
            "Isolates the hamstrings by curling the legs from a lying/seated position, enhancing muscle development.",
        metrics: [ExerciseMetric.weights],
        modes: [ExerciseModality.unilateral, ExerciseModality.bilateral],
        positions: [ExercisePosition.neutral],
        stances: [ExerciseStance.seated, ExerciseStance.lying],
        equipment: [ExerciseEquipment.machine, ExerciseEquipment.none],
        primaryMuscleGroups: [MuscleGroup.hamstrings],
        secondaryMuscleGroups: [MuscleGroup.glutes],
        movement: CoreMovement.hinge);

    _exercises.add(goodMorningExercise);
    _exercises.add(deadliftsExercise);
    _exercises.add(hamstringCurlExercise);
  }

  void _loadTricepsExercises() {
    final kickbacksExercise = ExerciseDTO(
        name: "Triceps Kickbacks",
        description: "Isolate the triceps by extending the arm backward in a controlled motion.",
        metrics: [ExerciseMetric.weights],
        modes: [ExerciseModality.unilateral],
        positions: [ExercisePosition.neutral],
        stances: [ExerciseStance.standing],
        equipment: [ExerciseEquipment.dumbbell, ExerciseEquipment.cableMachine],
        primaryMuscleGroups: [MuscleGroup.triceps],
        secondaryMuscleGroups: [MuscleGroup.chest, MuscleGroup.shoulders],
        movement: CoreMovement.push);

    final pushDownsExercise = ExerciseDTO(
        name: "Triceps Pushdowns",
        description: "Isolates the triceps with a unique underhand grip, emphasizing the medial head of the muscle.",
        metrics: [ExerciseMetric.weights],
        modes: [ExerciseModality.unilateral, ExerciseModality.bilateral],
        positions: [ExercisePosition.neutral],
        stances: [ExerciseStance.standing],
        equipment: [ExerciseEquipment.rope, ExerciseEquipment.vBarHandle, ExerciseEquipment.straightBarHandle],
        primaryMuscleGroups: [MuscleGroup.triceps],
        secondaryMuscleGroups: [MuscleGroup.chest, MuscleGroup.shoulders],
        movement: CoreMovement.push);

    final closeGripPressesExercise = ExerciseDTO(
        name: "Close-Grip Presses",
        description: "Targets the triceps by narrowing hand placement during the pressing motion.",
        metrics: [ExerciseMetric.reps, ExerciseMetric.weights],
        modes: [ExerciseModality.bilateral],
        positions: [ExercisePosition.incline, ExercisePosition.decline, ExercisePosition.neutral],
        stances: [ExerciseStance.lying, ExerciseStance.seated],
        equipment: [ExerciseEquipment.barbell, ExerciseEquipment.smithMachine],
        primaryMuscleGroups: [MuscleGroup.triceps],
        secondaryMuscleGroups: [MuscleGroup.chest, MuscleGroup.shoulders],
        movement: CoreMovement.push);

    final diamondPushUpExercise = ExerciseDTO(
        name: "Diamond Push-Ups",
        description: "Focuses on strengthening the triceps by positioning the hands close together in a diamond shape.",
        metrics: [ExerciseMetric.reps, ExerciseMetric.weights],
        modes: [ExerciseModality.bilateral],
        positions: [ExercisePosition.neutral],
        stances: [ExerciseStance.lying],
        equipment: [ExerciseEquipment.none, ExerciseEquipment.plate],
        primaryMuscleGroups: [MuscleGroup.triceps],
        secondaryMuscleGroups: [MuscleGroup.chest, MuscleGroup.shoulders],
        movement: CoreMovement.push);

    final dipsExercise = ExerciseDTO(
        name: "Dips",
        description:
            "Strengthens the triceps by using body weight or weights attachments in a dipping motion with support from bars.",
        metrics: [ExerciseMetric.reps, ExerciseMetric.weights],
        modes: [ExerciseModality.bilateral],
        positions: [ExercisePosition.neutral],
        stances: [ExerciseStance.standing],
        equipment: [ExerciseEquipment.parallelBars, ExerciseEquipment.straightBar, ExerciseEquipment.assistedMachine],
        primaryMuscleGroups: [MuscleGroup.triceps],
        secondaryMuscleGroups: [MuscleGroup.chest, MuscleGroup.shoulders],
        movement: CoreMovement.push);

    final extensionExercise = ExerciseDTO(
        name: "Triceps Extension",
        description: "Targets the long head of the triceps by stretching and contracting through the motion.",
        metrics: [ExerciseMetric.weights],
        modes: [ExerciseModality.unilateral, ExerciseModality.bilateral],
        positions: [ExercisePosition.neutral],
        stances: [ExerciseStance.standing],
        equipment: [ExerciseEquipment.rope, ExerciseEquipment.vBarHandle, ExerciseEquipment.straightBarHandle],
        primaryMuscleGroups: [MuscleGroup.triceps],
        secondaryMuscleGroups: [MuscleGroup.chest, MuscleGroup.shoulders],
        movement: CoreMovement.push);

    final overheadExtensionExercise = ExerciseDTO(
        name: "Overhead Triceps Extension",
        description: "Targets the long head of the triceps by stretching and contracting through the motion.",
        metrics: [ExerciseMetric.weights],
        modes: [ExerciseModality.unilateral, ExerciseModality.bilateral],
        positions: [ExercisePosition.neutral],
        stances: [ExerciseStance.standing, ExerciseStance.seated, ExerciseStance.lying],
        equipment: [
          ExerciseEquipment.rope,
          ExerciseEquipment.vBarHandle,
          ExerciseEquipment.straightBarHandle,
          ExerciseEquipment.dumbbell,
          ExerciseEquipment.barbell
        ],
        primaryMuscleGroups: [MuscleGroup.triceps],
        secondaryMuscleGroups: [MuscleGroup.chest, MuscleGroup.shoulders],
        movement: CoreMovement.push);

    _exercises.add(kickbacksExercise);
    _exercises.add(pushDownsExercise);
    _exercises.add(closeGripPressesExercise);
    _exercises.add(diamondPushUpExercise);
    _exercises.add(dipsExercise);
    _exercises.add(extensionExercise);
    _exercises.add(overheadExtensionExercise);
  }

  /// Helper methods

  ExerciseDTO whereExercise({required String name}) {
    return exercises.firstWhere((exercise) => exercise.name == name);
  }

  void clear() {
    _exercises.clear();
  }
}
