import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/enums/routine_preview_type_enum.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/utils/navigation_utils.dart';
import 'package:tracker_app/utils/string_utils.dart';
import 'package:tracker_app/widgets/chart/muscle_group_family_chart.dart';

import '../../../colors.dart';
import '../../../dtos/exercise_log_dto.dart';
import '../../controllers/routine_log_controller.dart';
import '../../controllers/routine_template_controller.dart';
import '../../dtos/routine_log_dto.dart';
import '../../dtos/routine_template_dto.dart';
import '../../dtos/viewmodels/exercise_log_view_model.dart';
import '../../dtos/viewmodels/routine_log_arguments.dart';
import '../../enums/muscle_group_enums.dart';
import '../../enums/routine_editor_type_enums.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/exercise_logs_utils.dart';
import '../../utils/routine_utils.dart';
import '../../widgets/routine/preview/exercise_log_listview.dart';
import '../shareable_screen.dart';

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
            backgroundColor: sapphireDark80,
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
            backgroundColor: sapphireDark,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: const FaIcon(FontAwesomeIcons.penToSquare)),
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                sapphireDark80,
                sapphireDark,
              ],
            ),
          ),
          child: Stack(children: [
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
                        color: sapphireDark.withOpacity(0.4), // Set the background color
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Table(
                        border: const TableBorder.symmetric(inside: BorderSide(color: sapphireLighter, width: 2)),
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
                    MuscleGroupFamilyChart(
                        frequencyData: _muscleGroupFamilyFrequencies(exerciseLogs: completedExerciseLogsAndSets)),
                    ExerciseLogListView(
                        exerciseLogs: _exerciseLogsToViewModels(exerciseLogs: completedExerciseLogsAndSets),
                        previewType: RoutinePreviewType.log),
                  ],
                ),
              ),
            ),
          ]),
        ));
  }

  Map<MuscleGroupFamily, double> _muscleGroupFamilyFrequencies({required List<ExerciseLogDto> exerciseLogs}) {
    final frequencyMap = <MuscleGroupFamily, int>{};

    // Counting the occurrences of each MuscleGroup
    for (var log in exerciseLogs) {
      frequencyMap.update(log.exercise.primaryMuscleGroup.family, (value) => value + 1, ifAbsent: () => 1);
    }

    int totalCount = exerciseLogs.length;
    final scaledFrequencyMap = <MuscleGroupFamily, double>{};

    // Scaling the frequencies from 0 to 1
    frequencyMap.forEach((key, value) {
      scaledFrequencyMap[key] = value / totalCount;
    });

    final sortedEntries = scaledFrequencyMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    final sortedFrequencyMap = LinkedHashMap<MuscleGroupFamily, double>.fromEntries(sortedEntries);
    return sortedFrequencyMap;
  }

  void _showBottomSheet() {
    displayBottomSheet(
        context: context,
        child: SafeArea(
          child: Column(children: [
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const FaIcon(FontAwesomeIcons.pen, size: 18),
              horizontalTitleGap: 6,
              title: Text("Edit Log",
                  style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16)),
              onTap: _editLog,
            ),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const FaIcon(FontAwesomeIcons.clock, size: 18),
              horizontalTitleGap: 6,
              title: Text("Edit duration",
                  style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16)),
              onTap: _editLogDuration,
            ),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const FaIcon(FontAwesomeIcons.floppyDisk, size: 18),
              horizontalTitleGap: 6,
              title: Text("Save as template",
                  style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16)),
              onTap: _createTemplate,
            ),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const FaIcon(
                FontAwesomeIcons.trash,
                size: 18,
                color: Colors.red,
              ),
              horizontalTitleGap: 6,
              title: Text("Delete log",
                  style: GoogleFonts.montserrat(color: Colors.red, fontWeight: FontWeight.w500, fontSize: 16)),
              onTap: _deleteLog,
            ),
          ]),
        ));
  }

  void _onShareLog({required RoutineLogDto log}) {
    final completedExerciseLogsAndSets = exerciseLogsWithCheckedSets(exerciseLogs: log.exerciseLogs);
    final updatedLog = log.copyWith(exerciseLogs: completedExerciseLogsAndSets);

    navigateWithSlideTransition(
        context: context,
        child: ShareableScreen(
            log: updatedLog, frequencyData: _muscleGroupFamilyFrequencies(exerciseLogs: completedExerciseLogsAndSets)));
  }

  void _toggleLoadingState({String message = ""}) {
    setState(() {
      _loading = !_loading;
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

  void _editLog() {
    Navigator.of(context).pop();
    final arguments = RoutineLogArguments(log: widget.log, editorMode: RoutineEditorMode.edit);
    navigateToRoutineLogEditor(context: context, arguments: arguments);
  }

  void _editLogDuration() {
    Navigator.of(context).pop();
    showDatetimeRangePicker(
        context: context,
        initialDateTimeRange: DateTimeRange(start: widget.log.startTime, end: widget.log.endTime),
        onChangedDateTimeRange: (DateTimeRange datetimeRange) async {
          Navigator.of(context).pop();
          final updatedRoutineLog = widget.log.copyWith(startTime: datetimeRange.start, endTime: datetimeRange.end);
          await Provider.of<RoutineLogController>(context, listen: false).updateLog(log: updatedRoutineLog);
        });
  }

  void _createTemplate() async {
    Navigator.of(context).pop();

    final log = widget.log;

    _toggleLoadingState(message: "Creating template");

    try {
      final exercises = log.exerciseLogs.map((exerciseLog) {
        final uncheckedSets = exerciseLog.sets.map((set) => set.copyWith(checked: false)).toList();

        /// [Exercise.duration] exercises do not have sets in templates
        /// This is because we only need to store the duration of the exercise in [RoutineEditorType.log] i.e data is log in realtime
        final sets = withDurationOnly(type: exerciseLog.exercise.type) ? <SetDto>[] : uncheckedSets;
        return exerciseLog.copyWith(sets: sets);
      }).toList();
      final templateToCreate = RoutineTemplateDto(
          id: "",
          name: log.name,
          notes: log.notes,
          exerciseTemplates: exercises,
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
      final newTemplate = templateToUpdate.copyWith(exerciseTemplates: exerciseLogs);
      await Provider.of<RoutineTemplateController>(context, listen: false).updateTemplate(template: newTemplate);
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
    Navigator.of(context).pop();

    showBottomSheetWithMultiActions(
        context: context,
        title: "Delete log?",
        description: "Are you sure you want to delete this log?",
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

  @override
  void initState() {
    super.initState();

    if (widget.finishedLogging) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _doUpdateTemplate();
        _onShareLog(log: widget.log);
      });
    }
  }
}
