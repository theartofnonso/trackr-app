import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_constants.dart';
import '../models/RoutineLog.dart';
import '../providers/routine_log_provider.dart';

class RoutineLogsScreen extends StatelessWidget {
  const RoutineLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logs = Provider.of<RoutineLogProvider>(context, listen: true).logs;
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: logs.isNotEmpty
              ? _RoutineLogsList(logs: logs)
              : const Center(child: _RoutineLogsEmptyState()),
        ),
      ),
    );
  }
}

class _RoutineLogsList extends StatelessWidget {
  final List<RoutineLog> logs;

  const _RoutineLogsList({required this.logs});

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      CupertinoListSection.insetGrouped(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        backgroundColor: Colors.transparent,
        header: CupertinoListTile(
          padding: EdgeInsets.zero,
          title: Text("History", style: Theme.of(context).textTheme.titleLarge),
          trailing: GestureDetector(
              onTap: () => {},
              child: const Icon(
                CupertinoIcons.plus,
                size: 24,
                color: CupertinoColors.white,
              )),
        ),
        children: [...logs.map((log) => _RoutineLogWidget(log: log)).toList()],
      ),
    ]);
  }
}

class _RoutineLogWidget extends StatelessWidget {
  final RoutineLog log;

  const _RoutineLogWidget({required this.log});

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
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              _removeLog(context: context);
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

  void _removeLog({required BuildContext context}) {
   // Provider.of<RoutineLogProvider>(context, listen: false).removeRoutine(id: routine.id);
  }

  void _navigateToRoutineLogPreview({required BuildContext context}) async {
    // Navigator.of(context)
    //     .push(CupertinoPageRoute(builder: (context) => RoutinePreviewScreen(routineId: routine.id)));
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoListTile.notched(
        onTap: () => _navigateToRoutineLogPreview(context: context),
        backgroundColor: tealBlueLight,
        backgroundColorActivated: tealBlueLighter,
        title: Text(
          log.name,
          style: const TextStyle(color: CupertinoColors.white),
        ),
        subtitle: const Column(children: [
          Text("3 Sets Chest Fly"),
          SizedBox(height: 4),
          Text("3 Sets Leg Press"),
          SizedBox(height: 4),
          Text("3 Sets Bulgarian Split")
        ],),
        trailing: Text("1hr 3mins"));
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
