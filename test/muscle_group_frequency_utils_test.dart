import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_app/dtos/exercise_dto.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/utils/exercise_logs_utils.dart';

import 'date_utils.dart';

void main() {

  final hamstringExercise = ExerciseDto(
      id: "id_hamstring_exercise",
      name: "Hamstring Exercise",
      primaryMuscleGroup: MuscleGroup.hamstrings,
      type: ExerciseType.weights,
      owner: false);

  final quadExercise = ExerciseDto(
      id: "id_quad_exercise",
      name: "Quad Exercise",
      primaryMuscleGroup: MuscleGroup.quadriceps,
      type: ExerciseType.weights,
      owner: false);

  final backExercise = ExerciseDto(
      id: "id_back_exercise",
      name: "Back Exercise",
      primaryMuscleGroup: MuscleGroup.back,
      type: ExerciseType.weights,
      owner: false);

  final trapsExercise = ExerciseDto(
      id: "id_traps_exercise",
      name: "Traps Exercise",
      primaryMuscleGroup: MuscleGroup.traps,
      type: ExerciseType.weights,
      owner: false);

  final chestExercise = ExerciseDto(
      id: "id_chest_exercise",
      name: "Chest Exercise",
      primaryMuscleGroup: MuscleGroup.chest,
      type: ExerciseType.weights,
      owner: false);

  final shouldersExercise = ExerciseDto(
      id: "id_shoulders_exercise",
      name: "Shoulders Exercise",
      primaryMuscleGroup: MuscleGroup.shoulders,
      type: ExerciseType.weights,
      owner: false);

  final bicepsExercise = ExerciseDto(
      id: "id_biceps_exercise",
      name: "Biceps Exercise",
      primaryMuscleGroup: MuscleGroup.biceps,
      type: ExerciseType.weights,
      owner: false);

  final tricepsExercise = ExerciseDto(
      id: "id_triceps_exercise",
      name: "Triceps Exercise",
      primaryMuscleGroup: MuscleGroup.triceps,
      type: ExerciseType.weights,
      owner: false);

  final abs = ExerciseDto(
      id: "id_abs",
      name: "Abs Exercise",
      primaryMuscleGroup: MuscleGroup.abs,
      type: ExerciseType.duration,
      owner: false);

  final dayOneDateTimes = generateWeeklyDateTimes(size: 4, startDate: DateTime(2024, 1, 1));
  final dayTwoDateTimes = generateWeeklyDateTimes(size: 4, startDate: DateTime(2024, 1, 3));

  final hamstringExerciseLogs = List.generate(dayOneDateTimes.length, (index) => ExerciseLogDto(
      hamstringExercise.id,
      "routineLogId1",
      "",
      hamstringExercise,
      "notes",
      [
        const SetDto(80, 15, true),
        const SetDto(100, 8, true),
        const SetDto(100, 6, true),
      ],
      dayOneDateTimes[index]));
  final quadExerciseLogs = List.generate(dayTwoDateTimes.length, (index) => ExerciseLogDto(
      quadExercise.id,
      "routineLogId1",
      "",
      quadExercise,
      "notes",
      [
        const SetDto(80, 15, true),
        const SetDto(100, 8, true),
        const SetDto(100, 6, true),
      ],
      dayTwoDateTimes[index]));

  final chest1ExerciseLogs = List.generate(dayOneDateTimes.length, (index) => ExerciseLogDto(
      chestExercise.id,
      "routineLogId1",
      "",
      chestExercise,
      "notes",
      [
        const SetDto(80, 15, true),
        const SetDto(100, 8, true),
        const SetDto(100, 6, true),
      ],
      dayOneDateTimes[index]));
  final chest2ExerciseLogs = List.generate(dayTwoDateTimes.length, (index) => ExerciseLogDto(
      chestExercise.id,
      "routineLogId1",
      "",
      chestExercise,
      "notes",
      [
        const SetDto(80, 15, true),
        const SetDto(100, 8, true),
        const SetDto(100, 6, true),
      ],
      dayTwoDateTimes[index]));

  final backExerciseLogs = List.generate(dayOneDateTimes.length, (index) => ExerciseLogDto(
      backExercise.id,
      "routineLogId1",
      "",
      backExercise,
      "notes",
      [
        const SetDto(80, 15, true),
        const SetDto(100, 8, true),
        const SetDto(100, 6, true),
      ],
      dayOneDateTimes[index]));
  final trapsExerciseLogs = List.generate(dayTwoDateTimes.length, (index) => ExerciseLogDto(
      trapsExercise.id,
      "routineLogId1",
      "",
      trapsExercise,
      "notes",
      [
        const SetDto(80, 15, true),
        const SetDto(100, 8, true),
        const SetDto(100, 6, true),
      ],
      dayTwoDateTimes[index]));

  final shoulders1ExerciseLogs = List.generate(dayOneDateTimes.length, (index) => ExerciseLogDto(
      shouldersExercise.id,
      "routineLogId1",
      "",
      shouldersExercise,
      "notes",
      [
        const SetDto(80, 15, true),
        const SetDto(100, 8, true),
        const SetDto(100, 6, true),
      ],
      dayOneDateTimes[index]));
  final shoulders2ExerciseLogs = List.generate(dayTwoDateTimes.length, (index) => ExerciseLogDto(
      shouldersExercise.id,
      "routineLogId1",
      "",
      shouldersExercise,
      "notes",
      [
        const SetDto(80, 15, true),
        const SetDto(100, 8, true),
        const SetDto(100, 6, true),
      ],
      dayTwoDateTimes[index]));

  final biceps1ExerciseLogs = List.generate(dayOneDateTimes.length, (index) => ExerciseLogDto(
      bicepsExercise.id,
      "routineLogId1",
      "",
      bicepsExercise,
      "notes",
      [
        const SetDto(80, 15, true),
        const SetDto(100, 8, true),
        const SetDto(100, 6, true),
      ],
      dayTwoDateTimes[index]));
  final biceps2ExerciseLogs = List.generate(dayTwoDateTimes.length, (index) => ExerciseLogDto(
      bicepsExercise.id,
      "routineLogId1",
      "",
      bicepsExercise,
      "notes",
      [
        const SetDto(80, 15, true),
        const SetDto(100, 8, true),
        const SetDto(100, 6, true),
      ],
      dayTwoDateTimes[index]));

  final triceps1ExerciseLogs = List.generate(dayOneDateTimes.length, (index) => ExerciseLogDto(
      tricepsExercise.id,
      "routineLogId1",
      "",
      tricepsExercise,
      "notes",
      [
        const SetDto(80, 15, true),
        const SetDto(100, 8, true),
        const SetDto(100, 6, true),
      ],
      dayOneDateTimes[index]));
  final triceps2ExerciseLogs = List.generate(dayTwoDateTimes.length, (index) => ExerciseLogDto(
      tricepsExercise.id,
      "routineLogId1",
      "",
      tricepsExercise,
      "notes",
      [
        const SetDto(80, 15, true),
        const SetDto(100, 8, true),
        const SetDto(100, 6, true),
      ],
      dayTwoDateTimes[index]));

  final abs1ExerciseLogs = List.generate(dayOneDateTimes.length, (index) => ExerciseLogDto(
      abs.id,
      "routineLogId1",
      "",
      abs,
      "notes",
      [
        const SetDto(80, 15, true),
        const SetDto(100, 8, true),
        const SetDto(100, 6, true),
      ],
      dayOneDateTimes[index]));
  final abs2ExerciseLogs = List.generate(dayTwoDateTimes.length, (index) => ExerciseLogDto(
      abs.id,
      "routineLogId1",
      "",
      abs,
      "notes",
      [
        const SetDto(80, 15, true),
        const SetDto(100, 8, true),
        const SetDto(100, 6, true),
      ],
      dayTwoDateTimes[index]));

  test("Has completed monthly single muscle target", () {

    final exerciseLogs = [
      ...hamstringExerciseLogs,
      ...quadExerciseLogs,
    ];

    final frequencyDistribution = weeklyScaledMuscleGroupFamilyFrequencies(exerciseLogs: exerciseLogs);

    final legMuscleGroup = frequencyDistribution.entries;

    expect(legMuscleGroup.first.key, MuscleGroupFamily.legs);
    expect(legMuscleGroup.first.value, 1);
  });

  test("Has completed 50% monthly single muscle target", () {

    final exerciseLogs = [
      ...hamstringExerciseLogs
    ];

    final frequencyDistribution = weeklyScaledMuscleGroupFamilyFrequencies(exerciseLogs: exerciseLogs);

    final legMuscleGroup = frequencyDistribution.entries;

    expect(legMuscleGroup.first.key, MuscleGroupFamily.legs);
    expect(legMuscleGroup.first.value, 0.5);
  });

  test("Has achieved 100% monthly muscle score", () {

    final exerciseLogs = [
      ...hamstringExerciseLogs,
      ...quadExerciseLogs,
      ...chest1ExerciseLogs,
      ...chest2ExerciseLogs,
      ...backExerciseLogs,
      ...trapsExerciseLogs,
      ...shoulders1ExerciseLogs,
      ...shoulders2ExerciseLogs,
      ...biceps1ExerciseLogs,
      ...biceps2ExerciseLogs,
      ...triceps1ExerciseLogs,
      ...triceps2ExerciseLogs,
      ...abs1ExerciseLogs,
      ...abs2ExerciseLogs,
    ];

    final score = cumulativeMuscleGroupFamilyFrequencies(exerciseLogs: exerciseLogs);

    expect(score, 1);
  });

}