import 'package:collection/collection.dart';
import 'package:tracker_app/dtos/biceps_exercises_dtos/bicep_curls_exercise_dto.dart';
import 'package:tracker_app/dtos/chest_exercise_dtos/bench_presses_exercise_dto.dart';
import 'package:tracker_app/dtos/chest_exercise_dtos/chest_flyes_exercise_dto.dart';
import 'package:tracker_app/dtos/hamstrings_exercises_dtos/deadlifts_exercise_dto.dart';
import 'package:tracker_app/dtos/hamstrings_exercises_dtos/good_morning_exercise_dto.dart';
import 'package:tracker_app/dtos/hamstrings_exercises_dtos/leg_curls_exercise_dto.dart';
import 'package:tracker_app/dtos/leg_exercises_dtos/leg_press_exercise_dto.dart';
import 'package:tracker_app/dtos/leg_exercises_dtos/lunges_exercise_dto.dart';
import 'package:tracker_app/dtos/leg_exercises_dtos/split_squat_exercise_dto.dart';
import 'package:tracker_app/dtos/leg_exercises_dtos/squat_exercise_dto.dart';
import 'package:tracker_app/dtos/leg_exercises_dtos/step_ups_exercise_dto.dart';
import 'package:tracker_app/dtos/triceps_exercises_dtos/triceps_dips_exercise_dto.dart';
import 'package:tracker_app/dtos/triceps_exercises_dtos/triceps_extensions_exercise_dto.dart';
import 'package:tracker_app/dtos/triceps_exercises_dtos/triceps_kickbacks_exercise_dto.dart';
import 'package:tracker_app/dtos/triceps_exercises_dtos/triceps_pushdowns_exercise_dto.dart';

import '../dtos/chest_exercise_dtos/chest_dips_exercise_dto.dart';
import '../dtos/chest_exercise_dtos/chest_pushUps_exercise_dto.dart';
import '../dtos/exercise_dto.dart';
import '../dtos/leg_exercises_dtos/leg_extension_exercise_dto.dart';
import '../dtos/triceps_exercises_dtos/triceps_pushUps_exercise_dto.dart';

class ExerciseRepository {
  final List<ExerciseDTO> _exercises = [];

  UnmodifiableListView<ExerciseDTO> get exercises => UnmodifiableListView(_exercises);

  void loadExercises() {
    // absExercise();
    // _loadAbductorAdductorExercises();
    // _calvesExercise();
    _loadChestExercises();
    _loadBicepsExercises();
    _loadTricepsExercises();
    //_loadBackExercises();
    _loadQuadricepsExercises();
    _loadHamstringExercises();
    // _loadShouldersExercises();
    // _glutesExercise();

    _exercises.sort((a, b) => a.name.compareTo(b.name));
  }

  void _loadChestExercises() async {
    final benchPressesExercise = BenchPressesExerciseDTO();

    final dipsExercise = ChestDipsExerciseDTO();

    final flyesExercise = ChestFlyesExerciseDTO();

    final pushUpsExercise = ChestPushUpsExerciseDto();

    _exercises.add(benchPressesExercise);
    _exercises.add(dipsExercise);
    _exercises.add(flyesExercise);
    _exercises.add(pushUpsExercise);
  }

  void _loadBicepsExercises() async {
    final bicepsExercise = BicepCurlsExerciseDTO();

    _exercises.add(bicepsExercise);
  }

  void _loadQuadricepsExercises() {
    final squatsExercise = SquatExerciseDTO();

    final lungesExercise = LungesExerciseDTO();

    final legPressExercise = LegPressExerciseDTO();

    final legExtensionsExercise = LegExtensionsExerciseDTO();

    final stepUpsExercise = StepUpsExerciseDTO();

    final splitSquatsExercise = SplitSquatExerciseDTO();

    _exercises.add(squatsExercise);
    _exercises.add(lungesExercise);
    _exercises.add(legPressExercise);
    _exercises.add(legExtensionsExercise);
    _exercises.add(stepUpsExercise);
    _exercises.add(splitSquatsExercise);
  }

  void _loadHamstringExercises() {
    final goodMorningExercise = GoodMorningExerciseDTO();

    final deadliftsExercise = DeadliftsExerciseDTO();

    final legCurlsExercise = LegCurlsExerciseDTO();

    _exercises.add(goodMorningExercise);
    _exercises.add(deadliftsExercise);
    _exercises.add(legCurlsExercise);
  }

