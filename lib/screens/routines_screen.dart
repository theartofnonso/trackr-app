import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/dtos/routine_dto.dart';
import 'package:tracker_app/screens/routine_preview_screen.dart';

import '../dtos/procedure_dto.dart';
import '../providers/routine_log_provider.dart';
import '../providers/routine_provider.dart';
import '../widgets/routine/minimised_routine_controller_widget.dart';
import 'routine_editor_screen.dart';

void _navigateToRoutineEditor(
    {required BuildContext context, RoutineDto? routineDto, RoutineEditorMode mode = RoutineEditorMode.editing}) {
  Navigator.of(context)
      .push(CupertinoPageRoute(builder: (context) => RoutineEditorScreen(routineDto: routineDto, mode: mode)));
}

class RoutinesScreen extends StatefulWidget with WidgetsBindingObserver {
  const RoutinesScreen({super.key});

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  @override
  Widget build(BuildContext context) {
    final routines = Provider.of<RoutineProvider>(context, listen: true).routines;

    final cachedRoutineLog = Provider.of<RoutineLogProvider>(context, listen: true).cacheLogDto;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.transparent,
        trailing: GestureDetector(
            onTap: () => _navigateToRoutineEditor(context: context),
            child: const Icon(
              CupertinoIcons.plus_app,
              size: 24,
              color: CupertinoColors.white,
            )),
      ),
      child: SafeArea(
        child: routines.isNotEmpty
            ? Stack(children: [
                _RoutineList(routinesDtos: routines),
                cachedRoutineLog != null
                    ? Positioned(
                        right: 0,
                        bottom: 0,
                        left: 0,
                        child: MinimisedRoutineControllerWidget(logDto: cachedRoutineLog))
                    : const SizedBox.shrink()
              ])
            : const Center(child: _RoutinesEmptyState()),
      ),
    );
  }
}

class _RoutineList extends StatelessWidget {
  final List<RoutineDto> routinesDtos;

  const _RoutineList({required this.routinesDtos});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(children: [
          Expanded(
            child: ListView.separated(
                itemBuilder: (BuildContext context, int index) => _RoutineWidget(routineDto: routinesDtos[index]),
                separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 12),
                itemCount: routinesDtos.length),
          )
        ]));
  }
}

class _RoutineWidget extends StatelessWidget {
  final RoutineDto routineDto;

  const _RoutineWidget({required this.routineDto});

  /// Show [CupertinoActionSheet]
  void _showWorkoutActionSheet({required BuildContext context}) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(color: tealBlueDark);

    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(
          routineDto.name,
          style: textStyle?.copyWith(color: tealBlueLight.withOpacity(0.6)),
        ),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _navigateToRoutineEditor(context: context, routineDto: routineDto);
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
              Provider.of<RoutineProvider>(context, listen: false).removeRoutine(id: routineDto.id);
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

  void _navigateToRoutinePreview({required BuildContext context}) async {
    Navigator.of(context)
        .push(CupertinoPageRoute(builder: (context) => RoutinePreviewScreen(routineId: routineDto.id)));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToRoutinePreview(context: context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CupertinoListTile(
              onTap: () =>
                  _navigateToRoutineEditor(context: context, routineDto: routineDto, mode: RoutineEditorMode.routine),
              leading: GestureDetector(
                  onTap: () => _navigateToRoutineEditor(
                      context: context, routineDto: routineDto, mode: RoutineEditorMode.routine),
                  child: const Icon(CupertinoIcons.play_arrow_solid, color: CupertinoColors.white)),
              title: Text(routineDto.name, style: Theme.of(context).textTheme.labelLarge),
              subtitle: Row(children: [
                const Icon(
                  CupertinoIcons.number,
                  color: CupertinoColors.white,
                  size: 12,
                ),
                Text("${routineDto.procedures.length} exercises",
                    style: TextStyle(color: CupertinoColors.white.withOpacity(0.8), fontWeight: FontWeight.w500)),
              ]),
              trailing: GestureDetector(
                  onTap: () => _showWorkoutActionSheet(context: context),
                  child: const Icon(
                    CupertinoIcons.ellipsis,
                    color: CupertinoColors.white,
                  ))),
          const SizedBox(height: 8),
          ..._proceduresToWidgets(context: context, procedures: routineDto.procedures),
          routineDto.procedures.length > 3
              ? Text(_footerLabel(),
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(fontSize: 14, color: CupertinoColors.white.withOpacity(0.6)))
              : const SizedBox.shrink()
        ],
      ),
    );
  }

  String _footerLabel() {
    final exercisesPlural = routineDto.procedures.length - 3 > 1 ? "exercises" : "exercise";
    return "See ${routineDto.procedures.length - 3} more $exercisesPlural";
  }

  List<Widget> _proceduresToWidgets({required BuildContext context, required List<ProcedureDto> procedures}) {
    return procedures
        .take(3)
        .map((procedure) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: CupertinoListTile(
                  backgroundColor: tealBlueLight,
                  title: Text(procedure.exercise.name,
                      style: const TextStyle(color: CupertinoColors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                  trailing: Text("${procedure.sets.length} sets", style: Theme.of(context).textTheme.labelMedium)),
            ))
        .toList();
  }
}

class _RoutinesEmptyState extends StatelessWidget {
  const _RoutinesEmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Create workouts ahead of gym time", style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
                color: tealBlueLight,
                onPressed: () => _navigateToRoutineEditor(context: context),
                child: Text(
                  "Create Workout",
                  style: Theme.of(context).textTheme.labelLarge,
                )),
          )
        ],
      ),
    );
  }
}
