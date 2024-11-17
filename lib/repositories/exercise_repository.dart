import 'package:collection/collection.dart';
import 'package:tracker_app/enums/exercise/core_movements_enum.dart';
import 'package:tracker_app/enums/exercise/exercise_equipment_enum.dart';
import 'package:tracker_app/enums/exercise/exercise_metrics_enums.dart';
import 'package:tracker_app/enums/exercise/exercise_modality_enum.dart';
import 'package:tracker_app/enums/exercise/exercise_movement_enum.dart';
import 'package:tracker_app/enums/exercise/exercise_position_enum.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';

import '../dtos/exercise_dto.dart';
import '../enums/exercise/exercise_stance_enum.dart';

class ExerciseRepository {
  final List<ExerciseDTO> _exercises = [];

  UnmodifiableListView<ExerciseDTO> get exercises => UnmodifiableListView(_exercises);

  void loadExercises() {
    absExercise();
    _loadAbductorAdductorExercises();
    _calvesExercise();
    _loadChestExercises();
    _loadBicepsExercises();
    _loadTricepsExercises();
    _loadBackExercises();
    _loadQuadricepsExercises();
    _loadHamstringExercises();
    _loadShouldersExercises();
    _glutesExercise();

    _exercises.sort((a, b) => a.name.compareTo(b.name));
  }

  void _loadChestExercises() async {
    final benchPressExercise = ExerciseDTO(
        id: "CHT_01",
        name: "Chest Press",
        description: "Strengthens the chest, shoulders, and triceps with a pressing motion.",
        metrics: [ExerciseMetric.weights],
        modes: [ExerciseModality.bilateral],
        positions: [ExercisePosition.neutral, ExercisePosition.incline, ExercisePosition.decline],
        stances: [ExerciseStance.lying],
        equipment: [
          ExerciseEquipment.dumbbell,
          ExerciseEquipment.barbell,
          ExerciseEquipment.ezBar,
          ExerciseEquipment.cableMachine,
          ExerciseEquipment.machine,
          ExerciseEquipment.band,
          ExerciseEquipment.kettleBell,
          ExerciseEquipment.plate
        ],
        primaryMuscleGroups: [MuscleGroup.chest],
        secondaryMuscleGroups: [MuscleGroup.shoulders, MuscleGroup.triceps],
        coreMovement: CoreMovement.push);

    final dipsExercise = ExerciseDTO(
        id: "CHT_02",
        name: "Chest Dips",
        description: "Targets chest, triceps, and shoulders to build upper body strength.",
        metrics: [ExerciseMetric.reps, ExerciseMetric.weights],
        modes: [ExerciseModality.bilateral],
        positions: [ExercisePosition.neutral],
        stances: [ExerciseStance.standing],
        equipment: [ExerciseEquipment.parallelBars, ExerciseEquipment.straightBar, ExerciseEquipment.assistedMachine],
        primaryMuscleGroups: [MuscleGroup.chest],
        secondaryMuscleGroups: [MuscleGroup.shoulders, MuscleGroup.triceps],
        coreMovement: CoreMovement.push);

    final flyesExercise = ExerciseDTO(
        id: "CHT_0E",
        name: "Chest Flyes",
        description: "Stretches and strengthens the chest muscles with a fly motion.",
        metrics: [ExerciseMetric.weights],
        modes: [ExerciseModality.unilateral],
        positions: [ExercisePosition.neutral, ExercisePosition.incline, ExercisePosition.decline],
        stances: [ExerciseStance.standing, ExerciseStance.seated, ExerciseStance.lying],
        equipment: [ExerciseEquipment.cableMachine, ExerciseEquipment.machine, ExerciseEquipment.dumbbell],
        movements: [ExerciseMovement.none, ExerciseMovement.highToLow, ExerciseMovement.lowToHigh],
        primaryMuscleGroups: [MuscleGroup.chest],
        secondaryMuscleGroups: [MuscleGroup.shoulders, MuscleGroup.triceps],
        coreMovement: CoreMovement.push);

    final pushUpExercise = ExerciseDTO(
        id: "CHT_04",
        name: "Push-Ups",
        description: "Strengthens the chest and triceps with a bodyweight.",
        metrics: [ExerciseMetric.reps, ExerciseMetric.weights],
        modes: [ExerciseModality.bilateral, ExerciseModality.unilateral],
        positions: [ExercisePosition.neutral, ExercisePosition.incline, ExercisePosition.decline],
        stances: [ExerciseStance.lying],
        equipment: [ExerciseEquipment.none, ExerciseEquipment.plate],
        primaryMuscleGroups: [MuscleGroup.chest],
        secondaryMuscleGroups: [MuscleGroup.triceps, MuscleGroup.shoulders],
        coreMovement: CoreMovement.push);

    _exercises.add(benchPressExercise);
    _exercises.add(dipsExercise);
    _exercises.add(flyesExercise);
    _exercises.add(pushUpExercise);
  }

