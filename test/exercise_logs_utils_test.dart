import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tracker_app/dtos/exercise_dto.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/dtos/pb_dto.dart';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/enums/pb_enums.dart';
import 'package:tracker_app/enums/template_changes_type_message_enums.dart';
import 'package:tracker_app/repositories/amplify_log_repository.dart';
import 'package:tracker_app/utils/exercise_logs_utils.dart';

class MockBuildContext extends Mock implements BuildContext {}

class MockAmplifyLogsRepository extends Mock implements AmplifyLogRepository {
  @override
  List<ExerciseLogDto> exerciseLogsForExercise({required ExerciseDto exercise}) {
    return [];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final lyingLegCurlExercise = ExerciseDto(
      id: "id_exercise1",
      name: "Lying Leg Curl",
      primaryMuscleGroup: MuscleGroup.legs,
      type: ExerciseType.weights,
      owner: false);

  final plankExercise = ExerciseDto(
      id: "id_exercise2",
      name: "Plank",
      primaryMuscleGroup: MuscleGroup.abs,
      type: ExerciseType.duration,
      owner: false);

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
      DateTime(2023, 12, 1));

  final lyingLegCurlExerciseLog2 = ExerciseLogDto(
      lyingLegCurlExercise.id,
      "routineLogId2",
      "superSetId",
      lyingLegCurlExercise,
      "notes",
      [
        const SetDto(80, 12, true),
        const SetDto(100, 10, true),
        const SetDto(100, 6, true),
      ],
      DateTime(2023, 12, 1));

