import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/dtos/appsync/activity_log_dto.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/dtos/open_ai_response_schema_dtos/monthly_training_report.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/screens/editors/past_routine_log_editor_screen.dart';
import 'package:tracker_app/shared_prefs.dart';
import 'package:tracker_app/utils/dialog_utils.dart';
import 'package:tracker_app/widgets/ai_widgets/trkr_coach_widget.dart';
import 'package:tracker_app/widgets/ai_widgets/trkr_information_container.dart';

import '../../controllers/activity_log_controller.dart';
import '../../controllers/exercise_and_routine_controller.dart';
import '../../controllers/routine_user_controller.dart';
import '../../dtos/abstract_class/log_class.dart';
import '../../dtos/appsync/routine_log_dto.dart';
import '../../dtos/appsync/routine_template_dto.dart';
import '../../dtos/viewmodels/routine_log_arguments.dart';
import '../../enums/activity_type_enums.dart';
import '../../enums/routine_editor_type_enums.dart';
import '../../openAI/open_ai.dart';
import '../../openAI/open_ai_response_format.dart';
import '../../strings/ai_prompts.dart';
import '../../utils/exercise_logs_utils.dart';
import '../../utils/general_utils.dart';
import '../../utils/navigation_utils.dart';
import '../../utils/routine_utils.dart';
import '../../widgets/ai_widgets/trkr_coach_button.dart';
import '../../widgets/ai_widgets/trkr_coach_text_widget.dart';
import '../../widgets/backgrounds/trkr_loading_screen.dart';
import '../../widgets/calendar/calendar.dart';
import '../../widgets/label_divider.dart';
import '../../widgets/monitors/log_streak_muscle_trend_monitor.dart';
import '../../widgets/monthly_insights/log_streak_chart_widget.dart';
import '../../widgets/routine/preview/activity_log_widget.dart';
import '../../widgets/routine/preview/routine_log_widget.dart';
import '../AI/monthly_training_report_screen.dart';
import '../AI/trkr_coach_chat_screen.dart';
import '../editors/routine_log_editor_screen.dart';
import '../logs/routine_log_screen.dart';
import 'monthly_insights_screen.dart';

class OverviewScreen extends StatefulWidget {
  final ScrollController scrollController;

  static const routeName = '/overview_screen';

  final DateTimeRange dateTimeRange;

  const OverviewScreen({super.key, required this.scrollController, required this.dateTimeRange});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  DateTime _selectedDateTime = DateTime.now().withoutTime();

  bool _loading = false;

  TextEditingController? _textEditingController;

