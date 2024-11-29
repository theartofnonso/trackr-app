import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_app/dtos/appsync/exercise_dto.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/dtos/set_dtos/weight_and_reps_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/utils/exercise_logs_utils.dart';

import 'date_utils.dart';

void main() {
  final hamstringExercise = ExerciseDto(
      id: "id_hamstring_exercise",
      name: "Hamstring Exercise",
      primaryMuscleGroup: MuscleGroup.hamstrings,
      secondaryMuscleGroups: [MuscleGroup.hamstrings],
      type: ExerciseType.weights,
      owner: "");

  final quadExercise = ExerciseDto(
      id: "id_quad_exercise",
      name: "Quad Exercise",
      primaryMuscleGroup: MuscleGroup.quadriceps,
      secondaryMuscleGroups: [MuscleGroup.hamstrings],
      type: ExerciseType.weights,
      owner: "");

  final backExercise = ExerciseDto(
      id: "id_back_exercise",
      name: "Back Exercise",
      primaryMuscleGroup: MuscleGroup.lats,
      secondaryMuscleGroups: [MuscleGroup.hamstrings],
      type: ExerciseType.weights,
      owner: "");

  final trapsExercise = ExerciseDto(
      id: "id_traps_exercise",
      name: "Traps Exercise",
      primaryMuscleGroup: MuscleGroup.traps,
      secondaryMuscleGroups: [MuscleGroup.hamstrings],
      type: ExerciseType.weights,
      owner: "");

  final chestExercise = ExerciseDto(
      id: "id_chest_exercise",
      name: "Chest Exercise",
      primaryMuscleGroup: MuscleGroup.chest,
      secondaryMuscleGroups: [MuscleGroup.hamstrings],
      type: ExerciseType.weights,
      owner: "");

  final shouldersExercise = ExerciseDto(
      id: "id_shoulders_exercise",
      name: "Shoulders Exercise",
      primaryMuscleGroup: MuscleGroup.shoulders,
      secondaryMuscleGroups: [MuscleGroup.hamstrings],
      type: ExerciseType.weights,
      owner: "");

  final bicepsExercise = ExerciseDto(
      id: "id_biceps_exercise",
      name: "Biceps Exercise",
      primaryMuscleGroup: MuscleGroup.biceps,
      secondaryMuscleGroups: [MuscleGroup.hamstrings],
      type: ExerciseType.weights,
      owner: "");

  final tricepsExercise = ExerciseDto(
      id: "id_triceps_exercise",
      name: "Triceps Exercise",
      primaryMuscleGroup: MuscleGroup.triceps,
      secondaryMuscleGroups: [MuscleGroup.hamstrings],
      type: ExerciseType.weights,
      owner: "");

  final abs = ExerciseDto(
      id: "id_abs",
      name: "Abs Exercise",
      primaryMuscleGroup: MuscleGroup.abs,
      secondaryMuscleGroups: [MuscleGroup.hamstrings],
      type: ExerciseType.duration,
      owner: "");

  final neck = ExerciseDto(
      id: "id_neck",
      name: "Neck Exercise",
      primaryMuscleGroup: MuscleGroup.neck,
      secondaryMuscleGroups: [MuscleGroup.neck],
      type: ExerciseType.weights,
      owner: "");

  final dayOneDateTimes = generateWeeklyDateTimes(size: 4, startDate: DateTime(2024, 1, 1));
  final dayTwoDateTimes = generateWeeklyDateTimes(size: 4, startDate: DateTime(2024, 1, 3));

  final hamstring1ExerciseLogs = List.generate(
      dayOneDateTimes.length,
      (index) => ExerciseLogDto(
            id: "hamstring1ExerciseLog$index",
            routineLogId: "legDayOneSession$index",
            superSetId: "",
            exercise: hamstringExercise,
            notes: "notes",
            sets: [
              const WeightAndRepsSetDto(weight: 80.0, reps: 15, checked: true),
              const WeightAndRepsSetDto(weight: 100.0, reps: 8, checked: true),
              const WeightAndRepsSetDto(weight: 100.0, reps: 6, checked: true),
            ],
            createdAt: dayOneDateTimes[index],
          ));

  final hamstring2ExerciseLogs = List.generate(
      dayTwoDateTimes.length,
      (index) => ExerciseLogDto(
            id: "hamstring2ExerciseLog$index",
            routineLogId: "legDayOneSession$index",
            superSetId: "",
            exercise: hamstringExercise,
            notes: "notes",
            sets: [
              const WeightAndRepsSetDto(weight: 80.0, reps: 15, checked: true),
              const WeightAndRepsSetDto(weight: 100.0, reps: 8, checked: true),
              const WeightAndRepsSetDto(weight: 100.0, reps: 6, checked: true),
            ],
            createdAt: dayTwoDateTimes[index],
          ));

  final quad1ExerciseLogs = List.generate(
      dayTwoDateTimes.length,
      (index) => ExerciseLogDto(
            id: "quad1ExerciseLog$index",
            routineLogId: "legDayTwoSession$index",
            superSetId: "",
            exercise: quadExercise,
            notes: "notes",
            sets: [
              const WeightAndRepsSetDto(weight: 80.0, reps: 15, checked: true),
              const WeightAndRepsSetDto(weight: 100.0, reps: 8, checked: true),
              const WeightAndRepsSetDto(weight: 100.0, reps: 6, checked: true),
            ],
            createdAt: dayOneDateTimes[index],
          ));

  final quad2ExerciseLogs = List.generate(
      dayTwoDateTimes.length,
      (index) => ExerciseLogDto(
            id: "quad2ExerciseLog$index",
            routineLogId: "legDayTwoSession$index",
            superSetId: "",
            exercise: quadExercise,
            notes: "notes",
            sets: [
              const WeightAndRepsSetDto(weight: 80.0, reps: 15, checked: true),
              const WeightAndRepsSetDto(weight: 100.0, reps: 8, checked: true),
              const WeightAndRepsSetDto(weight: 100.0, reps: 6, checked: true),
            ],
            createdAt: dayTwoDateTimes[index],
          ));

  final chest1ExerciseLogs = List.generate(
      dayOneDateTimes.length,
      (index) => ExerciseLogDto(
            id: "chest1ExerciseLog$index",
            routineLogId: "chestDayOneSession$index",
            superSetId: "",
            exercise: chestExercise,
            notes: "notes",
            sets: [
              const WeightAndRepsSetDto(weight: 80.0, reps: 15, checked: true),
              const WeightAndRepsSetDto(weight: 100.0, reps: 8, checked: true),
              const WeightAndRepsSetDto(weight: 100.0, reps: 6, checked: true),
            ],
            createdAt: dayOneDateTimes[index],
          ));

  final chest2ExerciseLogs = List.generate(
      dayTwoDateTimes.length,
      (index) => ExerciseLogDto(
            id: "chest2ExerciseLog$index",
            routineLogId: "chestDayTwoSession$index",
            superSetId: "",
            exercise: chestExercise,
            notes: "notes",
            sets: [
              const WeightAndRepsSetDto(weight: 80.0, reps: 15, checked: true),
              const WeightAndRepsSetDto(weight: 100.0, reps: 8, checked: true),
              const WeightAndRepsSetDto(weight: 100.0, reps: 6, checked: true),
            ],
            createdAt: dayTwoDateTimes[index],
          ));

  final back1ExerciseLogs = List.generate(
      dayOneDateTimes.length,
      (index) => ExerciseLogDto(
            id: "back1ExerciseLog$index",
            routineLogId: "backDayOneSession$index",
            superSetId: "",
            exercise: backExercise,
            notes: "notes",
            sets: [
              const WeightAndRepsSetDto(weight: 80.0, reps: 15, checked: true),
              const WeightAndRepsSetDto(weight: 100.0, reps: 8, checked: true),
              const WeightAndRepsSetDto(weight: 100.0, reps: 6, checked: true),
            ],
            createdAt: dayOneDateTimes[index],
          ));

  final back2ExerciseLogs = List.generate(
      dayTwoDateTimes.length,
      (index) => ExerciseLogDto(
            id: "back2ExerciseLog$index",
            routineLogId: "backDayTwoSession$index",
            superSetId: "",
            exercise: backExercise,
            notes: "notes",
            sets: [
              const WeightAndRepsSetDto(weight: 80.0, reps: 15, checked: true),
              const WeightAndRepsSetDto(weight: 100.0, reps: 8, checked: true),
              const WeightAndRepsSetDto(weight: 100.0, reps: 6, checked: true),
            ],
            createdAt: dayTwoDateTimes[index],
          ));

  final traps1ExerciseLogs = List.generate(
      dayTwoDateTimes.length,
      (index) => ExerciseLogDto(
            id: "traps1ExerciseLog$index",
            routineLogId: "backDayTwoSession$index",
            superSetId: "",
            exercise: trapsExercise,
            notes: "notes",
            sets: [
              const WeightAndRepsSetDto(weight: 80.0, reps: 15, checked: true),
              const WeightAndRepsSetDto(weight: 100.0, reps: 8, checked: true),
              const WeightAndRepsSetDto(weight: 100.0, reps: 6, checked: true),
            ],
            createdAt: dayOneDateTimes[index],
          ));

  final traps2ExerciseLogs = List.generate(
      dayTwoDateTimes.length,
      (index) => ExerciseLogDto(
            id: "traps2ExerciseLog$index",
            routineLogId: "backDayTwoSession$index",
            superSetId: "",
            exercise: trapsExercise,
            notes: "notes",
            sets: [
              const WeightAndRepsSetDto(weight: 80.0, reps: 15, checked: true),
              const WeightAndRepsSetDto(weight: 100.0, reps: 8, checked: true),
              const WeightAndRepsSetDto(weight: 100.0, reps: 6, checked: true),
            ],
            createdAt: dayTwoDateTimes[index],
          ));

  final shoulders1ExerciseLogs = List.generate(
      dayOneDateTimes.length,
      (index) => ExerciseLogDto(
            id: "shoulders1ExerciseLog$index",
            routineLogId: "shouldersDayOneSession$index",
            superSetId: "",
            exercise: shouldersExercise,
            notes: "notes",
            sets: [
              const WeightAndRepsSetDto(weight: 80.0, reps: 15, checked: true),
              const WeightAndRepsSetDto(weight: 100.0, reps: 8, checked: true),
              const WeightAndRepsSetDto(weight: 100.0, reps: 6, checked: true),
            ],
            createdAt: dayOneDateTimes[index],
          ));

  final shoulders2ExerciseLogs = List.generate(
      dayTwoDateTimes.length,
      (index) => ExerciseLogDto(
            id: "shoulders2ExerciseLog$index",
            routineLogId: "shouldersDayTwoSession$index",
            superSetId: "",
            exercise: shouldersExercise,
            notes: "notes",
            sets: [
              const WeightAndRepsSetDto(weight: 80.0, reps: 15, checked: true),
              const WeightAndRepsSetDto(weight: 100.0, reps: 8, checked: true),
              const WeightAndRepsSetDto(weight: 100.0, reps: 6, checked: true),
            ],
            createdAt: dayTwoDateTimes[index],
          ));

  final biceps1ExerciseLogs = List.generate(
      dayOneDateTimes.length,
      (index) => ExerciseLogDto(
            id: "biceps1ExerciseLog$index",
            routineLogId: "bicepsDayOneSession$index",
            superSetId: "",
            exercise: bicepsExercise,
            notes: "notes",
            sets: [
              const WeightAndRepsSetDto(weight: 80.0, reps: 15, checked: true),
              const WeightAndRepsSetDto(weight: 100.0, reps: 8, checked: true),
              const WeightAndRepsSetDto(weight: 100.0, reps: 6, checked: true),
            ],
            createdAt: dayTwoDateTimes[index],
          ));

  final biceps2ExerciseLogs = List.generate(
      dayTwoDateTimes.length,
      (index) => ExerciseLogDto(
            id: "biceps2ExerciseLog$index",
            routineLogId: "bicepsDayTwoSession$index",
            superSetId: "",
            exercise: bicepsExercise,
            notes: "notes",
            sets: [
              const WeightAndRepsSetDto(weight: 80.0, reps: 15, checked: true),
              const WeightAndRepsSetDto(weight: 100.0, reps: 8, checked: true),
              const WeightAndRepsSetDto(weight: 100.0, reps: 6, checked: true),
            ],
            createdAt: dayTwoDateTimes[index],
          ));

  final triceps1ExerciseLogs = List.generate(
      dayOneDateTimes.length,
      (index) => ExerciseLogDto(
            id: "triceps1ExerciseLog$index",
            routineLogId: "tricepsDayOneSession$index",
            superSetId: "",
            exercise: tricepsExercise,
            notes: "notes",
            sets: [
              const WeightAndRepsSetDto(weight: 80.0, reps: 15, checked: true),
              const WeightAndRepsSetDto(weight: 100.0, reps: 8, checked: true),
              const WeightAndRepsSetDto(weight: 100.0, reps: 6, checked: true),
            ],
            createdAt: dayOneDateTimes[index],
          ));

  final triceps2ExerciseLogs = List.generate(
      dayTwoDateTimes.length,
      (index) => ExerciseLogDto(
            id: "triceps2ExerciseLog$index",
            routineLogId: "tricepsDayTwoSession$index",
            superSetId: "",
            exercise: tricepsExercise,
            notes: "notes",
            sets: [
              const WeightAndRepsSetDto(weight: 80.0, reps: 15, checked: true),
              const WeightAndRepsSetDto(weight: 100.0, reps: 8, checked: true),
              const WeightAndRepsSetDto(weight: 100.0, reps: 6, checked: true),
            ],
            createdAt: dayTwoDateTimes[index],
          ));

  final abs1ExerciseLogs = List.generate(
      dayOneDateTimes.length,
      (index) => ExerciseLogDto(
            id: "abs1ExerciseLog$index",
            routineLogId: "coreDayOneSession$index",
            superSetId: "",
            exercise: abs,
            notes: "notes",
            sets: [
              const WeightAndRepsSetDto(weight: 80.0, reps: 15, checked: true),
              const WeightAndRepsSetDto(weight: 100.0, reps: 8, checked: true),
              const WeightAndRepsSetDto(weight: 100.0, reps: 6, checked: true),
            ],
            createdAt: dayOneDateTimes[index],
          ));

  final abs2ExerciseLogs = List.generate(
      dayTwoDateTimes.length,
      (index) => ExerciseLogDto(
            id: "abs2ExerciseLog$index",
            routineLogId: "coreDayTwoSession$index",
            superSetId: "",
            exercise: abs,
            notes: "notes",
            sets: [
              const WeightAndRepsSetDto(weight: 80.0, reps: 15, checked: true),
              const WeightAndRepsSetDto(weight: 100.0, reps: 8, checked: true),
              const WeightAndRepsSetDto(weight: 100.0, reps: 6, checked: true),
            ],
            createdAt: dayTwoDateTimes[index],
          ));

  final neck1ExerciseLogs = List.generate(
      dayOneDateTimes.length,
      (index) => ExerciseLogDto(
            id: "neck1ExerciseLog$index",
            routineLogId: "neckDayOneSession$index",
            superSetId: "",
            exercise: neck,
            notes: "notes",
            sets: [
              const WeightAndRepsSetDto(weight: 80.0, reps: 15, checked: true),
              const WeightAndRepsSetDto(weight: 100.0, reps: 8, checked: true),
              const WeightAndRepsSetDto(weight: 100.0, reps: 6, checked: true),
            ],
            createdAt: dayOneDateTimes[index],
          ));

  final neck2ExerciseLogs = List.generate(
      dayTwoDateTimes.length,
      (index) => ExerciseLogDto(
            id: "neck2ExerciseLog$index",
            routineLogId: "neckDayTwoSession$index",
            superSetId: "",
            exercise: neck,
            notes: "notes",
            sets: [
              const WeightAndRepsSetDto(weight: 80.0, reps: 15, checked: true),
              const WeightAndRepsSetDto(weight: 100.0, reps: 8, checked: true),
              const WeightAndRepsSetDto(weight: 100.0, reps: 6, checked: true),
            ],
            createdAt: dayTwoDateTimes[index],
          ));

  test("Has completed monthly single muscle target", () {
    final exerciseLogs = [
      ...hamstring1ExerciseLogs,
      ...quad2ExerciseLogs,
    ];

    final frequencyDistribution = muscleGroupFamilyFrequencyOn4WeeksScale(exerciseLogs: exerciseLogs);

    final legMuscleGroup = frequencyDistribution.entries;

    expect(legMuscleGroup.first.key, MuscleGroupFamily.legs);
    expect(legMuscleGroup.first.value, 1);
  });

  test("Has completed 50% monthly single muscle target", () {
    final exerciseLogs = [...hamstring1ExerciseLogs];

    final frequencyDistribution = muscleGroupFamilyFrequencyOn4WeeksScale(exerciseLogs: exerciseLogs);

    final legMuscleGroup = frequencyDistribution.entries;

    expect(legMuscleGroup.first.key, MuscleGroupFamily.legs);
    expect(legMuscleGroup.first.value, 0.5);
  });

  test("Has achieved 100% monthly muscle score", () {
    final exerciseLogs = [
      ...hamstring1ExerciseLogs,
      ...hamstring2ExerciseLogs,
      ...quad1ExerciseLogs,
      ...quad2ExerciseLogs,
      ...chest1ExerciseLogs,
      ...chest2ExerciseLogs,
      ...back1ExerciseLogs,
      ...back2ExerciseLogs,
      ...traps1ExerciseLogs,
      ...traps2ExerciseLogs,
      ...shoulders1ExerciseLogs,
      ...shoulders2ExerciseLogs,
      ...biceps1ExerciseLogs,
      ...biceps2ExerciseLogs,
      ...triceps1ExerciseLogs,
      ...triceps2ExerciseLogs,
      ...abs1ExerciseLogs,
      ...abs2ExerciseLogs,
      ...neck1ExerciseLogs,
      ...neck2ExerciseLogs
    ];

    final score = cumulativeMuscleGroupFamilyFrequency(exerciseLogs: exerciseLogs);
    expect(score, 1.0);
  });
}