  final lyingLegCurlExerciseLog3 = ExerciseLogDto(
      lyingLegCurlExercise.id,
      "routineLogId3",
      "superSetId",
      lyingLegCurlExercise,
      "notes",
      [
        const SetDto(80, 12, true),
        const SetDto(100, 10, true),
        const SetDto(150, 11, true),
      ],
      DateTime(2023, 12, 1));

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
      DateTime.now());

  final plankExerciseLog2 = ExerciseLogDto(
      plankExercise.id,
      "routineLogId2",
      "superSetId",
      plankExercise,
      "notes",
      [
        const SetDto(110000, 0, true),
        const SetDto(100000, 0, true),
        const SetDto(120000, 0, true),
      ],
      DateTime.now());

  group("Test on single ExerciseLogDto", () {
    test("Heaviest set weight for exercise log", () {
      final result = heaviestSetWeightForExerciseLog(exerciseLog: lyingLegCurlExerciseLog1);
      expect(result, lyingLegCurlExerciseLog1.sets[1]);
    });

    test("Longest duration for exercise log", () {
      final result = longestDurationForExerciseLog(exerciseLog: plankExerciseLog1);
      expect(result, Duration(milliseconds: plankExerciseLog1.sets[1].value1.toInt()));
    });

    test("Total duration for exercise log", () {
      final result = totalDurationExerciseLog(exerciseLog: plankExerciseLog1);
      expect(result, const Duration(milliseconds: 450000));
    });

    test("Total reps for exercise log", () {
      final result = totalRepsForExerciseLog(exerciseLog: lyingLegCurlExerciseLog1);
      expect(result, lyingLegCurlExerciseLog1.sets.fold(0, (previousValue, set) => previousValue + set.value2.toInt()));
    });

    test("Highest reps for exercise log", () {
      final result = highestRepsForExerciseLog(exerciseLog: lyingLegCurlExerciseLog1);
      expect(result, lyingLegCurlExerciseLog1.sets[0].value2);
    });

    test("Heaviest volume for exercise log", () {
      final result = heaviestVolumeForExerciseLog(exerciseLog: lyingLegCurlExerciseLog1);
      expect(result, lyingLegCurlExerciseLog1.sets[0].value1 * lyingLegCurlExerciseLog1.sets[0].value2);
    });

    test("Heaviest set volume for exercise log", () {
      final result = heaviestSetVolumeForExerciseLog(exerciseLog: lyingLegCurlExerciseLog1);
      expect(result, lyingLegCurlExerciseLog1.sets.first);
    });
  });

  group("Test on list of ExerciseLogDto", () {
    test("Heaviest set volume", () {
      final result = heaviestSetVolume(
          exerciseLogs: [lyingLegCurlExerciseLog1, lyingLegCurlExerciseLog2, lyingLegCurlExerciseLog3]);
      expect(result, (lyingLegCurlExerciseLog3.routineLogId, lyingLegCurlExerciseLog3.sets[2]));
    });

    test("Heaviest set weight", () {
      final result =
          heaviestWeight(exerciseLogs: [lyingLegCurlExerciseLog1, lyingLegCurlExerciseLog2, lyingLegCurlExerciseLog3]);
      expect(result, (lyingLegCurlExerciseLog3.routineLogId, lyingLegCurlExerciseLog3.sets[2].value1));
    });

    test("Most Reps (Set)", () {
      final result =
          mostRepsInSet(exerciseLogs: [lyingLegCurlExerciseLog1, lyingLegCurlExerciseLog2, lyingLegCurlExerciseLog3]);
      expect(result, (lyingLegCurlExerciseLog1.routineLogId, lyingLegCurlExerciseLog1.sets[0].value2));
    });

    test("Most Reps (Session)", () {
      final result = mostRepsInSession(
          exerciseLogs: [lyingLegCurlExerciseLog1, lyingLegCurlExerciseLog2, lyingLegCurlExerciseLog3]);
      expect(result, (
        lyingLegCurlExerciseLog3.routineLogId,
        lyingLegCurlExerciseLog3.sets.fold(0, (previousValue, set) => previousValue + set.value2.toInt())
      ));
    });

    test("Longest Duration", () {
      final result = longestDuration(exerciseLogs: [plankExerciseLog1, plankExerciseLog2]);
      expect(
          result, (plankExerciseLog1.routineLogId, Duration(milliseconds: plankExerciseLog1.sets[1].value1.toInt())));
    });
  });

  group("Test PBs", () {
    test("Has [PBType.weight]", () {
      final pbLog = ExerciseLogDto(
          lyingLegCurlExercise.id,
          "routineLogId4",
          "superSetId",
          lyingLegCurlExercise,
          "notes",
          [
            const SetDto(80, 12, true),
            const SetDto(100, 10, true),
            const SetDto(160, 6, true),
          ],
          DateTime.now());

      final pbs = [PBDto(set: pbLog.sets[2], exercise: lyingLegCurlExercise, pb: PBType.weight)];

      final result = calculatePBs(
          pastExerciseLogs: [lyingLegCurlExerciseLog1, lyingLegCurlExerciseLog2],
          exerciseType: ExerciseType.weights,
          exerciseLog: pbLog);

      expect(result.length, 1);
      expect(result[0].pb, pbs[0].pb);
      expect(result[0].set, pbs[0].set);
      expect(result[0].exercise, pbs[0].exercise);
    });

    test("Has [PBType.volume]", () {
      final pbLog = ExerciseLogDto(
          lyingLegCurlExercise.id,
          "routineLogId4",
          "superSetId",
          lyingLegCurlExercise,
          "notes",
          [
            const SetDto(80, 12, true),
            const SetDto(150, 20, true),
            const SetDto(100, 10, true),
          ],
          DateTime.now());

      final pbs = [PBDto(set: pbLog.sets[1], exercise: lyingLegCurlExercise, pb: PBType.volume)];

      final result = calculatePBs(
          pastExerciseLogs: [lyingLegCurlExerciseLog1, lyingLegCurlExerciseLog2, lyingLegCurlExerciseLog3],
          exerciseType: ExerciseType.weights,
          exerciseLog: pbLog);

      expect(result.length, 1);
      expect(result[0].pb, pbs[0].pb);
      expect(result[0].set, pbs[0].set);
      expect(result[0].exercise, pbs[0].exercise);
    });

    test("Has [PBType.weight], PBType.volume]", () {
      final pbLog = ExerciseLogDto(
          lyingLegCurlExercise.id,
          "routineLogId4",
          "superSetId",
          lyingLegCurlExercise,
          "notes",
          [
            const SetDto(80, 12, true),
            const SetDto(160, 12, true),
            const SetDto(100, 10, true),
          ],
          DateTime.now());

      final pbs = [
        PBDto(set: pbLog.sets[1], exercise: lyingLegCurlExercise, pb: PBType.weight),
        PBDto(set: pbLog.sets[1], exercise: lyingLegCurlExercise, pb: PBType.volume)
      ];

      final result = calculatePBs(
          pastExerciseLogs: [lyingLegCurlExerciseLog1, lyingLegCurlExerciseLog2, lyingLegCurlExerciseLog3],
          exerciseType: ExerciseType.weights,
          exerciseLog: pbLog);

      expect(result.length, 2);
      expect(result[0].pb, pbs[0].pb);
      expect(result[0].set, pbs[0].set);
      expect(result[1].pb, pbs[1].pb);
      expect(result[1].set, pbs[1].set);
      expect(result[0].exercise, pbs[0].exercise);
      expect(result[1].exercise, pbs[1].exercise);
    });

    test("Has [PBType.duration]", () {
      final pbLog = ExerciseLogDto(
          plankExercise.id,
          "routineLogId4",
          "superSetId",
          plankExercise,
          "notes",
          [
            const SetDto(110000, 0, true),
            const SetDto(100000, 0, true),
            const SetDto(220000, 0, true),
          ],
          DateTime.now());

      final pbs = [PBDto(set: pbLog.sets[2], exercise: plankExercise, pb: PBType.duration)];

      final result = calculatePBs(
          pastExerciseLogs: [plankExerciseLog1, plankExerciseLog2],
          exerciseType: ExerciseType.duration,
          exerciseLog: pbLog);

      expect(result.length, 1);
      expect(result[0].pb, pbs[0].pb);
      expect(result[0].set, pbs[0].set);
      expect(result[0].exercise, pbs[0].exercise);
    });

    test("Has [PBType.weight, PBType.volume, PBType.durations]", () {
      final pbLog1 = ExerciseLogDto(
          lyingLegCurlExercise.id,
          "routineLogId4",
          "superSetId",
          lyingLegCurlExercise,
          "notes",
          [
            const SetDto(80, 12, true),
            const SetDto(160, 12, true),
            const SetDto(100, 10, true),
          ],
          DateTime.now());

      final pbLog2 = ExerciseLogDto(
          plankExercise.id,
          "routineLogId4",
          "superSetId",
          plankExercise,
          "notes",
          [
            const SetDto(110000, 0, true),
            const SetDto(100000, 0, true),
            const SetDto(220000, 0, true),
          ],
          DateTime.now());

      final pbLogs = [pbLog1, pbLog2];

      final pbs = [
        PBDto(set: pbLog1.sets[1], exercise: lyingLegCurlExercise, pb: PBType.weight),
        PBDto(set: pbLog1.sets[1], exercise: lyingLegCurlExercise, pb: PBType.volume),
        PBDto(set: pbLog2.sets[2], exercise: plankExercise, pb: PBType.duration)
      ];

      final result = pbLogs
          .map((log) => calculatePBs(
              pastExerciseLogs: [lyingLegCurlExerciseLog1, lyingLegCurlExerciseLog2, lyingLegCurlExerciseLog3],
              exerciseType: log.exercise.type,
              exerciseLog: log))
          .expand((pbs) => pbs)
          .toList();

      expect(result.length, 3);
      expect(result[0].pb, pbs[0].pb);
      expect(result[0].set, pbs[0].set);
      expect(result[1].pb, pbs[1].pb);
      expect(result[1].set, pbs[1].set);
      expect(result[2].pb, pbs[2].pb);
      expect(result[2].set, pbs[2].set);
      expect(result[0].exercise, pbs[0].exercise);
      expect(result[1].exercise, pbs[1].exercise);
      expect(result[2].exercise, pbs[2].exercise);
    });
  });

  test("Different exercise lengths", () {
    final result = hasDifferentExerciseLogsLength(
        exerciseLogs1: [lyingLegCurlExerciseLog1, lyingLegCurlExerciseLog2],
        exerciseLogs2: [lyingLegCurlExerciseLog1, lyingLegCurlExerciseLog2, lyingLegCurlExerciseLog3]);
    expect(result, TemplateChange.exerciseLogLength);
  });

  test("Different re-ordered exercises", () {
    final result = hasReOrderedExercises(
        exerciseLogs1: [lyingLegCurlExerciseLog1, plankExerciseLog1],
        exerciseLogs2: [plankExerciseLog1, lyingLegCurlExerciseLog1]);
    expect(result, TemplateChange.exerciseOrder);
  });

  test("Different sets lengths", () {
    final result = hasDifferentSetsLength(
        exerciseLogs1: [lyingLegCurlExerciseLog1, plankExerciseLog1],
        exerciseLogs2: [plankExerciseLog1, lyingLegCurlExerciseLog1]);
    expect(result, TemplateChange.exerciseOrder);
  });

  // Add your widget tests here
}