  void _loadBicepsExercises() async {
    final bicepExercise = ExerciseDTO(
        id: "BIC_01",
        name: "Bicep Curls",
        description: "Focuses on building overall biceps mass with weights.",
        metrics: [ExerciseMetric.weights],
        modes: [ExerciseModality.unilateral, ExerciseModality.bilateral],
        positions: ExercisePosition.values,
        stances: [ExerciseStance.standing, ExerciseStance.seated],
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
        coreMovement: CoreMovement.pull);

    _exercises.add(bicepExercise);
  }

  void _loadQuadricepsExercises() {
    final squatsExercise = ExerciseDTO(
        id: "QUA_01",
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
        coreMovement: CoreMovement.squat);

    final lungesExercise = ExerciseDTO(
        id: "QUA_02",
        name: "Lunges",
        description: "An exercise emphasizing quadriceps, hamstrings, and glutes during lunging.",
        metrics: [ExerciseMetric.weights, ExerciseMetric.reps],
        modes: [ExerciseModality.unilateral],
        positions: [ExercisePosition.neutral],
        stances: [ExerciseStance.standing],
        equipment: [ExerciseEquipment.barbell, ExerciseEquipment.dumbbell, ExerciseEquipment.none],
        primaryMuscleGroups: [MuscleGroup.quadriceps],
        secondaryMuscleGroups: [MuscleGroup.hamstrings, MuscleGroup.glutes],
        coreMovement: CoreMovement.squat);

    final legPressesExercise = ExerciseDTO(
        id: "QUA_03",
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
        coreMovement: CoreMovement.squat);

    final legExtensionsExercise = ExerciseDTO(
        id: "QUA_04",
        name: "Leg Extensions",
        description: "An isolation exercise for strengthening the quadriceps using a leg extension machine.",
        metrics: [ExerciseMetric.weights],
        modes: [ExerciseModality.unilateral, ExerciseModality.bilateral],
        positions: [ExercisePosition.neutral],
        stances: [ExerciseStance.seated],
        equipment: [ExerciseEquipment.machine],
        primaryMuscleGroups: [MuscleGroup.quadriceps],
        secondaryMuscleGroups: [MuscleGroup.hamstrings, MuscleGroup.glutes],
        coreMovement: CoreMovement.hinge);

    final stepUpsExercise = ExerciseDTO(
        id: "QUA_05",
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
        coreMovement: CoreMovement.lunge);

    final splitSquatsExercise = ExerciseDTO(
        id: "QUA_06",
        name: "Split Squats",
        description: "A single-leg squat variation that isolates the quadriceps and glutes.",
        metrics: [ExerciseMetric.reps, ExerciseMetric.weights],
        modes: [ExerciseModality.unilateral],
        positions: [ExercisePosition.neutral],
        stances: [ExerciseStance.standing],
        equipment: [
          ExerciseEquipment.barbell,
          ExerciseEquipment.dumbbell,
          ExerciseEquipment.kettleBell,
          ExerciseEquipment.none
        ],
        primaryMuscleGroups: [MuscleGroup.quadriceps],
        secondaryMuscleGroups: [MuscleGroup.hamstrings, MuscleGroup.glutes],
        coreMovement: CoreMovement.squat);

    _exercises.add(squatsExercise);
    _exercises.add(lungesExercise);
    _exercises.add(legPressesExercise);
    _exercises.add(legExtensionsExercise);
    _exercises.add(stepUpsExercise);
    _exercises.add(splitSquatsExercise);
  }

