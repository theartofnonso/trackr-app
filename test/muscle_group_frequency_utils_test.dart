import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/utils/exercise_logs_utils.dart';

import 'exercise_utils.dart'; // Ensure this path matches your project structure

void main() {
  group('muscleGroupFamilyFrequency', () {
    test('returns empty map for no exercise logs', () {
      // Arrange
      final logs = <ExerciseLogDto>[];

      // Act
      final freq = muscleGroupFamilyFrequency(exerciseLogs: logs);

      // Assert
      expect(freq.isEmpty, true, reason: 'No logs means no frequencies');
    });

    test('returns correct scaling for single muscle group', () {
      // Arrange
      final chestExercise = makeExercise(id: 'e1', type: ExerciseType.bodyWeight, primary: MuscleGroup.chest);
      final logs = [
        makeLog(exercise: chestExercise),
        makeLog(exercise: chestExercise),
      ];
      // 2 occurrences of chest
      // scaled frequency: chest = 2/2 = 1.0

      // Act
      final freq = muscleGroupFamilyFrequency(exerciseLogs: logs);

      // Assert
      expect(freq[MuscleGroupFamily.chest], 1.0, reason: 'Only chest muscle group should be 1.0');
    });

    test('handles multiple muscle groups with scaling', () {
      // Arrange
      final chestExercise = makeExercise(id: 'chest_ex', type: ExerciseType.bodyWeight, primary: MuscleGroup.chest);
      final coreExercise = makeExercise(id: 'core_ex', type: ExerciseType.duration, primary: MuscleGroup.abs);
      final logs = [
        makeLog(exercise: chestExercise),
        makeLog(exercise: coreExercise),
        makeLog(exercise: chestExercise),
      ];
      // chest: 2 occurrences, core: 1 occurrence. total = 3
      // scaled: chest = 2/3 ≈ 0.666..., core = 1/3 ≈ 0.333...

      // Act
      final freq = muscleGroupFamilyFrequency(exerciseLogs: logs);

      // Assert
      expect(freq[MuscleGroupFamily.chest], closeTo(0.666, 0.001));
      expect(freq[MuscleGroupFamily.core], closeTo(0.333, 0.001));
    });

    test('excludes fullBody muscle group from calculations', () {
      // Arrange
      final fullBodyExercise =
          makeExercise(id: 'full_ex', type: ExerciseType.bodyWeight, primary: MuscleGroup.fullBody);
      final logs = [
        makeLog(exercise: fullBodyExercise),
        makeLog(exercise: fullBodyExercise),
      ];

      // Act
      final freq = muscleGroupFamilyFrequency(exerciseLogs: logs);

      // Assert
      expect(freq.isEmpty, true, reason: 'fullBody should not be included in frequency map');
    });

    test('includes secondary muscle groups if requested', () {
      // Arrange
      final chestAndCoreExercise = makeExercise(
          id: 'chest_core_ex', type: ExerciseType.weights, primary: MuscleGroup.chest, secondary: [MuscleGroup.abs]);

      final logs = [
        makeLog(exercise: chestAndCoreExercise),
      ];
      // primary: chest
      // secondary: abs (core family)
      // chest:1 occurrence, core:1 occurrence
      // total = 2 => chest=0.5, core=0.5

      // Act
      final freq = muscleGroupFamilyFrequency(exerciseLogs: logs);

      // Assert
      expect(freq[MuscleGroupFamily.chest], 0.5);
      expect(freq[MuscleGroupFamily.core], 0.5);
    });
  });

  group('muscleGroupFamilyFrequencyOn4WeeksScale', () {
    test('returns an empty map if no logs', () {
      // Arrange
      final logs = <ExerciseLogDto>[];

      // Act
      final freq = muscleGroupFamilyFrequencyOn4WeeksScale(exerciseLogs: logs);

      // Assert
      expect(freq.isEmpty, true);
    });

    test('scales frequencies to a maximum of 1 over a 4-week period', () {
      // Arrange:
      // Suppose that multiple exercises are logged on different days.
      // The function caps the frequency at a max of 8 occurrences over 4 weeks (as per code comments).
      // If we have more than 8 days logged for the same muscle group, it should still max out at 1.
      final chestExercise = makeExercise(id: 'chest_ex', type: ExerciseType.bodyWeight, primary: MuscleGroup.chest);

      // Create 10 logs on 10 different days for chest, which should cap at 8 occurrences.
      final logs = List.generate(
          10,
          (i) => makeLog(exercise: chestExercise, createdAt: DateTime(2024, 12, i + 1) // different day each iteration
              ));

      // Act
      final freq = muscleGroupFamilyFrequencyOn4WeeksScale(exerciseLogs: logs);

      // Assert
      // Should be capped at 8/8 = 1.0
      expect(freq[MuscleGroupFamily.chest], 1.0);
    });

    test('partially filled scale should return fraction < 1', () {
      // Arrange
      final chestExercise = makeExercise(id: 'chest_ex', type: ExerciseType.bodyWeight, primary: MuscleGroup.chest);

      // 4 occurrences on different days = 4/8 = 0.5
      final logs = List.generate(4, (i) => makeLog(exercise: chestExercise, createdAt: DateTime(2024, 12, i + 1)));

      // Act
      final freq = muscleGroupFamilyFrequencyOn4WeeksScale(exerciseLogs: logs);

      // Assert
      expect(freq[MuscleGroupFamily.chest], 0.5, reason: '4 occurrences should scale to 4/8=0.5');
    });
  });

  group('cumulativeMuscleGroupFamilyFrequency', () {
    test('returns 0 for no logs', () {
      // Arrange
      final logs = <ExerciseLogDto>[];

      // Act
      final cumulative = cumulativeMuscleGroupFamilyFrequency(exerciseLogs: logs);

      // Assert
      expect(cumulative, 0.0);
    });

    test('returns a value between 0 and 1 for some occurrences', () {
      // Arrange
      final chestExercise = makeExercise(id: 'chest_ex', type: ExerciseType.bodyWeight, primary: MuscleGroup.chest);

      // Let’s say we log chest exercise for 2 different days: 2/48 (since total scale is 48 for 6 muscle groups * 8 days)
      // The exact formula may differ, but as per code: cumulative frequency is sum of occurrences / 48.
      // With 2 days of chest, muscleGroupsFrequencyScore might be (2/48) = 0.04166...
      final logs = [
        makeLog(exercise: chestExercise, createdAt: DateTime(2024, 12, 1)),
        makeLog(exercise: chestExercise, createdAt: DateTime(2024, 12, 2)),
      ];

      // Act
      final cumulative = cumulativeMuscleGroupFamilyFrequency(exerciseLogs: logs);

      // Assert
      expect(cumulative, greaterThan(0));
      expect(cumulative, lessThanOrEqualTo(1));
    });
  });
}
