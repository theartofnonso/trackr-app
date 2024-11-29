import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_app/dtos/appsync/exercise_dto.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/dtos/pb_dto.dart';
import 'package:tracker_app/dtos/set_dtos/duration_set_dto.dart';
import 'package:tracker_app/dtos/set_dtos/weight_and_reps_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/enums/pb_enums.dart';
import 'package:tracker_app/utils/exercise_logs_utils.dart';

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

  final legCurlExerciseLog1 = ExerciseLogDto(
      id: lyingLegCurlExercise.id,
      routineLogId: "routineLogId1",
      superSetId: "superSetId",
      exercise: lyingLegCurlExercise,
      notes: "notes",
      sets: [
        const WeightAndRepsSetDto(weight: 80, reps: 15, checked: true),
        const WeightAndRepsSetDto(weight: 100, reps: 8, checked: true),
        const WeightAndRepsSetDto(weight: 100, reps: 6, checked: true),
      ],
      createdAt: DateTime(2023, 12, 1));

  final lyingLegCurlExerciseLog2 = ExerciseLogDto(
      id: lyingLegCurlExercise.id,
      routineLogId: "routineLogId2",
      superSetId: "superSetId",
      exercise: lyingLegCurlExercise,
      notes: "notes",
      sets: [
        const WeightAndRepsSetDto(weight: 80, reps: 15, checked: true),
        const WeightAndRepsSetDto(weight: 100, reps: 8, checked: true),
        const WeightAndRepsSetDto(weight: 100, reps: 6, checked: true),
      ],
      createdAt: DateTime(2023, 12, 1));

  final legCurlExerciseLog3 = ExerciseLogDto(
      id: lyingLegCurlExercise.id,
      routineLogId: "routineLogId1",
      superSetId: "superSetId",
      exercise: lyingLegCurlExercise,
      notes: "notes",
      sets: [
        const WeightAndRepsSetDto(weight: 80, reps: 12, checked: true),
        const WeightAndRepsSetDto(weight: 100, reps: 10, checked: true),
        const WeightAndRepsSetDto(weight: 150, reps: 11, checked: true),
      ],
      createdAt: DateTime(2023, 12, 1));

  final plankExerciseLog1 = ExerciseLogDto(
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

  final plankExerciseLog2 = ExerciseLogDto(
      id: plankExercise.id,
      routineLogId: "routineLogId1",
      superSetId: "superSetId",
      exercise: plankExercise,
      notes: "notes",
      sets: [
        const DurationSetDto(duration: Duration(milliseconds: 110000), checked: true),
        const DurationSetDto(duration: Duration(milliseconds: 100000), checked: true),
        const DurationSetDto(duration: Duration(milliseconds: 120000), checked: true),
      ],
      createdAt: DateTime.now());

  group("Test on single ExerciseLogDto", () {
    test("Heaviest set weight for exercise log", () {
      final result = heaviestWeightInSetForExerciseLog(exerciseLog: legCurlExerciseLog1);
      expect(result, legCurlExerciseLog1.sets[1]);
    });

    test("Longest duration for exercise log", () {
      final result = longestDurationForExerciseLog(exerciseLog: plankExerciseLog1);
      expect(result, (plankExerciseLog1.sets[1] as DurationSetDto).duration);
    });

    test("Total duration for exercise log", () {
      final result = totalDurationExerciseLog(exerciseLog: plankExerciseLog1);
      expect(result, const Duration(milliseconds: 450000));
    });

    test("Total reps for exercise log", () {
      final result = totalRepsForExerciseLog(exerciseLog: legCurlExerciseLog1);
      expect(
          result,
          legCurlExerciseLog1.sets
              .map((set) => set as WeightAndRepsSetDto)
              .fold(0, (previousValue, set) => previousValue + set.reps));
    });

    test("Highest reps for exercise log", () {
      final result = highestRepsForExerciseLog(exerciseLog: legCurlExerciseLog1);
      expect(result, (legCurlExerciseLog1.sets[0] as WeightAndRepsSetDto).reps);
    });

    test("Heaviest volume for exercise log", () {
      final result = heaviestVolumeForExerciseLog(exerciseLog: legCurlExerciseLog1);
      expect(
          result,
          (legCurlExerciseLog1.sets[0] as WeightAndRepsSetDto).weight *
              (legCurlExerciseLog1.sets[0] as WeightAndRepsSetDto).reps);
    });

    test("Heaviest set volume for exercise log", () {
      final result = heaviestSetVolumeForExerciseLog(exerciseLog: legCurlExerciseLog1);
      expect(result, legCurlExerciseLog1.sets.first);
    });
  });

  group("Test on list of ExerciseLogDto", () {
    test("Heaviest set volume", () {
      final result =
          heaviestSetVolume(exerciseLogs: [legCurlExerciseLog1, lyingLegCurlExerciseLog2, legCurlExerciseLog3]);
      expect(result, (legCurlExerciseLog3.routineLogId, legCurlExerciseLog3.sets[2]));
    });

    test("Heaviest set weight", () {
      final result = heaviestWeight(exerciseLogs: [legCurlExerciseLog1, lyingLegCurlExerciseLog2, legCurlExerciseLog3]);
      expect(result, (legCurlExerciseLog3.routineLogId, (legCurlExerciseLog3.sets[2] as WeightAndRepsSetDto).weight));
    });

    test("Most Reps (Set)", () {
      final result = mostRepsInSet(exerciseLogs: [legCurlExerciseLog1, lyingLegCurlExerciseLog2, legCurlExerciseLog3]);
      expect(result, (legCurlExerciseLog1.routineLogId, (legCurlExerciseLog1.sets[0] as WeightAndRepsSetDto).reps));
    });

    test("Most Reps (Session)", () {
      final result =
          mostRepsInSession(exerciseLogs: [legCurlExerciseLog1, lyingLegCurlExerciseLog2, legCurlExerciseLog3]);
      expect(result, (
        legCurlExerciseLog3.routineLogId,
        legCurlExerciseLog3.sets
            .map((set) => set as WeightAndRepsSetDto)
            .fold(0, (previousValue, set) => previousValue + set.reps)
      ));
    });

    test("Longest Duration", () {
      final result = longestDuration(exerciseLogs: [plankExerciseLog1, plankExerciseLog2]);
      expect(result, (plankExerciseLog1.routineLogId, (plankExerciseLog1.sets[1] as DurationSetDto).duration));
    });
  });

  group("Test PBs", () {
    test("Has [PBType.weight]", () {
      final pbLog = legCurlExerciseLog1.copyWith(sets: [
        const WeightAndRepsSetDto(weight: 80, reps: 12, checked: true),
        const WeightAndRepsSetDto(weight: 100, reps: 10, checked: true),
        const WeightAndRepsSetDto(weight: 160, reps: 6, checked: true)
      ]);

      final pbs = [PBDto(set: pbLog.sets[2], exercise: lyingLegCurlExercise, pb: PBType.weight)];

      final result = calculatePBs(
          pastExerciseLogs: [legCurlExerciseLog1, lyingLegCurlExerciseLog2],
          exerciseType: ExerciseType.weights,
          exerciseLog: pbLog);

      expect(result.length, 1);
      expect(result[0].pb, pbs[0].pb);
      expect(result[0].set, pbs[0].set);
      expect(result[0].exercise, pbs[0].exercise);
    });

    test("Has [PBType.volume]", () {
      final pbLog = legCurlExerciseLog1.copyWith(routineLogId: "routineLogId4", sets: [
        const WeightAndRepsSetDto(weight: 80, reps: 12, checked: true),
        const WeightAndRepsSetDto(weight: 150, reps: 20, checked: true),
        const WeightAndRepsSetDto(weight: 100, reps: 10, checked: true)
      ]);

      final pbs = [PBDto(set: pbLog.sets[1], exercise: lyingLegCurlExercise, pb: PBType.volume)];

      final result = calculatePBs(
          pastExerciseLogs: [legCurlExerciseLog1, lyingLegCurlExerciseLog2, legCurlExerciseLog3],
          exerciseType: ExerciseType.weights,
          exerciseLog: pbLog);

      expect(result.length, 1);
      expect(result[0].pb, pbs[0].pb);
      expect(result[0].set, pbs[0].set);
      expect(result[0].exercise, pbs[0].exercise);
    });

    test("Has [PBType.weight], PBType.volume]", () {
      final pbLog = legCurlExerciseLog1.copyWith(routineLogId: "routineLogId4", sets: [
        const WeightAndRepsSetDto(weight: 80, reps: 12, checked: true),
        const WeightAndRepsSetDto(weight: 160, reps: 12, checked: true),
        const WeightAndRepsSetDto(weight: 100, reps: 10, checked: true)
      ]);

      final pbs = [
        PBDto(set: pbLog.sets[1], exercise: lyingLegCurlExercise, pb: PBType.weight),
        PBDto(set: pbLog.sets[1], exercise: lyingLegCurlExercise, pb: PBType.volume)
      ];

      final result = calculatePBs(
          pastExerciseLogs: [legCurlExerciseLog1, lyingLegCurlExerciseLog2, legCurlExerciseLog3],
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
      final pbLog = plankExerciseLog1.copyWith(routineLogId: "routineLogId4", sets: [
        DurationSetDto(duration: const Duration(milliseconds: 110000), checked: true),
        DurationSetDto(duration: const Duration(milliseconds: 100000), checked: true),
        DurationSetDto(duration: const Duration(milliseconds: 220000), checked: true),
      ]);

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
      final pbLog1 = legCurlExerciseLog1.copyWith(sets: [
        const WeightAndRepsSetDto(weight: 80, reps: 12, checked: true),
        const WeightAndRepsSetDto(weight: 160, reps: 12, checked: true),
        const WeightAndRepsSetDto(weight: 100, reps: 10, checked: true)
      ]);

      final pbLog2 = plankExerciseLog1.copyWith(sets: [
        DurationSetDto(duration: const Duration(milliseconds: 110000), checked: true),
        DurationSetDto(duration: const Duration(milliseconds: 100000), checked: true),
        DurationSetDto(duration: const Duration(milliseconds: 220000), checked: true),
      ]);

      final pbLogs = [pbLog1, pbLog2];

      final pbs = [
        PBDto(set: pbLog1.sets[1], exercise: lyingLegCurlExercise, pb: PBType.weight),
        PBDto(set: pbLog1.sets[1], exercise: lyingLegCurlExercise, pb: PBType.volume),
        PBDto(set: pbLog2.sets[2], exercise: plankExercise, pb: PBType.duration)
      ];

      final result = pbLogs
          .map((log) => calculatePBs(
              pastExerciseLogs: [legCurlExerciseLog1, lyingLegCurlExerciseLog2, legCurlExerciseLog3],
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
  // Add your widget tests here
}
