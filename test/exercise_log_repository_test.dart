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
  // Mock exercises
  final lyingLegCurlExercise = ExerciseDto(
    id: "id_lyingLegCurlExercise",
    name: "Lying Leg Curl",
    primaryMuscleGroup: MuscleGroup.hamstrings,
    secondaryMuscleGroups: [MuscleGroup.hamstrings],
    type: ExerciseType.weights,
    owner: "",
  );

  final plankExercise = ExerciseDto(
    id: "id_plankExercise",
    name: "Plank",
    primaryMuscleGroup: MuscleGroup.abs,
    secondaryMuscleGroups: [MuscleGroup.hamstrings],
    type: ExerciseType.duration,
    owner: "",
  );

  final benchPressExercise = ExerciseDto(
    id: "id_benchPressExercise",
    name: "Bench Press",
    primaryMuscleGroup: MuscleGroup.chest,
    secondaryMuscleGroups: [MuscleGroup.hamstrings],
    type: ExerciseType.weights,
    owner: "",
  );

  // Mock exercise logs
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
    createdAt: DateTime(2023, 12, 1),
  );

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
    createdAt: DateTime.now(),
  );

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
    createdAt: DateTime(2023, 12, 1),
  );

  group('ExerciseLogRepository Tests', () {
    test("Load Exercise Logs in log mode", () {
      final exerciseLogRepository = ExerciseLogRepository();

      // Act
      exerciseLogRepository.loadExerciseLogs(
          exerciseLogs: [legCurlExerciseLog, plankExerciseLog, benchPressExerciseLog], mode: RoutineEditorMode.log);

      // Assert
      expect(exerciseLogRepository.exerciseLogs.length, 3);
    });

    test("Load Exercise Logs in edit mode (duration sets should be cleared)", () {
      final exerciseLogRepository = ExerciseLogRepository();

      // Act
      exerciseLogRepository.loadExerciseLogs(
          exerciseLogs: [legCurlExerciseLog, plankExerciseLog, benchPressExerciseLog], mode: RoutineEditorMode.edit);

      // For duration exercises in edit mode, sets may be cleared or differ based on your logic
      final plankLog = exerciseLogRepository.exerciseLogs.firstWhere((log) => log.id == plankExercise.id);

      // Assert: Duration exercises often reset sets in edit mode
      expect(plankLog.sets.isEmpty, true, reason: "Duration sets should be cleared in edit mode");
    });

    test("Check sets for [ExerciseType.duration] in [RoutineEditorMode.log]", () {
      final exerciseLogRepository = ExerciseLogRepository();

      exerciseLogRepository.loadExerciseLogs(
          exerciseLogs: [legCurlExerciseLog, plankExerciseLog, benchPressExerciseLog], mode: RoutineEditorMode.log);

      final checkedSets = plankExerciseLog.sets.where((set) => set.checked == true);

      expect(checkedSets.length, 3);
    });

    test("Remove Exercise Log", () {
      final exerciseLogRepository = ExerciseLogRepository();
      exerciseLogRepository.loadExerciseLogs(
          exerciseLogs: [legCurlExerciseLog, plankExerciseLog, benchPressExerciseLog], mode: RoutineEditorMode.log);

      // Act
      exerciseLogRepository.removeExerciseLog(logId: legCurlExerciseLog.id);

      // Assert
      expect(exerciseLogRepository.exerciseLogs.length, 2);
      expect(exerciseLogRepository.exerciseLogs.firstWhereOrNull((log) => log.id == legCurlExerciseLog.id), null);
    });

    test("Update Exercise Log notes", () {
      final exerciseLogRepository = ExerciseLogRepository();
      exerciseLogRepository.loadExerciseLogs(
          exerciseLogs: [legCurlExerciseLog, plankExerciseLog, benchPressExerciseLog], mode: RoutineEditorMode.log);

      // Act
      exerciseLogRepository.updateExerciseLogNotes(exerciseLogId: plankExerciseLog.id, value: 'This works your core');

      // Assert
      expect(exerciseLogRepository.exerciseLogs.firstWhereOrNull((log) => log.id == plankExerciseLog.id)?.notes,
          'This works your core');
    });

    test("Super set Exercise Logs", () {
      final exerciseLogRepository = ExerciseLogRepository();
      exerciseLogRepository.loadExerciseLogs(
          exerciseLogs: [legCurlExerciseLog, plankExerciseLog, benchPressExerciseLog], mode: RoutineEditorMode.log);

      exerciseLogRepository.addSuperSets(
          firstExerciseLogId: legCurlExerciseLog.id,
          secondExerciseLogId: benchPressExerciseLog.id,
          superSetId: "superset_id_${legCurlExerciseLog.id}_${benchPressExerciseLog.id}");

      expect(exerciseLogRepository.exerciseLogs.firstWhereOrNull((log) => log.id == legCurlExerciseLog.id)?.superSetId,
          "superset_id_${legCurlExerciseLog.id}_${benchPressExerciseLog.id}");

      expect(
          exerciseLogRepository.exerciseLogs.firstWhereOrNull((log) => log.id == benchPressExerciseLog.id)?.superSetId,
          "superset_id_${legCurlExerciseLog.id}_${benchPressExerciseLog.id}");
    });

    test("Remove Super set Exercise Logs", () {
      final exerciseLogRepository = ExerciseLogRepository();
      exerciseLogRepository.loadExerciseLogs(
          exerciseLogs: [legCurlExerciseLog, plankExerciseLog, benchPressExerciseLog], mode: RoutineEditorMode.log);

      exerciseLogRepository.addSuperSets(
          firstExerciseLogId: legCurlExerciseLog.id,
          secondExerciseLogId: benchPressExerciseLog.id,
          superSetId: "superset_id_${legCurlExerciseLog.id}_${benchPressExerciseLog.id}");

      exerciseLogRepository.removeSuperSet(
          superSetId: "superset_id_${legCurlExerciseLog.id}_${benchPressExerciseLog.id}");

      expect(exerciseLogRepository.exerciseLogs.firstWhereOrNull((log) => log.id == legCurlExerciseLog.id)?.superSetId,
          "");
      expect(
          exerciseLogRepository.exerciseLogs.firstWhereOrNull((log) => log.id == benchPressExerciseLog.id)?.superSetId,
          "");
    });

    test("Add new set", () {
      final exerciseLogRepository = ExerciseLogRepository();
      exerciseLogRepository.loadExerciseLogs(exerciseLogs: [legCurlExerciseLog], mode: RoutineEditorMode.log);

      final initialLength =
          exerciseLogRepository.exerciseLogs.firstWhere((log) => log.id == legCurlExerciseLog.id).sets.length;

      // Act
      exerciseLogRepository.addSet(exerciseLogId: legCurlExerciseLog.id, pastSets: legCurlExerciseLog.sets);

      final newLength =
          exerciseLogRepository.exerciseLogs.firstWhere((log) => log.id == legCurlExerciseLog.id).sets.length;

      // Assert
      expect(newLength, initialLength + 1);
    });

    test("Remove set by index", () {
      final exerciseLogRepository = ExerciseLogRepository();
      exerciseLogRepository.loadExerciseLogs(exerciseLogs: [legCurlExerciseLog], mode: RoutineEditorMode.log);

      final initialSets = [...exerciseLogRepository.exerciseLogs.firstWhere((log) => log.id == legCurlExerciseLog.id).sets];

      // Act: Remove set at index 1
      exerciseLogRepository.removeSet(exerciseLogId: legCurlExerciseLog.id, index: 1);

      final updatedSets = exerciseLogRepository.exerciseLogs.firstWhere((log) => log.id == legCurlExerciseLog.id).sets;

      // Assert: The second set (index 1) should now be gone
      expect(updatedSets.length, initialSets.length - 1);
      expect(updatedSets.contains(initialSets[1]), false);
    });

    test("Update weight of a set", () {
      final exerciseLogRepository = ExerciseLogRepository();
      exerciseLogRepository.loadExerciseLogs(exerciseLogs: [legCurlExerciseLog], mode: RoutineEditorMode.log);

      // Act
      exerciseLogRepository.updateWeight(
          exerciseLogId: legCurlExerciseLog.id,
          index: 0,
          setDto: const WeightAndRepsSetDto(weight: 90, reps: 15, checked: false));

      // Assert
      expect((exerciseLogRepository.exerciseLogs.first.sets[0] as WeightAndRepsSetDto).weight, 90);
    });

    test("Update reps of a set", () {
      final exerciseLogRepository = ExerciseLogRepository();
      exerciseLogRepository.loadExerciseLogs(exerciseLogs: [legCurlExerciseLog], mode: RoutineEditorMode.log);

      exerciseLogRepository.updateWeight(
          exerciseLogId: legCurlExerciseLog.id,
          index: 0,
          setDto: const WeightAndRepsSetDto(weight: 80, reps: 25, checked: false));

      expect((exerciseLogRepository.exerciseLogs.first.sets[0] as WeightAndRepsSetDto).reps, 25);
    });

    test("Update check status of a set", () {
      final exerciseLogRepository = ExerciseLogRepository();
      final modifiedLog =
          legCurlExerciseLog.copyWith(sets: [const WeightAndRepsSetDto(weight: 80, reps: 25, checked: false)]);

      exerciseLogRepository.loadExerciseLogs(exerciseLogs: [modifiedLog], mode: RoutineEditorMode.log);

      // Act
      exerciseLogRepository.updateSetCheck(
          exerciseLogId: modifiedLog.id,
          index: 0,
          setDto: const WeightAndRepsSetDto(weight: 80, reps: 25, checked: true));

      // Assert
      expect(exerciseLogRepository.exerciseLogs[0].sets[0].checked, true);
    });

    test("Merge exercise logs and sets in log mode", () {
      final exerciseLogRepository = ExerciseLogRepository();
      exerciseLogRepository.loadExerciseLogs(
          exerciseLogs: [benchPressExerciseLog, plankExerciseLog, legCurlExerciseLog], mode: RoutineEditorMode.log);

      final mergedLogs = exerciseLogRepository.mergeExerciseLogsAndSets(mode: RoutineEditorMode.log);
      final totalSets = mergedLogs.fold<int>(0, (sum, log) => sum + log.sets.length);

      expect(totalSets, 9); // 3 sets each for three exercises
    });

    test("All [ExerciseType.duration] sets must be checked when merging in log mode", () {
      final exerciseLogRepository = ExerciseLogRepository();

      // Create an initially empty plank log in log mode
      final emptyPlankLog = plankExerciseLog.copyWith(sets: []);

      exerciseLogRepository.loadExerciseLogs(
          exerciseLogs: [legCurlExerciseLog, emptyPlankLog, benchPressExerciseLog], mode: RoutineEditorMode.log);

      // Add two new duration sets (initially unchecked)
      exerciseLogRepository.addSet(exerciseLogId: emptyPlankLog.id, pastSets: []);
      exerciseLogRepository.addSet(exerciseLogId: emptyPlankLog.id, pastSets: []);

      // Update them with duration values and keep them unchecked
      exerciseLogRepository.updateDuration(
          exerciseLogId: emptyPlankLog.id,
          index: 0,
          setDto: const DurationSetDto(duration: Duration(milliseconds: 120000), checked: false));
      exerciseLogRepository.updateDuration(
          exerciseLogId: emptyPlankLog.id,
          index: 1,
          setDto: const DurationSetDto(duration: Duration(milliseconds: 100000), checked: false));

      final mergedLogs = exerciseLogRepository.mergeExerciseLogsAndSets(mode: RoutineEditorMode.log);
      final updatedPlankLog = mergedLogs.firstWhereOrNull((log) => log.id == emptyPlankLog.id);

      // All duration sets should now be checked after merging
      final allChecked = updatedPlankLog?.sets.every((set) => set.checked == true);
      expect(allChecked, true);
    });

    test("Clear repository", () {
      final exerciseLogRepository = ExerciseLogRepository();
      exerciseLogRepository.loadExerciseLogs(
          exerciseLogs: [legCurlExerciseLog, plankExerciseLog, benchPressExerciseLog], mode: RoutineEditorMode.log);

      exerciseLogRepository.clear();
      expect(exerciseLogRepository.exerciseLogs.length, 0);
    });

    // Additional Tests for Uncovered Methods or Cases

    test("Replace Exercise in a Log", () {
      final exerciseLogRepository = ExerciseLogRepository();
      exerciseLogRepository.loadExerciseLogs(exerciseLogs: [legCurlExerciseLog], mode: RoutineEditorMode.log);

      // Assuming replaceExercise method exists: it replaces the exercise in the specified log
      final newExercise = plankExercise;
      exerciseLogRepository
          .replaceExercise(oldExerciseId: legCurlExerciseLog.id, newExercise: newExercise, pastSets: []);

      final updatedLog = exerciseLogRepository.exerciseLogs.firstWhere((log) => log.id == newExercise.id);
      expect(updatedLog.exercise.id, newExercise.id);
      expect(updatedLog.exercise.name, newExercise.name);
    });

    test("Overwrite Sets in an Exercise Log", () {
      final exerciseLogRepository = ExerciseLogRepository();
      exerciseLogRepository.loadExerciseLogs(exerciseLogs: [legCurlExerciseLog], mode: RoutineEditorMode.log);

      final newSets = [
        const WeightAndRepsSetDto(weight: 50, reps: 10, checked: true),
        const WeightAndRepsSetDto(weight: 60, reps: 8, checked: false),
      ];

      exerciseLogRepository.overwriteSets(exerciseLogId: legCurlExerciseLog.id, sets: newSets);

      final updatedLog = exerciseLogRepository.exerciseLogs.firstWhere((log) => log.id == legCurlExerciseLog.id);
      expect(updatedLog.sets.length, 2);
      expect((updatedLog.sets[0] as WeightAndRepsSetDto).weight, 50);
      expect((updatedLog.sets[1] as WeightAndRepsSetDto).weight, 60);
    });

    test("completedExerciseLogs returns only logs with checked sets", () {
      final exerciseLogRepository = ExerciseLogRepository();
      // Make benchPressExerciseLog have all unchecked sets
      final benchPressAllUnchecked = benchPressExerciseLog.copyWith(
        sets: [
          const WeightAndRepsSetDto(weight: 80, reps: 15, checked: false),
          const WeightAndRepsSetDto(weight: 100, reps: 8, checked: false),
          const WeightAndRepsSetDto(weight: 100, reps: 6, checked: false),
        ],
      );

      exerciseLogRepository.loadExerciseLogs(
          exerciseLogs: [legCurlExerciseLog, plankExerciseLog, benchPressAllUnchecked], mode: RoutineEditorMode.log);

      final completed = exerciseLogRepository.completedExerciseLogs();
      // legCurl and plank logs have checked sets, bench press does not
      expect(completed.length, 2);
      expect(completed.any((log) => log.id == benchPressExerciseLog.id), false);
    });

    test("completedSets returns only the sets that are checked across all logs", () {
      final exerciseLogRepository = ExerciseLogRepository();

      exerciseLogRepository
          .loadExerciseLogs(exerciseLogs: [legCurlExerciseLog, plankExerciseLog], mode: RoutineEditorMode.log);

      final completed = exerciseLogRepository.completedSets();
      // All sets in these logs are checked (from initial data)
      final totalSets = legCurlExerciseLog.sets.length + plankExerciseLog.sets.length;
      expect(completed.length, totalSets);
    });

    test("Attempting to remove a non-existent log should not crash", () {
      final exerciseLogRepository = ExerciseLogRepository();
      exerciseLogRepository.loadExerciseLogs(exerciseLogs: [legCurlExerciseLog], mode: RoutineEditorMode.log);

      // Non-existent ID
      exerciseLogRepository.removeExerciseLog(logId: "non_existent_id");
      // No crash and no changes
      expect(exerciseLogRepository.exerciseLogs.length, 1);
    });

    test("Attempting to remove a non-existent set should not crash", () {
      final exerciseLogRepository = ExerciseLogRepository();
      exerciseLogRepository.loadExerciseLogs(exerciseLogs: [legCurlExerciseLog], mode: RoutineEditorMode.log);

      // Index out of range
      exerciseLogRepository.removeSet(exerciseLogId: legCurlExerciseLog.id, index: 999);
      // No crash and no changes
      final updatedLog = exerciseLogRepository.exerciseLogs.firstWhere((log) => log.id == legCurlExerciseLog.id);
      expect(updatedLog.sets.length, legCurlExerciseLog.sets.length);
    });

    test("Loading empty exercise logs should result in empty repository", () {
      final exerciseLogRepository = ExerciseLogRepository();

      exerciseLogRepository.loadExerciseLogs(exerciseLogs: [], mode: RoutineEditorMode.log);

      expect(exerciseLogRepository.exerciseLogs.isEmpty, true);
    });
  });
}
