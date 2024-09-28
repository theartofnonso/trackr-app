import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/enums/routine_preview_type_enum.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/extensions/routine_log_extension.dart';
import 'package:tracker_app/screens/logs/routine_log_summary_screen.dart';
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
import '../../enums/routine_editor_type_enums.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/exercise_logs_utils.dart';
import '../../utils/routine_utils.dart';
import '../../widgets/information_container_lite.dart';
import '../../widgets/routine/preview/exercise_log_listview.dart';

class RoutineLogScreen extends StatefulWidget {
  static const routeName = '/routine_log_screen';

  final String id;
  final bool showSummary;

  const RoutineLogScreen({super.key, required this.id, required this.showSummary});

  @override
  State<RoutineLogScreen> createState() => _RoutineLogScreenState();
}

class _RoutineLogScreenState extends State<RoutineLogScreen> {
  RoutineLogDto? _log;

  bool _loading = false;

  bool _isOwner = false;

  @override
  Widget build(BuildContext context) {
    final log = _log;

    if (log == null) {
      Provider.of<RoutineTemplateController>(context, listen: false).fetchTemplate(id: widget.id);
      return const _EmptyState();
    }

    final completedExerciseLogsAndSets = exerciseLogsWithCheckedSets(exerciseLogs: log.exerciseLogs);

    final numberOfCompletedSets = completedExerciseLogsAndSets.expand((exerciseLog) => exerciseLog.sets);
    final completedSetsSummary =
        "${numberOfCompletedSets.length} ${pluralize(word: "Set", count: numberOfCompletedSets.length)}";

    return Scaffold(
        backgroundColor: sapphireDark,
        appBar: AppBar(
            backgroundColor: sapphireDark80,
            leading: IconButton(
              icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
              onPressed: () => context.pop(),
            ),
            title: Text(log.name,
                style: GoogleFonts.ubuntu(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16)),
            actions: _isOwner
                ? [
                    IconButton(
                        onPressed: () => _onShareLog(log: log),
                        icon: const FaIcon(FontAwesomeIcons.arrowUpFromBracket, color: Colors.white, size: 18)),
                  ]
                : []),
        floatingActionButton: _isOwner
            ? FloatingActionButton(
                heroTag: "routine_log_screen",
                onPressed: _showBottomSheet,
                backgroundColor: sapphireDark,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                child: const FaIcon(FontAwesomeIcons.penToSquare))
            : null,
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
                            style: GoogleFonts.ubuntu(
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
                            style: GoogleFonts.ubuntu(
                                color: Colors.white.withOpacity(0.95), fontWeight: FontWeight.w500, fontSize: 12)),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.access_time_rounded,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 1),
                        Text(log.endTime.formattedTime(),
                            style: GoogleFonts.ubuntu(
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
                                    style: GoogleFonts.ubuntu(
                                        color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
                              ),
                            ),
                            TableCell(
                              verticalAlignment: TableCellVerticalAlignment.middle,
                              child: Center(
                                child: Text(
                                    "${completedExerciseLogsAndSets.length} ${pluralize(word: "Exercise", count: completedExerciseLogsAndSets.length)}",
                                    style: GoogleFonts.ubuntu(
                                        color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
                              ),
                            ),
                            TableCell(
                              verticalAlignment: TableCellVerticalAlignment.middle,
                              child: Center(
                                child: Text(log.duration().hmsAnalog(),
                                    style: GoogleFonts.ubuntu(
                                        color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
                              ),
                            )
                          ]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    MuscleGroupFamilyChart(
                        frequencyData: muscleGroupFamilyFrequency(exerciseLogs: completedExerciseLogsAndSets)),
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

  void _loadData() {
    final routineLogController = Provider.of<RoutineLogController>(context, listen: false);
    _log = routineLogController.logWhereId(id: widget.id);
    if (_log == null) {
      _loading = true;
      routineLogController.fetchLog(id: widget.id).then((data) {
        setState(() {
          _loading = false;
          _log = data?.dto();
        });
      });
    } else {
      _isOwner = _log != null;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    if (widget.showSummary) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final log = _log;
        if (log != null) {
          navigateWithSlideTransition(context: context, child: RoutineLogSummaryScreen(log: log));
        }
      });
    }
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
                  style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16)),
              onTap: _editLog,
            ),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const FaIcon(FontAwesomeIcons.clock, size: 18),
              horizontalTitleGap: 6,
              title: Text("Edit duration",
                  style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16)),
              onTap: _editLogDuration,
            ),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const FaIcon(FontAwesomeIcons.floppyDisk, size: 18),
              horizontalTitleGap: 6,
              title: Text("Save as template",
                  style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16)),
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
                  style: GoogleFonts.ubuntu(color: Colors.red, fontWeight: FontWeight.w500, fontSize: 16)),
              onTap: _deleteLog,
            ),
          ]),
        ));
  }

  void _onShareLog({required RoutineLogDto log}) {
    navigateToShareableScreen(context: context, log: log);
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

  void _editLog() {
    context.pop();
    final log = _log;
    if (log != null) {
      final arguments = RoutineLogArguments(log: _log!, editorMode: RoutineEditorMode.edit);
      navigateToRoutineLogEditor(context: context, arguments: arguments);
    }
  }

  void _editLogDuration() {
    context.pop();
    final log = _log;
    if (log != null) {
      showDatetimeRangePicker(
          context: context,
          initialDateTimeRange: DateTimeRange(start: log.startTime, end: log.endTime),
          onChangedDateTimeRange: (DateTimeRange datetimeRange) async {
            context.pop();
            final updatedRoutineLog = log.copyWith(startTime: datetimeRange.start, endTime: datetimeRange.end);
            await Provider.of<RoutineLogController>(context, listen: false).updateLog(log: updatedRoutineLog);
          });
    }
  }

  void _createTemplate() async {
    context.pop();

    final log = _log;
    if (log != null) {
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
              context: context,
              icon: const Icon(Icons.info_outline),
              message: "Oops, we are unable to create template");
        }
      } finally {
        _toggleLoadingState();
      }
    }
  }

  void _doDeleteLog() async {
    final log = _log;
    if (log != null) {
      try {
        await Provider.of<RoutineLogController>(context, listen: false).removeLog(log: log);
        if (mounted) {
          context.pop();
        }
      } catch (_) {
        if (mounted) {
          showSnackbar(
              context: context,
              icon: const Icon(Icons.info_outline),
              message: "Oops, we are unable to delete this log");
        }
      } finally {
        _toggleLoadingState();
      }
    }
  }

  void _deleteLog() {
    context.pop(); // Close the previous BottomSheet
    showBottomSheetWithMultiActions(
        context: context,
        title: "Delete log?",
        description: "Are you sure you want to delete this log?",
        leftAction: context.pop,
        rightAction: () {
          context.pop(); // Close current BottomSheet
          _toggleLoadingState(message: "Deleting log");
          _doDeleteLog();
        },
        leftActionLabel: 'Cancel',
        rightActionLabel: 'Delete',
        isRightActionDestructive: true);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: sapphireDark80,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
          onPressed: () => context.pop(),
        ),
        title: Text("Workout Log",
            style: GoogleFonts.ubuntu(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16)),
      ),
      body: Container(
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
        child: SafeArea(
            child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                  text: TextSpan(
                      style: GoogleFonts.ubuntu(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.white),
                      children: [
                    TextSpan(
                        text: "Not F",
                        style:
                            GoogleFonts.ubuntu(fontSize: 48, color: Colors.white70, fontWeight: FontWeight.w900)),
                    const WidgetSpan(
                        child: Padding(
                          padding: EdgeInsets.only(left: 6.0),
                          child: FaIcon(FontAwesomeIcons.magnifyingGlass, size: 48, color: Colors.white70),
                        ),
                        alignment: PlaceholderAlignment.middle),
                    TextSpan(
                        text: "und",
                        style:
                            GoogleFonts.ubuntu(fontSize: 48, color: Colors.white70, fontWeight: FontWeight.w900)),
                  ])),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                child: InformationContainerLite(
                    content: "We can't find this workout log, Please check the link and try again.",
                    color: Colors.orange),
              ),
            ],
          ),
        )),
      ),
    );
  }
}