  void _loadTricepsExercises() {
    final kickbacksExercise = TricepsKickbacksExerciseDTO();

    final pushDownsExercise = TricepsPushdownsExerciseDTO();

    final pushUpExercise = TricepsPushUpsExerciseDto();

    final dipsExercise = TricepsDipsExerciseDTO();

    final extensionExercise = TricepsExtensionsExerciseDTO();

    _exercises.add(kickbacksExercise);
    _exercises.add(pushDownsExercise);
    _exercises.add(pushUpExercise);
    _exercises.add(dipsExercise);
    _exercises.add(extensionExercise);
  }

  // void _loadBackExercises() {
  //   final rowsExercise = ExerciseDTO(
  //       id: "BAC_01",
  //       name: "Rows",
  //       description: "Targets the lats, traps, and rhomboids.",
  //       metrics: [ExerciseMetric.weights],
  //       modes: [ExerciseModality.bilateral, ExerciseModality.unilateral],
  //       positions: [ExercisePosition.neutral],
  //       stances: [ExerciseStance.standing, ExerciseStance.seated],
  //       equipment: [
  //         ExerciseEquipment.dumbbell,
  //         ExerciseEquipment.cableMachine,
  //         ExerciseEquipment.barbell,
  //         ExerciseEquipment.kettleBell,
  //         ExerciseEquipment.smithMachine,
  //         ExerciseEquipment.tBarHandle
  //       ],
  //       primaryMuscleGroups: [MuscleGroup.back],
  //       movements: [ExerciseMovement.reverse, ExerciseMovement.none],
  //       secondaryMuscleGroups: [MuscleGroup.biceps, MuscleGroup.abs, MuscleGroup.shoulders],
  //       coreMovement: CoreMovement.pull);
  //
  //   final latPullDownsExercise = ExerciseDTO(
  //       id: "BAC_02",
  //       name: "Lat Pulldowns",
  //       description: "Focuses on the lats and upper back, ideal for developing width.",
  //       metrics: [ExerciseMetric.weights],
  //       modes: [ExerciseModality.bilateral, ExerciseModality.unilateral],
  //       positions: [ExercisePosition.neutral],
  //       stances: [ExerciseStance.seated],
  //       equipment: [ExerciseEquipment.cableMachine],
  //       primaryMuscleGroups: [MuscleGroup.back],
  //       movements: [ExerciseMovement.none, ExerciseMovement.reverse],
  //       secondaryMuscleGroups: [MuscleGroup.biceps, MuscleGroup.shoulders],
  //       coreMovement: CoreMovement.pull);
  //
  //   final pullUpsExercise = ExerciseDTO(
  //       id: "BAC_03",
  //       name: "Pull-Ups",
  //       description: "A bodyweight exercise that activates the lats and upper back, promoting overall back strength.",
  //       metrics: [ExerciseMetric.reps, ExerciseMetric.weights],
  //       modes: [ExerciseModality.bilateral, ExerciseModality.unilateral],
  //       positions: [ExercisePosition.neutral],
  //       stances: [ExerciseStance.hanging],
  //       equipment: [
  //         ExerciseEquipment.none,
  //         ExerciseEquipment.plate,
  //         ExerciseEquipment.dumbbell,
  //         ExerciseEquipment.kettleBell,
  //         ExerciseEquipment.assistedMachine,
  //         ExerciseEquipment.band
  //       ],
  //       primaryMuscleGroups: [MuscleGroup.back],
  //       movements: [ExerciseMovement.none, ExerciseMovement.reverse],
  //       secondaryMuscleGroups: [MuscleGroup.biceps, MuscleGroup.shoulders],
  //       coreMovement: CoreMovement.pull);
  //
  //   final hyperExtensionExercise = ExerciseDTO(
  //       id: "BAC_04",
  //       name: "Back Extension",
  //       description: "Targets the lower back and hamstrings with a bodyweight or weighted hyperextension.",
  //       metrics: [ExerciseMetric.reps, ExerciseMetric.weights],
  //       modes: [ExerciseModality.bilateral],
  //       positions: [ExercisePosition.neutral],
  //       stances: [ExerciseStance.lying],
  //       equipment: [ExerciseEquipment.none, ExerciseEquipment.plate],
  //       primaryMuscleGroups: [MuscleGroup.back],
  //       secondaryMuscleGroups: [MuscleGroup.glutes, MuscleGroup.hamstrings, MuscleGroup.abs],
  //       coreMovement: CoreMovement.hinge);
  //
  //   _exercises.add(rowsExercise);
  //   _exercises.add(latPullDownsExercise);
  //   _exercises.add(hyperExtensionExercise);
  //   _exercises.add(pullUpsExercise);
  // }

