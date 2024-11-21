import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_app/dtos/appsync/exercise_dtoo.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/dtos/pb_dto.dart';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/enums/exercise/exercise_metrics_enums.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/enums/pb_enums.dart';
import 'package:tracker_app/enums/template_changes_type_message_enums.dart';
import 'package:tracker_app/utils/exercise_logs_utils.dart';

void main() {

  final lyingLegCurlExercise = ExerciseDTO(
      type: "id_exercise1",
      name: "Lying Leg Curl",
      primaryMuscleGroup: MuscleGroup.hamstrings,
      secondaryMuscleGroups: [MuscleGroup.hamstrings],
      exerciseMetric: SetType.weightsAndReps,
      owner: "");

  final plankExercise = ExerciseDTO(
      type: "id_exercise2",
      name: "Plank",
      primaryMuscleGroup: MuscleGroup.abs,
      secondaryMuscleGroups: [MuscleGroup.hamstrings],
      exerciseMetric: SetType.duration,
      owner: "");

  final benchPressExercise = ExerciseDTO(
      type: "id_benchPressExercise",
      name: "Bench Press",
      primaryMuscleGroup: MuscleGroup.chest,
      secondaryMuscleGroups: [MuscleGroup.hamstrings],
      exerciseMetric: SetType.weightsAndReps,
      owner: "");

  final lyingLegCurlExerciseLog1 = ExerciseLogDTO(
      lyingLegCurlExercise.type,
      "routineLogId1",
      "superSetId",
      lyingLegCurlExercise,
      "notes",
      [
        const SetDTO(80, 15, true),
        const SetDTO(100, 8, true),
        const SetDTO(100, 6, true),
      ],
      DateTime(2023, 12, 1), []);

  final lyingLegCurlExerciseLog2 = ExerciseLogDTO(
      lyingLegCurlExercise.type,
      "routineLogId2",
      "superSetId",
      lyingLegCurlExercise,
      "notes",
      [
        const SetDTO(80, 12, true),
        const SetDTO(100, 10, true),
        const SetDTO(100, 6, true),
      ],
      DateTime(2023, 12, 1), []);

  final lyingLegCurlExerciseLog3 = ExerciseLogDTO(
      lyingLegCurlExercise.type,
      "routineLogId3",
      "superSetId",
      lyingLegCurlExercise,
      "notes",
      [
        const SetDTO(80, 12, true),
        const SetDTO(100, 10, true),
        const SetDTO(150, 11, true),
      ],
      DateTime(2023, 12, 1), []);

  final plankExerciseLog1 = ExerciseLogDTO(
      plankExercise.type,
      "routineLogId1",
      "superSetId",
      plankExercise,
      "notes",
      [
        const SetDTO(120000, 0, true),
        const SetDTO(180000, 0, true),
        const SetDTO(150000, 0, true),
      ],
      DateTime.now(), []);

  final plankExerciseLog2 = ExerciseLogDTO(
      plankExercise.type,
      "routineLogId2",
      "superSetId",
      plankExercise,
      "notes",
      [
        const SetDTO(110000, 0, true),
        const SetDTO(100000, 0, true),
        const SetDTO(120000, 0, true),
      ],
      DateTime.now(), []);

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
      final pbLog = ExerciseLogDTO(
          lyingLegCurlExercise.type,
          "routineLogId4",
          "superSetId",
          lyingLegCurlExercise,
          "notes",
          [
            const SetDTO(80, 12, true),
            const SetDTO(100, 10, true),
            const SetDTO(160, 6, true),
          ],
          DateTime.now(), []);

      final pbs = [PBDto(set: pbLog.sets[2], exerciseVariant: lyingLegCurlExercise, pb: PBType.weight)];

      final result = calculatePBs(
          pastExerciseLogs: [lyingLegCurlExerciseLog1, lyingLegCurlExerciseLog2],
          exerciseMetrics: SetType.weightsAndReps,
          exerciseLog: pbLog);

      expect(result.length, 1);
      expect(result[0].pb, pbs[0].pb);
      expect(result[0].set, pbs[0].set);
      expect(result[0].exerciseVariant, pbs[0].exerciseVariant);
    });

    test("Has [PBType.volume]", () {
      final pbLog = ExerciseLogDTO(
          lyingLegCurlExercise.type,
          "routineLogId4",
          "superSetId",
          lyingLegCurlExercise,
          "notes",
          [
            const SetDTO(80, 12, true),
            const SetDTO(150, 20, true),
            const SetDTO(100, 10, true),
          ],
          DateTime.now(), []);

      final pbs = [PBDto(set: pbLog.sets[1], exerciseVariant: lyingLegCurlExercise, pb: PBType.volume)];

      final result = calculatePBs(
          pastExerciseLogs: [lyingLegCurlExerciseLog1, lyingLegCurlExerciseLog2, lyingLegCurlExerciseLog3],
          exerciseMetrics: SetType.weightsAndReps,
          exerciseLog: pbLog);

      expect(result.length, 1);
      expect(result[0].pb, pbs[0].pb);
      expect(result[0].set, pbs[0].set);
      expect(result[0].exerciseVariant, pbs[0].exerciseVariant);
    });

    test("Has [PBType.weight], PBType.volume]", () {
      final pbLog = ExerciseLogDTO(
          lyingLegCurlExercise.type,
          "routineLogId4",
          "superSetId",
          lyingLegCurlExercise,
          "notes",
          [
            const SetDTO(80, 12, true),
            const SetDTO(160, 12, true),
            const SetDTO(100, 10, true),
          ],
          DateTime.now(), []);

      final pbs = [
        PBDto(set: pbLog.sets[1], exerciseVariant: lyingLegCurlExercise, pb: PBType.weight),
        PBDto(set: pbLog.sets[1], exerciseVariant: lyingLegCurlExercise, pb: PBType.volume)
      ];

      final result = calculatePBs(
          pastExerciseLogs: [lyingLegCurlExerciseLog1, lyingLegCurlExerciseLog2, lyingLegCurlExerciseLog3],
          exerciseMetrics: SetType.weightsAndReps,
          exerciseLog: pbLog);

      expect(result.length, 2);
      expect(result[0].pb, pbs[0].pb);
      expect(result[0].set, pbs[0].set);
      expect(result[1].pb, pbs[1].pb);
      expect(result[1].set, pbs[1].set);
      expect(result[0].exerciseVariant, pbs[0].exerciseVariant);
      expect(result[1].exerciseVariant, pbs[1].exerciseVariant);
    });

    test("Has [PBType.duration]", () {
      final pbLog = ExerciseLogDTO(
          plankExercise.type,
          "routineLogId4",
          "superSetId",
          plankExercise,
          "notes",
          [
            const SetDTO(110000, 0, true),
            const SetDTO(100000, 0, true),
            const SetDTO(220000, 0, true),
          ],
          DateTime.now(), []);

      final pbs = [PBDto(set: pbLog.sets[2], exerciseVariant: plankExercise, pb: PBType.duration)];

      final result = calculatePBs(
          pastExerciseLogs: [plankExerciseLog1, plankExerciseLog2],
          exerciseMetrics: SetType.duration,
          exerciseLog: pbLog);

      expect(result.length, 1);
      expect(result[0].pb, pbs[0].pb);
      expect(result[0].set, pbs[0].set);
      expect(result[0].exerciseVariant, pbs[0].exerciseVariant);
    });

    test("Has [PBType.weight, PBType.volume, PBType.durations]", () {
      final pbLog1 = ExerciseLogDTO(
          lyingLegCurlExercise.type,
          "routineLogId4",
          "superSetId",
          lyingLegCurlExercise,
          "notes",
          [
            const SetDTO(80, 12, true),
            const SetDTO(160, 12, true),
            const SetDTO(100, 10, true),
          ],
          DateTime.now(), []);

      final pbLog2 = ExerciseLogDTO(
          plankExercise.type,
          "routineLogId4",
          "superSetId",
          plankExercise,
          "notes",
          [
            const SetDTO(110000, 0, true),
            const SetDTO(100000, 0, true),
            const SetDTO(220000, 0, true),
          ],
          DateTime.now(), []);

      final pbLogs = [pbLog1, pbLog2];

      final pbs = [
        PBDto(set: pbLog1.sets[1], exerciseVariant: lyingLegCurlExercise, pb: PBType.weight),
        PBDto(set: pbLog1.sets[1], exerciseVariant: lyingLegCurlExercise, pb: PBType.volume),
        PBDto(set: pbLog2.sets[2], exerciseVariant: plankExercise, pb: PBType.duration)
      ];

      final result = pbLogs
          .map((log) => calculatePBs(
              pastExerciseLogs: [lyingLegCurlExerciseLog1, lyingLegCurlExerciseLog2, lyingLegCurlExerciseLog3],
              exerciseMetrics: log.exerciseVariant.exerciseMetric,
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
      expect(result[0].exerciseVariant, pbs[0].exerciseVariant);
      expect(result[1].exerciseVariant, pbs[1].exerciseVariant);
      expect(result[2].exerciseVariant, pbs[2].exerciseVariant);
    });
  });

