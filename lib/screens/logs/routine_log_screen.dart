import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/enums/routine_preview_type_enum.dart';
import 'package:tracker_app/extensions/amplify_models/routine_log_extension.dart';
import 'package:tracker_app/screens/logs/routine_log_summary_screen.dart';
import 'package:tracker_app/shared_prefs.dart';
import 'package:tracker_app/utils/general_utils.dart';
import 'package:tracker_app/utils/https_utils.dart';
import 'package:tracker_app/utils/navigation_utils.dart';
import 'package:tracker_app/widgets/backgrounds/trkr_loading_screen.dart';
import 'package:tracker_app/widgets/chart/muscle_group_family_chart.dart';

import '../../../colors.dart';
import '../../../dtos/exercise_log_dto.dart';
import '../../controllers/exercise_and_routine_controller.dart';
import '../../controllers/routine_user_controller.dart';
import '../../dtos/appsync/routine_log_dto.dart';
import '../../dtos/appsync/routine_template_dto.dart';
import '../../dtos/viewmodels/exercise_log_view_model.dart';
import '../../dtos/viewmodels/routine_log_arguments.dart';
import '../../enums/routine_editor_type_enums.dart';
import '../../models/RoutineLog.dart';
import '../../openAI/open_ai.dart';
import '../../strings/ai_prompts.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/exercise_logs_utils.dart';
import '../../utils/routine_utils.dart';
import '../../widgets/ai_widgets/trkr_information_container.dart';
import '../../widgets/routine/preview/date_duration_pb.dart';
import '../../widgets/routine/preview/exercise_log_listview.dart';
import '../AI/trkr_coach_summary_screen.dart';
import '../empty_state_screens/not_found.dart';

class RoutineLogScreen extends StatefulWidget {
  static const routeName = '/routine_log_screen';

  final String id;
  final bool showSummary;
  final bool isEditable;

  const RoutineLogScreen({super.key, required this.id, required this.showSummary, this.isEditable = true});

  @override
  State<RoutineLogScreen> createState() => _RoutineLogScreenState();
}

class _RoutineLogScreenState extends State<RoutineLogScreen> {
  RoutineLogDto? _log;

  bool _loading = false;

  bool _minimized = true;

