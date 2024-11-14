import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_app/dtos/appsync/exercise_dto.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/enums/routine_editor_type_enums.dart';
import 'package:tracker_app/repositories/exercise_log_repository.dart';

void main() {

  final lyingLegCurlExercise = ExerciseDto(
      id: "id_lyingLegCurlExercise",
      name: "Lying Leg Curl",
      primaryMuscleGroup: MuscleGroup.hamstrings,
      secondaryMuscleGroups: [MuscleGroup.hamstrings],
      type: ExerciseType.weights,
      owner: "");

  final plankExercise = ExerciseDto(
      id: "id_plankExercise",
      name: "Plank",
      primaryMuscleGroup: MuscleGroup.abs,
      secondaryMuscleGroups: [MuscleGroup.hamstrings],
      type: ExerciseType.duration,
      owner: "");

  final benchPressExercise = ExerciseDto(
      id: "id_benchPressExercise",
      name: "Bench Press",
      primaryMuscleGroup: MuscleGroup.chest,
      secondaryMuscleGroups: [MuscleGroup.hamstrings],
      type: ExerciseType.weights,
      owner: "");

  final lyingLegCurlExerciseLog1 = ExerciseLogDto(
      lyingLegCurlExercise.id,
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

  final plankExerciseLog1 = ExerciseLogDto(
      plankExercise.id,
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

  final benchPressExerciseLog1 = ExerciseLogDto(
      benchPressExercise.id,
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

    exerciseLogRepository.removeExerciseLog(logId: lyingLegCurlExerciseLog1.id);

    expect(exerciseLogRepository.exerciseLogs.length, 2);

    expect(exerciseLogRepository.exerciseLogs.firstWhereOrNull((log) => log.id == lyingLegCurlExerciseLog1.id), null);

  });

  test("Update Exercise Log notes", () {
    final exerciseLogRepository = ExerciseLogRepository();

    exerciseLogRepository.loadExerciseLogs(
        exerciseLogs: [lyingLegCurlExerciseLog1, plankExerciseLog1, benchPressExerciseLog1], mode: RoutineEditorMode.log);

    exerciseLogRepository.updateExerciseLogNotes(exerciseLogId: plankExerciseLog1.id, value: 'This works your core');

    expect(exerciseLogRepository.exerciseLogs.firstWhereOrNull((log) => log.id == plankExerciseLog1.id)?.notes,
        'This works your core');
  });

  test("Super set Exercise Logs", () {
    final exerciseLogRepository = ExerciseLogRepository();

    exerciseLogRepository.loadExerciseLogs(
        exerciseLogs: [lyingLegCurlExerciseLog1, plankExerciseLog1, benchPressExerciseLog1], mode: RoutineEditorMode.log);

    exerciseLogRepository.addSuperSets(
        firstExerciseLogId: lyingLegCurlExerciseLog1.id,
        secondExerciseLogId: benchPressExerciseLog1.id,
        superSetId: "superset_id_${lyingLegCurlExerciseLog1.exercise.id}_${benchPressExerciseLog1.exercise.id}");

    expect(
        exerciseLogRepository.exerciseLogs.firstWhereOrNull((log) => log.id == lyingLegCurlExerciseLog1.id)?.superSetId,
        "superset_id_${lyingLegCurlExerciseLog1.exercise.id}_${benchPressExerciseLog1.exercise.id}");

    expect(
        exerciseLogRepository.exerciseLogs.firstWhereOrNull((log) => log.id == benchPressExerciseLog1.id)?.superSetId,
        "superset_id_${lyingLegCurlExerciseLog1.exercise.id}_${benchPressExerciseLog1.exercise.id}");
  });

  test("Remove Super set Exercise Logs", () {
    final exerciseLogRepository = ExerciseLogRepository();

    exerciseLogRepository.loadExerciseLogs(
        exerciseLogs: [lyingLegCurlExerciseLog1, plankExerciseLog1, benchPressExerciseLog1], mode: RoutineEditorMode.log);

    exerciseLogRepository.addSuperSets(
        firstExerciseLogId: lyingLegCurlExerciseLog1.id,
        secondExerciseLogId: benchPressExerciseLog1.id,
        superSetId: "superset_id_${lyingLegCurlExerciseLog1.exercise.id}_${benchPressExerciseLog1.exercise.id}");

    exerciseLogRepository.removeSuperSet(
        superSetId: "superset_id_${lyingLegCurlExerciseLog1.exercise.id}_${benchPressExerciseLog1.exercise.id}");

    expect(
        exerciseLogRepository.exerciseLogs.firstWhereOrNull((log) => log.id == lyingLegCurlExerciseLog1.id)?.superSetId,
        "");

    expect(
        exerciseLogRepository.exerciseLogs.firstWhereOrNull((log) => log.id == benchPressExerciseLog1.id)?.superSetId,
        "");
  });

  test("Add new set", () {
    final exerciseLogRepository = ExerciseLogRepository();

    exerciseLogRepository.loadExerciseLogs(
        exerciseLogs: [lyingLegCurlExerciseLog1, plankExerciseLog1, benchPressExerciseLog1], mode: RoutineEditorMode.log);

    exerciseLogRepository.addSet(exerciseLogId: lyingLegCurlExerciseLog1.id, pastSets: lyingLegCurlExerciseLog1.sets);

    final newLength = lyingLegCurlExerciseLog1.sets.length;

    expect(lyingLegCurlExerciseLog1.sets.length, newLength);
  });

  test("Remove set", () {
    final exerciseLogRepository = ExerciseLogRepository();

    exerciseLogRepository.loadExerciseLogs(
        exerciseLogs: [lyingLegCurlExerciseLog1, plankExerciseLog1, benchPressExerciseLog1], mode: RoutineEditorMode.log);

    exerciseLogRepository.removeSet(exerciseLogId: lyingLegCurlExerciseLog1.id, index: 1);

    final newLength = lyingLegCurlExerciseLog1.sets.length;

    expect(lyingLegCurlExerciseLog1.sets.length, newLength);

    expect(lyingLegCurlExerciseLog1.sets[1], const SetDto(100, 6, true));
  });

  test("Update weight (Value 1)", () {
    final exerciseLogRepository = ExerciseLogRepository();

    exerciseLogRepository.loadExerciseLogs(
        exerciseLogs: [lyingLegCurlExerciseLog1, plankExerciseLog1, benchPressExerciseLog1], mode: RoutineEditorMode.log);

    exerciseLogRepository.updateWeight(
        exerciseLogId: lyingLegCurlExerciseLog1.id, index: 0, setDto: const SetDto(90, 15, false));

    expect(lyingLegCurlExerciseLog1.sets[0].value1, 90);
  });

  test("Update reps (Value 2)", () {
    final exerciseLogRepository = ExerciseLogRepository();

    exerciseLogRepository.loadExerciseLogs(
        exerciseLogs: [lyingLegCurlExerciseLog1, plankExerciseLog1, benchPressExerciseLog1], mode: RoutineEditorMode.log);

    exerciseLogRepository.updateWeight(
        exerciseLogId: lyingLegCurlExerciseLog1.id, index: 0, setDto: const SetDto(80, 25, false));

    expect(lyingLegCurlExerciseLog1.sets[0].value2, 25);
  });

  test("Update check", () {
    final exerciseLogRepository = ExerciseLogRepository();

    exerciseLogRepository.loadExerciseLogs(
        exerciseLogs: [lyingLegCurlExerciseLog1, plankExerciseLog1, benchPressExerciseLog1], mode: RoutineEditorMode.log);

    exerciseLogRepository.updateSetCheck(
        exerciseLogId: lyingLegCurlExerciseLog1.id, index: 0, setDto: const SetDto(80, 25, true));

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

    final plankExerciseLog1 = ExerciseLogDto(
        plankExercise.id,
        "routineLogId1",
        "superSetId",
        plankExercise,
        "notes",
        [],
        DateTime.now(), []);

    exerciseLogRepository.loadExerciseLogs(
        exerciseLogs: [lyingLegCurlExerciseLog1, plankExerciseLog1, benchPressExerciseLog1], mode: RoutineEditorMode.log);

    exerciseLogRepository.addSet(exerciseLogId: plankExerciseLog1.id, pastSets: []);
    exerciseLogRepository.addSet(exerciseLogId: plankExerciseLog1.id, pastSets: []);

    exerciseLogRepository.updateDuration(
        exerciseLogId: plankExerciseLog1.id, index: 0, setDto: const SetDto(120000, 0, false));
    exerciseLogRepository.updateDuration(
        exerciseLogId: plankExerciseLog1.id, index: 1, setDto: const SetDto(100000, 0, false));

    final mergedLogs = exerciseLogRepository.mergeExerciseLogsAndSets();

    final plankLog = mergedLogs.firstWhereOrNull((log) => log.id == plankExerciseLog1.id);

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