  void _loadHamstringExercises() {
    final goodMorningExercise = ExerciseDTO(
        id: "HAM_01",
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
        coreMovement: CoreMovement.hinge);

    final deadliftsExercise = ExerciseDTO(
        id: "HAM_02",
        name: "Deadlifts",
        description: "Targets the hamstrings and lower back with a hinge motion, building posterior chain strength.",
        metrics: [ExerciseMetric.weights],
        modes: [ExerciseModality.bilateral, ExerciseModality.unilateral],
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
        secondaryMuscleGroups: [MuscleGroup.glutes, MuscleGroup.back, MuscleGroup.abs],
        coreMovement: CoreMovement.hinge);

    final hamstringCurlExercise = ExerciseDTO(
        id: "HAM_03",
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
        coreMovement: CoreMovement.hinge);

    final nordicCurlsExercise = ExerciseDTO(
        id: "HAM_04",
        name: "Nordic Curls",
        description:
            "An advanced bodyweight exercise that focuses on eccentric hamstring strength and injury prevention.",
        metrics: [ExerciseMetric.reps, ExerciseMetric.weights],
        modes: [ExerciseModality.bilateral],
        positions: [ExercisePosition.neutral],
        stances: [ExerciseStance.lying],
        equipment: [ExerciseEquipment.plate, ExerciseEquipment.none],
        primaryMuscleGroups: [MuscleGroup.hamstrings],
        secondaryMuscleGroups: [
          MuscleGroup.glutes,
          MuscleGroup.quadriceps,
          MuscleGroup.calves,
        ],
        coreMovement: CoreMovement.hinge);

    _exercises.add(goodMorningExercise);
    _exercises.add(deadliftsExercise);
    _exercises.add(hamstringCurlExercise);
    _exercises.add(nordicCurlsExercise);
  }

