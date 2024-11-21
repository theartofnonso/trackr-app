import 'package:collection/collection.dart';
import 'package:tracker_app/dtos/exercises/abs_exercises_dtos/leg_raises_exercise_dto.dart';
import 'package:tracker_app/dtos/exercises/glutes_exercises_dtos/hip_thrust_exercise_dto.dart';
import 'package:tracker_app/dtos/exercises/glutes_exercises_dtos/pull_throughs_exercise_dto.dart';

import '../dtos/abstract_class/exercise_dto.dart';
import '../dtos/exercises/abductor_adduction_exercises_dtos/abductor_exercise_dto.dart';
import '../dtos/exercises/abductor_adduction_exercises_dtos/adductor_exercise_dto.dart';
import '../dtos/exercises/abs_exercises_dtos/crunches_exercise_dto.dart';
import '../dtos/exercises/abs_exercises_dtos/knee_raises_exercise_dto.dart';
import '../dtos/exercises/abs_exercises_dtos/plank_exercise_dto.dart';
import '../dtos/exercises/back_exercises_dtos/back_extension_exercise_dto.dart';
import '../dtos/exercises/back_exercises_dtos/back_rows_exercise_dto.dart';
import '../dtos/exercises/back_exercises_dtos/pulldown_exercise_dto.dart';
import '../dtos/exercises/back_exercises_dtos/pullup_exercise_dto.dart';
import '../dtos/exercises/biceps_exercises_dtos/bicep_curls_exercise_dto.dart';
import '../dtos/exercises/calves/calf_raises_exercise_dto.dart';
import '../dtos/exercises/calves/jump_rope_exercise_dto.dart';
import '../dtos/exercises/chest_exercise_dtos/bench_presses_exercise_dto.dart';
import '../dtos/exercises/chest_exercise_dtos/chest_dips_exercise_dto.dart';
import '../dtos/exercises/chest_exercise_dtos/chest_flys_exercise_dto.dart';
import '../dtos/exercises/chest_exercise_dtos/chest_pushUps_exercise_dto.dart';
import '../dtos/exercises/glutes_exercises_dtos/glute_bridge_exercise_dto.dart';
import '../dtos/exercises/glutes_exercises_dtos/kickbacks_exercise_dto.dart';
import '../dtos/exercises/hamstrings_exercises_dtos/deadlifts_exercise_dto.dart';
import '../dtos/exercises/hamstrings_exercises_dtos/good_morning_exercise_dto.dart';
import '../dtos/exercises/hamstrings_exercises_dtos/leg_curls_exercise_dto.dart';
import '../dtos/exercises/quadriceps_exercises_dtos/leg_extension_exercise_dto.dart';
import '../dtos/exercises/quadriceps_exercises_dtos/leg_press_exercise_dto.dart';
import '../dtos/exercises/quadriceps_exercises_dtos/lunges_exercise_dto.dart';
import '../dtos/exercises/quadriceps_exercises_dtos/split_squat_exercise_dto.dart';
import '../dtos/exercises/quadriceps_exercises_dtos/squat_exercise_dto.dart';
import '../dtos/exercises/quadriceps_exercises_dtos/step_ups_exercise_dto.dart';
import '../dtos/exercises/shoulder_exercises_dtos/face_pulls_exercise_dto.dart';
import '../dtos/exercises/shoulder_exercises_dtos/shoulder_flys_exercise_dto.dart';
import '../dtos/exercises/shoulder_exercises_dtos/shoulder_presses_exercise_dto.dart';
import '../dtos/exercises/shoulder_exercises_dtos/shoulder_raises_exercise_dto.dart';
import '../dtos/exercises/shoulder_exercises_dtos/shoulder_rotations_exercise_dto.dart';
import '../dtos/exercises/shoulder_exercises_dtos/upright_rows_exercise_dto.dart';
import '../dtos/exercises/triceps_exercises_dtos/triceps_dips_exercise_dto.dart';
import '../dtos/exercises/triceps_exercises_dtos/triceps_extensions_exercise_dto.dart';
import '../dtos/exercises/triceps_exercises_dtos/triceps_kickbacks_exercise_dto.dart';
import '../dtos/exercises/triceps_exercises_dtos/triceps_pushUps_exercise_dto.dart';
import '../dtos/exercises/triceps_exercises_dtos/triceps_pushdowns_exercise_dto.dart';

class ExerciseRepository {
  final List<ExerciseDTO> _exercises = [];

  UnmodifiableListView<ExerciseDTO> get exercises => UnmodifiableListView(_exercises);

  void loadExercises() {
    _absExercise();
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
    final benchPressesExercise = BenchPressesExerciseDTO();

    final dipsExercise = ChestDipsExerciseDTO();

    final flyesExercise = ChestFlysExerciseDTO();

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

  void _loadBackExercises() {
    final rowsExercise = RowsExerciseDTO();

    final latPullDownsExercise = PulldownExerciseDTO();

    final pullUpsExercise = PullUpsExerciseDTO();

    final hyperExtensionExercise = BackExtensionExerciseDTO();

    _exercises.add(rowsExercise);
    _exercises.add(latPullDownsExercise);
    _exercises.add(hyperExtensionExercise);
    _exercises.add(pullUpsExercise);
  }

  void _loadAbductorAdductorExercises() {
    final abductorExercise = AbductorExerciseDTO();

    final adductionExercise = AdductorExerciseDTO();

    _exercises.add(abductorExercise);
    _exercises.add(adductionExercise);
  }

  void _loadShouldersExercises() {
    final raisesExercise = ShoulderRaisesExerciseDTO();

    final uprightRowExercise = UprightRowsExerciseDto();

    final shoulderPressExercise = ShoulderPressesExerciseDTO();

    final flysExercise = ShoulderFlysExerciseDTO();

    final rotationExercise = ShoulderRotationsExerciseDTO();

    final facePullExercise = FacePullsExerciseDto();

    _exercises.add(raisesExercise);
    _exercises.add(uprightRowExercise);
    _exercises.add(shoulderPressExercise);
    _exercises.add(flysExercise);
    _exercises.add(rotationExercise);
    _exercises.add(facePullExercise);
  }

  void _glutesExercise() {
    final gluteBridgeExercise = GluteBridgeExerciseDTO();

    final hipThrustExercise = HipThrustsExerciseDto();

    final kickBacksExercise = GluteKickBacksExerciseDTO();

    final pullThroughsExercise = PullThroughsExerciseDto();

    _exercises.add(gluteBridgeExercise);
    _exercises.add(hipThrustExercise);
    _exercises.add(kickBacksExercise);
    _exercises.add(pullThroughsExercise);
  }

  void _absExercise() {
    final planksExercise = PlanksExerciseDTO();

    final crunchesExercise = CrunchesExerciseDto();

    final legRaisesExercise = LegRaisesExerciseDto();

    final kneeRaisesExercise = KneeRaisesExerciseDto();

    _exercises.add(planksExercise);
    _exercises.add(crunchesExercise);
    _exercises.add(legRaisesExercise);
    _exercises.add(kneeRaisesExercise);
  }

  void _calvesExercise() {
    final calfRaisesExercise = CalfRaisesExerciseDTO();

    final jumpRopeExercise = JumpRopeExerciseDto();

    _exercises.add(calfRaisesExercise);
    _exercises.add(jumpRopeExercise);
  }

  /// Helper methods

  ExerciseDTO whereExercise({required String id}) {
    return exercises.firstWhere((exercise) => exercise.id == id);
  }

  void clear() {
    _exercises.clear();
  }
}