  @override
  Widget build(BuildContext context) {
    if (_loading) return TRKRLoadingScreen(action: _hideLoadingScreen);

    final routineLogController = Provider.of<ExerciseAndRoutineController>(context, listen: false);

    if (routineLogController.errorMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showSnackbar(
            context: context,
            icon: const FaIcon(FontAwesomeIcons.circleInfo),
            message: routineLogController.errorMessage);
      });
    }

    final routineUserController = Provider.of<RoutineUserController>(context, listen: false);

    final log = _log;

    if (log == null) return const NotFound();

    final updatedExerciseLogs = completedExercises(exerciseLogs: log.exerciseLogs);

    final updatedLog = log.copyWith(exerciseLogs: updatedExerciseLogs);

    final numberOfCompletedSets = updatedExerciseLogs.expand((exerciseLog) => exerciseLog.sets);

    final muscleGroupFamilyFrequencies = muscleGroupFamilyFrequency(exerciseLogs: updatedExerciseLogs);

    final calories = calculateCalories(
        duration: updatedLog.duration(), bodyWeight: routineUserController.weight(), activity: log.activityType);

    final pbs = updatedLog.exerciseLogs.map((exerciseLog) {
      final pastExerciseLogs =
          routineLogController.whereExerciseLogsBefore(exercise: exerciseLog.exercise, date: exerciseLog.createdAt);

      return calculatePBs(
          pastExerciseLogs: pastExerciseLogs, exerciseType: exerciseLog.exercise.type, exerciseLog: exerciseLog);
    }).expand((pbs) => pbs);

    return Scaffold(
        backgroundColor: sapphireDark,
        appBar: AppBar(
            backgroundColor: sapphireDark80,
            leading: IconButton(
              icon: const FaIcon(FontAwesomeIcons.solidCircleXmark, color: Colors.white, size: 28),
              onPressed: context.pop,
            ),
            title: Text(updatedLog.name,
                style: GoogleFonts.ubuntu(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16)),
            actions: updatedLog.owner == SharedPrefs().userId && widget.isEditable
                ? [
                    IconButton(
                        onPressed: () => _onShareLog(log: log),
                        icon: const FaIcon(FontAwesomeIcons.arrowUpFromBracket, color: Colors.white, size: 18)),
                  ]
                : []),
        floatingActionButton: updatedLog.owner == SharedPrefs().userId && widget.isEditable
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                        child: DateDurationPBWidget(
                            dateTime: updatedLog.createdAt, duration: updatedLog.duration(), pbs: 0)),
                    if (updatedLog.notes.isNotEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20, right: 10, bottom: 10, left: 10),
                          child: Text('"${updatedLog.notes}"',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.ubuntu(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),

                    /// Keep this spacing for when notes isn't available
                    if (updatedLog.notes.isEmpty)
                      const SizedBox(
                        height: 20,
                      ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          _StatisticWidget(
                            title: "${updatedExerciseLogs.length}",
                            subtitle: "Exercises",
                            image: "dumbbells",
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          _StatisticWidget(
                            title: "${numberOfCompletedSets.length}",
                            subtitle: "Sets",
                            icon: FontAwesomeIcons.listOl,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          _StatisticWidget(
                            title: "$calories",
                            subtitle: "Calories",
                            icon: FontAwesomeIcons.fire,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          _StatisticWidget(
                            title: "${pbs.length}",
                            subtitle: "PBs",
                            icon: FontAwesomeIcons.star,
                          ),
                          const SizedBox(
                            width: 10,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: _onMinimiseMuscleGroupSplit,
                            child: Container(
                              color: Colors.transparent,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Text("Muscle Groups Split".toUpperCase(),
                                        style: GoogleFonts.ubuntu(
                                            color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                                    const Spacer(),
                                    if (muscleGroupFamilyFrequencies.length > 3)
                                      FaIcon(_minimized ? FontAwesomeIcons.angleDown : FontAwesomeIcons.angleUp,
                                          color: Colors.white70, size: 16),
                                  ]),
                                  const SizedBox(height: 10),
                                  Text("Here's a breakdown of the muscle groups in your ${log.name} workout log.",
                                      style: GoogleFonts.ubuntu(
                                          color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 10),
                                  MuscleGroupFamilyChart(
                                      frequencyData: muscleGroupFamilyFrequencies, minimized: _minimized),
                                ],
                              ),
                            ),
                          ),
                          if (updatedLog.owner == SharedPrefs().userId && widget.isEditable)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                              child: TRKRInformationContainer(
                                  ctaLabel: updatedLog.summary != null ? "Review your feedback" : "Ask for feedback",
                                  description:
                                      "Completing a workout is an achievement, however consistent progress is what drives you toward your ultimate fitness goals.",
                                  onTap: () => updatedLog.summary != null
                                      ? _showSummary()
                                      : _generateSummary(logs: updatedExerciseLogs)),
                            ),
                          ExerciseLogListView(
                              exerciseLogs: _exerciseLogsToViewModels(exerciseLogs: updatedExerciseLogs),
                              previewType: RoutinePreviewType.log),
                        ],
                      ),
                    )
                    //
                    // const EdgeInsets.only(right: 10, bottom: 10, left: 10)
                  ],
                ),
              ),
            ),
          ]),
        ));
  }

  void _onMinimiseMuscleGroupSplit() {
    setState(() {
      _minimized = !_minimized;
    });
  }

  void _showSummary() {
    final log = _log;

    if (log != null) {
      final summary = log.summary;
      if (summary != null) {
        navigateWithSlideTransition(
            context: context,
            child: TRKRCoachSummaryScreen(
              content: summary,
            ));
      }
    }
  }

  void _generateSummary({required List<ExerciseLogDto> logs}) async {
    final log = _log;

    if (log == null) return;

    final userInstructions =
        "Review my ${log.name} workout log and provide feedback. Please note, that my weights are in ${weightLabel()}";

    final logJsons = logs.map((log) => log.toJson());

    final StringBuffer buffer = StringBuffer();

    buffer.writeln(userInstructions);
    buffer.writeln(logJsons);

    final completeInstructions = buffer.toString();

    _showLoadingScreen();

    final summary = await runMessage(system: routineLogSystemInstruction, user: completeInstructions);

    _hideLoadingScreen();

    if (summary != null) {
      _saveSummary(response: summary, log: log);

      if (mounted) {
        navigateWithSlideTransition(context: context, child: TRKRCoachSummaryScreen(content: summary));
      }
    }
  }

  void _loadData() {
    final routineLogController = Provider.of<ExerciseAndRoutineController>(context, listen: false);
    _log = routineLogController.logWhereId(id: widget.id);
    if (_log == null) {
      _loading = true;
      getAPI(endpoint: "/routine-logs/${widget.id}").then((data) {
        if (data.isNotEmpty) {
          final json = jsonDecode(data);
          final body = json["data"];
          final routineLog = body["getRoutineLog"];
          if (routineLog != null) {
            final routineLogDto = RoutineLog.fromJson(routineLog);
            setState(() {
              _loading = false;
              _log = routineLogDto.dto();
            });
          } else {
            setState(() {
              _loading = false;
            });
          }
        }
      });
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
              leading: const FaIcon(FontAwesomeIcons.solidPenToSquare, size: 18),
              horizontalTitleGap: 6,
              title: Text("Edit Log",
                  style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16)),
              onTap: _editLog,
            ),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const FaIcon(FontAwesomeIcons.solidClock, size: 18),
              horizontalTitleGap: 6,
              title: Text("Edit duration",
                  style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16)),
              onTap: _editDuration,
            ),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const FaIcon(FontAwesomeIcons.solidFloppyDisk, size: 18),
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

  void _showLoadingScreen() {
    setState(() {
      _loading = true;
    });
  }

  void _hideLoadingScreen() {
    setState(() {
      _loading = false;
    });
  }

  List<ExerciseLogViewModel> _exerciseLogsToViewModels({required List<ExerciseLogDto> exerciseLogs}) {
    return exerciseLogs
        .map((exerciseLog) => ExerciseLogViewModel(
            exerciseLog: exerciseLog,
            superSet: whereOtherExerciseInSuperSet(firstExercise: exerciseLog, exercises: exerciseLogs)))
        .toList();
  }

  void _editLog() async {
    Navigator.of(context).pop();
    final log = _log;
    if (log != null) {
      final arguments = RoutineLogArguments(log: log, editorMode: RoutineEditorMode.edit);
      final updatedLog = await navigateAndEditLog(context: context, arguments: arguments);
      if (updatedLog != null) {
        setState(() {
          _log = updatedLog;
        });
        if (mounted) {
          navigateWithSlideTransition(context: context, child: RoutineLogSummaryScreen(log: updatedLog));
        }
      }
    }
  }

  void _editDuration() {
    Navigator.of(context).pop();
    final log = _log;
    if (log != null) {
      showDatetimeRangePicker(
          context: context,
          initialDateTimeRange: DateTimeRange(start: log.startTime, end: log.endTime),
          onChangedDateTimeRange: (DateTimeRange datetimeRange) async {
            Navigator.of(context).pop();
            final updatedLog = log.copyWith(
                startTime: datetimeRange.start,
                endTime: datetimeRange.end,
                createdAt: datetimeRange.start,
                updatedAt: DateTime.now());
            await Provider.of<ExerciseAndRoutineController>(context, listen: false).updateLog(log: updatedLog);
            setState(() {
              _log = updatedLog;
            });
          });
    }
  }

  void _saveSummary({required RoutineLogDto log, required String response}) async {
    final updatedLog = log.copyWith(summary: response);
    await Provider.of<ExerciseAndRoutineController>(context, listen: false).updateLog(log: updatedLog);
    setState(() {
      _log = updatedLog;
    });
  }

  void _createTemplate() async {
    Navigator.of(context).pop();

    final log = _log;
    if (log != null) {
      _showLoadingScreen();

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
            owner: "",
            createdAt: DateTime.now(),
            updatedAt: DateTime.now());

        final createdTemplate = await Provider.of<ExerciseAndRoutineController>(context, listen: false)
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
        _hideLoadingScreen();
      }
    }
  }

  void _doDeleteLog() async {
    final log = _log;
    if (log != null) {
      try {
        await Provider.of<ExerciseAndRoutineController>(context, listen: false).removeLog(log: log);
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
        _hideLoadingScreen();
      }
    }
  }

  void _deleteLog() {
    Navigator.of(context).pop(); // Close the previous BottomSheet
    showBottomSheetWithMultiActions(
        context: context,
        title: "Delete log?",
        description: "Are you sure you want to delete this log?",
        leftAction: Navigator.of(context).pop,
        rightAction: () {
          Navigator.of(context).pop(); // Close current BottomSheet
          _showLoadingScreen();
          _doDeleteLog();
        },
        leftActionLabel: 'Cancel',
        rightActionLabel: 'Delete',
        isRightActionDestructive: true);
  }
}

class _StatisticWidget extends StatelessWidget {
  final IconData? icon;
  final String? image;
  final String title;
  final String subtitle;

  const _StatisticWidget({this.icon, this.image, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final leading = image != null
        ? Image.asset(
            'icons/$image.png',
            fit: BoxFit.contain,
            color: Colors.white70,
            height: 14, // Adjust the height as needed
          )
        : FaIcon(icon, size: 14, color: Colors.white70);

    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: sapphireDark60, // Background color of the container
        borderRadius: BorderRadius.circular(5), // Border radius for rounded corners
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              leading,
              const SizedBox(
                width: 6,
              ),
              Text(subtitle.toUpperCase(),
                  style: GoogleFonts.ubuntu(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold))
            ],
          ),
          const SizedBox(
            height: 6,
          ),
          Text(title, style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900))
        ],
      ),
    );
  }
}
