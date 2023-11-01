import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/providers/weight_unit_provider.dart';
import 'package:tracker_app/screens/routine_editor_screen.dart';
import 'package:tracker_app/utils/snackbar_utils.dart';
import 'package:tracker_app/widgets/empty_states/screen_empty_state.dart';

import '../../app_constants.dart';
import '../../models/Routine.dart';
import '../../providers/exercise_provider.dart';
import '../../providers/routine_log_provider.dart';
import '../../providers/routine_provider.dart';
import '../../widgets/routine/minimised_routine_banner.dart';
import '../../widgets/routine_log/routine_log_widget.dart';
import '../calender_screen.dart';

void navigateToRoutineEditor({required BuildContext context, TemporalDateTime? createdAt}) async {
  try {
    final emptyRoutine = Routine(
        name: '',
        procedures: [],
        notes: '',
        createdAt: TemporalDateTime.fromString("${DateTime.now().toIso8601String()}Z"),
        updatedAt: TemporalDateTime.fromString("${DateTime.now().toIso8601String()}Z"));

    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            RoutineEditorScreen(routine: emptyRoutine, mode: RoutineEditorMode.routine, type: RoutineEditingType.log, createdAt: createdAt)));
  } catch (e) {
    showSnackbar(
        context: context,
        icon: const Icon(
          Icons.info_outline,
          color: Colors.white,
        ),
        message: "Unable to start new workout");
  }
}

class RoutineLogsScreen extends StatefulWidget {
  const RoutineLogsScreen({super.key});

  @override
  State<RoutineLogsScreen> createState() => _RoutineLogsScreenState();
}

class _RoutineLogsScreenState extends State<RoutineLogsScreen> with WidgetsBindingObserver {
  void _navigateToCalendarScreen() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CalendarScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Consumer<RoutineLogProvider>(builder: (_, provider, __) {
      final cachedRoutineLog = provider.cachedLog;

      return Scaffold(
        appBar: AppBar(
          backgroundColor: tealBlueDark,
          title: const Text("Home", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          centerTitle: false,
          actions: [
            GestureDetector(
              onTap: _navigateToCalendarScreen,
              child: const Padding(
                padding: EdgeInsets.only(right: 14.0),
                child: Icon(Icons.calendar_month_rounded),
              ),
            )
          ],
        ),
        floatingActionButton: cachedRoutineLog == null
            ? FloatingActionButton(
                heroTag: "fab_routine_logs_screen",
                onPressed: () {
                  navigateToRoutineEditor(context: context);
                },
                backgroundColor: tealBlueLighter,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                child: const Icon(Icons.play_arrow_rounded),
              )
            : null,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              children: [
                cachedRoutineLog != null ? MinimisedRoutineBanner(log: cachedRoutineLog) : const SizedBox.shrink(),
                provider.logs.isNotEmpty
                    ? Expanded(
                        child: ListView.separated(
                            itemBuilder: (BuildContext context, int index) =>
                                RoutineLogWidget(log: provider.logs[index]),
                            separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 14),
                            itemCount: provider.logs.length),
                      )
                    : const Expanded(
                        child: Center(child: ScreenEmptyState(message: "Start tracking your performance"))),
              ],
            ),
          ),
        ),
      );
    }));
  }

  void _loadData() async {
    await Provider.of<ExerciseProvider>(context, listen: false).listExercises();
    if (mounted) {
      final routineLogProvider = Provider.of<RoutineLogProvider>(context, listen: false);
      routineLogProvider.listRoutineLogs(context);
      routineLogProvider.retrieveCachedRoutineLog(context);
      Provider.of<RoutineProvider>(context, listen: false).listRoutines(context);
      Provider.of<WeightUnitProvider>(context, listen: false).toggleUnit();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => Provider.of<RoutineLogProvider>(context, listen: false).listRoutineLogs(context));
    }
  }
}