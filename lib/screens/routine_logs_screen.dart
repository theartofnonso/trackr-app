import 'dart:convert';

import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/procedure_dto.dart';
import 'package:tracker_app/screens/routine_editor_screen.dart';
import 'package:tracker_app/screens/routine_log_preview_screen.dart';
import 'package:tracker_app/utils/datetime_utils.dart';
import 'package:tracker_app/widgets/empty_states/screen_empty_state.dart';

import '../app_constants.dart';
import '../models/Routine.dart';
import '../models/RoutineLog.dart';
import '../providers/exercises_provider.dart';
import '../providers/routine_log_provider.dart';
import '../providers/routine_provider.dart';
import '../widgets/routine/minimised_routine_banner.dart';

class RoutineLogsScreen extends StatefulWidget {
  const RoutineLogsScreen({super.key});

  @override
  State<RoutineLogsScreen> createState() => _RoutineLogsScreenState();
}

class _RoutineLogsScreenState extends State<RoutineLogsScreen> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Consumer<RoutineLogProvider>(builder: (_, provider, __) {
      final cachedRoutineLog = provider.cachedLog;

      return Scaffold(
        floatingActionButton: cachedRoutineLog == null
            ? FloatingActionButton(
                heroTag: "fab_routine_logs_screen",
                onPressed: () {
                  _navigateToRoutineEditor(context: context);
                },
                backgroundColor: tealBlueLighter,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                child: const Icon(Icons.play_arrow_rounded),
              )
            : null,
        body: SafeArea(
          child: provider.logs.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    children: [
                      cachedRoutineLog != null
                          ? MinimisedRoutineBanner(provider: provider, log: cachedRoutineLog)
                          : const SizedBox.shrink(),
                      Expanded(
                        child: ListView.separated(
                            itemBuilder: (BuildContext context, int index) =>
                                _RoutineLogWidget(log: provider.logs[index]),
                            separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 14),
                            itemCount: provider.logs.length),
                      ),
                    ],
                  ),
                )
              : const Center(child: ScreenEmptyState(message: "Start tracking your performance")),
        ),
      );
    }));
  }

  void _navigateToRoutineEditor({required BuildContext context}) {
    final routine = Routine(
        id: '',
        name: '',
        notes: '',
        procedures: [],
        createdAt: TemporalDateTime.fromString("${DateTime.now().toIso8601String()}Z"),
        updatedAt: TemporalDateTime.fromString("${DateTime.now().toIso8601String()}Z"));
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            RoutineEditorScreen(routine: routine, mode: RoutineEditorMode.routine, type: RoutineEditingType.log)));
  }

  void _loadData() async {
    await Provider.of<ExerciseProvider>(context, listen: false).listExercises();
    if (mounted) {
      final routineLogProvider = Provider.of<RoutineLogProvider>(context, listen: false);
      routineLogProvider.listRoutineLogs(context);
      routineLogProvider.retrieveCachedRoutineLog(context);
      Provider.of<RoutineProvider>(context, listen: false).listRoutines(context);
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

class _RoutineLogWidget extends StatelessWidget {
  final RoutineLog log;

  const _RoutineLogWidget({required this.log});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(log.name, style: Theme.of(context).textTheme.labelLarge),
            subtitle: Row(children: [
              const Icon(
                Icons.date_range_rounded,
                color: Colors.white,
                size: 12,
              ),
              const SizedBox(width: 1),
              Text(log.createdAt.getDateTimeInUtc().durationSinceOrDate(),
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500)),
              const SizedBox(width: 10),
              const Icon(
                Icons.timer,
                color: Colors.white,
                size: 12,
              ),
              const SizedBox(width: 1),
              Text(_logDuration(), style: TextStyle(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500)),
            ]),
            trailing: MenuAnchor(
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
                    Icons.more_horiz_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  tooltip: 'Show menu',
                );
              },
              menuChildren: _menuActionButtons(context: context),
            )),
        const SizedBox(height: 8),
        ..._proceduresToWidgets(context: context, procedureJsons: log.procedures),
        log.procedures.length > 3
            ? Text(_footerLabel(),
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(fontSize: 14, color: Colors.white.withOpacity(0.6)))
            : const SizedBox.shrink()
      ],
    );
  }

  /// [MenuItemButton]
  List<Widget> _menuActionButtons({required BuildContext context}) {
    return [
      MenuItemButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => RoutineEditorScreen(routineLog: log, type: RoutineEditingType.log)));
        },
        leadingIcon: const Icon(Icons.edit),
        child: const Text("Edit"),
      ),
      MenuItemButton(
        onPressed: () {
          Provider.of<RoutineLogProvider>(context, listen: false).removeLog(id: log.id);
        },
        leadingIcon: const Icon(Icons.delete_sweep, color: Colors.red),
        child: const Text("Delete", style: TextStyle(color: Colors.red)),
      )
    ];
  }

  void _navigateToRoutineLogPreview({required BuildContext context}) async {
    final routine = await Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => RoutineLogPreviewScreen(routineLogId: log.id)))
        as Map<String, String>?;
    if (routine != null) {
      final id = routine["id"] ?? "";
      if (id.isNotEmpty) {
        if (context.mounted) {
          Provider.of<RoutineLogProvider>(context, listen: false).removeLog(id: id);
        }
      }
    }
  }

  String _footerLabel() {
    final exercisesPlural = log.procedures.length - 3 > 1 ? "exercises" : "exercise";
    return "Plus ${log.procedures.length - 3} more $exercisesPlural";
  }

  String _logDuration() {
    String interval = "";
    final startTime = log.startTime.getDateTimeInUtc();
    final endTime = log.endTime.getDateTimeInUtc();
    final difference = endTime.difference(startTime);
    interval = difference.secondsOrMinutesOrHours();
    return interval;
  }

  List<Widget> _proceduresToWidgets({required BuildContext context, required List<String> procedureJsons}) {
    final exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);
    final procedures = procedureJsons.map((json) => ProcedureDto.fromJson(jsonDecode(json))).toList();
    return procedures
        .take(3)
        .map((procedure) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Theme(
                data: ThemeData(splashColor: tealBlueLight),
                child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.0), // Adjust the border radius as needed
                    ),
                    onTap: () => _navigateToRoutineLogPreview(context: context),
                    tileColor: tealBlueLight,
                    title: Text(exerciseProvider.whereExercise(exerciseId: procedure.exerciseId).name,
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                    trailing: Text("${procedure.sets.length} sets", style: Theme.of(context).textTheme.labelMedium)),
              ),
            ))
        .toList();
  }
}
