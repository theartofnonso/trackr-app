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
import '../providers/routine_log_provider.dart';
import '../widgets/helper_widgets/dialog_helper.dart';

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
                      Expanded(
                        child: ListView.separated(
                            itemBuilder: (BuildContext context, int index) =>
                                _RoutineLogWidget(logDto: provider.logs[index]),
                            separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 14),
                            itemCount: provider.logs.length),
                      )
                    ],
                  ),
                )
              : const Center(child: _RoutineLogsEmptyState()),
        ),
      );
    }));
  }

  void _navigateToRoutineEditor({required BuildContext context}) async {
    final routine = RoutineDto(id: '', name: '', procedures: [], createdAt: DateTime.now(), updatedAt: DateTime.now());
    await Navigator.of(context).push(CupertinoPageRoute(
        builder: (context) =>
            RoutineEditorScreen(routineDto: routine, mode: RoutineEditorMode.routine, type: RoutineEditingType.log)));
    print("Returned to Routine Logs");
    if (context.mounted) {
      showMinimisedRoutineBanner(context);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RoutineLogProvider>(context, listen: false).retrieveCachedRoutineLog(context);
      showMinimisedRoutineBanner(context);
    });
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CupertinoListTile(
            title: Text(logDto.name, style: Theme.of(context).textTheme.labelLarge),
            subtitle: Row(children: [
              const Icon(
                CupertinoIcons.calendar,
                color: CupertinoColors.white,
                size: 12,
              ),
              const SizedBox(width: 1),
              Text(logDto.createdAt.durationSinceOrDate(),
                  style: TextStyle(color: CupertinoColors.white.withOpacity(0.8), fontWeight: FontWeight.w500)),
              const SizedBox(width: 10),
              const Icon(
                CupertinoIcons.timer,
                color: CupertinoColors.white,
                size: 12,
              ),
              const SizedBox(width: 1),
              Text(_logDuration(),
                  style: TextStyle(color: CupertinoColors.white.withOpacity(0.8), fontWeight: FontWeight.w500)),
            ]),
            trailing: GestureDetector(
                onTap: () => _showWorkoutActionSheet(context: context),
                child: const Icon(
                  CupertinoIcons.ellipsis,
                  color: CupertinoColors.white,
                ))),
        const SizedBox(height: 8),
        ..._proceduresToWidgets(context: context, procedures: logDto.procedures),
        logDto.procedures.length > 3
            ? Text(_footerLabel(),
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(fontSize: 14, color: CupertinoColors.white.withOpacity(0.6)))
            : const SizedBox.shrink()
      ],
    );
  }

  void _navigateToRoutineLogPreview({required BuildContext context}) async {
    final routine = await Navigator.of(context)
            .push(CupertinoPageRoute(builder: (context) => RoutineLogPreviewScreen(routineLogId: logDto.id)))
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
              child: CupertinoListTile(
                  onTap: () => _navigateToRoutineLogPreview(context: context),
                  backgroundColor: tealBlueLight,
                  backgroundColorActivated: tealBlueLight,
                  title: Text(procedure.exercise.name,
                      style: const TextStyle(color: CupertinoColors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                  trailing: Text("${procedure.sets.length} sets", style: Theme.of(context).textTheme.labelMedium)),
            ))
        .toList();
  }

  /// Show [CupertinoActionSheet]
  void _showWorkoutActionSheet({required BuildContext context}) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(color: tealBlueDark);

    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(
          logDto.name,
          style: textStyle?.copyWith(color: tealBlueLight.withOpacity(0.6)),
        ),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).push(CupertinoPageRoute(
                  builder: (context) => RoutineEditorScreen(routineDto: logDto, type: RoutineEditingType.log)));
            },
            child: Text(
              'Edit',
              style: textStyle,
            ),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              Provider.of<RoutineLogProvider>(context, listen: false).removeLog(id: logDto.id);
            },
            child: const Text(
              'Remove',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
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
