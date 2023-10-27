import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/procedure_dto.dart';
import 'package:tracker_app/dtos/routine_dto.dart';
import 'package:tracker_app/screens/routine_editor_screen.dart';
import 'package:tracker_app/screens/routine_log_preview_screen.dart';
import 'package:tracker_app/utils/datetime_utils.dart';

import '../app_constants.dart';
import '../dtos/routine_log_dto.dart';
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
      final cachedRoutineLog = provider.cachedLogDto;

      return Scaffold(
        floatingActionButton: cachedRoutineLog == null
            ? FloatingActionButton(
                onPressed: () {
                  _navigateToRoutineEditor(context: context);
                },
                backgroundColor: tealBlueLighter,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                child: const Icon(CupertinoIcons.play_arrow_solid),
              )
            : null,
        body: SafeArea(
          child: provider.logs.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    children: [
                      cachedRoutineLog != null
                          ? MinimisedRoutineBanner(provider: provider, logDto: cachedRoutineLog)
                          : const SizedBox.shrink(),
                      Expanded(
                        child: ListView.separated(
                            itemBuilder: (BuildContext context, int index) =>
                                _RoutineLogWidget(logDto: provider.logs[index]),
                            separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 14),
                            itemCount: provider.logs.length),
                      ),
                    ],
                  ),
                )
              : const Center(child: _RoutineLogsEmptyState()),
        ),
      );
    }));
  }

  void _navigateToRoutineEditor({required BuildContext context}) {
    final routine = RoutineDto(id: '', name: '', procedures: [], createdAt: DateTime.now(), updatedAt: DateTime.now());
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            RoutineEditorScreen(routineDto: routine, mode: RoutineEditorMode.routine, type: RoutineEditingType.log)));
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
  final RoutineLogDto logDto;

  const _RoutineLogWidget({required this.logDto});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CupertinoListTile(
            title: Text(logDto.name, style: Theme.of(context).textTheme.labelLarge),
            subtitle: Row(children: [
              const Icon(
                CupertinoIcons.calendar,
                color: Colors.white,
                size: 12,
              ),
              const SizedBox(width: 1),
              Text(logDto.createdAt.durationSinceOrDate(),
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500)),
              const SizedBox(width: 10),
              const Icon(
                CupertinoIcons.timer,
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
        ..._proceduresToWidgets(context: context, procedures: logDto.procedures),
        logDto.procedures.length > 3
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
              builder: (context) => RoutineEditorScreen(routineDto: logDto, type: RoutineEditingType.log)));
        },
        // style: ButtonStyle(backgroundColor: MaterialStateProperty.all(tealBlueLight),),
        leadingIcon: const Icon(Icons.edit),
        child: const Text("Edit"),
      ),
      MenuItemButton(
        onPressed: () {
          Provider.of<RoutineLogProvider>(context, listen: false).removeLog(id: logDto.id);
        },
        // style: ButtonStyle(backgroundColor: MaterialStateProperty.all(tealBlueLight),),
        leadingIcon: const Icon(Icons.delete_sweep, color: Colors.red),
        child: const Text("Delete", style: TextStyle(color: Colors.red)),
      )
    ];
  }

  void _navigateToRoutineLogPreview({required BuildContext context}) async {
    final routine = await Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => RoutineLogPreviewScreen(routineLogId: logDto.id)))
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
    final exercisesPlural = logDto.procedures.length - 3 > 1 ? "exercises" : "exercise";
    return "Plus ${logDto.procedures.length - 3} more $exercisesPlural";
  }

  String _logDuration() {
    String interval = "";
    final startTime = logDto.startTime;
    final endTime = logDto.endTime;
    if (startTime != null && endTime != null) {
      final difference = endTime.difference(startTime);
      interval = difference.secondsOrMinutesOrHours();
    }
    return interval;
  }

  List<Widget> _proceduresToWidgets({required BuildContext context, required List<ProcedureDto> procedures}) {
    return procedures
        .take(3)
        .map((procedure) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Theme(
                data: ThemeData(splashColor: tealBlueLight),
                child: ListTile(
                    onTap: () => _navigateToRoutineLogPreview(context: context),
                    tileColor: tealBlueLight,
                    title: Text(procedure.exercise.name,
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                    trailing: Text("${procedure.sets.length} sets", style: Theme.of(context).textTheme.labelMedium)),
              ),
            ))
        .toList();
  }
}

class _RoutineLogsEmptyState extends StatelessWidget {
  const _RoutineLogsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Start tracking your performance", style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
