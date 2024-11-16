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
  }

  void _loadBicepsExercises() async {
    final bicepExercise = ExerciseDTO(
        name: "Bicep Curls",
        description: "Focuses on building overall biceps mass with weights.",
        metrics: [ExerciseMetric.weights],
        modes: ExerciseModality.values,
        positions: ExercisePosition.values,
        stances: ExerciseStance.values,
        equipment: ExerciseEquipment.dumbbell,
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
        equipment: ExerciseEquipment.none,
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
        equipment: ExerciseEquipment.none,
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
        equipment: ExerciseEquipment.machine,
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
        equipment: ExerciseEquipment.machine,
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
        equipment: ExerciseEquipment.none,
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
        equipment: ExerciseEquipment.none,
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

  /// Helper methods

  ExerciseDTO whereExercise({required String name}) {
    return exercises.firstWhere((exercise) => exercise.name == name);
  }

  void clear() {
    _exercises.clear();
  }
}
