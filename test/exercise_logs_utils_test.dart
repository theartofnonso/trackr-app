import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tracker_app/dtos/exercise_dto.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/providers/routine_log_provider.dart';
import 'package:tracker_app/utils/exercise_logs_utils.dart';

class MockBuildContext extends Mock implements BuildContext {}

class MockRoutineLogProvider extends Mock implements RoutineLogProvider {



  @override
  List<ExerciseLogDto> exerciseLogsForExercise({required ExerciseDto exercise}) {
    return [];
  }
}

void main() {
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
        const SetDto(80, 12, true),
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
        const SetDto(100, 11, true),
      ],
      DateTime.now());

  final plankExerciseLog = ExerciseLogDto(
      plankExercise.id,
      "routineLogId",
      "superSetId",
      plankExercise,
      "notes",
      [
        const SetDto(120000, 0, true),
        const SetDto(180000, 0, true),
        const SetDto(150000, 0, true),
      ],
      DateTime.now());

  group("Test on ExerciseLogDto", () {
    test("Heaviest set weight for exercise log", () {
      final result = heaviestSetWeightForExerciseLog(exerciseLog: lyingLegCurlExerciseLog1);
      expect(result, lyingLegCurlExerciseLog1.sets[1]);
    });

    test("Longest duration for exercise log", () {
      final result = longestDurationForExerciseLog(exerciseLog: plankExerciseLog);
      expect(result, Duration(milliseconds: plankExerciseLog.sets[1].value1.toInt()));
    });

    test("Total duration for exercise log", () {
      final result = totalDurationExerciseLog(exerciseLog: plankExerciseLog);
      expect(result, const Duration(milliseconds: 450000));
    });

    test("Total reps for exercise log", () {
      final result = totalRepsForExerciseLog(exerciseLog: lyingLegCurlExerciseLog1);
      expect(result, 26);
    });

    test("Highest reps for exercise log", () {
      final result = highestRepsForExerciseLog(exerciseLog: lyingLegCurlExerciseLog1);
      expect(result, 12);
    });

    test("Heaviest volume for exercise log", () {
      final result = heaviestVolumeForExerciseLog(exerciseLog: lyingLegCurlExerciseLog1);
      expect(result, 960);
    });

    test("Heaviest set volume for exercise log", () {
      final result = heaviestSetVolumeForExerciseLog(exerciseLog: lyingLegCurlExerciseLog1);
      expect(result, lyingLegCurlExerciseLog1.sets.first);
    });
  });

  final mockBuildContext = MockBuildContext();
  final mockRoutineLogProvider = RoutineLogProvider();

  // when(mockRoutineLogProvider.exerciseLogsForExercise(exercise: lyingLegCurlExercise))
  //     .thenReturn([lyingLegCurlExerciseLog1, lyingLegCurlExerciseLog2, lyingLegCurlExerciseLog3]);

  test("Heaviest set volume for exercise", () {

    final result = heaviestSetVolumeForExercise(context: mockBuildContext, exercise: lyingLegCurlExercise);
    expect(result, (lyingLegCurlExerciseLog3.routineLogId, lyingLegCurlExerciseLog3.sets[2]));
  });
}
