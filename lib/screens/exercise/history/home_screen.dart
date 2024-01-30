import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/controllers/routine_log_controller.dart';
import 'package:tracker_app/controllers/exercise_controller.dart';
import 'package:tracker_app/screens/editors/exercise_editor_screen.dart';
import 'package:tracker_app/screens/exercise/history/history_screen.dart';
import 'package:tracker_app/screens/exercise/history/exercise_chart_screen.dart';
import 'package:tracker_app/screens/settings_screen.dart';

import '../../../dtos/exercise_dto.dart';
import '../../../shared_prefs.dart';
import '../../../utils/exercise_logs_utils.dart';
import '../../../widgets/chart/line_chart_widget.dart';
import '../../../utils/dialog_utils.dart';

const exerciseRouteName = "/exercise-history-screen";

ChartUnitLabel weightUnit() {
  return SharedPrefs().weightUnit == WeightUnit.kg.name ? ChartUnitLabel.kg : ChartUnitLabel.lbs;
}

class HomeScreen extends StatelessWidget {
  final ExerciseDto exercise;

  const HomeScreen({super.key, required this.exercise});

  void _deleteExercise(BuildContext context) async {
    Navigator.pop(context);
    try {
      await Provider.of<ExerciseController>(context, listen: false).removeExercise(exercise: exercise);
      if (context.mounted) {
        Navigator.of(context).pop();
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
        Provider.of<ExerciseController>(context, listen: true).whereExercise(exerciseId: exercise.id) ?? exercise;

    final exerciseLogs =
        Provider.of<RoutineLogController>(context, listen: true).exerciseLogsForExercise(exercise: foundExercise);

    final heaviestSetVolumeRecord = heaviestSetVolume(exerciseLogs: exerciseLogs);

    final heaviestWeightRecord = heaviestWeight(exerciseLogs: exerciseLogs);

    final longestDurationRecord = longestDuration(exerciseLogs: exerciseLogs);

    final mostRepsSetRecord = mostRepsInSet(exerciseLogs: exerciseLogs);

    final mostRepsSessionRecord = mostRepsInSession(exerciseLogs: exerciseLogs);

    final menuActions = [
      MenuItemButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => ExerciseEditorScreen(exercise: exercise)));
        },
        child: const Text("Edit"),
      ),
      MenuItemButton(
        onPressed: () {
          showAlertDialogWithMultiActions(
              context: context,
              message: "Delete exercise?",
              leftAction: Navigator.of(context).pop,
              rightAction: () => _deleteExercise(context),
              leftActionLabel: 'Cancel',
              rightActionLabel: 'Delete',
              isRightActionDestructive: true);
        },
        child: Text("Delete", style: GoogleFonts.montserrat(color: Colors.red)),
      )
    ];

    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(foundExercise.name,
                style: GoogleFonts.montserrat(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
            bottom: TabBar(
              dividerColor: Colors.transparent,
              tabs: [
                Tab(child: Text("Summary", style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600))),
                Tab(child: Text("History", style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600))),
              ],
            ),
            actions: foundExercise.owner
                ? [
                    MenuAnchor(
                      style: MenuStyle(
                        backgroundColor: MaterialStateProperty.all(tealBlueLighter),
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
          body: SafeArea(
            child: TabBarView(
              children: [
                ExerciseChartScreen(
                  heaviestWeight: heaviestWeightRecord,
                  heaviestSet: heaviestSetVolumeRecord,
                  longestDuration: longestDurationRecord,
                  mostRepsSet: mostRepsSetRecord,
                  mostRepsSession: mostRepsSessionRecord,
                  exercise: foundExercise,
                ),
                HistoryScreen(exercise: foundExercise),
              ],
            ),
          ),
        ));
  }
}