  void _loadTricepsExercises() {
    final kickbacksExercise = ExerciseDTO(
        id: "TRI_01",
        name: "Triceps Kickbacks",
        description: "Isolate the triceps by extending the arm backward in a controlled motion.",
        metrics: [ExerciseMetric.weights],
        modes: [ExerciseModality.unilateral],
        positions: [ExercisePosition.neutral],
        stances: [ExerciseStance.standing],
        equipment: [ExerciseEquipment.dumbbell, ExerciseEquipment.cableMachine],
        primaryMuscleGroups: [MuscleGroup.triceps],
        secondaryMuscleGroups: [MuscleGroup.chest, MuscleGroup.shoulders],
        coreMovement: CoreMovement.push);

    final pushDownsExercise = ExerciseDTO(
        id: "TRI_02",
        name: "Triceps Pushdowns",
        description: "Isolates the triceps with a unique underhand grip, emphasizing the medial head of the muscle.",
        metrics: [ExerciseMetric.weights],
        modes: [ExerciseModality.unilateral, ExerciseModality.bilateral],
        positions: [ExercisePosition.neutral],
        stances: [ExerciseStance.standing],
        equipment: [ExerciseEquipment.rope, ExerciseEquipment.vBarHandle, ExerciseEquipment.straightBarHandle],
        primaryMuscleGroups: [MuscleGroup.triceps],
        secondaryMuscleGroups: [MuscleGroup.chest, MuscleGroup.shoulders],
        coreMovement: CoreMovement.push);

    final closeGripPressesExercise = ExerciseDTO(
        id: "TRI_03",
        name: "Close-Grip Presses",
        description: "Targets the triceps by narrowing hand placement during the pressing motion.",
        metrics: [ExerciseMetric.reps, ExerciseMetric.weights],
        modes: [ExerciseModality.bilateral],
        positions: [ExercisePosition.incline, ExercisePosition.decline, ExercisePosition.neutral],
        stances: [ExerciseStance.lying, ExerciseStance.seated],
        equipment: [ExerciseEquipment.barbell, ExerciseEquipment.smithMachine],
        primaryMuscleGroups: [MuscleGroup.triceps],
        secondaryMuscleGroups: [MuscleGroup.chest, MuscleGroup.shoulders],
        coreMovement: CoreMovement.push);

    final diamondPushUpExercise = ExerciseDTO(
        id: "TRI_04",
        name: "Diamond Push-Ups",
        description: "Focuses on strengthening the triceps by positioning the hands close together in a diamond shape.",
        metrics: [ExerciseMetric.reps, ExerciseMetric.weights],
        modes: [ExerciseModality.bilateral],
        positions: [ExercisePosition.neutral, ExercisePosition.incline, ExercisePosition.decline],
        stances: [ExerciseStance.lying],
        equipment: [ExerciseEquipment.none, ExerciseEquipment.plate],
        primaryMuscleGroups: [MuscleGroup.triceps],
        secondaryMuscleGroups: [MuscleGroup.chest, MuscleGroup.shoulders],
        coreMovement: CoreMovement.push);

    final dipsExercise = ExerciseDTO(
        id: "TRI_05",
        name: "Triceps Dips",
        description:
            "Strengthens the triceps by using body weight or weights attachments in a dipping motion with support from bars.",
        metrics: [ExerciseMetric.reps, ExerciseMetric.weights],
        modes: [ExerciseModality.bilateral],
        positions: [ExercisePosition.neutral],
        stances: [ExerciseStance.standing],
        equipment: [ExerciseEquipment.parallelBars, ExerciseEquipment.straightBar, ExerciseEquipment.assistedMachine],
        primaryMuscleGroups: [MuscleGroup.triceps],
        secondaryMuscleGroups: [MuscleGroup.chest, MuscleGroup.shoulders],
        coreMovement: CoreMovement.push);

    final extensionExercise = ExerciseDTO(
        id: "TRI_06",
        name: "Triceps Extensions",
        description: "Targets the long head of the triceps by stretching and contracting through the motion.",
        metrics: [ExerciseMetric.weights],
        modes: [ExerciseModality.unilateral, ExerciseModality.bilateral],
        positions: [ExercisePosition.neutral],
        stances: [ExerciseStance.standing, ExerciseStance.seated, ExerciseStance.lying],
        movements: [ExerciseMovement.overhead, ExerciseMovement.none],
        equipment: [
          ExerciseEquipment.rope,
          ExerciseEquipment.vBarHandle,
          ExerciseEquipment.straightBarHandle,
          ExerciseEquipment.dumbbell,
          ExerciseEquipment.barbell
        ],
        primaryMuscleGroups: [MuscleGroup.triceps],
        secondaryMuscleGroups: [MuscleGroup.chest, MuscleGroup.shoulders],
        coreMovement: CoreMovement.push);

    _exercises.add(kickbacksExercise);
    _exercises.add(pushDownsExercise);
    _exercises.add(closeGripPressesExercise);
    _exercises.add(diamondPushUpExercise);
    _exercises.add(dipsExercise);
    _exercises.add(extensionExercise);
  }

