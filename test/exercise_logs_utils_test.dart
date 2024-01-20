import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tracker_app/dtos/exercise_dto.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
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
      DateTime.now());

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
      DateTime.now());

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
      DateTime.now());

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

  group("Test on list of ExerciseLogDto",  () {
    test("Heaviest set volume", () {
      final result = heaviestSetVolume(exerciseLogs: [lyingLegCurlExerciseLog1, lyingLegCurlExerciseLog2, lyingLegCurlExerciseLog3]);
      expect(result, (lyingLegCurlExerciseLog3.routineLogId, lyingLegCurlExerciseLog3.sets[2]));
    });

    test("Heaviest set weight", () {
      final result = heaviestWeight(exerciseLogs: [lyingLegCurlExerciseLog1, lyingLegCurlExerciseLog2, lyingLegCurlExerciseLog3]);
      expect(result, (lyingLegCurlExerciseLog3.routineLogId, lyingLegCurlExerciseLog3.sets[2].value1));
    });

    test("Most Reps (Set)", () {
      final result = mostRepsInSet(exerciseLogs: [lyingLegCurlExerciseLog1, lyingLegCurlExerciseLog2, lyingLegCurlExerciseLog3]);
      expect(result, (lyingLegCurlExerciseLog1.routineLogId, lyingLegCurlExerciseLog1.sets[0].value2));
    });

    test("Most Reps (Session)", () {
      final result = mostRepsInSession(exerciseLogs: [lyingLegCurlExerciseLog1, lyingLegCurlExerciseLog2, lyingLegCurlExerciseLog3]);
      expect(result, (lyingLegCurlExerciseLog3.routineLogId, lyingLegCurlExerciseLog3.sets.fold(0, (previousValue, set) => previousValue + set.value2.toInt())));
    });

    test("Longest Duration", () {
      final result = longestDuration(exerciseLogs: [plankExerciseLog1, plankExerciseLog2]);
      expect(result, (plankExerciseLog1.routineLogId, Duration(milliseconds: plankExerciseLog1.sets[1].value1.toInt())));
    });
  });

  // Add your widget tests here
}
