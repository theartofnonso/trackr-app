
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/enums/routine_preview_type_enum.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/utils/navigation_utils.dart';
import 'package:tracker_app/utils/string_utils.dart';
import 'package:tracker_app/widgets/backgrounds/overlay_background.dart';
import 'package:tracker_app/widgets/buttons/text_button_widget.dart';
import 'package:tracker_app/widgets/chart/routine_muscle_group_split_chart.dart';

import '../../../app_constants.dart';
import '../../../dtos/exercise_log_dto.dart';
import '../../controllers/routine_log_controller.dart';
import '../../controllers/routine_template_controller.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/exercise_logs_utils.dart';
import '../../utils/routine_utils.dart';
import '../../dtos/viewmodels/exercise_log_view_model.dart';
import '../../dtos/routine_log_dto.dart';
import '../../dtos/routine_template_dto.dart';
import '../../enums/routine_editor_type_enums.dart';
import '../../widgets/routine/preview/exercise_log_listview.dart';
import '../../widgets/shareables/shareable_container.dart';

class RoutineLogPreviewScreen extends StatefulWidget {
  final RoutineLogDto log;
  final String previousRouteName;
  final bool finishedLogging;

  const RoutineLogPreviewScreen(
      {super.key, required this.log, this.previousRouteName = "", this.finishedLogging = false});

  @override
  State<RoutineLogPreviewScreen> createState() => _RoutineLogPreviewScreenState();
}

class _RoutineLogPreviewScreenState extends State<RoutineLogPreviewScreen> {
  bool _loading = false;
  String _loadingMessage = "";