  // void _loadAbductorAdductorExercises() {
  //   final abductorExercise = ExerciseDTO(
  //       id: "ABD_01",
  //       name: "Hip Abduction",
  //       description: "Activates and strengthens the hip abductors using resistance, focusing on lateral leg movement.",
  //       metrics: [ExerciseMetric.weights],
  //       modes: [ExerciseModality.bilateral],
  //       positions: [ExercisePosition.neutral],
  //       stances: [ExerciseStance.seated],
  //       equipment: [ExerciseEquipment.machine, ExerciseEquipment.band],
  //       primaryMuscleGroups: [MuscleGroup.abductors],
  //       secondaryMuscleGroups: [MuscleGroup.glutes],
  //       coreMovement: CoreMovement.others);
  //
  //   final adductionExercise = ExerciseDTO(
  //       id: "ADD_01",
  //       name: "Hip Adduction",
  //       description:
  //           "Targets the inner thigh muscles, specifically the adductors, to improve leg stability and strength.",
  //       metrics: [ExerciseMetric.reps, ExerciseMetric.weights],
  //       modes: [ExerciseModality.bilateral],
  //       positions: [ExercisePosition.neutral],
  //       stances: [ExerciseStance.seated],
  //       equipment: [ExerciseEquipment.none, ExerciseEquipment.machine, ExerciseEquipment.band],
  //       primaryMuscleGroups: [MuscleGroup.adductors],
  //       coreMovement: CoreMovement.others);
  //
  //   _exercises.add(abductorExercise);
  //   _exercises.add(adductionExercise);
  // }
  //
  // void _loadShouldersExercises() {
  //   final raisesExercise = ExerciseDTO(
  //       id: "SHO_01",
  //       name: "Shoulder Raises",
  //       description: "Targets the front/lateral deltoid muscles to build shoulder size.",
  //       metrics: [ExerciseMetric.weights],
  //       modes: [ExerciseModality.unilateral],
  //       positions: [ExercisePosition.neutral],
  //       stances: [ExerciseStance.standing, ExerciseStance.seated],
  //       equipment: [
  //         ExerciseEquipment.dumbbell,
  //         ExerciseEquipment.cableMachine,
  //         ExerciseEquipment.machine,
  //         ExerciseEquipment.plate,
  //         ExerciseEquipment.kettleBell,
  //         ExerciseEquipment.barbell
  //       ],
  //       primaryMuscleGroups: [MuscleGroup.shoulders],
  //       coreMovement: CoreMovement.push);
  //
  //   final uprightRowExercise = ExerciseDTO(
  //       id: "SHO_02",
  //       name: "Upright Rows",
  //       description: "Works the shoulders and traps for shoulder development.",
  //       metrics: [ExerciseMetric.weights],
  //       modes: [ExerciseModality.bilateral],
  //       positions: [ExercisePosition.neutral],
  //       stances: [ExerciseStance.standing, ExerciseStance.seated],
  //       equipment: [
  //         ExerciseEquipment.barbell,
  //         ExerciseEquipment.dumbbell,
  //         ExerciseEquipment.cableMachine,
  //         ExerciseEquipment.plate,
  //         ExerciseEquipment.kettleBell
  //       ],
  //       primaryMuscleGroups: [MuscleGroup.shoulders],
  //       coreMovement: CoreMovement.push);
  //
  //   final arnoldPressExercise = ExerciseDTO(
  //       id: "SHO_03",
  //       name: "Arnold Press",
  //       description: "A variation of the shoulder press that activates all three heads of the deltoid muscles.",
  //       metrics: [ExerciseMetric.weights],
  //       modes: [ExerciseModality.unilateral],
  //       positions: [ExercisePosition.neutral],
  //       stances: [ExerciseStance.standing, ExerciseStance.seated],
  //       equipment: [ExerciseEquipment.dumbbell, ExerciseEquipment.kettleBell],
  //       primaryMuscleGroups: [MuscleGroup.shoulders],
  //       coreMovement: CoreMovement.push);
  //
  //   final overheadExercise = ExerciseDTO(
  //       id: "SHO_04",
  //       name: "Overhead Press",
  //       description: "Builds overall shoulder strength, also involving the triceps and upper chest.",
  //       metrics: [ExerciseMetric.weights],
  //       modes: [ExerciseModality.bilateral, ExerciseModality.unilateral],
  //       positions: [ExercisePosition.neutral],
  //       stances: [ExerciseStance.standing, ExerciseStance.seated],
  //       equipment: [
  //         ExerciseEquipment.barbell,
  //         ExerciseEquipment.machine,
  //         ExerciseEquipment.dumbbell,
  //         ExerciseEquipment.kettleBell
  //       ],
  //       primaryMuscleGroups: [MuscleGroup.shoulders],
  //       movements: [ExerciseMovement.overhead],
  //       coreMovement: CoreMovement.push);
  //
  //   final flyesExercise = ExerciseDTO(
  //       id: "SHO_05",
  //       name: "Reverse Shoulder Flyes",
  //       description: "Strengthens the rear deltoids and upper back, enhancing posture and shoulder support.",
  //       metrics: [ExerciseMetric.weights],
  //       modes: [ExerciseModality.bilateral, ExerciseModality.unilateral],
  //       positions: [ExercisePosition.neutral],
  //       stances: [ExerciseStance.standing, ExerciseStance.seated],
  //       equipment: [
  //         ExerciseEquipment.cableMachine,
  //         ExerciseEquipment.machine,
  //         ExerciseEquipment.dumbbell,
  //         ExerciseEquipment.kettleBell
  //       ],
  //       primaryMuscleGroups: [MuscleGroup.shoulders],
  //       movements: [ExerciseMovement.reverse],
  //       coreMovement: CoreMovement.push);
  //
  //   final rotationExercise = ExerciseDTO(
  //       id: "SHO_06",
  //       name: "Shoulder Rotations",
  //       description: "Strengthens the rear deltoids and upper back, enhancing posture and shoulder support.",
  //       metrics: [ExerciseMetric.weights],
  //       modes: [ExerciseModality.unilateral],
  //       positions: [ExercisePosition.neutral],
  //       stances: [ExerciseStance.standing, ExerciseStance.seated, ExerciseStance.lying],
  //       equipment: [
  //         ExerciseEquipment.cableMachine,
  //         ExerciseEquipment.machine,
  //         ExerciseEquipment.dumbbell,
  //         ExerciseEquipment.kettleBell
  //       ],
  //       primaryMuscleGroups: [MuscleGroup.shoulders],
  //       movements: [ExerciseMovement.internalRotation, ExerciseMovement.externalRotation],
  //       coreMovement: CoreMovement.push);
  //
  //   final facePullExercise = ExerciseDTO(
  //       id: "SHO_07",
  //       name: "Face Pull",
  //       description: "Improves shoulder health by targeting the rear delts and upper back.",
  //       metrics: [ExerciseMetric.weights],
  //       modes: [ExerciseModality.bilateral],
  //       positions: [ExercisePosition.neutral],
  //       stances: [ExerciseStance.standing, ExerciseStance.seated],
  //       equipment: [ExerciseEquipment.cableMachine, ExerciseEquipment.band],
  //       primaryMuscleGroups: [MuscleGroup.shoulders],
  //       coreMovement: CoreMovement.pull);
  //
  //   _exercises.add(raisesExercise);
  //   _exercises.add(uprightRowExercise);
  //   _exercises.add(arnoldPressExercise);
  //   _exercises.add(overheadExercise);
  //   _exercises.add(flyesExercise);
  //   _exercises.add(rotationExercise);
  //   _exercises.add(facePullExercise);
  // }
  //
  // void _glutesExercise() {
  //   final gluteBridgeExercise = ExerciseDTO(
  //       id: "GLU_01",
  //       name: "Glute Bridge",
  //       description: "Strengthens the glutes during a hip-lifting movement.",
  //       metrics: [ExerciseMetric.reps, ExerciseMetric.weights],
  //       modes: [ExerciseModality.bilateral, ExerciseModality.unilateral],
  //       positions: [ExercisePosition.neutral],
  //       stances: [ExerciseStance.lying],
  //       equipment: [
  //         ExerciseEquipment.none,
  //         ExerciseEquipment.dumbbell,
  //         ExerciseEquipment.plate,
  //         ExerciseEquipment.kettleBell,
  //         ExerciseEquipment.barbell
  //       ],
  //       primaryMuscleGroups: [MuscleGroup.glutes],
  //       secondaryMuscleGroups: [MuscleGroup.hamstrings, MuscleGroup.back],
  //       coreMovement: CoreMovement.others);
  //
  //   final hipThrustExercise = ExerciseDTO(
  //       id: "GLU_02",
  //       name: "Hip Thrust",
  //       description: "Targets the gluteus maximus for strength and size through hip extension.",
  //       metrics: [ExerciseMetric.reps, ExerciseMetric.weights],
  //       modes: [ExerciseModality.bilateral, ExerciseModality.unilateral],
  //       positions: [ExercisePosition.neutral],
  //       stances: [ExerciseStance.lying],
  //       equipment: [
  //         ExerciseEquipment.barbell,
  //         ExerciseEquipment.dumbbell,
  //         ExerciseEquipment.plate,
  //         ExerciseEquipment.kettleBell,
  //         ExerciseEquipment.smithMachine,
  //         ExerciseEquipment.machine
  //       ],
  //       primaryMuscleGroups: [MuscleGroup.glutes],
  //       secondaryMuscleGroups: [
  //         MuscleGroup.hamstrings,
  //         MuscleGroup.quadriceps,
  //         MuscleGroup.adductors,
  //         MuscleGroup.back
  //       ],
  //       coreMovement: CoreMovement.hinge);
  //
  //   final kickBacksExercise = ExerciseDTO(
  //       id: "GLU_03",
  //       name: "Glute Kickbacks",
  //       description: "Bodyweight exercise that isolates the glutes with a backward kicking motion.",
  //       metrics: [ExerciseMetric.reps, ExerciseMetric.weights],
  //       modes: [ExerciseModality.unilateral],
  //       positions: [ExercisePosition.neutral],
  //       stances: [ExerciseStance.kneeling, ExerciseStance.standing],
  //       equipment: [
  //         ExerciseEquipment.none,
  //         ExerciseEquipment.cableMachine,
  //         ExerciseEquipment.machine,
  //         ExerciseEquipment.band,
  //       ],
  //       primaryMuscleGroups: [MuscleGroup.glutes],
  //       secondaryMuscleGroups: [
  //         MuscleGroup.hamstrings,
  //         MuscleGroup.quadriceps,
  //         MuscleGroup.adductors,
  //         MuscleGroup.back
  //       ],
  //       coreMovement: CoreMovement.others);
  //
  //   final pullThroughsExercise = ExerciseDTO(
  //       id: "GLU_04",
  //       name: "Pull Throughs",
  //       description: "Engages the glutes and hamstrings while focusing on hip hinge movement.",
  //       metrics: [ExerciseMetric.reps, ExerciseMetric.weights],
  //       modes: [ExerciseModality.bilateral],
  //       positions: [ExercisePosition.neutral],
  //       stances: [ExerciseStance.standing],
  //       equipment: [ExerciseEquipment.band, ExerciseEquipment.cableMachine],
  //       primaryMuscleGroups: [MuscleGroup.glutes],
  //       secondaryMuscleGroups: [MuscleGroup.hamstrings, MuscleGroup.adductors, MuscleGroup.back],
  //       coreMovement: CoreMovement.hinge);
  //
  //   _exercises.add(gluteBridgeExercise);
  //   _exercises.add(hipThrustExercise);
  //   _exercises.add(kickBacksExercise);
  //   _exercises.add(pullThroughsExercise);
  // }
  //
  // void absExercise() {
  //   final planksExercise = ExerciseDTO(
  //       id: "ABS_01",
  //       name: "Planks",
  //       description: "Strengthens the core by holding a static plank position, engaging the entire midsection.",
  //       metrics: [ExerciseMetric.duration],
  //       modes: [ExerciseModality.bilateral, ExerciseModality.unilateral],
  //       positions: [ExercisePosition.neutral],
  //       stances: [ExerciseStance.lying, ExerciseStance.kneeling],
  //       equipment: [ExerciseEquipment.none, ExerciseEquipment.plate],
  //       movements: [ExerciseMovement.none, ExerciseMovement.reverse],
  //       primaryMuscleGroups: [MuscleGroup.abs],
  //       coreMovement: CoreMovement.others);
  //
  //   final crunchesExercise = ExerciseDTO(
  //       id: "ABS_02",
  //       name: "Crunches",
  //       description: "Targets the upper abs in a crunching motion.",
  //       metrics: [ExerciseMetric.reps, ExerciseMetric.weights],
  //       modes: [ExerciseModality.bilateral],
  //       positions: [ExercisePosition.neutral, ExercisePosition.decline],
  //       stances: [ExerciseStance.lying],
  //       movements: [ExerciseMovement.none, ExerciseMovement.reverse],
  //       equipment: [
  //         ExerciseEquipment.none,
  //         ExerciseEquipment.machine,
  //         ExerciseEquipment.cableMachine,
  //         ExerciseEquipment.plate,
  //         ExerciseEquipment.dumbbell,
  //         ExerciseEquipment.kettleBell
  //       ],
  //       primaryMuscleGroups: [MuscleGroup.abs],
  //       coreMovement: CoreMovement.others);
  //
  //   final legRaisesExercise = ExerciseDTO(
  //       id: "ABS_03",
  //       name: "Leg Raises",
  //       description: "Targets the lower abs by lifting the legs while suspended.",
  //       metrics: [ExerciseMetric.reps, ExerciseMetric.weights],
  //       modes: [ExerciseModality.bilateral],
  //       positions: [ExercisePosition.neutral],
  //       stances: [ExerciseStance.lying, ExerciseStance.hanging],
  //       movements: [ExerciseMovement.none, ExerciseMovement.reverse],
  //       equipment: [
  //         ExerciseEquipment.none,
  //         ExerciseEquipment.machine,
  //         ExerciseEquipment.cableMachine,
  //         ExerciseEquipment.plate,
  //         ExerciseEquipment.dumbbell,
  //         ExerciseEquipment.kettleBell
  //       ],
  //       primaryMuscleGroups: [MuscleGroup.abs],
  //       coreMovement: CoreMovement.hinge);
  //
  //   _exercises.add(planksExercise);
  //   _exercises.add(crunchesExercise);
  //   _exercises.add(legRaisesExercise);
  // }
  //
  // void _calvesExercise() {
  //   final calfRaisesExercise = ExerciseDTO(
  //       id: "CAL_01",
  //       name: "Calf Raises",
  //       description: "Strengthens the calf muscles by raising the heels from a standing position.",
  //       metrics: [ExerciseMetric.reps, ExerciseMetric.weights],
  //       modes: [ExerciseModality.bilateral, ExerciseModality.unilateral],
  //       positions: [ExercisePosition.neutral],
  //       stances: [ExerciseStance.standing, ExerciseStance.seated],
  //       equipment: [ExerciseEquipment.none, ExerciseEquipment.plate, ExerciseEquipment.dumbbell, ExerciseEquipment.machine],
  //       primaryMuscleGroups: [MuscleGroup.calves],
  //       coreMovement: CoreMovement.others);
  //
  //   final jumpRopeExercise = ExerciseDTO(
  //       id: "CAL_02",
  //       name: "Jump Rope",
  //       description:
  //           "Engages the calves through repetitive jumping motions, building strength, endurance, and coordination while improving overall lower-body mobility and agility.",
  //       metrics: [ExerciseMetric.reps, ExerciseMetric.weights],
  //       modes: [ExerciseModality.bilateral, ExerciseModality.unilateral],
  //       positions: [ExercisePosition.neutral],
  //       stances: [ExerciseStance.standing],
  //       equipment: [ExerciseEquipment.rope],
  //       primaryMuscleGroups: [MuscleGroup.calves],
  //       coreMovement: CoreMovement.others);
  //
  //   _exercises.add(calfRaisesExercise);
  //   _exercises.add(jumpRopeExercise);
  // }

  /// Helper methods

  ExerciseDTO whereExercise({required String id}) {
    return exercises.firstWhere((exercise) => exercise.id == id);
  }

  void clear() {
    _exercises.clear();
  }
}