  void _loadBackExercises() {
    final rowsExercise = ExerciseDTO(
        id: "BAC_01",
        name: "Rows",
        description: "Targets the lats, traps, and rhomboids.",
        metrics: [ExerciseMetric.weights],
        modes: [ExerciseModality.unilateral, ExerciseModality.bilateral],
        positions: [ExercisePosition.neutral],
        stances: [ExerciseStance.standing, ExerciseStance.seated],
        equipment: [
          ExerciseEquipment.dumbbell,
          ExerciseEquipment.cableMachine,
          ExerciseEquipment.barbell,
          ExerciseEquipment.kettleBell,
          ExerciseEquipment.smithMachine,
          ExerciseEquipment.tBarHandle
        ],
        primaryMuscleGroups: [MuscleGroup.back],
        movements: [ExerciseMovement.reverse, ExerciseMovement.none],
        secondaryMuscleGroups: [MuscleGroup.biceps, MuscleGroup.abs, MuscleGroup.shoulders],
        coreMovement: CoreMovement.pull);

    final latPullDownsExercise = ExerciseDTO(
        id: "BAC_02",
        name: "Lat Pulldowns",
        description: "Focuses on the lats and upper back, ideal for developing width.",
        metrics: [ExerciseMetric.weights],
        modes: [ExerciseModality.unilateral, ExerciseModality.bilateral],
        positions: [ExercisePosition.neutral],
        stances: [ExerciseStance.seated],
        equipment: [ExerciseEquipment.cableMachine],
        primaryMuscleGroups: [MuscleGroup.back],
        movements: [ExerciseMovement.reverse, ExerciseMovement.none],
        secondaryMuscleGroups: [MuscleGroup.biceps, MuscleGroup.shoulders],
        coreMovement: CoreMovement.pull);

    final pullUpsExercise = ExerciseDTO(
        id: "BAC_03",
        name: "Pull-Ups",
        description: "A bodyweight exercise that activates the lats and upper back, promoting overall back strength.",
        metrics: [ExerciseMetric.reps, ExerciseMetric.weights],
        modes: [ExerciseModality.unilateral, ExerciseModality.bilateral],
        positions: [ExercisePosition.neutral],
        stances: [ExerciseStance.hanging],
        equipment: [
          ExerciseEquipment.plate,
          ExerciseEquipment.dumbbell,
          ExerciseEquipment.kettleBell,
          ExerciseEquipment.assistedMachine,
          ExerciseEquipment.band
        ],
        primaryMuscleGroups: [MuscleGroup.back],
        movements: [ExerciseMovement.reverse, ExerciseMovement.none],
        secondaryMuscleGroups: [MuscleGroup.biceps, MuscleGroup.shoulders],
        coreMovement: CoreMovement.pull);

    final hyperExtensionExercise = ExerciseDTO(
        id: "BAC_04",
        name: "Back Extension",
        description: "Targets the lower back and hamstrings with a bodyweight or weighted hyperextension.",
        metrics: [ExerciseMetric.reps, ExerciseMetric.weights],
        modes: [ExerciseModality.bilateral],
        positions: [ExercisePosition.neutral],
        stances: [ExerciseStance.lying],
        equipment: [ExerciseEquipment.none, ExerciseEquipment.plate],
        primaryMuscleGroups: [MuscleGroup.back],
        secondaryMuscleGroups: [MuscleGroup.glutes, MuscleGroup.hamstrings, MuscleGroup.abs],
        coreMovement: CoreMovement.hinge);

    _exercises.add(rowsExercise);
    _exercises.add(latPullDownsExercise);
    _exercises.add(hyperExtensionExercise);
    _exercises.add(pullUpsExercise);
  }

  void _loadAbductorAdductorExercises() {
    final abductorExercise = ExerciseDTO(
        id: "ABD_01",
        name: "Hip Abduction",
        description: "Activates and strengthens the hip abductors using resistance, focusing on lateral leg movement.",
        metrics: [ExerciseMetric.weights],
        modes: [ExerciseModality.bilateral],
        positions: [ExercisePosition.neutral],
        stances: [ExerciseStance.seated],
        equipment: [ExerciseEquipment.machine, ExerciseEquipment.band],
        primaryMuscleGroups: [MuscleGroup.abductors],
        secondaryMuscleGroups: [MuscleGroup.glutes],
        coreMovement: CoreMovement.others);

    final adductionExercise = ExerciseDTO(
        id: "ADD_01",
        name: "Hip Adduction",
        description:
            "Targets the inner thigh muscles, specifically the adductors, to improve leg stability and strength.",
        metrics: [ExerciseMetric.weights],
        modes: [ExerciseModality.bilateral],
        positions: [ExercisePosition.neutral],
        stances: [ExerciseStance.seated],
        equipment: [ExerciseEquipment.machine, ExerciseEquipment.band],
        primaryMuscleGroups: [MuscleGroup.adductors],
        coreMovement: CoreMovement.others);

    _exercises.add(abductorExercise);
    _exercises.add(adductionExercise);
  }