  @override
  Widget build(BuildContext context) {
    final foundLog = Provider.of<RoutineLogController>(context, listen: true).logWhereId(id: widget.log.id);

    final log = foundLog ?? widget.log;

    final numberOfCompletedSets = _calculateCompletedSets(procedures: log.exerciseLogs);
    final completedSetsSummary = "$numberOfCompletedSets ${pluralize(word: "Set", count: numberOfCompletedSets)}";

    final completedExerciseLogsAndSets = exerciseLogsWithCheckedSets(exerciseLogs: log.exerciseLogs);

    return Scaffold(
        backgroundColor: sapphireDark,
        appBar: AppBar(
            leading: IconButton(
              icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(log.name,
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16)),
            actions: [
              IconButton(
                  onPressed: () => _onShareLog(log: log),
                  icon: const FaIcon(FontAwesomeIcons.arrowUpFromBracket, color: Colors.white, size: 18)),
            ]),
        floatingActionButton: FloatingActionButton(
            heroTag: "routine_log_screen",
            onPressed: _showBottomSheet,
            backgroundColor: sapphireLighter,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: const FaIcon(FontAwesomeIcons.circle)),
        body: Stack(children: [
          SafeArea(
            minimum: const EdgeInsets.only(right: 10, bottom: 10, left: 10),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (log.notes.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(log.notes,
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 14,
                          )),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.date_range_rounded,
                        color: Colors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 1),
                      Text(log.createdAt.formattedDayAndMonthAndYear(),
                          style: GoogleFonts.montserrat(
                              color: Colors.white.withOpacity(0.95), fontWeight: FontWeight.w500, fontSize: 12)),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.access_time_rounded,
                        color: Colors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 1),
                      Text(log.endTime.formattedTime(),
                          style: GoogleFonts.montserrat(
                              color: Colors.white.withOpacity(0.95), fontWeight: FontWeight.w500, fontSize: 12)),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 24, bottom: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5), // Use BorderRadius.circular for a rounded container
                      color: sapphireLight, // Set the background color
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Table(
                      border: TableBorder.symmetric(inside: const BorderSide(color: sapphireLighter, width: 2)),
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
                                  style: GoogleFonts.montserrat(
                                      color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
                            ),
                          ),
                          TableCell(
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            child: Center(
                              child: Text(
                                  "${completedExerciseLogsAndSets.length} ${pluralize(word: "Exercise", count: completedExerciseLogsAndSets.length)}",
                                  style: GoogleFonts.montserrat(
                                      color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
                            ),
                          ),
                          TableCell(
                            verticalAlignment: TableCellVerticalAlignment.middle,
                            child: Center(
                              child: Text(log.duration().hmsAnalog(),
                                  style: GoogleFonts.montserrat(
                                      color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
                            ),
                          )
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  RoutineMuscleGroupSplitChart(frequencyData: muscleGroupFrequency(exerciseLogs: completedExerciseLogsAndSets)),
                  ExerciseLogListView(
                      exerciseLogs: _exerciseLogsToViewModels(exerciseLogs: completedExerciseLogsAndSets),
                      previewType: RoutinePreviewType.log),
                ],
              ),
            ),
          ),
          if (_loading) OverlayBackground(loadingMessage: _loadingMessage)
        ]));
  }

  void _showBottomSheet() {
    displayBottomSheet(context: context, child: Column(
      children: [
        const SizedBox(height: 10),
        ListTile(
          dense: true,
          title: Text("Edit Log", style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
          onTap: () {
            Navigator.of(context).pop();
            _editLog(log: widget.log);
          },
        ),
        ListTile(
          dense: true,
          title: Text("Save as template", style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
          onTap: () {
            Navigator.of(context).pop();
            _createTemplate();
          },
        ),
        ListTile(
          dense: true,
          title: Text("Delete log", style: GoogleFonts.montserrat(color: Colors.red, fontWeight: FontWeight.w500, fontSize: 14)),
          onTap: () {
            Navigator.of(context).pop();
            _deleteLog();
          },
        ),
      ]
    ));
  }

  void _onShareLog({required RoutineLogDto log}) {
    final completedExerciseLogsAndSets = exerciseLogsWithCheckedSets(exerciseLogs: log.exerciseLogs);
    final updatedLog = log.copyWith(exerciseLogs: completedExerciseLogsAndSets);

    displayBottomSheet(
        color: sapphireDark,
        padding: const EdgeInsets.only(top: 16, left: 10, right: 10),
        context: context,
        isScrollControlled: true,
        child: ShareableContainer(log: updatedLog, frequencyData: muscleGroupFrequency(exerciseLogs: completedExerciseLogsAndSets)));
  }

  void _toggleLoadingState({String message = ""}) {
    setState(() {
      _loading = !_loading;
      _loadingMessage = message;
    });
  }

  List<ExerciseLogViewModel> _exerciseLogsToViewModels({required List<ExerciseLogDto> exerciseLogs}) {
    return exerciseLogs
        .map((exerciseLog) => ExerciseLogViewModel(
            exerciseLog: exerciseLog,
            superSet: whereOtherExerciseInSuperSet(firstExercise: exerciseLog, exercises: exerciseLogs)))
        .toList();
  }

  int _calculateCompletedSets({required List<ExerciseLogDto> procedures}) {
    List<SetDto> completedSets = [];
    for (var procedure in procedures) {
      completedSets.addAll(procedure.sets);
    }
    return completedSets.length;
  }

  void _editLog({required RoutineLogDto log}) {
    navigateToRoutineLogEditor(context: context, log: log, editorMode: RoutineEditorMode.edit);
  }

  void _createTemplate() async {
    final log = widget.log;
    try {
      final exercises = log.exerciseLogs.map((exerciseLog) {
        final newSets = exerciseLog.sets.map((set) => set.copyWith(checked: false)).toList();
        return exerciseLog.copyWith(sets: newSets);
      }).toList();
      final templateToCreate = RoutineTemplateDto(
          id: "",
          name: log.name,
          notes: log.notes,
          exercises: exercises,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now());
      final createdTemplate = await Provider.of<RoutineTemplateController>(context, listen: false)
          .saveTemplate(templateDto: templateToCreate);
      if (mounted) {
        if (createdTemplate != null) {
          navigateToRoutineTemplatePreview(context: context, template: createdTemplate);
        }
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

  Future<void> _doUpdateTemplate() async {
    final templateToUpdate =
        Provider.of<RoutineTemplateController>(context, listen: false).templateWhere(id: widget.log.templateId);
    if (templateToUpdate != null) {
      final exerciseLogs = widget.log.exerciseLogs.map((exerciseLog) {
        final newSets = exerciseLog.sets.map((set) => set.copyWith(checked: false)).toList();
        return exerciseLog.copyWith(sets: newSets);
      }).toList();
      final newTemplate = templateToUpdate.copyWith(exercises: exerciseLogs);
      await Provider.of<RoutineTemplateController>(context, listen: false).updateTemplate(template: newTemplate);
    }
  }

  Future<void> _doUpdateTemplateSetsOnly() async {
    final templateToUpdate =
        Provider.of<RoutineTemplateController>(context, listen: false).templateWhere(id: widget.log.templateId);
    if (templateToUpdate != null) {
      await Provider.of<RoutineTemplateController>(context, listen: false)
          .updateTemplateSetsOnly(templateId: widget.log.templateId, newExercises: widget.log.exerciseLogs);
    }
  }

  void _doDeleteLog() async {
    try {
      await Provider.of<RoutineLogController>(context, listen: false).removeLog(log: widget.log);
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

  void _deleteLog() {
    showAlertDialogWithMultiActions(
        context: context,
        message: "Delete log?",
        leftAction: Navigator.of(context).pop,
        rightAction: () {
          Navigator.of(context).pop();
          _toggleLoadingState(message: "Deleting log");
          _doDeleteLog();
        },
        leftActionLabel: 'Cancel',
        rightActionLabel: 'Delete',
        isRightActionDestructive: true);
  }

  void _checkForTemplateUpdates() {
    final templateId = widget.log.templateId;

    if (templateId.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onShareLog(log: widget.log);
      });
      return;
    }

    final routineTemplate =
        Provider.of<RoutineTemplateController>(context, listen: false).templateWhere(id: templateId);
    if (routineTemplate == null) {
      return;
    }

    final exerciseLog1 = routineTemplate.exercises;
    final exerciseLog2 = widget.log.exerciseLogs;
    final templateChanges = checkForChanges(exerciseLog1: exerciseLog1, exerciseLog2: exerciseLog2);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (templateChanges.isNotEmpty) {
        displayBottomSheet(
            isDismissible: false,
            enabledDrag: false,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            context: context,
            child: _TemplateChangesDialog(
                templateName: routineTemplate.name,
                onPressed: () {
                  Navigator.of(context).pop();
                  _doUpdateTemplate();
                  _onShareLog(log: widget.log);
                },
                onDismissed: () {
                  Navigator.of(context).pop();
                  _doUpdateTemplateSetsOnly();
                  _onShareLog(log: widget.log);
                }));
      } else {
        _doUpdateTemplate();
        _onShareLog(log: widget.log);
      }
    });
  }

  @override
  void initState() {
    super.initState();

    if (widget.finishedLogging) {
      _checkForTemplateUpdates();
    }
  }
}

class _TemplateChangesDialog extends StatelessWidget {
  final String templateName;
  final void Function() onPressed;
  final void Function() onDismissed;

  const _TemplateChangesDialog({required this.templateName, required this.onPressed, required this.onDismissed});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("Update $templateName?",
            style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
            textAlign: TextAlign.start),
        Text("You have made changes to this template. Do you want to update it",
            style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white70),
            textAlign: TextAlign.start),
        const SizedBox(height: 16),
        Row(children: [
          const SizedBox(width: 15),
          CTextButton(
              onPressed: onDismissed,
              label: "Cancel",
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white),
              buttonColor: Colors.transparent,
              buttonBorderColor: Colors.transparent),
          const SizedBox(width: 10),
          CTextButton(
              onPressed: onPressed,
              label: "Update Template",
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black),
              buttonColor: vibrantGreen)
        ])
      ],
    );
  }
}
