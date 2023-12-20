import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/models/ModelProvider.dart';
import 'package:tracker_app/providers/exercise_provider.dart';
import 'package:tracker_app/providers/routine_provider.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/utils/navigation_utils.dart';
import 'package:tracker_app/widgets/backgrounds/overlay_background.dart';
import 'package:tracker_app/widgets/routine/preview/exercise_log_widget.dart';

import '../../app_constants.dart';
import '../../dtos/exercise_log_dto.dart';
import '../../providers/routine_log_provider.dart';
import '../../utils/snackbar_utils.dart';
import '../../widgets/helper_widgets/dialog_helper.dart';
import '../../widgets/helper_widgets/routine_helper.dart';
import 'editors/helper_utils.dart';
import 'exercise/history/home_screen.dart';

class RoutineLogPreviewScreen extends StatefulWidget {
  final RoutineLog log;
  final String previousRouteName;

  const RoutineLogPreviewScreen({super.key, required this.log, this.previousRouteName = ""});

  @override
  State<RoutineLogPreviewScreen> createState() => _RoutineLogPreviewScreenState();
}

class _RoutineLogPreviewScreenState extends State<RoutineLogPreviewScreen> {
  bool _loading = false;
  String _loadingMessage = "";

  @override
  Widget build(BuildContext context) {
    Provider.of<ExerciseProvider>(context, listen: true);
    final log = widget.log;

    List<ExerciseLogDto> procedures =
        log.procedures.map((json) => ExerciseLogDto.fromJson(json: jsonDecode(json))).map((procedure) {
      final exerciseFromLibrary =
          Provider.of<ExerciseProvider>(context, listen: false).whereExerciseOrNull(exerciseId: procedure.exercise.id);
      if (exerciseFromLibrary != null) {
        return procedure.copyWith(exercise: exerciseFromLibrary);
      }
      return procedure;
    }).toList();

    final numberOfCompletedSets = _calculateCompletedSets(procedures: procedures);
    final completedSetsSummary = "$numberOfCompletedSets set(s)";

    return Scaffold(
        backgroundColor: tealBlueDark,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_outlined),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title:
              Text(log.name, style: GoogleFonts.lato(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16)),
          actions: [
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
              menuChildren: _menuActionButtons(context: context, log: log),
            )
          ],
        ),
        body: Stack(children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(right: 10, bottom: 10, left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    log.notes.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Text(log.notes,
                                style: GoogleFonts.lato(
                                  color: Colors.white,
                                  fontSize: 14,
                                )),
                          )
                        : const SizedBox.shrink(),
                    Row(
                      children: [
                        const Icon(
                          Icons.date_range_rounded,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 1),
                        Text(log.createdAt.getDateTimeInUtc().formattedDayAndMonthAndYear(),
                            style: GoogleFonts.lato(
                                color: Colors.white.withOpacity(0.95), fontWeight: FontWeight.w500, fontSize: 12)),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.access_time_rounded,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 1),
                        Text(log.endTime.getDateTimeInUtc().formattedTime(),
                            style: GoogleFonts.lato(
                                color: Colors.white.withOpacity(0.95), fontWeight: FontWeight.w500, fontSize: 12)),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 24, bottom: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5), // Use BorderRadius.circular for a rounded container
                        color: tealBlueLight, // Set the background color
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Table(
                        border: TableBorder.symmetric(inside: const BorderSide(color: tealBlueLighter, width: 2)),
                        columnWidths: const <int, TableColumnWidth>{
                          0: FlexColumnWidth(),
                          1: FlexColumnWidth(),
                          2: FlexColumnWidth(),
                        },
                        children: [
                          TableRow(children: [
                            TableCell(
                              verticalAlignment: TableCellVerticalAlignment.middle,
                              child: Center(
                                child: Text(completedSetsSummary,
                                    style: GoogleFonts.lato(
                                        color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
                              ),
                            ),
                            TableCell(
                              verticalAlignment: TableCellVerticalAlignment.middle,
                              child: Center(
                                child: Text("${log.procedures.length} exercise(s)",
                                    style: GoogleFonts.lato(
                                        color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
                              ),
                            ),
                            TableCell(
                              verticalAlignment: TableCellVerticalAlignment.middle,
                              child: Center(
                                child: Text(_logDuration(log: log),
                                    style: GoogleFonts.lato(
                                        color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
                              ),
                            )
                          ]),
                        ],
                      ),
                    ),
                    ..._proceduresToWidgets(procedures: procedures)
                  ],
                ),
              ),
            ),
          ),
          if (_loading) OverlayBackground(loadingMessage: _loadingMessage)
        ]));
  }

  void _toggleLoadingState({String message = ""}) {
    setState(() {
      _loading = !_loading;
      _loadingMessage = message;
    });
  }

  List<Widget> _proceduresToWidgets({required List<ExerciseLogDto> procedures}) {
    return procedures
        .map((procedure) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ExerciseLogWidget(
                exerciseLog: procedure,
                superSet: whereOtherExerciseInSuperSet(firstExercise: procedure, exercises: procedures),
                readOnly: widget.previousRouteName == exerciseRouteName,
              ),
            ))
        .toList();
  }

  String _logDuration({required RoutineLog log}) {
    String interval = "";
    final startTime = log.startTime.getDateTimeInUtc();
    final endTime = log.endTime.getDateTimeInUtc();
    final difference = endTime.difference(startTime);
    interval = difference.secondsOrMinutesOrHours();
    return interval;
  }

  int _calculateCompletedSets({required List<ExerciseLogDto> procedures}) {
    List<SetDto> completedSets = [];
    for (var procedure in procedures) {
      completedSets.addAll(procedure.sets);
    }
    return completedSets.length;
  }

  /// [MenuItemButton]
  List<Widget> _menuActionButtons({required BuildContext context, required RoutineLog log}) {
    return [
      log.routine?.id != null
          ? MenuItemButton(
              onPressed: () {
                showAlertDialogWithMultiActions(
                    context: context,
                    message: "Update template?",
                    leftAction: Navigator.of(context).pop,
                    rightAction: () {
                      Navigator.of(context).pop();
                      _toggleLoadingState(message: "Updating template from log");
                      _updateRoutine(log);
                    },
                    leftActionLabel: 'Cancel',
                    rightActionLabel: 'Update',
                    isRightActionDestructive: true);
              },
              child: const Text("Update template"),
            )
          : const SizedBox.shrink(),
      MenuItemButton(
        onPressed: () {
          _toggleLoadingState(message: "Creating template from log");
          _createRoutine(log);
        },
        child: const Text("Create template"),
      ),
      MenuItemButton(
        onPressed: () {
          showAlertDialogWithMultiActions(
              context: context,
              message: "Delete log?",
              leftAction: Navigator.of(context).pop,
              rightAction: () {
                Navigator.of(context).pop();
                _toggleLoadingState(message: "Deleting log");
                _deleteLog();
              },
              leftActionLabel: 'Cancel',
              rightActionLabel: 'Delete',
              isRightActionDestructive: true);
        },
        child: Text("Delete", style: GoogleFonts.lato(color: Colors.red)),
      )
    ];
  }

  void _createRoutine(RoutineLog log) async {
    try {
      final decodedProcedures = log.procedures.map((json) => ExerciseLogDto.fromJson(json: jsonDecode(json)));
      final procedures = decodedProcedures.map((procedure) {
        final newSets = procedure.sets.map((set) => set.copyWith(checked: false)).toList();
        return procedure.copyWith(sets: newSets);
      }).toList();
      final routineId = await Provider.of<RoutineProvider>(context, listen: false)
          .saveRoutine(name: log.name, notes: log.notes, procedures: procedures);
      if (mounted) {
        navigateToRoutinePreview(context: context, routineId: routineId);
      }
    } catch (_) {
      if (mounted) {
        showSnackbar(
            context: context, icon: const Icon(Icons.info_outline), message: "Oops, we are unable to create template");
      }
    } finally {
      _toggleLoadingState();
    }
  }

  void _updateRoutine(RoutineLog log) async {
    try {
      final routineId = log.routine?.id;
      if (routineId != null) {
        final routineToUpdate = Provider.of<RoutineProvider>(context, listen: false).routineWhere(id: routineId);
        if (routineToUpdate != null) {
          final exerciseLogJsons = log.procedures
              .map((json) => ExerciseLogDto.fromJson(json: jsonDecode(json)))
              .map((exerciseLog) {
                final newSets = exerciseLog.sets.map((set) => set.copyWith(checked: false)).toList();
                return exerciseLog.copyWith(sets: newSets);
              })
              .map((exerciseLog) => exerciseLog.toJson())
              .toList();
          await Provider.of<RoutineProvider>(context, listen: false)
              .updateRoutine(routine: routineToUpdate.copyWith(procedures: exerciseLogJsons));
          if (mounted) {
            navigateToRoutinePreview(context: context, routineId: routineId);
          }
        }
      }
    } catch (_) {
      if (mounted) {
        showSnackbar(
            context: context, icon: const Icon(Icons.info_outline), message: "Oops, we are unable to update template");
      }
    } finally {
      _toggleLoadingState();
    }
  }

  void _deleteLog() async {
    try {
      await Provider.of<RoutineLogProvider>(context, listen: false).removeLog(id: widget.log.id);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        showSnackbar(
            context: context, icon: const Icon(Icons.info_outline), message: "Oops, we are unable to delete this log");
      }
    } finally {
      _toggleLoadingState();
    }
  }

  void _checkForUpdate() {
    final routine = widget.log.routine;
    if (routine == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final routineTemplate = Provider.of<RoutineProvider>(context, listen: false).routineWhere(id: routine.id);
      final routineTemplateExerciseLogs =
          routineTemplate?.procedures.map((json) => ExerciseLogDto.fromJson(json: jsonDecode(json))).toList();
      final exerciseLog1 = routineTemplateExerciseLogs ?? [];
      final exerciseLog2 =
          widget.log.procedures.map((json) => ExerciseLogDto.fromJson(json: jsonDecode(json))).toList();
      final unsavedChangesMessage =
          checkForChanges(context: context, exerciseLog1: exerciseLog1, exerciseLog2: exerciseLog2);
      if (unsavedChangesMessage.isNotEmpty) {
        print(unsavedChangesMessage);
        // showAlertDialogWithMultiActions(
        //     context: context,
        //     message: "Update template?",
        //     leftAction: Navigator.of(context).pop,
        //     rightAction: () {
        //       Navigator.of(context).pop();
        //       _toggleLoadingState(message: "Updating template from log");
        //       _updateRoutine(widget.log);
        //     },
        //     leftActionLabel: 'Cancel',
        //     rightActionLabel: 'Update',
        //     isRightActionDestructive: true);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _checkForUpdate();
  }
}
