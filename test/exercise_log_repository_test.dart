import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_app/dtos/appsync/exercise_dto.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/dtos/set_dtos/duration_set_dto.dart';
import 'package:tracker_app/dtos/set_dtos/weight_and_reps_dto.dart';
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

  final legCurlExerciseLog = ExerciseLogDto(
      id: lyingLegCurlExercise.id,
      routineLogId: "routineLogId1",
      exercise: lyingLegCurlExercise,
      superSetId: "superSetId",
      notes: "notes",
      sets: [
        const WeightAndRepsSetDto(weight: 80, reps: 15, checked: true),
        const WeightAndRepsSetDto(weight: 100, reps: 8, checked: true),
        const WeightAndRepsSetDto(weight: 100, reps: 6, checked: true),
      ],
      createdAt: DateTime(2023, 12, 1));

  final plankExerciseLog = ExerciseLogDto(
      id: plankExercise.id,
      routineLogId: "routineLogId1",
      superSetId: "superSetId",
      exercise: plankExercise,
      notes: "notes",
      sets: [
        const DurationSetDto(duration: Duration(milliseconds: 120000), checked: true),
        const DurationSetDto(duration: Duration(milliseconds: 180000), checked: true),
        const DurationSetDto(duration: Duration(milliseconds: 150000), checked: true),
      ],
      createdAt: DateTime.now());

  final benchPressExerciseLog = ExerciseLogDto(
    id: benchPressExercise.id,
      routineLogId: "routineLogId1",
      superSetId: "superSetId",
      exercise: benchPressExercise,
      notes: "notes",
      sets: [
        const WeightAndRepsSetDto(weight: 80, reps: 15, checked: true),
        const WeightAndRepsSetDto(weight: 100, reps: 8, checked: true),
        const WeightAndRepsSetDto(weight: 100, reps: 6, checked: true),
      ],
      createdAt: DateTime(2023, 12, 1));

  test("Load Exercise Logs", () {
    final exerciseLogRepository = ExerciseLogRepository();

    exerciseLogRepository.loadExerciseLogs(
        exerciseLogs: [legCurlExerciseLog, plankExerciseLog, benchPressExerciseLog],
        mode: RoutineEditorMode.log);

    expect(exerciseLogRepository.exerciseLogs.length, 3);
  });

  test("Check sets for [Exercise.Duration] in [RoutineEditorMode.log]", () {
    final exerciseLogRepository = ExerciseLogRepository();

    exerciseLogRepository.loadExerciseLogs(
        exerciseLogs: [legCurlExerciseLog, plankExerciseLog, benchPressExerciseLog],
        mode: RoutineEditorMode.log);

    final checkedSets = legCurlExerciseLog.sets.where((set) => set.checked == true);

    expect(checkedSets.length, 3);
  });

  test("Remove Exercise Log", () {
    final exerciseLogRepository = ExerciseLogRepository();

    exerciseLogRepository.loadExerciseLogs(
        exerciseLogs: [legCurlExerciseLog, plankExerciseLog, benchPressExerciseLog],
        mode: RoutineEditorMode.log);

    exerciseLogRepository.removeExerciseLog(logId: legCurlExerciseLog.id);

    expect(exerciseLogRepository.exerciseLogs.length, 2);

    expect(
        exerciseLogRepository.exerciseLogs.firstWhereOrNull(
                (log) => log.id == legCurlExerciseLog.id),
        null);
  });

  test("Update Exercise Log notes", () {
    final exerciseLogRepository = ExerciseLogRepository();

    exerciseLogRepository.loadExerciseLogs(
        exerciseLogs: [legCurlExerciseLog, plankExerciseLog, benchPressExerciseLog],
        mode: RoutineEditorMode.log);

    exerciseLogRepository.updateExerciseLogNotes(
        exerciseLogId: plankExerciseLog.id, value: 'This works your core');

    expect(
        exerciseLogRepository.exerciseLogs
            .firstWhereOrNull(
                (log) => log.id == plankExerciseLog.id)
            ?.notes,
        'This works your core');
  });

  test("Super set Exercise Logs", () {
    final exerciseLogRepository = ExerciseLogRepository();

    exerciseLogRepository.loadExerciseLogs(
        exerciseLogs: [legCurlExerciseLog, plankExerciseLog, benchPressExerciseLog],
        mode: RoutineEditorMode.log);

    exerciseLogRepository.addSuperSets(
        firstExerciseLogId: legCurlExerciseLog.id,
        secondExerciseLogId: benchPressExerciseLog.id,
        superSetId:
        "superset_id_${legCurlExerciseLog.id}_${benchPressExerciseLog.id}");

    expect(
        exerciseLogRepository.exerciseLogs
            .firstWhereOrNull(
                (log) => log.id == legCurlExerciseLog.id)
            ?.superSetId,
        "superset_id_${legCurlExerciseLog.id}_${benchPressExerciseLog.id}");

    expect(
        exerciseLogRepository.exerciseLogs
            .firstWhereOrNull(
                (log) => log.id == benchPressExerciseLog.id)
            ?.superSetId,
        "superset_id_${legCurlExerciseLog.id}_${benchPressExerciseLog.id}");
  });

  test("Remove Super set Exercise Logs", () {
    final exerciseLogRepository = ExerciseLogRepository();

    exerciseLogRepository.loadExerciseLogs(
        exerciseLogs: [legCurlExerciseLog, plankExerciseLog, benchPressExerciseLog],
        mode: RoutineEditorMode.log);

    exerciseLogRepository.addSuperSets(
        firstExerciseLogId: legCurlExerciseLog.id,
        secondExerciseLogId: benchPressExerciseLog.id,
        superSetId:
        "superset_id_${legCurlExerciseLog.id}_${benchPressExerciseLog.id}");

    exerciseLogRepository.removeSuperSet(
        superSetId:
        "superset_id_${legCurlExerciseLog.id}_${benchPressExerciseLog.id}");

    expect(
        exerciseLogRepository.exerciseLogs
            .firstWhereOrNull(
                (log) => log.id == legCurlExerciseLog.id)
            ?.superSetId,
        "");

    expect(
        exerciseLogRepository.exerciseLogs
            .firstWhereOrNull(
                (log) => log.id == benchPressExerciseLog.id)
            ?.superSetId,
        "");
  });

  test("Add new set", () {
    final exerciseLogRepository = ExerciseLogRepository();

    exerciseLogRepository.loadExerciseLogs(
        exerciseLogs: [legCurlExerciseLog, plankExerciseLog, benchPressExerciseLog],
        mode: RoutineEditorMode.log);

    exerciseLogRepository.addSet(
        exerciseLogId: legCurlExerciseLog.id,
        pastSets: legCurlExerciseLog.sets);

    final newLength = legCurlExerciseLog.sets.length;

    expect(legCurlExerciseLog.sets.length, newLength);
  });

  test("Remove set", () {
    final exerciseLogRepository = ExerciseLogRepository();

    exerciseLogRepository.loadExerciseLogs(
        exerciseLogs: [legCurlExerciseLog, plankExerciseLog, benchPressExerciseLog],
        mode: RoutineEditorMode.log);

    exerciseLogRepository.removeSet(exerciseLogId: legCurlExerciseLog.id, index: 1);

    final newLength = legCurlExerciseLog.sets.length;

    expect(legCurlExerciseLog.sets.length, newLength);

    expect(legCurlExerciseLog.sets[1], const WeightAndRepsSetDto(weight: 100, reps: 6, checked: true));
  });

  test("Update weight (Value 1)", () {
    final exerciseLogRepository = ExerciseLogRepository();

    exerciseLogRepository.loadExerciseLogs(
        exerciseLogs: [legCurlExerciseLog, plankExerciseLog, benchPressExerciseLog],
        mode: RoutineEditorMode.log);

    exerciseLogRepository.updateWeight(
        exerciseLogId: legCurlExerciseLog.id,
        index: 0,
        setDto: const WeightAndRepsSetDto(weight: 90, reps: 15, checked: false));

    expect((legCurlExerciseLog.sets[0] as WeightAndRepsSetDto).weight, 90);
  });

  test("Update reps (Value 2)", () {
    final exerciseLogRepository = ExerciseLogRepository();

    exerciseLogRepository.loadExerciseLogs(
        exerciseLogs: [legCurlExerciseLog, plankExerciseLog, benchPressExerciseLog],
        mode: RoutineEditorMode.log);

    exerciseLogRepository.updateWeight(
        exerciseLogId: legCurlExerciseLog.id,
        index: 0,
        setDto: const WeightAndRepsSetDto(weight: 80, reps: 25, checked: false));

    expect((legCurlExerciseLog.sets[0] as WeightAndRepsSetDto).reps, 25);
  });

  test("Update check", () {
    final exerciseLogRepository = ExerciseLogRepository();

    exerciseLogRepository.loadExerciseLogs(exerciseLogs: [
      legCurlExerciseLog.copyWith(sets: [const WeightAndRepsSetDto(weight: 80, reps: 25, checked: false)]),
      plankExerciseLog,
      benchPressExerciseLog
    ], mode: RoutineEditorMode.log);

    exerciseLogRepository.updateSetCheck(
        exerciseLogId: legCurlExerciseLog.id,
        index: 0,
        setDto: const WeightAndRepsSetDto(weight: 80, reps: 25, checked: true));

    expect(exerciseLogRepository.exerciseLogs[0].sets[0].checked, true);
  });

  test("Merge exercise and sets", () {
    final exerciseLogRepository = ExerciseLogRepository();

    exerciseLogRepository.loadExerciseLogs(
        exerciseLogs: [benchPressExerciseLog, plankExerciseLog, legCurlExerciseLog],
        mode: RoutineEditorMode.log);

    final mergedLogs = exerciseLogRepository.mergeExerciseLogsAndSets(mode: RoutineEditorMode.log);

    expect(mergedLogs.expand((element) => element.sets).length, 9);
  });

  test("All [ExerciseType.duration] sets must be checked when merging", () {
    final exerciseLogRepository = ExerciseLogRepository();

    final plankExerciseLog = ExerciseLogDto(
      id: "hijnnooin",
        routineLogId: "routineLogId1",
        superSetId: "superSetId",
        exercise: plankExercise,
        notes: "notes",
        sets: [],
        createdAt: DateTime.now());

    exerciseLogRepository.loadExerciseLogs(
        exerciseLogs: [legCurlExerciseLog, plankExerciseLog, benchPressExerciseLog],
        mode: RoutineEditorMode.log);

    exerciseLogRepository.addSet(
        exerciseLogId: plankExerciseLog.id,
        pastSets: []);
    exerciseLogRepository.addSet(
        exerciseLogId: plankExerciseLog.id,
        pastSets: []);

    exerciseLogRepository.updateDuration(
        exerciseLogId: plankExerciseLog.id,
        index: 0,
        setDto: const DurationSetDto(duration: Duration(milliseconds: 120000), checked: false));
    exerciseLogRepository.updateDuration(
        exerciseLogId: plankExerciseLog.id,
        index: 1,
        setDto: const DurationSetDto(duration: Duration(milliseconds: 100000), checked: false));

    final mergedLogs = exerciseLogRepository.mergeExerciseLogsAndSets(mode: RoutineEditorMode.log);

    final plankLog = mergedLogs.firstWhereOrNull(
            (log) => log.id == plankExerciseLog.id);

    final allChecked = plankLog?.sets.where((set) => set.checked == true);

    expect(allChecked?.length, 2);
  });

  test("Clear Controller", () {
    final exerciseLogRepository = ExerciseLogRepository();

    exerciseLogRepository.loadExerciseLogs(
        exerciseLogs: [legCurlExerciseLog, plankExerciseLog, benchPressExerciseLog],
        mode: RoutineEditorMode.log);

    exerciseLogRepository.clear();

    expect(exerciseLogRepository.exerciseLogs.length, 0);
  });
}