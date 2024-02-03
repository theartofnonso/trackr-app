import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/controllers/exercise_controller.dart';
import 'package:tracker_app/controllers/exercise_log_controller.dart';
import 'package:tracker_app/controllers/routine_log_controller.dart';
import 'package:tracker_app/dtos/exercise_dto.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/dtos/routine_log_dto.dart';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/enums/routine_editor_type_enums.dart';
import 'package:tracker_app/main.dart';
import 'package:tracker_app/repositories/achievement_repository.dart';
import 'package:tracker_app/repositories/amplify_exercise_repository.dart';
import 'package:tracker_app/repositories/amplify_log_repository.dart';
import 'package:tracker_app/repositories/exercise_log_repository.dart';
import 'package:tracker_app/screens/editors/routine_log_editor_screen.dart';
import 'package:tracker_app/widgets/exercise/selectable_exercise_widget.dart';

import 'routine_log_editor_test.mocks.dart';

class MockAmplifyExerciseRepository extends Mock implements AmplifyExerciseRepository {}

@GenerateNiceMocks([MockSpec<BuildContext>()])
void main() {

  TestWidgetsFlutterBinding.ensureInitialized();

  MockBuildContext mockContext = MockBuildContext();

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

  testWidgets('Select exercises from Exercise Library', (tester) async {

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ExerciseController>(
            create: (context) => ExerciseController(AmplifyExerciseRepository()),
          ),
          ChangeNotifierProvider<ExerciseLogController>(
            create: (context) => ExerciseLogController(ExerciseLogRepository()),
          ),
          ChangeNotifierProvider<RoutineLogController>(
              create: (context) => RoutineLogController(AmplifyLogRepository(), AchievementRepository())
          ),
        ],
        builder: (context, child) {
          return MaterialApp(
            home: RoutineLogEditorScreen(
              log: legDayRoutineLog,
              mode: RoutineEditorMode.log,
            ),
          );
        },
      ),
    );

    final selectExercisesInLibraryButton = find.byKey(const Key("select_exercises_in_library_btn"));
    await tester.tap(selectExercisesInLibraryButton);
    await tester.pump();
    final listview = find.byKey(const Key("exercise_library_listview"));

    expect(listview, find);

    // final airSquat = find.byWidgetPredicate((widget) {
    //   return widget.key == const Key("Air Squat");
    // });

    //final airSquat = find.byKey(const Key("Air Squat"));
    final arnoldPress = find.byKey(const Key("Arnold Press"));
    //
    //await tester.tap(airSquat);
    // await tester.tap(arnoldPress);
    //
    // final addExercisesButton = find.byKey(const Key("add_exercises_btn"));
    // await tester.tap(addExercisesButton);

  });
}