  @override
  Widget build(BuildContext context) {
    if (_loading) return TRKRLoadingScreen(action: _hideLoadingScreen);

    /// Be notified of changes
    Provider.of<ExerciseAndRoutineController>(context, listen: true);
    Provider.of<ActivityLogController>(context, listen: true);

    DateTime today = DateTime.now();
    DateTime currentMonthStart = DateTime(today.year, today.month, 1);
    bool canNavigateNext = !widget.dateTimeRange.start.monthlyStartDate().isAtSameMomentAs(currentMonthStart);

    /// Logic to determine whether to show new monthly insights widget
    final isStartOfNewMonth = today.day == 1;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: _loading
          ? null
          : FloatingActionButton(
              heroTag: "fab_overview_screen",
              onPressed: _showBottomSheet,
              backgroundColor: sapphireDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              child: const FaIcon(FontAwesomeIcons.plus, color: Colors.white, size: 24),
            ),
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
        child: SafeArea(
            minimum: const EdgeInsets.only(right: 10.0, bottom: 10, left: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                      controller: widget.scrollController,
                      padding: const EdgeInsets.only(bottom: 150),
                      child: Column(children: [
                        const SizedBox(height: 12),
                        LogStreakMuscleTrendMonitor(dateTime: widget.dateTimeRange.start),
                        if (isStartOfNewMonth)
                          Padding(
                            padding: const EdgeInsets.only(top: 24.0),
                            child: TRKRInformationContainer(
                                ctaLabel:
                                    "View ${today.subtract(const Duration(days: 29)).formattedFullMonth()} insights",
                                description:
                                    "It’s a new month of training, but before we dive in, let’s reflect on your past performance and plan for this month.",
                                onTap: () => _showMonthlyInsights(datetime: today.subtract(const Duration(days: 29)))),
                          ),
                        if (SharedPrefs().showCalendar)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Column(
                              children: [
                                Calendar(
                                  onSelectDate: _onChangedDateTime,
                                  dateTime: widget.dateTimeRange.start,
                                ),
                                const SizedBox(height: 10),
                                _LogsListView(dateTime: _selectedDateTime),
                              ],
                            ),
                          ),
                        if (canNavigateNext)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 12),
                              TRKRCoachButton(
                                  label: "Review ${widget.dateTimeRange.start.formattedFullMonth()} insights.",
                                  onTap: () => _showMonthlyInsights(datetime: widget.dateTimeRange.start)),
                            ],
                          ),
                        const SizedBox(height: 12),
                        MonthlyInsightsScreen(dateTimeRange: widget.dateTimeRange),
                        const SizedBox(height: 18),
                        LogStreakChartWidget(),
                      ])),
                )
                // Add more widgets here for exercise insights
              ],
            )),
      ),
    );
  }

  void _logEmptyRoutine() async {
    final log = Provider.of<ExerciseAndRoutineController>(context, listen: false).cachedLog();
    if (log == null) {
      final log = RoutineLogDto(
          id: "",
          templateId: "",
          name: "${timeOfDay()} Session",
          exerciseLogs: [],
          notes: "",
          startTime: DateTime.now(),
          endTime: DateTime.now(),
          owner: "",
          createdAt: DateTime.now(),
          updatedAt: DateTime.now());
      final recentLog = await navigateWithSlideTransition(
          context: context, child: RoutineLogEditorScreen(log: log, mode: RoutineEditorMode.log));
      if (recentLog != null) {
        if (mounted) {
          context.push(RoutineLogScreen.routeName, extra: {"log": recentLog, "showSummary": true, "isEditable": true});
        }
      }
    } else {
      showSnackbar(context: context, icon: const Icon(Icons.info_outline_rounded), message: "${log.name} is running");
    }
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

  void _showMonthlyInsights({required DateTime datetime}) {
    _showLoadingScreen();

    final routineUserController = Provider.of<RoutineUserController>(context, listen: false);

    final exerciseAndRoutineLogController = Provider.of<ExerciseAndRoutineController>(context, listen: false);

    final activityLogController = Provider.of<ActivityLogController>(context, listen: false);

    List<RoutineLogDto> lastMonthRoutineLogs = exerciseAndRoutineLogController.whereLogsIsSameMonth(dateTime: datetime);

    List<ActivityLogDto> lastMonthActivityLogs = activityLogController.whereLogsIsSameMonth(dateTime: datetime);

    // Helper function to get muscles trained from exercise logs
    List<String> getMusclesTrained(List<ExerciseLogDto> exerciseLogs) {
      return exerciseLogs
          .expand((exerciseLog) => [
                exerciseLog.exercise.primaryMuscleGroup.name,
                ...exerciseLog.exercise.secondaryMuscleGroups.map((mg) => mg.name),
              ])
          .toSet()
          .toList();
    }

    // Helper function to get personal bests from exercise logs
    List<String> getPersonalBests(List<ExerciseLogDto> exerciseLogs) {
      return exerciseLogs
          .expand((exerciseLog) {
            final pastExerciseLogs = exerciseAndRoutineLogController.whereExerciseLogsBefore(
              exercise: exerciseLog.exercise,
              date: exerciseLog.createdAt,
            );

            return calculatePBs(
              pastExerciseLogs: pastExerciseLogs,
              exerciseType: exerciseLog.exercise.type,
              exerciseLog: exerciseLog,
            );
          })
          .map((pbDto) => pbDto.pb.description)
          .toList();
    }

    final StringBuffer buffer = StringBuffer();

    buffer.writeln("""
        Please provide a comparative analysis of my training logs for ${datetime.formattedFullMonth()}. 
        The report should focus on:
            - Exercise selection
            - Muscles trained
            - Calories burned
            - Personal bests achieved
            - Hours spent training
            - Consistency and frequency of workouts
            - Any notable improvements or regressions
        Highlight any trends or patterns that could help optimize my future training sessions.
        
        Lastly, please provide a summary of the number of activities the user has logged outside of strength training. 
        If the user has logged few or no such activities, focus on encouraging them to engage in and record more non-strength training exercises. 
        The report should highlight the benefits of incorporating a variety of activities into their fitness regimen and offer suggestions on how they can diversify their workouts.
        Note: All weights are measured in ${weightLabel()}.
        Note: Your report should sound personal.
""");

    // Main processing
    for (final log in lastMonthRoutineLogs) {
      final completedExerciseLogs = completedExercises(exerciseLogs: log.exerciseLogs);
      final musclesTrained = getMusclesTrained(completedExerciseLogs);
      final exercises = log.exerciseLogs.map((exerciseLog) => exerciseLog.exercise.name).toSet().toList();
      final caloriesBurned = calculateCalories(
        duration: log.duration(),
        bodyWeight: routineUserController.weight(),
        activity: log.activityType,
      );
      final personalBests = getPersonalBests(log.exerciseLogs);

      buffer.writeln("Log information for ${log.name} workout in ${log.createdAt.formattedFullMonth}");
      buffer.writeln("List of exercises performed: $exercises}");
      buffer.writeln("List of muscles trained: $musclesTrained}");
      buffer.writeln("Amount of calories burned: $caloriesBurned}");
      buffer.writeln("Personal bests: $personalBests}");
      buffer.writeln("Duration of workout: ${log.duration().hmsAnalog()}}");
      buffer.writeln();
    }

    buffer.writeln();

    for (final log in lastMonthActivityLogs) {
      buffer.writeln("Logged ${log.name} activity in ${log.createdAt.formattedFullMonth}");
    }

    final completeInstructions = buffer.toString();

    runMessage(
            system: routineLogSystemInstruction,
            user: completeInstructions,
            responseFormat: monthlyReportResponseFormat)
        .then((response) {
      _hideLoadingScreen();
      if (response != null) {
        if (mounted) {
          // Deserialize the JSON string
          Map<String, dynamic> json = jsonDecode(response);

          // Create an instance of ExerciseLogsResponse
          MonthlyTrainingReport report = MonthlyTrainingReport.fromJson(json);
          navigateWithSlideTransition(
              context: context,
              child: MonthlyTrainingReportScreen(
                dateTime: datetime,
                monthlyTrainingReport: report,
                routineLogs: lastMonthRoutineLogs,
                activityLogs: activityLogController.whereLogsIsSameMonth(dateTime: datetime),
              ));
        }
      }
    }).catchError((e) {
      _hideLoadingScreen();
      if (mounted) {
        showSnackbar(
            context: context,
            icon: TRKRCoachWidget(),
            message: "Oops! I am unable to generate your ${datetime.formattedFullMonth()} report");
      }
    });
  }

  void _showBottomSheet() {
    displayBottomSheet(
        context: context,
        child: SafeArea(
          child: Column(children: [
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const FaIcon(FontAwesomeIcons.play, size: 18),
              horizontalTitleGap: 6,
              title: Text("Log new session",
                  style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16)),
              onTap: () {
                Navigator.of(context).pop();
                _showLogNewSessionBottomSheet();
              },
            ),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const FaIcon(FontAwesomeIcons.clockRotateLeft, size: 18),
              horizontalTitleGap: 6,
              title: Text("Log past session",
                  style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16)),
              onTap: () {
                Navigator.of(context).pop();
                showDatetimeRangePicker(
                    context: context,
                    onChangedDateTimeRange: (DateTimeRange datetimeRange) {
                      Navigator.of(context).pop();
                      final logName = "${timeOfDay(datetime: datetimeRange.start)} Session";
                      final log = RoutineLogDto(
                          id: "",
                          templateId: '',
                          name: logName,
                          exerciseLogs: [],
                          notes: "",
                          startTime: datetimeRange.start,
                          endTime: datetimeRange.end,
                          owner: "",
                          createdAt: datetimeRange.start,
                          updatedAt: datetimeRange.end);
                      navigateWithSlideTransition(context: context, child: PastRoutineLogEditorScreen(log: log));
                    });
              },
            ),
            const SizedBox(
              height: 10,
            ),
            const LabelDivider(
              label: "Log non-resistance training",
              labelColor: Colors.white70,
              dividerColor: sapphireLighter,
            ),
            const SizedBox(
              height: 6,
            ),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const FaIcon(
                FontAwesomeIcons.circlePlus,
                size: 18,
                color: Colors.greenAccent,
              ),
              horizontalTitleGap: 6,
              title: Text("Log Activity",
                  style: GoogleFonts.ubuntu(color: Colors.greenAccent, fontWeight: FontWeight.w500, fontSize: 16)),
              onTap: () {
                Navigator.of(context).pop();
                showActivityPicker(
                    context: context,
                    onChangedActivity: (ActivityType activity, DateTimeRange datetimeRange) {
                      Navigator.of(context).pop();
                      final activityLog = ActivityLogDto(
                          id: "id",
                          name: activity.name,
                          notes: "",
                          startTime: datetimeRange.start,
                          endTime: datetimeRange.end,
                          createdAt: datetimeRange.end,
                          updatedAt: datetimeRange.end,
                          owner: '');
                      Provider.of<ActivityLogController>(context, listen: false).saveLog(logDto: activityLog);
                    });
              },
            ),
          ]),
        ));
  }

  void _showLogNewSessionBottomSheet() {
    displayBottomSheet(
        context: context,
        child: SafeArea(
          child: Column(children: [
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const FaIcon(FontAwesomeIcons.play, size: 18),
              horizontalTitleGap: 6,
              title: Text("Log new session",
                  style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16)),
              onTap: () {
                Navigator.of(context).pop();
                _logEmptyRoutine();
              },
            ),
            const SizedBox(
              height: 10,
            ),
            const LabelDivider(
              label: "Don't know what to train?",
              labelColor: Colors.white70,
              dividerColor: sapphireLighter,
            ),
            const SizedBox(
              height: 6,
            ),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const TRKRCoachWidget(),
              horizontalTitleGap: 10,
              title: TRKRCoachTextWidget("Describe your workout",
                  style: GoogleFonts.ubuntu(color: vibrantGreen, fontWeight: FontWeight.w500, fontSize: 16)),
              onTap: () {
                Navigator.of(context).pop();
                _switchToAIContext();
              },
            ),
          ]),
        ));
  }

  void _switchToAIContext() async {
    final result =
        await navigateWithSlideTransition(context: context, child: const TRKRCoachChatScreen()) as RoutineTemplateDto?;
    if (result != null) {
      if (context.mounted) {
        final arguments = RoutineLogArguments(log: result.toLog(), editorMode: RoutineEditorMode.log);
        if (mounted) {
          navigateToRoutineLogEditor(context: context, arguments: arguments);
        }
      }
    }
  }

  void _onChangedDateTime(DateTime date) {
    setState(() {
      _selectedDateTime = date;
    });
  }

  @override
  void dispose() {
    _textEditingController?.dispose();
    super.dispose();
  }
}

