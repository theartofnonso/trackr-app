import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/controllers/exercise_log_controller.dart';
import 'package:tracker_app/dtos/exercise_dto.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/dtos/routine_log_dto.dart';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/enums/routine_editor_type_enums.dart';
import 'package:tracker_app/repositories/exercise_log_repository.dart';
import 'package:tracker_app/screens/editors/routine_log_editor_screen.dart';

void main() {
  final lyingLegCurlExercise = ExerciseDto(
      id: "id_lyingLegCurlExercise",
      name: "Lying Leg Curl",
      primaryMuscleGroup: MuscleGroup.hamstrings,
      type: ExerciseType.weights,
      owner: false);

  final lyingLegCurlExerciseLog1 = ExerciseLogDto(
      lyingLegCurlExercise.id,
      "routineLogId1",
      "superSetId",
      lyingLegCurlExercise,
      "notes",
      [
        const SetDto(80, 15, true),
        const SetDto(100, 8, true),
        const SetDto(100, 6, true),
      ],
      DateTime(2024, 1, 1));

  final legDayRoutineLog = RoutineLogDto(
      id: "routineLogId1",
      templateId: "legDayRoutineId",
      name: "legDayRoutineName",
      notes: "notes",
      exerciseLogs: [
        lyingLegCurlExerciseLog1,
      ],
      createdAt: DateTime(2024, 1, 1),
      startTime: DateTime.now(),
      endTime: DateTime.now().add(const Duration(hours: 1)),
      updatedAt: DateTime.now());

  testWidgets('MyWidget has a title and message', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ExerciseLogController>(
            create: (context) => ExerciseLogController(ExerciseLogRepository()),
          ),
        ],
        child: Builder(
          builder: (_) => RoutineLogEditorScreen(log: legDayRoutineLog, mode: RoutineEditorMode.log),
        ),
      ),
    );
  });
}