group ("Template changes", () {
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
        exerciseLogs1: [plankExerciseLog1, lyingLegCurlExerciseLog1],
        exerciseLogs2: [plankExerciseLog1.copyWith(sets: plankExerciseLog1.sets.take(2).toList()), lyingLegCurlExerciseLog1.copyWith(sets: lyingLegCurlExerciseLog1.sets.take(2).toList())]);
    expect(result, TemplateChange.setsLength);
  });

  test("Different exercises", () {

    final newExerciseLog = ExerciseLogDTO(
        benchPressExercise.type,
        "routineLogId1",
        "superSetId",
        benchPressExercise,
        "notes",
        [
          const SetDTO(80, 12, true),
          const SetDTO(160, 12, true),
          const SetDTO(100, 10, true),
        ],
        DateTime.now(), []);

    final result = hasExercisesChanged(
        exerciseLogs1: [lyingLegCurlExerciseLog1, plankExerciseLog1],
        exerciseLogs2: [lyingLegCurlExerciseLog1, newExerciseLog]);
    expect(result, TemplateChange.exerciseLogChange);
  });

  test("Changed super set id", () {
    final result = hasSuperSetIdChanged(
        exerciseLogs1: [lyingLegCurlExerciseLog1, lyingLegCurlExerciseLog2.copyWith(superSetId: "123"), plankExerciseLog1.copyWith(superSetId: "123")],
        exerciseLogs2: [lyingLegCurlExerciseLog1, lyingLegCurlExerciseLog2.copyWith(superSetId: "890"), plankExerciseLog1.copyWith(superSetId: "890")]);
    expect(result, TemplateChange.supersetId);
  });

  test("Changed super set id", () {

    final updatedExerciseLog = lyingLegCurlExerciseLog2.copyWith(sets: [const SetDTO(80, 12, true), const SetDTO(100, 10, true), const SetDTO(150, 11, false)]);

    final result = hasCheckedSetsChanged(
        exerciseLogs1: [lyingLegCurlExerciseLog1, lyingLegCurlExerciseLog2],
        exerciseLogs2: [lyingLegCurlExerciseLog1, updatedExerciseLog]);
    expect(result, TemplateChange.checkedSets);
  });

  test("Changed set value", () {

    final updatedExerciseLog = lyingLegCurlExerciseLog2.copyWith(sets: [const SetDTO(80, 12, true), const SetDTO(100, 10, true), const SetDTO(160, 11, false)]);

    final result = hasSetValueChanged(
        exerciseLogs1: [lyingLegCurlExerciseLog1, lyingLegCurlExerciseLog2],
        exerciseLogs2: [lyingLegCurlExerciseLog1, updatedExerciseLog]);
    expect(result, TemplateChange.setValue);
  });
});
  // Add your widget tests here
}