class _LogsListView extends StatelessWidget {
  final DateTime dateTime;

  const _LogsListView({required this.dateTime});

  @override
  Widget build(BuildContext context) {
    /// Routine Logs
    final routineLogController = Provider.of<ExerciseAndRoutineController>(context, listen: true);
    final routineLogsForCurrentDate = routineLogController.whereLogsIsSameDay(dateTime: dateTime).toList();

    /// Activity Logs
    final activityLogController = Provider.of<ActivityLogController>(context, listen: true);
    final activityLogsForCurrentDate = activityLogController.whereLogsIsSameDay(dateTime: dateTime).toList();

    /// Aggregates
    final allLogsForCurrentDate = [...routineLogsForCurrentDate, ...activityLogsForCurrentDate]
        .sorted((a, b) => b.createdAt.compareTo(a.createdAt))
        .toList();

    final children = allLogsForCurrentDate.map((log) {
      Widget widget;

      if (log.logType == LogType.routine) {
        final routineLog = log as RoutineLogDto;
        widget = RoutineLogWidget(log: routineLog, trailing: routineLog.duration().hmsAnalog(), color: sapphireDark80);
      } else {
        final activityLog = log as ActivityLogDto;
        widget = ActivityLogWidget(
          activity: activityLog,
          trailing: activityLog.duration().hmsAnalog(),
          onTap: () {
            showActivityBottomSheet(context: context, activity: activityLog);
          },
          color: sapphireDark80,
        );
      }
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: widget,
      );
    }).toList();

    return Column(children: children);
  }
}
