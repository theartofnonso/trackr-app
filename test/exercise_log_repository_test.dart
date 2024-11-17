import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_app/dtos/exercise_dto.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/enums/exercise/exercise_metrics_enums.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/enums/routine_editor_type_enums.dart';
import 'package:tracker_app/repositories/exercise_log_repository.dart';

void main() {

  final lyingLegCurlExercise = ExerciseDTO(
      name: "Lying Leg Curl",
      primaryMuscleGroupss: MuscleGroup.hamstrings,
      secondaryMuscleGroups: [MuscleGroup.hamstrings],
      exerciseMetric: ExerciseMetric.weights,
      owner: "");

  final plankExercise = ExerciseDTO(
      type: "id_plankExercise",
      name: "Plank",
      primaryMuscleGroupss: MuscleGroup.abs,
      secondaryMuscleGroups: [MuscleGroup.hamstrings],
      metric: ExerciseMetric.duration,
      owner: "");

  final benchPressExercise = ExerciseDTO(
      name: "Bench Press",
      primaryMuscleGroups: MuscleGroup.chest,
      secondaryMuscleGroups: [MuscleGroup.hamstrings],
      exerciseMetric: ExerciseMetric.weights,
      owner: "");

  final lyingLegCurlExerciseLog1 = ExerciseLogDTO(
      lyingLegCurlExercise.name,
      "routineLogId1",
      "superSetId",
      lyingLegCurlExercise,
      "notes",
      [
        const SetDto(80, 15, true),
        const SetDto(100, 8, true),
        const SetDto(100, 6, true),
      ],
      DateTime(2023, 12, 1), []);

  final plankExerciseLog1 = ExerciseLogDTO(
      plankExercise.type,
      "routineLogId1",
      "superSetId",
      plankExercise,
      "notes",
      [
        const SetDto(120000, 0, true),
        const SetDto(180000, 0, true),
        const SetDto(150000, 0, true),
      ],
      DateTime.now(), []);

  final benchPressExerciseLog1 = ExerciseLogDTO(
      benchPressExercise.type,
      "routineLogId1",
      "superSetId",
      benchPressExercise,
      "notes",
      [
        const SetDto(80, 15, true),
        const SetDto(100, 8, true),
        const SetDto(100, 6, true),
      ],
      DateTime(2023, 12, 1), []);

  test("Load Exercise Logs", () {
    final exerciseLogRepository = ExerciseLogRepository();

    exerciseLogRepository.loadExerciseLogs(
        exerciseLogs: [lyingLegCurlExerciseLog1, plankExerciseLog1, benchPressExerciseLog1], mode: RoutineEditorMode.log);

    expect(exerciseLogRepository.exerciseLogs.length, 3);
  });

  test("Check sets for [Exercise.Duration] in [RoutineEditorMode.log]", () {

    final exerciseLogRepository = ExerciseLogRepository();

    exerciseLogRepository.loadExerciseLogs(
        exerciseLogs: [lyingLegCurlExerciseLog1, plankExerciseLog1, benchPressExerciseLog1], mode: RoutineEditorMode.log);

    final checkedSets = lyingLegCurlExerciseLog1.sets.where((set) => set.checked == true);

    expect(checkedSets.length, 3);
  });

  test("Remove Exercise Log", () {
    final exerciseLogRepository = ExerciseLogRepository();

    exerciseLogRepository.loadExerciseLogs(
        exerciseLogs: [lyingLegCurlExerciseLog1, plankExerciseLog1, benchPressExerciseLog1], mode: RoutineEditorMode.log);

    exerciseLogRepository.removeExerciseLog(exerciseName: lyingLegCurlExerciseLog1.type);

    expect(exerciseLogRepository.exerciseLogs.length, 2);

    expect(exerciseLogRepository.exerciseLogs.firstWhereOrNull((log) => log.type == lyingLegCurlExerciseLog1.type), null);

  });

  test("Update Exercise Log notes", () {
    final exerciseLogRepository = ExerciseLogRepository();

    exerciseLogRepository.loadExerciseLogs(
        exerciseLogs: [lyingLegCurlExerciseLog1, plankExerciseLog1, benchPressExerciseLog1], mode: RoutineEditorMode.log);

    exerciseLogRepository.updateExerciseLogNotes(exerciseName: plankExerciseLog1.type, value: 'This works your core');

    expect(exerciseLogRepository.exerciseLogs.firstWhereOrNull((log) => log.type == plankExerciseLog1.type)?.notes,
        'This works your core');
  });

  test("Super set Exercise Logs", () {
    final exerciseLogRepository = ExerciseLogRepository();

    exerciseLogRepository.loadExerciseLogs(
        exerciseLogs: [lyingLegCurlExerciseLog1, plankExerciseLog1, benchPressExerciseLog1], mode: RoutineEditorMode.log);

    exerciseLogRepository.addSuperSets(
        firstExerciseName: lyingLegCurlExerciseLog1.type,
        secondExerciseName: benchPressExerciseLog1.type,
        superSetId: "superset_id_${lyingLegCurlExerciseLog1.exerciseVariant.type}_${benchPressExerciseLog1.exerciseVariant.type}");

    expect(
        exerciseLogRepository.exerciseLogs.firstWhereOrNull((log) => log.type == lyingLegCurlExerciseLog1.type)?.superSetId,
        "superset_id_${lyingLegCurlExerciseLog1.exerciseVariant.type}_${benchPressExerciseLog1.exerciseVariant.type}");

    expect(
        exerciseLogRepository.exerciseLogs.firstWhereOrNull((log) => log.type == benchPressExerciseLog1.type)?.superSetId,
        "superset_id_${lyingLegCurlExerciseLog1.exerciseVariant.type}_${benchPressExerciseLog1.exerciseVariant.type}");
  });

  test("Remove Super set Exercise Logs", () {
    final exerciseLogRepository = ExerciseLogRepository();

    exerciseLogRepository.loadExerciseLogs(
        exerciseLogs: [lyingLegCurlExerciseLog1, plankExerciseLog1, benchPressExerciseLog1], mode: RoutineEditorMode.log);

    exerciseLogRepository.addSuperSets(
        firstExerciseName: lyingLegCurlExerciseLog1.type,
        secondExerciseName: benchPressExerciseLog1.type,
        superSetId: "superset_id_${lyingLegCurlExerciseLog1.exerciseVariant.type}_${benchPressExerciseLog1.exerciseVariant.type}");

    exerciseLogRepository.removeSuperSet(
        superSetId: "superset_id_${lyingLegCurlExerciseLog1.exerciseVariant.type}_${benchPressExerciseLog1.exerciseVariant.type}");

    expect(
        exerciseLogRepository.exerciseLogs.firstWhereOrNull((log) => log.type == lyingLegCurlExerciseLog1.type)?.superSetId,
        "");

    expect(
        exerciseLogRepository.exerciseLogs.firstWhereOrNull((log) => log.type == benchPressExerciseLog1.type)?.superSetId,
        "");
  });

  test("Add new set", () {
    final exerciseLogRepository = ExerciseLogRepository();

    exerciseLogRepository.loadExerciseLogs(
        exerciseLogs: [lyingLegCurlExerciseLog1, plankExerciseLog1, benchPressExerciseLog1], mode: RoutineEditorMode.log);

    exerciseLogRepository.addSet(exerciseName: lyingLegCurlExerciseLog1.type, pastSets: lyingLegCurlExerciseLog1.sets);

    final newLength = lyingLegCurlExerciseLog1.sets.length;

    expect(lyingLegCurlExerciseLog1.sets.length, newLength);
  });

  test("Remove set", () {
    final exerciseLogRepository = ExerciseLogRepository();

    exerciseLogRepository.loadExerciseLogs(
        exerciseLogs: [lyingLegCurlExerciseLog1, plankExerciseLog1, benchPressExerciseLog1], mode: RoutineEditorMode.log);

    exerciseLogRepository.removeSet(exerciseName: lyingLegCurlExerciseLog1.type, index: 1);

    final newLength = lyingLegCurlExerciseLog1.sets.length;

    expect(lyingLegCurlExerciseLog1.sets.length, newLength);

    expect(lyingLegCurlExerciseLog1.sets[1], const SetDto(100, 6, true));
  });

  test("Update weight (Value 1)", () {
    final exerciseLogRepository = ExerciseLogRepository();

    exerciseLogRepository.loadExerciseLogs(
        exerciseLogs: [lyingLegCurlExerciseLog1, plankExerciseLog1, benchPressExerciseLog1], mode: RoutineEditorMode.log);

    exerciseLogRepository.updateWeight(
        exerciseLogId: lyingLegCurlExerciseLog1.type, index: 0, setDto: const SetDto(90, 15, false));

    expect(lyingLegCurlExerciseLog1.sets[0].value1, 90);
  });

  test("Update reps (Value 2)", () {
    final exerciseLogRepository = ExerciseLogRepository();

    exerciseLogRepository.loadExerciseLogs(
        exerciseLogs: [lyingLegCurlExerciseLog1, plankExerciseLog1, benchPressExerciseLog1], mode: RoutineEditorMode.log);

    exerciseLogRepository.updateWeight(
        exerciseLogId: lyingLegCurlExerciseLog1.type, index: 0, setDto: const SetDto(80, 25, false));

    expect(lyingLegCurlExerciseLog1.sets[0].value2, 25);
  });

  test("Update check", () {
    final exerciseLogRepository = ExerciseLogRepository();

    exerciseLogRepository.loadExerciseLogs(
        exerciseLogs: [lyingLegCurlExerciseLog1, plankExerciseLog1, benchPressExerciseLog1], mode: RoutineEditorMode.log);

    exerciseLogRepository.updateSetCheck(
        exerciseLogId: lyingLegCurlExerciseLog1.type, index: 0, setDto: const SetDto(80, 25, true));

    expect(lyingLegCurlExerciseLog1.sets[0].checked, true);
  });

  test("Merge exercise and sets", () {
    final exerciseLogRepository = ExerciseLogRepository();

    exerciseLogRepository.loadExerciseLogs(
        exerciseLogs: [lyingLegCurlExerciseLog1, plankExerciseLog1, benchPressExerciseLog1], mode: RoutineEditorMode.log);

    final mergedLogs = exerciseLogRepository.mergeExerciseLogsAndSets();

    expect(mergedLogs.expand((element) => element.sets).length, 9);
  });

  test("All [ExerciseType.duration] sets must be checked when merging", () {
    final exerciseLogRepository = ExerciseLogRepository();

    final plankExerciseLog1 = ExerciseLogDTO(
        plankExercise.type,
        "routineLogId1",
        "superSetId",
        plankExercise,
        "notes",
        [],
        DateTime.now(), []);

    exerciseLogRepository.loadExerciseLogs(
        exerciseLogs: [lyingLegCurlExerciseLog1, plankExerciseLog1, benchPressExerciseLog1], mode: RoutineEditorMode.log);

    exerciseLogRepository.addSet(exerciseName: plankExerciseLog1.type, pastSets: []);
    exerciseLogRepository.addSet(exerciseName: plankExerciseLog1.type, pastSets: []);

    exerciseLogRepository.updateDuration(
        exerciseLogId: plankExerciseLog1.type, index: 0, setDto: const SetDto(120000, 0, false));
    exerciseLogRepository.updateDuration(
        exerciseLogId: plankExerciseLog1.type, index: 1, setDto: const SetDto(100000, 0, false));

    final mergedLogs = exerciseLogRepository.mergeExerciseLogsAndSets();

    final plankLog = mergedLogs.firstWhereOrNull((log) => log.type == plankExerciseLog1.type);

    final allChecked = plankLog?.sets.where((set) => set.checked == true);

    expect(allChecked?.length, 2);
  });

  test("Clear Controller", () {
    final exerciseLogRepository = ExerciseLogRepository();

    exerciseLogRepository.loadExerciseLogs(
        exerciseLogs: [lyingLegCurlExerciseLog1, plankExerciseLog1, benchPressExerciseLog1], mode: RoutineEditorMode.log);

    exerciseLogRepository.clear();

    expect(exerciseLogRepository.exerciseLogs.length, 0);
  });
}
