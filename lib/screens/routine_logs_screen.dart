import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/procedure_dto.dart';
import 'package:tracker_app/utils/datetime_utils.dart';

import '../app_constants.dart';
import '../models/RoutineLog.dart';
import '../providers/routine_log_provider.dart';

class RoutineLogsScreen extends StatelessWidget {
  const RoutineLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logs = Provider.of<RoutineLogProvider>(context, listen: true).logs;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.transparent,
        trailing: GestureDetector(
            onTap: () => {},
            child: const Icon(
              CupertinoIcons.plus_app,
              size: 24,
              color: CupertinoColors.white,
            )),
      ),
      child: SafeArea(
          child: logs.isNotEmpty ? _RoutineLogsList(logs: logs) : const Center(child: _RoutineLogsEmptyState())),
    );
  }
}

class _RoutineLogsList extends StatelessWidget {
  final List<RoutineLog> logs;

  const _RoutineLogsList({required this.logs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
                itemBuilder: (BuildContext context, int index) => _RoutineLogWidget(log: logs[index]),
                separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 14),
                itemCount: logs.length),
          )
        ],
      ),
    );
  }
}

class _RoutineLogWidget extends StatelessWidget {
  final RoutineLog log;

  const _RoutineLogWidget({required this.log});

  @override
  Widget build(BuildContext context) {
    final procedures =
        log.procedures.map((procedureJson) => ProcedureDto.fromJson(json.decode(procedureJson), context)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CupertinoListTile(
            title: Text(log.name, style: Theme.of(context).textTheme.labelLarge),
            subtitle: Row(children: [
              const Icon(CupertinoIcons.calendar, color: CupertinoColors.white, size: 12,),
              Text("Yesterday", style: TextStyle(color: CupertinoColors.white.withOpacity(0.8), fontWeight: FontWeight.w500)),
              const SizedBox(width: 10),
              const Icon(CupertinoIcons.timer, color: CupertinoColors.white, size: 12,),
              Text(_logDuration(), style: TextStyle(color: CupertinoColors.white.withOpacity(0.8), fontWeight: FontWeight.w500)),
            ]), trailing: GestureDetector(
            onTap: () => _showWorkoutActionSheet(context: context),
            child: const Icon(
              CupertinoIcons.ellipsis,
              color: CupertinoColors.white,
            ))),
        const SizedBox(height: 8),
        ..._proceduresToWidgets(context: context, procedures: procedures),
        log.procedures.length > 3
            ? Text(_footerLabel(), style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 14, color: CupertinoColors.white.withOpacity(0.6)))
            : const SizedBox.shrink()
      ],
    );
  }

  String _footerLabel() {
    final exercisesPlural = log.procedures.length - 3 > 1 ? "exercises" : "exercise";
    return "See ${log.procedures.length - 3} more $exercisesPlural";
  }

  String _logDuration() {
    final startTime = log.startTime.getDateTimeInUtc();
    final endTime = log.endTime.getDateTimeInUtc();
    final interval = endTime.difference(startTime);
    return interval.secondsOrMinutesOrHours();
  }

  List<Widget> _proceduresToWidgets({required BuildContext context, required List<ProcedureDto> procedures}) {
    return procedures
        .take(3)
        .map((procedure) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: CupertinoListTile(
                  backgroundColor: tealBlueLight,
                  title:
                      Text(procedure.exercise.name, style: const TextStyle(color: CupertinoColors.white, fontSize: 14, fontWeight: FontWeight.w500)),
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
          log.name,
          style: textStyle?.copyWith(color: tealBlueLight.withOpacity(0.6)),
        ),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              //Navigator.of(context).push(CupertinoPageRoute(builder: (context) => RoutineEditorScreen(routine: log)));
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
              Provider.of<RoutineLogProvider>(context, listen: false).removeLog(id: log.id);
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

  void _navigateToRoutineLogPreview({required BuildContext context}) async {
    // Navigator.of(context)
    //     .push(CupertinoPageRoute(builder: (context) => RoutinePreviewScreen(routineId: routine.id)));
  }
}

class _RoutineLogsEmptyState extends StatelessWidget {
  const _RoutineLogsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Start tracking your performance", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: CupertinoButton(
              color: tealBlueLight,
              onPressed: () => {},
              child: Text(
                "Start a new workout",
                style: Theme.of(context).textTheme.labelLarge,
              )),
        )
      ],
    );
  }
}
