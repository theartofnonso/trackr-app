import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_app/dtos/appsync/exercise_dto.dart';
import 'package:tracker_app/dtos/appsync/routine_log_dto.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/dtos/milestones/reps_milestone.dart';
import 'package:tracker_app/dtos/set_dtos/reps_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/enums/milestone_type_enums.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';

void main() {
  group('RepsMilestone', () {
    test('loadMilestones returns a milestone for each muscle group with zero progress if no logs', () {
      final logs = <RoutineLogDto>[];
      final milestones = RepsMilestone.loadMilestones(logs: logs);

      // The code lists 14 muscle groups explicitly (abs, biceps, back, calves, chest, forearms, glutes,
      // hamstrings, lats, neck, shoulders, traps, triceps, quadriceps).
      expect(milestones.length, 14);

      final chestMilestone = milestones.firstWhere((m) => m.muscleGroup == MuscleGroup.chest);
      expect(chestMilestone.type, MilestoneType.reps);
      expect(chestMilestone.target, 1000);
      // The name should be uppercase of the returned string
      expect(chestMilestone.name, "PECTACULAR");
      // Progress should be (0, [])
      expect(chestMilestone.progress.$1, 0);
      expect(chestMilestone.progress.$2, isEmpty);
    });

    test('calculate progress with no logs', () {
      final milestones = RepsMilestone.loadMilestones(logs: []);
      for (final milestone in milestones) {
        final (progress, qualifyingLogs) = milestone.progress;
        expect(progress, 0);
        expect(qualifyingLogs, isEmpty);
      }
    });

    test('partial progress is calculated correctly', () {
      final chestExercise = ExerciseDto(
        id: 'chest-ex',
        name: 'Bench Press',
        primaryMuscleGroup: MuscleGroup.chest,
        secondaryMuscleGroups: [],
        type: ExerciseType.weights,
        owner: '',
      );

      final routineLog = RoutineLogDto(
        id: 'log1',
        templateId: 'temp1',
        name: 'Workout 1',
        notes: '',
        summary: null,
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        exerciseLogs: [
          ExerciseLogDto(
            id: 'exLog1',
            routineLogId: 'log1',
            superSetId: '',
            exercise: chestExercise,
            notes: '',
            sets: [
              RepsSetDto(reps: 200, checked: true),
              RepsSetDto(reps: 100, checked: true),
            ],
            createdAt: DateTime.now(),
          )
        ],
        owner: 'user',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final milestones = RepsMilestone.loadMilestones(logs: [routineLog]);

      final chestMilestone = milestones.firstWhere((milestone) => milestone.muscleGroup == MuscleGroup.chest);

      final (progress, qualifyingLogs) = chestMilestone.progress;

      expect(progress, (300 / 1000));
      expect(qualifyingLogs.length, 1);
      expect(qualifyingLogs.first, routineLog);
    });

    test('progress caps at 1.0 when target exceeded', () {
      final chestExercise = ExerciseDto(
        id: 'chest-ex',
        name: 'Bench Press',
        primaryMuscleGroup: MuscleGroup.chest,
        secondaryMuscleGroups: [],
        type: ExerciseType.weights,
        owner: '',
      );

      final routineLog = RoutineLogDto(
        id: 'log1',
        templateId: 'temp1',
        name: 'Workout 1',
        notes: '',
        summary: null,
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        exerciseLogs: [
          ExerciseLogDto(
            id: 'exLog1',
            routineLogId: 'log1',
            superSetId: '',
            exercise: chestExercise,
            notes: '',
            sets: [
              RepsSetDto(reps: 500, checked: true),
              RepsSetDto(reps: 600, checked: true), // total 1100 reps
            ],
            createdAt: DateTime.now(),
          )
        ],
        owner: 'user',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final milestones = RepsMilestone.loadMilestones(logs: [routineLog]);

      final chestMilestone = milestones.firstWhere((milestone) => milestone.muscleGroup == MuscleGroup.chest);

      final (progress, qualifyingLogs) = chestMilestone.progress;

      expect(progress, 1.0);
      expect(qualifyingLogs.length, 1);
    });

    test('only logs targeting the correct muscle group are counted', () {
      final chestExercise = ExerciseDto(
        id: 'chest-ex',
        name: 'Chest Press',
        primaryMuscleGroup: MuscleGroup.chest,
        secondaryMuscleGroups: [],
        type: ExerciseType.weights,
        owner: '',
      );

      final bicepExercise = ExerciseDto(
        id: 'bicep-ex',
        name: 'Bicep Curl',
        primaryMuscleGroup: MuscleGroup.biceps,
        secondaryMuscleGroups: [],
        type: ExerciseType.bodyWeight,
        owner: '',
      );

      final routineLog = RoutineLogDto(
        id: 'log1',
        templateId: 'temp1',
        name: 'Workout 1',
        notes: '',
        summary: null,
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        exerciseLogs: [
          ExerciseLogDto(
            id: 'exLogChest',
            routineLogId: 'log1',
            superSetId: '',
            exercise: chestExercise,
            notes: '',
            sets: [
              RepsSetDto(reps: 200, checked: true),
              RepsSetDto(reps: 200, checked: true),
            ],
            createdAt: DateTime.now(),
          ),
          ExerciseLogDto(
            id: 'exLogBicep',
            routineLogId: 'log1',
            superSetId: '',
            exercise: bicepExercise,
            notes: '',
            sets: [
              RepsSetDto(reps: 300, checked: true),
              RepsSetDto(reps: 300, checked: true),
            ],
            createdAt: DateTime.now(),
          ),
        ],
        owner: 'user',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Chest progress
      final milestonesWithChest = RepsMilestone.loadMilestones(logs: [routineLog]);

      final chestMilestone = milestonesWithChest.firstWhere((milestone) => milestone.muscleGroup == MuscleGroup.chest);

      final (chestProgress, chestLogs) = chestMilestone.progress;

      expect(chestProgress, 400 / 1000);
      expect(chestLogs.length, 1);

      // Biceps progress
      final milestonesWithBiceps = RepsMilestone.loadMilestones(logs: [routineLog]);

      final bicepsMilestone =
          milestonesWithBiceps.firstWhere((milestone) => milestone.muscleGroup == MuscleGroup.biceps);

      final (bicepsProgress, bicepsLogs) = bicepsMilestone.progress;

      expect(bicepsProgress, 600 / 1000);
      expect(bicepsLogs.length, 1);

      // Abs (not targeted)

      final milestonesWithoutAbs = RepsMilestone.loadMilestones(logs: [routineLog]);

      final absMilestone = milestonesWithoutAbs.firstWhere((milestone) => milestone.muscleGroup == MuscleGroup.abs);

      final (absProgress, absLogs) = absMilestone.progress;

      expect(absProgress, 0);
      expect(absLogs, isEmpty);
    });
  });
}
