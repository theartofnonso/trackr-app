import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/dtos/routine_dto.dart';
import 'package:tracker_app/screens/routine_preview_screen.dart';
import 'package:tracker_app/widgets/empty_states/screen_empty_state.dart';

import '../dtos/procedure_dto.dart';
import '../providers/routine_log_provider.dart';
import '../providers/routine_provider.dart';
import '../widgets/routine/minimised_routine_banner.dart';
import 'routine_editor_screen.dart';

void _navigateToRoutineEditor({required BuildContext context, RoutineDto? routineDto, RoutineEditorMode mode = RoutineEditorMode.editing}) {
  Navigator.of(context).push(MaterialPageRoute(
      builder: (context) =>
          RoutineEditorScreen(routineDto: routineDto, mode: mode, type: RoutineEditingType.template)));
}

class RoutinesScreen extends StatelessWidget {
  const RoutinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<RoutineProvider, RoutineLogProvider>(builder: (_, routineProvider, routineLogProvider, __) {
      final cachedRoutineLog = routineLogProvider.cachedLogDto;
      return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () => _navigateToRoutineEditor(context: context),
            backgroundColor: tealBlueLighter,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: const Icon(Icons.add),
          ),
          body: SafeArea(
              child: routineProvider.routines.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(children: [
                        cachedRoutineLog != null
                            ? MinimisedRoutineBanner(provider: routineLogProvider, logDto: cachedRoutineLog)
                            : const SizedBox.shrink(),
                        Expanded(
                          child: ListView.separated(
                              itemBuilder: (BuildContext context, int index) => _RoutineWidget(
                                  routineDto: routineProvider.routines[index],
                                  canStartRoutine: cachedRoutineLog == null),
                              separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 12),
                              itemCount: routineProvider.routines.length),
                        )
                      ]))
                  : const Center(child: ScreenEmptyState(message: "Create workouts ahead of gym time"))));
    });
  }
}

class _RoutineWidget extends StatelessWidget {
  final RoutineDto routineDto;
  final bool canStartRoutine;

  const _RoutineWidget({required this.routineDto, required this.canStartRoutine});

  /// [MenuItemButton]
  List<Widget> _menuActionButtons({required BuildContext context, required RoutineDto routineDto}) {
    return [
      MenuItemButton(
        onPressed: () {
          _navigateToRoutineEditor(context: context, routineDto: routineDto);
        },
        leadingIcon: const Icon(Icons.edit),
        child: const Text("Edit"),
      ),
      MenuItemButton(
        onPressed: () {
          Provider.of<RoutineProvider>(context, listen: false).removeRoutine(id: routineDto.id);
        },
        leadingIcon: const Icon(Icons.delete_sweep, color: Colors.red),
        child: const Text("Delete", style: TextStyle(color: Colors.red)),
      )
    ];
  }

  void _navigateToRoutinePreview({required BuildContext context}) async {
    final routine = await Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => RoutinePreviewScreen(routineId: routineDto.id)))
        as Map<String, String>?;
    if (routine != null) {
      final id = routine["id"] ?? "";
      if (id.isNotEmpty) {
        if (context.mounted) {
          Provider.of<RoutineProvider>(context, listen: false).removeRoutine(id: id);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CupertinoListTile(
            backgroundColorActivated: tealBlueLight,
            leading: canStartRoutine
                ? GestureDetector(
                    onTap: () {
                      _navigateToRoutineEditor(
                          context: context, routineDto: routineDto, mode: RoutineEditorMode.routine);
                    },
                    child: const Icon(Icons.play_arrow, color: Colors.white))
                : null,
            title: Text(routineDto.name, style: Theme.of(context).textTheme.labelLarge),
            subtitle: Row(children: [
              const Icon(
                Icons.numbers,
                color: Colors.white,
                size: 12,
              ),
              Text("${routineDto.procedures.length} exercises",
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500)),
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
              menuChildren: _menuActionButtons(context: context, routineDto: routineDto),
            )),
        const SizedBox(height: 8),
        ..._proceduresToWidgets(context: context, procedures: routineDto.procedures),
        routineDto.procedures.length > 3
            ? Text(_footerLabel(),
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(fontSize: 14, color: Colors.white.withOpacity(0.6)))
            : const SizedBox.shrink()
      ],
    );
  }

  String _footerLabel() {
    final exercisesPlural = routineDto.procedures.length - 3 > 1 ? "exercises" : "exercise";
    return "Plus ${routineDto.procedures.length - 3} more $exercisesPlural";
  }

  List<Widget> _proceduresToWidgets({required BuildContext context, required List<ProcedureDto> procedures}) {
    return procedures
        .take(3)
        .map((procedure) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Theme(
                data: ThemeData(splashColor: tealBlueLight),
                child: ListTile(
                    onTap: () => _navigateToRoutinePreview(context: context),
                    tileColor: tealBlueLight,
                    title: Text(procedure.exercise.name,
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                    trailing: Text("${procedure.sets.length} sets", style: Theme.of(context).textTheme.labelMedium)),
              ),
            ))
        .toList();
  }
}