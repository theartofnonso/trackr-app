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
      final freq = muscleGroupFrequency(exerciseLogs: logs);

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
      final freq = muscleGroupFrequency(exerciseLogs: logs);

      // Assert
      expect(freq[MuscleGroup.chest], 1.0, reason: 'Only chest muscle group should be 1.0');
    });

    test('handles multiple muscle groups with scaling', () {
      // Arrange
      final chestExercise = makeExercise(id: 'chest_ex', type: ExerciseType.bodyWeight, primary: MuscleGroup.chest);
      final absExercise = makeExercise(id: 'abs_ex', type: ExerciseType.duration, primary: MuscleGroup.abs);
      final logs = [
        makeLog(exercise: chestExercise),
        makeLog(exercise: absExercise),
        makeLog(exercise: chestExercise),
      ];
      // chest: 2 occurrences, core: 1 occurrence. total = 3
      // scaled: chest = 2/3 ≈ 0.666..., core = 1/3 ≈ 0.333...

      // Act
      final freq = muscleGroupFrequency(exerciseLogs: logs);

      // Assert
      expect(freq[MuscleGroup.chest], closeTo(0.666, 0.001));
      expect(freq[MuscleGroup.abs], closeTo(0.333, 0.001));
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
      final freq = muscleGroupFrequency(exerciseLogs: logs);

      // Assert
      expect(freq.isEmpty, true, reason: 'fullBody should not be included in frequency map');
    });
  });
}