  void _loadShouldersExercises() {
    final raisesExercise = ExerciseDTO(
        id: "SHO_01",
        name: "Shoulder Raises",
        description: "Targets the front/lateral deltoid muscles to build shoulder size.",
        metrics: [ExerciseMetric.weights],
        modes: [ExerciseModality.unilateral],
        positions: [ExercisePosition.neutral],
        stances: [ExerciseStance.standing, ExerciseStance.seated],
        equipment: [
          ExerciseEquipment.dumbbell,
          ExerciseEquipment.cableMachine,
          ExerciseEquipment.machine,
          ExerciseEquipment.plate,
          ExerciseEquipment.kettleBell,
          ExerciseEquipment.barbell
        ],
        primaryMuscleGroups: [MuscleGroup.shoulders],
        coreMovement: CoreMovement.push);

    final uprightRowExercise = ExerciseDTO(
        id: "SHO_02",
        name: "Upright Rows",
        description: "Works the shoulders and traps for shoulder development.",
        metrics: [ExerciseMetric.weights],
        modes: [ExerciseModality.bilateral],
        positions: [ExercisePosition.neutral],
        stances: [ExerciseStance.standing, ExerciseStance.seated],
        equipment: [
          ExerciseEquipment.barbell,
          ExerciseEquipment.dumbbell,
          ExerciseEquipment.cableMachine,
          ExerciseEquipment.plate,
          ExerciseEquipment.kettleBell
        ],
        primaryMuscleGroups: [MuscleGroup.shoulders],
        coreMovement: CoreMovement.push);

    final arnoldPressExercise = ExerciseDTO(
        id: "SHO_03",
        name: "Arnold Press",
        description: "A variation of the shoulder press that activates all three heads of the deltoid muscles.",
        metrics: [ExerciseMetric.weights],
        modes: [ExerciseModality.unilateral],
        positions: [ExercisePosition.neutral],
        stances: [ExerciseStance.standing, ExerciseStance.seated],
        equipment: [ExerciseEquipment.dumbbell, ExerciseEquipment.kettleBell],
        primaryMuscleGroups: [MuscleGroup.shoulders],
        coreMovement: CoreMovement.push);

    final overheadExercise = ExerciseDTO(
        id: "SHO_04",
        name: "Overhead Press",
        description: "Builds overall shoulder strength, also involving the triceps and upper chest.",
        metrics: [ExerciseMetric.weights],
        modes: [ExerciseModality.bilateral, ExerciseModality.unilateral],
        positions: [ExercisePosition.neutral],
        stances: [ExerciseStance.standing, ExerciseStance.seated],
        equipment: [
          ExerciseEquipment.barbell,
          ExerciseEquipment.machine,
          ExerciseEquipment.dumbbell,
          ExerciseEquipment.kettleBell
        ],
        primaryMuscleGroups: [MuscleGroup.shoulders],
        movements: [ExerciseMovement.overhead],
        coreMovement: CoreMovement.push);

    final reverseExercise = ExerciseDTO(
        id: "SHO_05",
        name: "Reverse Shoulder Flyes",
        description: "Strengthens the rear deltoids and upper back, enhancing posture and shoulder support.",
        metrics: [ExerciseMetric.weights],
        modes: [ExerciseModality.bilateral, ExerciseModality.unilateral],
        positions: [ExercisePosition.neutral],
        stances: [ExerciseStance.standing, ExerciseStance.seated],
        equipment: [
          ExerciseEquipment.cableMachine,
          ExerciseEquipment.machine,
          ExerciseEquipment.dumbbell,
          ExerciseEquipment.kettleBell
        ],
        primaryMuscleGroups: [MuscleGroup.shoulders],
        movements: [ExerciseMovement.reverse],
        coreMovement: CoreMovement.push);

    final rotationExercise = ExerciseDTO(
        id: "SHO_06",
        name: "Shoulder Rotations",
        description: "Strengthens the rear deltoids and upper back, enhancing posture and shoulder support.",
        metrics: [ExerciseMetric.weights],
        modes: [ExerciseModality.unilateral],
        positions: [ExercisePosition.neutral],
        stances: [ExerciseStance.standing, ExerciseStance.seated, ExerciseStance.lying],
        equipment: [
          ExerciseEquipment.cableMachine,
          ExerciseEquipment.machine,
          ExerciseEquipment.dumbbell,
          ExerciseEquipment.kettleBell
        ],
        primaryMuscleGroups: [MuscleGroup.shoulders],
        movements: [ExerciseMovement.internalRotation, ExerciseMovement.externalRotation],
        coreMovement: CoreMovement.push);

    final facePullExercise = ExerciseDTO(
        id: "SHO_07",
        name: "Face Pull",
        description: "Improves shoulder health by targeting the rear delts and upper back.",
        metrics: [ExerciseMetric.weights],
        modes: [ExerciseModality.bilateral],
        positions: [ExercisePosition.neutral],
        stances: [ExerciseStance.standing, ExerciseStance.seated],
        equipment: [ExerciseEquipment.cableMachine, ExerciseEquipment.band],
        primaryMuscleGroups: [MuscleGroup.shoulders],
        coreMovement: CoreMovement.pull);

    _exercises.add(raisesExercise);
    _exercises.add(uprightRowExercise);
    _exercises.add(arnoldPressExercise);
    _exercises.add(overheadExercise);
    _exercises.add(reverseExercise);
    _exercises.add(rotationExercise);
    _exercises.add(facePullExercise);
  }

