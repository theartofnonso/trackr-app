import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/controllers/routine_log_controller.dart';
import 'package:tracker_app/controllers/exercise_controller.dart';
import 'package:tracker_app/dtos/viewmodels/exercise_editor_arguments.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/extensions/routine_log_extension.dart';
import 'package:tracker_app/screens/exercise/history/exercise_video_screen.dart';
import 'package:tracker_app/screens/exercise/history/history_screen.dart';
import 'package:tracker_app/screens/exercise/history/exercise_chart_screen.dart';

import '../../../dtos/exercise_dto.dart';
import '../../../dtos/exercise_log_dto.dart';
import '../../../utils/exercise_logs_utils.dart';
import '../../../utils/dialog_utils.dart';
import '../../../utils/navigation_utils.dart';
import '../../../utils/routine_utils.dart';
import '../../../widgets/backgrounds/overlay_background.dart';
import '../../../widgets/calendar/calendar_years_navigator.dart';

const exerciseRouteName = "/exercise-history-screen";

class HomeScreen extends StatefulWidget {
  final ExerciseDto exercise;

  const HomeScreen({super.key, required this.exercise});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, List<ExerciseLogDto>>? _exerciseLogsById;

  bool _loading = false;

  void _deleteExercise(BuildContext context) async {
    Navigator.pop(context);
    try {
      await Provider.of<ExerciseController>(context, listen: false).removeExercise(exercise: widget.exercise);
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

    final foundExercise =
        Provider.of<ExerciseController>(context, listen: true).whereExercise(exerciseId: widget.exercise.id) ??
            widget.exercise;

    final exerciseLogs = _exerciseLogsById?[foundExercise.id] ?? [];

    final completedExerciseLogs = exerciseLogsWithCheckedSets(exerciseLogs: exerciseLogs);

    final heaviestSetVolumeRecord = heaviestSetVolume(exerciseLogs: completedExerciseLogs);

    final heaviestWeightRecord = heaviestWeight(exerciseLogs: completedExerciseLogs);

    final longestDurationRecord = longestDuration(exerciseLogs: completedExerciseLogs);

    final mostRepsSetRecord = mostRepsInSet(exerciseLogs: completedExerciseLogs);

    final mostRepsSessionRecord = mostRepsInSession(exerciseLogs: completedExerciseLogs);

    final menuActions = [
      MenuItemButton(
        onPressed: () {
          navigateToExerciseEditor(
              context: context,
              arguments: ExerciseEditorArguments(
                exercise: foundExercise,
              ));
        },
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

    final hasVideo = foundExercise.video != null;

    return DefaultTabController(
        length: hasVideo ? 3 : 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: sapphireDark80,
            leading: IconButton(
              icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
              onPressed: context.pop,
            ),
            title: Text(foundExercise.name,
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
                          style:
                              GoogleFonts.ubuntu(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600))),
              ],
            ),
            actions: foundExercise.owner
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
            child: Stack(children: [
              SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    CalendarYearsNavigator(onChangedDateTimeRange: _onChangedDateTimeRange),
                    const SizedBox(height: 10),
                    Expanded(
                      child: TabBarView(
                        children: [
                          ExerciseChartScreen(
                            key: UniqueKey(),
                            heaviestWeight: heaviestWeightRecord,
                            heaviestSet: heaviestSetVolumeRecord,
                            longestDuration: longestDurationRecord,
                            mostRepsSet: mostRepsSetRecord,
                            mostRepsSession: mostRepsSessionRecord,
                            exercise: foundExercise,
                            exerciseLogs: completedExerciseLogs,
                          ),
                          HistoryScreen(exerciseLogs: completedExerciseLogs),
                          if (hasVideo) ExerciseVideoScreen(exercise: foundExercise)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (_loading) const OverlayBackground(opacity: 0.9)
            ]),
          ),
        ));
  }

  void _onChangedDateTimeRange(DateTimeRange? range) {
    if (range == null) return;

    setState(() {
      _loading = true;
    });

    final routineLogController = Provider.of<RoutineLogController>(context, listen: false);

    routineLogController.fetchLogsCloud(range: range.start.dateTimeRange()).then((logs) {
      setState(() {
        _loading = false;
        final routineLogs = logs.map((log) => log.dto()).sorted((a, b) => a.createdAt.compareTo(b.createdAt));
        _exerciseLogsById = groupExerciseLogsByExerciseId(routineLogs: routineLogs);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    final routineLogController = Provider.of<RoutineLogController>(context, listen: false);
    _exerciseLogsById = routineLogController.exerciseLogsById;
  }
}
