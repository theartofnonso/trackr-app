import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/dtos/template_changes_messages_dto.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/providers/exercise_provider.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/utils/navigation_utils.dart';
import 'package:tracker_app/widgets/backgrounds/overlay_background.dart';
import 'package:tracker_app/widgets/buttons/text_button_widget.dart';

import '../../app_constants.dart';
import '../../dtos/exercise_log_dto.dart';
import '../../providers/routine_log_provider.dart';
import '../../widgets/helper_widgets/dialog_helper.dart';
import '../../widgets/helper_widgets/routine_helper.dart';
import '../dtos/viewmodels/exercise_log_view_model.dart';
import '../dtos/routine_log_dto.dart';
import '../dtos/routine_template_dto.dart';
import '../enums/muscle_group_enums.dart';
import '../providers/routine_template_provider.dart';
import '../widgets/fabs/expandable_fab.dart';
import '../widgets/fabs/fab_action.dart';
import '../widgets/routine/preview/exercise_log_listview.dart';
import 'editors/helper_utils.dart';
import 'editors/routine_log_editor_screen.dart';

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
    Provider.of<ExerciseProvider>(context, listen: true);

    final foundLog = Provider.of<RoutineLogProvider>(context, listen: true).whereRoutineLog(id: widget.log.id);

    final log = foundLog ?? widget.log;

    List<ExerciseLogDto> exerciseLogs = log.exerciseLogs.map((exerciseLog) {
      final exerciseFromLibrary = Provider.of<ExerciseProvider>(context, listen: false)
          .whereExerciseOrNull(exerciseId: exerciseLog.exercise.id);
      if (exerciseFromLibrary != null) {
        return exerciseLog.copyWith(exercise: exerciseFromLibrary);
      }
      return exerciseLog;
    }).toList();

    final numberOfCompletedSets = _calculateCompletedSets(procedures: exerciseLogs);
    final completedSetsSummary = "$numberOfCompletedSets set(s)";

    return Scaffold(
        backgroundColor: tealBlueDark,
        appBar: AppBar(
          leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title:
              Text(log.name, style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16)),
        ),
        floatingActionButton: ExpandableFab(
          distance: 112,
          children: [
            ActionButton(
              onPressed: () => _editLog(log: log),
              icon: const FaIcon(FontAwesomeIcons.solidPenToSquare, color: Colors.white),
            ),
            ActionButton(
              onPressed: _createTemplate,
              icon: const FaIcon(FontAwesomeIcons.fileCirclePlus, color: Colors.white),
            ),
            ActionButton(
              onPressed: _deleteLog,
              icon: FaIcon(FontAwesomeIcons.trash, color: Colors.red.withOpacity(0.9)),
            ),
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
                                style: GoogleFonts.montserrat(
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
                                    style: GoogleFonts.montserrat(
                                        color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
                              ),
                            ),
                            TableCell(
                              verticalAlignment: TableCellVerticalAlignment.middle,
                              child: Center(
                                child: Text("${log.exerciseLogs.length} exercise(s)",
                                    style: GoogleFonts.montserrat(
                                        color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
                              ),
                            ),
                            TableCell(
                              verticalAlignment: TableCellVerticalAlignment.middle,
                              child: Center(
                                child: Text(log.duration().secondsOrMinutesOrHours(),
                                    style: GoogleFonts.montserrat(
                                        color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
                              ),
                            )
                          ]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    _HorizontalBarChart(frequencyData: calculateFrequency(exerciseLogs)),
                    ExerciseLogListView(exerciseLogs: _exerciseLogsToViewModels(exerciseLogs: exerciseLogs)),
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

  Map<MuscleGroupFamily, double> calculateFrequency(List<ExerciseLogDto> logList) {
    var frequencyMap = <MuscleGroupFamily, int>{};

    // Counting the occurrences of each MuscleGroup
    for (var log in logList) {
      frequencyMap.update(log.exercise.primaryMuscleGroup.family, (value) => value + 1, ifAbsent: () => 1);
    }

    int totalCount = logList.length;
    var scaledFrequencyMap = <MuscleGroupFamily, double>{};

    // Scaling the frequencies from 0 to 1
    frequencyMap.forEach((key, value) {
      scaledFrequencyMap[key] = value / totalCount;
    });

    var sortedEntries = scaledFrequencyMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    var sortedFrequencyMap = LinkedHashMap<MuscleGroupFamily, double>.fromEntries(sortedEntries);

    return sortedFrequencyMap;
  }

  List<ExerciseLogViewModel> _exerciseLogsToViewModels({required List<ExerciseLogDto> exerciseLogs}) {
    return exerciseLogs
        .map((exerciseLog) {
          final completedSets = exerciseLog.sets.where((set) => set.isNotEmpty() && set.checked).toList();
          if (completedSets.isNotEmpty) {
            return ExerciseLogViewModel(
                exerciseLog: exerciseLog = exerciseLog.copyWith(sets: completedSets),
                superSet: whereOtherExerciseInSuperSet(firstExercise: exerciseLog, exercises: exerciseLogs));
          }
          return null;
        })
        .whereType<ExerciseLogViewModel>()
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
    navigateToRoutineLogEditor(context: context, log: log, editorMode: RoutineLogEditorMode.edit);
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
      final createdTemplate = await Provider.of<RoutineTemplateProvider>(context, listen: false).saveTemplate(templateDto: templateToCreate);
      if (mounted) {
        navigateToRoutinePreview(context: context, templateId: createdTemplate.id);
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
    Provider.of<RoutineTemplateProvider>(context, listen: false).templateWhere(id: widget.log.templateId);
    if (templateToUpdate != null) {
      final exerciseLogs = widget.log.exerciseLogs.map((exerciseLog) {
        final newSets = exerciseLog.sets.map((set) => set.copyWith(checked: false)).toList();
        return exerciseLog.copyWith(sets: newSets);
      }).toList();
      await Provider.of<RoutineTemplateProvider>(context, listen: false)
          .updateTemplate(template: templateToUpdate.copyWith(exercises: exerciseLogs));
    }
  }

  void _updateTemplate() async {
    _toggleLoadingState(message: "Updating template from log");

    try {
      await _doUpdateTemplate();
    } catch (_) {
      if (mounted) {
        showSnackbar(
            context: context, icon: const Icon(Icons.info_outline), message: "Oops, we are unable to update template");
      }
    } finally {
      _toggleLoadingState();
    }
  }

  void _doDeleteLog() async {
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
      return;
    }

    final routineTemplate = Provider.of<RoutineTemplateProvider>(context, listen: false).templateWhere(id: templateId);
    if (routineTemplate == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final exerciseLog1 = routineTemplate.exercises;
      final exerciseLog2 = widget.log.exerciseLogs;
      final templateChanges = checkForChanges(context: context, exerciseLog1: exerciseLog1, exerciseLog2: exerciseLog2);
      if (templateChanges.isNotEmpty) {
        displayBottomSheet(
            context: context,
            child: _TemplateChangesListView(
                templateName: routineTemplate.name,
                changes: templateChanges,
                onPressed: () {
                  Navigator.of(context).pop();
                  _updateTemplate();
                }));
      } else {
        _doUpdateTemplate();
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

class _TemplateChangesListView extends StatelessWidget {
  final String templateName;
  final List<TemplateChangesMessageDto> changes;
  final void Function() onPressed;

  const _TemplateChangesListView({required this.templateName, required this.changes, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final listTiles = changes
        .map((change) => ListTile(
            dense: true,
            title: Text(change.message, style: GoogleFonts.montserrat(color: Colors.white)),
            leading: const Icon(Icons.info_outline_rounded),
            horizontalTitleGap: 6))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15, top: 12.0, bottom: 10),
          child: Text("Update $templateName",
              style: GoogleFonts.montserrat(color: Colors.white70, fontWeight: FontWeight.w500, fontSize: 15)),
        ),
        ...listTiles,
        const SizedBox(height: 10),
        Align(alignment: Alignment.center, child: CTextButton(onPressed: onPressed, label: "Update template"))
      ],
    );
  }
}

class _HorizontalBarChart extends StatelessWidget {

  final Map<MuscleGroupFamily, double> frequencyData;

  const _HorizontalBarChart({required this.frequencyData});

  @override
  Widget build(BuildContext context) {
    final children = frequencyData.entries.map((entry) => _LinearBar(muscleGroupFamily: entry.key, frequency: entry.value)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [...children,
        const SizedBox(height: 2),
        Text("Calculations are based on primary muscle groups",
            style: GoogleFonts.montserrat(color: Colors.white70, fontWeight: FontWeight.w500, fontSize: 12)),
        const SizedBox(height: 8),
      ]
    );
  }
}

class _LinearBar extends StatelessWidget {
  final MuscleGroupFamily muscleGroupFamily;
  final double frequency;

  const _LinearBar({required this.muscleGroupFamily, required this.frequency});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(children: [
          LinearProgressIndicator(
            value: frequency,
            backgroundColor: Colors.green.withOpacity(0.1),
            color: Colors.green,
            minHeight: 24,
            borderRadius: BorderRadius.circular(3.0), // Border r
          ),
          Positioned.fill(
            child: Align(
             alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 1, right: 14),
                child: Text(muscleGroupFamily.name, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          )
        ],),
        const SizedBox(height: 8),
      ],
    );
  }
}