  void _glutesExercise() {
    final gluteBridgeExercise = ExerciseDTO(
        id: "GLU_01",
        name: "Glute Bridge",
        description: "Strengthens the glutes during a hip-lifting movement.",
        metrics: [ExerciseMetric.reps, ExerciseMetric.weights],
        modes: [ExerciseModality.unilateral, ExerciseModality.bilateral],
        positions: [ExercisePosition.neutral],
        stances: [ExerciseStance.lying],
        equipment: [
          ExerciseEquipment.dumbbell,
          ExerciseEquipment.plate,
          ExerciseEquipment.kettleBell,
          ExerciseEquipment.barbell
        ],
        primaryMuscleGroups: [MuscleGroup.glutes],
        secondaryMuscleGroups: [MuscleGroup.hamstrings, MuscleGroup.back],
        coreMovement: CoreMovement.others);

    final hipThrustExercise = ExerciseDTO(
        id: "GLU_02",
        name: "Hip Thrust",
        description: "Targets the gluteus maximus for strength and size through hip extension.",
        metrics: [ExerciseMetric.reps, ExerciseMetric.weights],
        modes: [ExerciseModality.unilateral, ExerciseModality.bilateral],
        positions: [ExercisePosition.neutral],
        stances: [ExerciseStance.lying],
        equipment: [
          ExerciseEquipment.dumbbell,
          ExerciseEquipment.plate,
          ExerciseEquipment.kettleBell,
          ExerciseEquipment.barbell,
          ExerciseEquipment.smithMachine,
          ExerciseEquipment.machine
        ],
        primaryMuscleGroups: [MuscleGroup.glutes],
        secondaryMuscleGroups: [
          MuscleGroup.hamstrings,
          MuscleGroup.quadriceps,
          MuscleGroup.adductors,
          MuscleGroup.back
        ],
        coreMovement: CoreMovement.hinge);

    final kickBacksExercise = ExerciseDTO(
        id: "GLU_03",
        name: "Glute Kickbacks",
        description: "Bodyweight exercise that isolates the glutes with a backward kicking motion.",
        metrics: [ExerciseMetric.reps, ExerciseMetric.weights],
        modes: [ExerciseModality.unilateral],
        positions: [ExercisePosition.neutral],
        stances: [ExerciseStance.kneeling, ExerciseStance.standing],
        equipment: [
          ExerciseEquipment.cableMachine,
          ExerciseEquipment.machine,
          ExerciseEquipment.band,
          ExerciseEquipment.none
        ],
        primaryMuscleGroups: [MuscleGroup.glutes],
        secondaryMuscleGroups: [
          MuscleGroup.hamstrings,
          MuscleGroup.quadriceps,
          MuscleGroup.adductors,
          MuscleGroup.back
        ],
        coreMovement: CoreMovement.others);

    final pullThroughsExercise = ExerciseDTO(
        id: "GLU_04",
        name: "Pull Throughs",
        description: "Engages the glutes and hamstrings while focusing on hip hinge movement.",
        metrics: [ExerciseMetric.reps, ExerciseMetric.weights],
        modes: [ExerciseModality.bilateral],
        positions: [ExercisePosition.neutral],
        stances: [ExerciseStance.standing],
        equipment: [ExerciseEquipment.cableMachine, ExerciseEquipment.band],
        primaryMuscleGroups: [MuscleGroup.glutes],
        secondaryMuscleGroups: [MuscleGroup.hamstrings, MuscleGroup.adductors, MuscleGroup.back],
        coreMovement: CoreMovement.hinge);

    _exercises.add(gluteBridgeExercise);
    _exercises.add(hipThrustExercise);
    _exercises.add(kickBacksExercise);
    _exercises.add(pullThroughsExercise);
  }

