import 'package:flutter_test/flutter_test.dart';
import 'package:tracker_app/dtos/exercise_dto.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/utils/exercise_logs_utils.dart';

void main() {
  final exercise = ExerciseDto(
      id: "id_exercise1", name: "name", primaryMuscleGroup: MuscleGroup.legs, type: ExerciseType.weights, owner: false);

  final sets = [
    const SetDto(80, 10, true),
    const SetDto(100, 8, true),
    const SetDto(100, 6, true),
  ];

  final testExerciseLog =
      ExerciseLogDto("id_exercise_log1", "routineLogId", "superSetId", exercise, "notes", sets, DateTime.now());

  test("Heaviest weight for log", () {
    final result = heaviestWeightForLog(exerciseLog: testExerciseLog);

    expect(result, const SetDto(100, 8, true));
  });
}
