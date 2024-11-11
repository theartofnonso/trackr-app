import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/controllers/exercise_and_routine_controller.dart';
import 'package:tracker_app/dtos/viewmodels/exercise_editor_arguments.dart';
import 'package:tracker_app/screens/exercise/history/exercise_chart_screen.dart';
import 'package:tracker_app/screens/exercise/history/exercise_video_screen.dart';
import 'package:tracker_app/screens/exercise/history/history_screen.dart';
import 'package:tracker_app/shared_prefs.dart';

import '../../../dtos/appsync/exercise_dto.dart';
import '../../../dtos/exercise_log_dto.dart';
import '../../../utils/dialog_utils.dart';
import '../../../utils/exercise_logs_utils.dart';
import '../../../utils/navigation_utils.dart';
import '../../empty_state_screens/not_found.dart';

class ExerciseHomeScreen extends StatefulWidget {
  static const routeName = "/exercise_home_screen";

  final ExerciseDto exercise;

  const ExerciseHomeScreen({super.key, required this.exercise});

  @override
  State<ExerciseHomeScreen> createState() => _ExerciseHomeScreenState();
}

class _ExerciseHomeScreenState extends State<ExerciseHomeScreen> {
  ExerciseDto? _exercise;

  Map<String, List<ExerciseLogDto>>? _exerciseLogsById;

  void _deleteExercise(BuildContext context) async {
    context.pop();
    try {
      await Provider.of<ExerciseAndRoutineController>(context, listen: false).removeExercise(exercise: widget.exercise);
      if (context.mounted) {
        context.pop();
      }
    } catch (_) {
      if (context.mounted) {
        showSnackbar(
            context: context,
            icon: const Icon(Icons.info_outline),
            message: "Oops, we are unable delete this exercise");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercise = _exercise;

    if (exercise == null) return const NotFound();

    final exerciseLogs = _exerciseLogsById?[exercise.id] ?? [];

    final completedExerciseLogs = completedExercises(exerciseLogs: exerciseLogs);

    final heaviestSetVolumeRecord = heaviestSetVolume(exerciseLogs: completedExerciseLogs);

    final heaviestWeightRecord = heaviestWeight(exerciseLogs: completedExerciseLogs);

    final longestDurationRecord = longestDuration(exerciseLogs: completedExerciseLogs);

    final mostRepsSetRecord = mostRepsInSet(exerciseLogs: completedExerciseLogs);

    final mostRepsSessionRecord = mostRepsInSession(exerciseLogs: completedExerciseLogs);

    final menuActions = [
      MenuItemButton(
        onPressed: _navigateToExerciseEditor,
        child: const Text("Edit"),
      ),
      MenuItemButton(
        onPressed: () {
          showBottomSheetWithMultiActions(
              context: context,
              title: "Delete exercise?",
              description: "Are you sure you want to delete this exercise?",
              leftAction: Navigator.of(context).pop,
              rightAction: () => _deleteExercise(context),
              leftActionLabel: 'Cancel',
              rightActionLabel: 'Delete',
              isRightActionDestructive: true);
        },
        child: Text("Delete", style: GoogleFonts.ubuntu(color: Colors.red)),
      )
    ];

    final hasVideo = exercise.video != null;

    return DefaultTabController(
        length: hasVideo ? 3 : 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: sapphireDark80,
            leading: IconButton(
              icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
              onPressed: context.pop,
            ),
            title: Text(exercise.name,
                style: GoogleFonts.ubuntu(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
            bottom: TabBar(
              dividerColor: Colors.transparent,
              tabs: [
                Tab(
                    child: Text("Summary",
                        style: GoogleFonts.ubuntu(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600))),
                Tab(
                    child: Text("History",
                        style: GoogleFonts.ubuntu(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600))),
                if (hasVideo)
                  Tab(
                      child: Text("Video",
                          style: GoogleFonts.ubuntu(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600))),
              ],
            ),
            actions: exercise.owner == SharedPrefs().userId
                ? [
                    MenuAnchor(
                      style: MenuStyle(
                        backgroundColor: WidgetStateProperty.all(sapphireDark80),
                        surfaceTintColor: WidgetStateProperty.all(sapphireDark),
                      ),
                      builder: (BuildContext context, MenuController controller, Widget? child) {
                        return IconButton(
                          onPressed: () {
                            if (controller.isOpen) {
                              controller.close();
                            } else {
                              controller.open();
                            }
                          },
                          icon: const Icon(
                            Icons.more_vert_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                          tooltip: 'Show menu',
                        );
                      },
                      menuChildren: menuActions,
                    )
                  ]
                : null,
          ),
          body: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  sapphireDark80,
                  sapphireDark,
                ],
              ),
            ),
            child: SafeArea(
              child: TabBarView(
                children: [
                  ExerciseChartScreen(
                    heaviestWeight: heaviestWeightRecord,
                    heaviestSet: heaviestSetVolumeRecord,
                    longestDuration: longestDurationRecord,
                    mostRepsSet: mostRepsSetRecord,
                    mostRepsSession: mostRepsSessionRecord,
                    exercise: exercise,
                    exerciseLogs: completedExerciseLogs,
                  ),
                  HistoryScreen(exerciseLogs: completedExerciseLogs),
                  if (hasVideo) ExerciseVideoScreen(exercise: exercise)
                ],
              ),
            ),
          ),
        ));
  }

  void _navigateToExerciseEditor() async {
    final exercise = _exercise;
    if (exercise != null) {
      final arguments = ExerciseEditorArguments(exercise: exercise);
      final updatedExercise = await navigateToExerciseEditor(context: context, arguments: arguments);
      if (updatedExercise != null) {
        setState(() {
          _exercise = updatedExercise;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final routineLogController = Provider.of<ExerciseAndRoutineController>(context, listen: false);
    _exerciseLogsById = routineLogController.exerciseLogsById;
    _exercise = widget.exercise;
  }
}