  void absExercise() {
    final planksExercise = ExerciseDTO(
        id: "ABS_01",
        name: "Planks",
        description: "Strengthens the core by holding a static plank position, engaging the entire midsection.",
        metrics: [ExerciseMetric.duration],
        modes: [ExerciseModality.unilateral, ExerciseModality.bilateral],
        positions: [ExercisePosition.neutral],
        stances: [ExerciseStance.lying, ExerciseStance.kneeling],
        equipment: [ExerciseEquipment.plate],
        movements: [ExerciseMovement.reverse, ExerciseMovement.none],
        primaryMuscleGroups: [MuscleGroup.abs],
        coreMovement: CoreMovement.others);

    final crunchesExercise = ExerciseDTO(
        id: "ABS_02",
        name: "Crunches",
        description: "Targets the upper abs in a crunching motion.",
        metrics: [ExerciseMetric.reps, ExerciseMetric.weights],
        modes: [ExerciseModality.bilateral],
        positions: [ExercisePosition.neutral, ExercisePosition.decline],
        stances: [ExerciseStance.lying],
        movements: [ExerciseMovement.reverse, ExerciseMovement.none],
        equipment: [
          ExerciseEquipment.none,
          ExerciseEquipment.machine,
          ExerciseEquipment.cableMachine,
          ExerciseEquipment.plate,
          ExerciseEquipment.dumbbell,
          ExerciseEquipment.kettleBell
        ],
        primaryMuscleGroups: [MuscleGroup.abs],
        coreMovement: CoreMovement.others);

    final legRaisesExercise = ExerciseDTO(
        id: "ABS_03",
        name: "Leg Raises",
        description: "Targets the lower abs by lifting the legs while suspended.",
        metrics: [ExerciseMetric.reps, ExerciseMetric.weights],
        modes: [ExerciseModality.bilateral],
        positions: [ExercisePosition.neutral],
        stances: [ExerciseStance.lying, ExerciseStance.hanging],
        movements: [ExerciseMovement.reverse, ExerciseMovement.none],
        equipment: [
          ExerciseEquipment.none,
          ExerciseEquipment.machine,
          ExerciseEquipment.cableMachine,
          ExerciseEquipment.plate,
          ExerciseEquipment.dumbbell,
          ExerciseEquipment.kettleBell
        ],
        primaryMuscleGroups: [MuscleGroup.abs],
        coreMovement: CoreMovement.hinge);

    _exercises.add(planksExercise);
    _exercises.add(crunchesExercise);
    _exercises.add(legRaisesExercise);
  }

  void _calvesExercise() {
    final calfRaisesExercise = ExerciseDTO(
        id: "CAL_01",
        name: "Calf Raises",
        description: "Strengthens the calf muscles by raising the heels from a standing position.",
        metrics: [ExerciseMetric.reps, ExerciseMetric.weights],
        modes: [ExerciseModality.unilateral, ExerciseModality.bilateral],
        positions: [ExercisePosition.neutral],
        stances: [ExerciseStance.standing, ExerciseStance.seated],
        equipment: [ExerciseEquipment.plate, ExerciseEquipment.dumbbell, ExerciseEquipment.machine],
        primaryMuscleGroups: [MuscleGroup.calves],
        coreMovement: CoreMovement.others);

    final jumpRopeExercise = ExerciseDTO(
        id: "CAL_02",
        name: "Jump Rope",
        description:
            "Engages the calves through repetitive jumping motions, building strength, endurance, and coordination while improving overall lower-body mobility and agility.",
        metrics: [ExerciseMetric.reps, ExerciseMetric.weights],
        modes: [ExerciseModality.unilateral, ExerciseModality.bilateral],
        positions: [ExercisePosition.neutral],
        stances: [ExerciseStance.standing],
        equipment: [ExerciseEquipment.rope],
        primaryMuscleGroups: [MuscleGroup.calves],
        coreMovement: CoreMovement.others);

    _exercises.add(calfRaisesExercise);
    _exercises.add(jumpRopeExercise);
  }

  /// Helper methods

  ExerciseDTO whereExercise({required String name}) {
    return exercises.firstWhere((exercise) => exercise.name == name);
  }

  void clear() {
    _exercises.clear();
  }
}
