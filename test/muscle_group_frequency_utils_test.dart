import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_app/dtos/exercise_dto.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/enums/exercise/core_movements_enum.dart';
import 'package:tracker_app/enums/exercise/exercise_metrics_enums.dart';
import 'package:tracker_app/enums/exercise/exercise_modality_enum.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/utils/exercise_logs_utils.dart';

import 'date_utils.dart';

void main() {
  final hamstringExercise = ExerciseDTO(
    name: "Hamstring Exercise",
    primaryMuscleGroups: [MuscleGroup.hamstrings],
    secondaryMuscleGroups: [MuscleGroup.hamstrings],
    type: SetType.weightsAndReps,
    description: '',
    modality: ExerciseModality.bilateral,
    equipment: SetType.machine,
    coreMovement: CoreMovement.hinge,
  );

  final quadExercise = ExerciseDTO(
    name: "Quad Exercise",
    primaryMuscleGroups: [MuscleGroup.quadriceps],
    secondaryMuscleGroups: [MuscleGroup.quadriceps],
    type: SetType.weightsAndReps,
    description: '',
    modality: ExerciseModality.bilateral,
    equipment: SetType.machine,
    coreMovement: CoreMovement.squat,
  );

  final backExercise = ExerciseDTO(
      name: "Back Exercise",
      primaryMuscleGroups: [MuscleGroup.back],
      secondaryMuscleGroups: [MuscleGroup.back],
      type: SetType.weightsAndReps,
      description: '',
      modality: ExerciseModality.bilateral,
      equipment: SetType.machine,
      coreMovement: CoreMovement.pull);

  final trapsExercise = ExerciseDTO(
      name: "Traps Exercise",
      primaryMuscleGroups: [MuscleGroup.traps],
      secondaryMuscleGroups: [MuscleGroup.traps],
      type: SetType.weightsAndReps,
      description: '',
      modality: ExerciseModality.bilateral,
      equipment: SetType.machine,
      coreMovement: CoreMovement.pull);

  final chestExercise = ExerciseDTO(
      name: "Chest Exercise",
      primaryMuscleGroups: [MuscleGroup.chest],
      secondaryMuscleGroups: [MuscleGroup.chest],
      type: SetType.weightsAndReps,
      description: '',
      modality: ExerciseModality.bilateral,
      equipment: SetType.machine,
      coreMovement: CoreMovement.push);

  final shouldersExercise = ExerciseDTO(
      name: "Shoulders Exercise",
      primaryMuscleGroups: [MuscleGroup.shoulders],
      secondaryMuscleGroups: [MuscleGroup.shoulders],
      type: SetType.weightsAndReps,
      description: '',
      modality: ExerciseModality.bilateral,
      equipment: SetType.machine,
      coreMovement: CoreMovement.push);

  final bicepsExercise = ExerciseDTO(
      name: "Biceps Exercise",
      primaryMuscleGroups: [MuscleGroup.biceps],
      secondaryMuscleGroups: [MuscleGroup.biceps],
      type: SetType.weightsAndReps,
      description: '',
      modality: ExerciseModality.bilateral,
      equipment: SetType.machine,
      coreMovement: CoreMovement.push);

  final tricepsExercise = ExerciseDTO(
      name: "Triceps Exercise",
      primaryMuscleGroups: [MuscleGroup.triceps],
      secondaryMuscleGroups: [MuscleGroup.triceps],
      type: SetType.weightsAndReps,
      description: '',
      modality: ExerciseModality.bilateral,
      equipment: SetType.machine,
      coreMovement: CoreMovement.push);

  final abs = ExerciseDTO(
      name: "Abs Exercise",
      primaryMuscleGroups: [MuscleGroup.abs],
      secondaryMuscleGroups: [MuscleGroup.abs],
      type: SetType.weightsAndReps,
      description: '',
      modality: ExerciseModality.bilateral,
      equipment: SetType.machine,
      coreMovement: CoreMovement.pull);

  final neck = ExerciseDTO(
      name: "Neck Exercise",
      primaryMuscleGroups: [MuscleGroup.neck],
      secondaryMuscleGroups: [MuscleGroup.neck],
      type: SetType.weightsAndReps,
      description: '',
      modality: ExerciseModality.bilateral,
      equipment: SetType.machine,
      coreMovement: CoreMovement.others);

  final dayOneDateTimes = generateWeeklyDateTimes(size: 4, startDate: DateTime(2024, 1, 1));
  final dayTwoDateTimes = generateWeeklyDateTimes(size: 4, startDate: DateTime(2024, 1, 3));

  final hamstring1ExerciseLogs = List.generate(
      dayOneDateTimes.length,
      (index) => ExerciseLogDTO(
          hamstringExercise.type,
          "legDayOneSession$index",
          "",
          hamstringExercise,
          "notes",
          [
            const SetDTO(80, 15, true),
            const SetDTO(100, 8, true),
            const SetDTO(100, 6, true),
          ],
          dayOneDateTimes[index],
          []));
  final hamstring2ExerciseLogs = List.generate(
      dayOneDateTimes.length,
      (index) => ExerciseLogDTO(
          hamstringExercise.type,
          "legDayOneSession$index",
          "",
          hamstringExercise,
          "notes",
          [
            const SetDTO(80, 15, true),
            const SetDTO(100, 8, true),
            const SetDTO(100, 6, true),
          ],
          dayTwoDateTimes[index],
          []));

  final quad1ExerciseLogs = List.generate(
      dayTwoDateTimes.length,
      (index) => ExerciseLogDTO(
          quadExercise.type,
          "legDayTwoSession$index",
          "",
          quadExercise,
          "notes",
          [
            const SetDTO(80, 15, true),
            const SetDTO(100, 8, true),
            const SetDTO(100, 6, true),
          ],
          dayOneDateTimes[index],
          []));
  final quad2ExerciseLogs = List.generate(
      dayTwoDateTimes.length,
      (index) => ExerciseLogDTO(
          quadExercise.type,
          "legDayTwoSession$index",
          "",
          quadExercise,
          "notes",
          [
            const SetDTO(80, 15, true),
            const SetDTO(100, 8, true),
            const SetDTO(100, 6, true),
          ],
          dayTwoDateTimes[index],
          []));

  final chest1ExerciseLogs = List.generate(
      dayOneDateTimes.length,
      (index) => ExerciseLogDTO(
          chestExercise.type,
          "chestDayOneSession$index",
          "",
          chestExercise,
          "notes",
          [
            const SetDTO(80, 15, true),
            const SetDTO(100, 8, true),
            const SetDTO(100, 6, true),
          ],
          dayOneDateTimes[index],
          []));
  final chest2ExerciseLogs = List.generate(
      dayTwoDateTimes.length,
      (index) => ExerciseLogDTO(
          chestExercise.type,
          "chestDayTwoSession$index",
          "",
          chestExercise,
          "notes",
          [
            const SetDTO(80, 15, true),
            const SetDTO(100, 8, true),
            const SetDTO(100, 6, true),
          ],
          dayTwoDateTimes[index],
          []));

  final back1ExerciseLogs = List.generate(
      dayOneDateTimes.length,
      (index) => ExerciseLogDTO(
          backExercise.type,
          "backDayOneSession$index",
          "",
          backExercise,
          "notes",
          [
            const SetDTO(80, 15, true),
            const SetDTO(100, 8, true),
            const SetDTO(100, 6, true),
          ],
          dayOneDateTimes[index],
          []));
  final back2ExerciseLogs = List.generate(
      dayOneDateTimes.length,
      (index) => ExerciseLogDTO(
          backExercise.type,
          "backDayOneSession$index",
          "",
          backExercise,
          "notes",
          [
            const SetDTO(80, 15, true),
            const SetDTO(100, 8, true),
            const SetDTO(100, 6, true),
          ],
          dayTwoDateTimes[index],
          []));

  final traps1ExerciseLogs = List.generate(
      dayTwoDateTimes.length,
      (index) => ExerciseLogDTO(
          trapsExercise.type,
          "backDayTwoSession$index",
          "",
          trapsExercise,
          "notes",
          [
            const SetDTO(80, 15, true),
            const SetDTO(100, 8, true),
            const SetDTO(100, 6, true),
          ],
          dayOneDateTimes[index],
          []));
  final traps2ExerciseLogs = List.generate(
      dayTwoDateTimes.length,
      (index) => ExerciseLogDTO(
          trapsExercise.type,
          "backDayTwoSession$index",
          "",
          trapsExercise,
          "notes",
          [
            const SetDTO(80, 15, true),
            const SetDTO(100, 8, true),
            const SetDTO(100, 6, true),
          ],
          dayTwoDateTimes[index],
          []));

  final shoulders1ExerciseLogs = List.generate(
      dayOneDateTimes.length,
      (index) => ExerciseLogDTO(
          shouldersExercise.type,
          "shouldersDayOneSession$index",
          "",
          shouldersExercise,
          "notes",
          [
            const SetDTO(80, 15, true),
            const SetDTO(100, 8, true),
            const SetDTO(100, 6, true),
          ],
          dayOneDateTimes[index],
          []));
  final shoulders2ExerciseLogs = List.generate(
      dayTwoDateTimes.length,
      (index) => ExerciseLogDTO(
          shouldersExercise.type,
          "shouldersDayTwoSession$index",
          "",
          shouldersExercise,
          "notes",
          [
            const SetDTO(80, 15, true),
            const SetDTO(100, 8, true),
            const SetDTO(100, 6, true),
          ],
          dayTwoDateTimes[index],
          []));

  final biceps1ExerciseLogs = List.generate(
      dayOneDateTimes.length,
      (index) => ExerciseLogDTO(
          bicepsExercise.type,
          "bicepsDayOneSession$index",
          "",
          bicepsExercise,
          "notes",
          [
            const SetDTO(80, 15, true),
            const SetDTO(100, 8, true),
            const SetDTO(100, 6, true),
          ],
          dayTwoDateTimes[index],
          []));
  final biceps2ExerciseLogs = List.generate(
      dayTwoDateTimes.length,
      (index) => ExerciseLogDTO(
          bicepsExercise.type,
          "bicepsDayTwoSession$index",
          "",
          bicepsExercise,
          "notes",
          [
            const SetDTO(80, 15, true),
            const SetDTO(100, 8, true),
            const SetDTO(100, 6, true),
          ],
          dayTwoDateTimes[index],
          []));

  final triceps1ExerciseLogs = List.generate(
      dayOneDateTimes.length,
      (index) => ExerciseLogDTO(
          tricepsExercise.type,
          "tricepsDayOneSession$index",
          "",
          tricepsExercise,
          "notes",
          [
            const SetDTO(80, 15, true),
            const SetDTO(100, 8, true),
            const SetDTO(100, 6, true),
          ],
          dayOneDateTimes[index],
          []));
  final triceps2ExerciseLogs = List.generate(
      dayTwoDateTimes.length,
      (index) => ExerciseLogDTO(
          tricepsExercise.type,
          "tricepsDayTwoSession$index",
          "",
          tricepsExercise,
          "notes",
          [
            const SetDTO(80, 15, true),
            const SetDTO(100, 8, true),
            const SetDTO(100, 6, true),
          ],
          dayTwoDateTimes[index],
          []));

  final abs1ExerciseLogs = List.generate(
      dayOneDateTimes.length,
      (index) => ExerciseLogDTO(
          abs.type,
          "coreDayOneSession$index",
          "",
          abs,
          "notes",
          [
            const SetDTO(80, 15, true),
            const SetDTO(100, 8, true),
            const SetDTO(100, 6, true),
          ],
          dayOneDateTimes[index],
          []));
  final abs2ExerciseLogs = List.generate(
      dayTwoDateTimes.length,
      (index) => ExerciseLogDTO(
          abs.type,
          "coreDayTwoSession$index",
          "",
          abs,
          "notes",
          [
            const SetDTO(80, 15, true),
            const SetDTO(100, 8, true),
            const SetDTO(100, 6, true),
          ],
          dayTwoDateTimes[index],
          []));

  final neck1ExerciseLogs = List.generate(
      dayOneDateTimes.length,
      (index) => ExerciseLogDTO(
          abs.type,
          "neckDayOneSession$index",
          "",
          neck,
          "notes",
          [
            const SetDTO(80, 15, true),
            const SetDTO(100, 8, true),
            const SetDTO(100, 6, true),
          ],
          dayOneDateTimes[index],
          []));
  final neck2ExerciseLogs = List.generate(
      dayTwoDateTimes.length,
      (index) => ExerciseLogDTO(
          routineLogId: abs.type,
          superSetId: "neckDayTwoSession$index",
          "",
          exerciseVariant: neck,
          "notes",
          [
            const SetDTO(80, 15, true),
            const SetDTO(100, 8, true),
            const SetDTO(100, 6, true),
          ],
          dayTwoDateTimes[index],
          []));

  test("Has completed monthly single muscle target", () {
    final exerciseLogs = [
      ...hamstring1ExerciseLogs,
      ...quad2ExerciseLogs,
    ];

    final frequencyDistribution = muscleGroupFrequencyOn4WeeksScale(exerciseLogs: exerciseLogs);

    final legMuscleGroup = frequencyDistribution.entries;

    expect(legMuscleGroup.first.key, MuscleGroupFamily.legs);
    expect(legMuscleGroup.first.value, 1);
  });

  test("Has completed 50% monthly single muscle target", () {
    final exerciseLogs = [...hamstring1ExerciseLogs];

    final frequencyDistribution = muscleGroupFrequencyOn4WeeksScale(exerciseLogs: exerciseLogs);

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
