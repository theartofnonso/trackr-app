import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/dtos/appsync/activity_log_dto.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/dtos/open_ai_response_schema_dtos/monthly_training_report.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/screens/editors/activity_editor_screen.dart';
import 'package:tracker_app/screens/editors/past_routine_log_editor_screen.dart';
import 'package:tracker_app/utils/dialog_utils.dart';
import 'package:tracker_app/widgets/ai_widgets/trkr_coach_widget.dart';

import '../../controllers/activity_log_controller.dart';
import '../../controllers/exercise_and_routine_controller.dart';
import '../../dtos/abstract_class/log_class.dart';
import '../../dtos/appsync/routine_log_dto.dart';
import '../../dtos/appsync/routine_template_dto.dart';
import '../../dtos/viewmodels/routine_log_arguments.dart';
import '../../enums/posthog_analytics_event.dart';
import '../../enums/routine_editor_type_enums.dart';
import '../../openAI/open_ai.dart';
import '../../openAI/open_ai_response_format.dart';
import '../../strings/ai_prompts.dart';
import '../../utils/exercise_logs_utils.dart';
import '../../utils/general_utils.dart';
import '../../utils/navigation_utils.dart';
import '../../widgets/ai_widgets/trkr_coach_text_widget.dart';
import '../../widgets/backgrounds/trkr_loading_screen.dart';
import '../../widgets/calendar/calendar.dart';
import '../../widgets/dividers/label_divider.dart';
import '../../widgets/monitors/log_streak_monitor.dart';
import '../../widgets/routine/preview/activity_log_widget.dart';
import '../../widgets/routine/preview/routine_log_widget.dart';
import '../AI/monthly_training_report_screen.dart';
import '../AI/trkr_coach_chat_screen.dart';

enum TrainingAndVolume {
  training,
  volume;
}

class OverviewScreen extends StatefulWidget {
  final ScrollController scrollController;

  static const routeName = '/overview_screen';

  final DateTimeRange dateTimeRange;

  const OverviewScreen({super.key, required this.scrollController, required this.dateTimeRange});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  bool _loading = false;

  TextEditingController? _textEditingController;

  TrainingAndVolume _trainingAndVolume = TrainingAndVolume.training;

  String _predictTemplate({required List<RoutineLogDto> logs}) {
    if (logs.isEmpty) {
      return "";
    }

    final currentWeekday = DateTime.now().weekday;
    final sameWeekdayLogs = logs.where((log) => log.createdAt.weekday == currentWeekday).toList();

    final logsToConsider = sameWeekdayLogs.isNotEmpty ? sameWeekdayLogs : logs;

    final counts = <String, int>{};
    final latestDates = <String, DateTime>{};

    for (final log in logsToConsider) {
      final name = log.name;
      counts[name] = (counts[name] ?? 0) + 1;

      final currentLatest = latestDates[name];
      if (currentLatest == null || log.createdAt.isAfter(currentLatest)) {
        latestDates[name] = log.createdAt;
      }
    }

    final maxCount = counts.values.fold(0, (max, count) => count > max ? count : max);
    final candidates = counts.entries.where((entry) => entry.value == maxCount).map((entry) => entry.key).toList();

    if (candidates.length == 1) {
      return candidates.first;
    }

    // Resolve tie by selecting the most recent date
    String selectedId = candidates.first;
    DateTime latestDate = latestDates[selectedId]!;

    for (final id in candidates.skip(1)) {
      final date = latestDates[id]!;
      if (date.isAfter(latestDate)) {
        selectedId = id;
        latestDate = date;
      }
    }

    return selectedId;
  }

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    if (_loading) return TRKRLoadingScreen(action: _hideLoadingScreen);

    /// Be notified of changes
    final exerciseAndRoutineController = Provider.of<ExerciseAndRoutineController>(context, listen: true);
    Provider.of<ActivityLogController>(context, listen: true);

    DateTime today = DateTime.now();
    DateTime currentMonthStart = DateTime(today.year, today.month, 1);
    bool canNavigateNext = !widget.dateTimeRange.start.monthlyStartDate().isAtSameMomentAs(currentMonthStart);

    /// Logic to determine whether to show new monthly insights widget
    final isStartOfNewMonth = today.day == 1;

    final templates = exerciseAndRoutineController.templates;

    final logsForCurrentDay =
        exerciseAndRoutineController.whereLogsIsSameDay(dateTime: DateTime.now().withoutTime()).toList();

    final logsForCurrentMonth =
        exerciseAndRoutineController.whereLogsIsSameMonth(dateTime: widget.dateTimeRange.start.withoutTime()).toList();

    final last30DaysDatetime = today.subtract(const Duration(days: 29));

    final logsForPastMonth = exerciseAndRoutineController.whereLogsIsSameMonth(dateTime: last30DaysDatetime).toList();

    List<RoutineLogDto> routineLogs = [];
    for (final template in templates) {
      final logs = exerciseAndRoutineController.whereLogsWithTemplateName(templateName: template.name).toList();
      routineLogs.addAll(logs);
    }

    final predictedTemplateName = _predictTemplate(logs: routineLogs);

    final predictedTemplate = templates.firstWhereOrNull((template) => template.name == predictedTemplateName);

    final hasTodayScheduleBeenLogged =
        logsForCurrentDay.firstWhereOrNull((log) => log.name == predictedTemplate?.name) != null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: themeGradient(context: context),
        ),
        child: SafeArea(
            minimum: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Expanded(
                  child: SingleChildScrollView(
                      controller: widget.scrollController,
                      padding: const EdgeInsets.only(top: 3, bottom: 150),
                      child: Column(children: [
                        LogStreakMonitor(dateTime: widget.dateTimeRange.start),
                        const SizedBox(height: 24),
                        StaggeredGrid.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          children: [
                            StaggeredGridTile.count(
                              crossAxisCellCount: 1,
                              mainAxisCellCount: 1,
                              child: _ScheduledTitle(
                                  scheduledToday: predictedTemplate, isLogged: hasTodayScheduleBeenLogged),
                            ),
                            StaggeredGridTile.count(
                              crossAxisCellCount: 1,
                              mainAxisCellCount: 1,
                              child: GestureDetector(
                                onTap: () => navigateToRoutineTemplates(context: context),
                                child: _TemplatesTile(),
                              ),
                            ),
                            StaggeredGridTile.count(
                              crossAxisCellCount: 4,
                              mainAxisCellCount: 2,
                              child: Calendar(
                                onSelectDate: _onSelectCalendarDateTime,
                                dateTime: widget.dateTimeRange.start,
                              ),
                            ),
                            StaggeredGridTile.count(
                              crossAxisCellCount: 1,
                              mainAxisCellCount: 1,
                              child: GestureDetector(
                                onTap: _showNewBottomSheet,
                                child: _AddTile(),
                              ),
                            ),
                            StaggeredGridTile.count(
                              crossAxisCellCount: 1,
                              mainAxisCellCount: 1,
                              child: _SettingsTile(),
                            ),
                          ],
                        ),
                      ])),
                )
                // Add more widgets here for exercise insights
              ],
            )),
      ),
    );
  }

  void _showLoadingScreen() {
    setState(() {
      _loading = true;
    });
  }

  void _hideLoadingScreen() {
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  void _generateMonthlyInsightsReport({required DateTime datetime}) {
    _showLoadingScreen();

    final exerciseAndRoutineLogController = Provider.of<ExerciseAndRoutineController>(context, listen: false);

    final activityLogController = Provider.of<ActivityLogController>(context, listen: false);

    List<RoutineLogDto> routineLogs = exerciseAndRoutineLogController.whereLogsIsSameMonth(dateTime: datetime);

    List<ActivityLogDto> activityLogs = activityLogController.whereLogsIsSameMonth(dateTime: datetime);

    // Helper function to get muscles trained from exercise logs
    List<String> getMusclesTrained(List<ExerciseLogDto> exerciseLogs) {
      return exerciseLogs.map((exerciseLog) => exerciseLog.exercise.primaryMuscleGroup.name).toList();
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
            - Personal bests achieved
            - Hours spent training
            - Consistency and frequency of workouts
            - Any notable improvements or regressions
        Highlight any trends or patterns that could help optimize my future training sessions.
        
        Lastly, please provide a summary of the number of activities the user has logged outside of strength training. 
        Note: All weights are measured in ${weightLabel()}.
        Note: Your report should sound personal and motivating.
""");

    // Main processing
    for (final log in routineLogs) {
      final completedExerciseLogs = loggedExercises(exerciseLogs: log.exerciseLogs);
      final musclesTrained = getMusclesTrained(completedExerciseLogs);
      final exercises = log.exerciseLogs.map((exerciseLog) => exerciseLog.exercise.name).toSet().toList();
      final personalBests = getPersonalBests(log.exerciseLogs);

      buffer.writeln("Log information for ${log.name} workout in ${log.createdAt.formattedFullMonth}");
      buffer.writeln("List of exercises performed: $exercises}");
      buffer.writeln("List of muscles trained: $musclesTrained}");
      buffer.writeln("Personal bests: $personalBests}");
      buffer.writeln("Duration of workout: ${log.duration().hmsAnalog()}}");
      buffer.writeln();
    }

    buffer.writeln();

    for (final log in activityLogs) {
      buffer.writeln("Logged ${log.nameOrSummary} activity in ${log.createdAt.formattedFullMonth}");
    }

    final completeInstructions = buffer.toString();

    runMessage(
            system: routineLogSystemInstruction,
            user: completeInstructions,
            responseFormat: monthlyReportResponseFormat)
        .then((response) {
      Posthog().capture(eventName: PostHogAnalyticsEvent.generateMonthlyInsights.displayName);

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
                routineLogs: routineLogs,
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

  void _showNewBottomSheet() {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    displayBottomSheet(
        context: context,
        child: SafeArea(
          bottom: false,
          child: Column(children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const FaIcon(FontAwesomeIcons.play, size: 18),
              horizontalTitleGap: 6,
              title: Text("Log new session", style: Theme.of(context).textTheme.bodyLarge),
              onTap: () {
                Navigator.of(context).pop();
                _showLogNewSessionBottomSheet();
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const FaIcon(FontAwesomeIcons.clockRotateLeft, size: 18),
              horizontalTitleGap: 6,
              title: Text("Log past session", style: Theme.of(context).textTheme.bodyLarge),
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
            LabelDivider(
              label: "Log an activity",
              labelColor: isDarkMode ? Colors.white70 : Colors.black,
              dividerColor: sapphireLighter,
            ),
            const SizedBox(
              height: 6,
            ),
            ListTile(
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
                navigateWithSlideTransition(context: context, child: ActivityEditorScreen());
              },
            ),
          ]),
        ));
  }

  void _showLogsBottomSheet({required DateTime dateTime}) {
    displayBottomSheet(
        isScrollControlled: true,
        context: context,
        child: SafeArea(
          child: _LogsListView(dateTime: dateTime),
        ));
  }

  void _showLogNewSessionBottomSheet() {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    displayBottomSheet(
        context: context,
        child: SafeArea(
          child: Column(children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const FaIcon(FontAwesomeIcons.play, size: 18),
              horizontalTitleGap: 6,
              title: Text("Log new session", style: Theme.of(context).textTheme.bodyLarge),
              onTap: () {
                Navigator.of(context).pop();
                logEmptyRoutine(context: context);
              },
            ),
            const SizedBox(
              height: 10,
            ),
            LabelDivider(
              label: "Don't know what to train?",
              labelColor: isDarkMode ? Colors.white70 : Colors.black,
              dividerColor: sapphireLighter,
            ),
            const SizedBox(
              height: 6,
            ),
            ListTile(
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

  void _onSelectCalendarDateTime(DateTime date) {
    _showLogsBottomSheet(dateTime: date);
  }

  @override
  void dispose() {
    _textEditingController?.dispose();
    super.dispose();
  }
}

class _ScheduledTitle extends StatelessWidget {
  const _ScheduledTitle({required this.scheduledToday, required this.isLogged});

  final RoutineTemplateDto? scheduledToday;

  final bool isLogged;

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return isLogged
        ? Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: isDarkMode ? vibrantGreen.withValues(alpha: 0.1) : vibrantGreen,
                borderRadius: BorderRadius.circular(5)),
            child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Text("${scheduledToday?.name} has been completed",
                  style: GoogleFonts.ubuntu(fontSize: 18, height: 1.5, fontWeight: FontWeight.w600)),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 25,
                    height: 25,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: vibrantGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Center(
                      child: FaIcon(
                        FontAwesomeIcons.check,
                        color: vibrantGreen,
                        size: 14,
                      ),
                    ),
                  )
                ],
              ),
            ]),
          )
        : Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: isDarkMode ? vibrantGreen.withValues(alpha: 0.1) : vibrantGreen,
                borderRadius: BorderRadius.circular(5)),
            child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Text("${scheduledToday?.name} is scheduled today. Time to get moving!",
                  style: GoogleFonts.ubuntu(fontSize: 18, height: 1.5, fontWeight: FontWeight.w600)),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 25,
                    height: 25,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDarkMode ? vibrantGreen.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Center(
                      child: FaIcon(
                        FontAwesomeIcons.calendarDay,
                        color: isDarkMode ? vibrantGreen : Colors.white,
                        size: 14,
                      ),
                    ),
                  )
                ],
              ),
            ]),
          );
  }
}

class _TemplatesTile extends StatelessWidget {
  const _TemplatesTile();

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: isDarkMode ? vibrantBlue.withValues(alpha: 0.1) : vibrantBlue, borderRadius: BorderRadius.circular(5)),
      child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        Text("Manage your workout templates",
            style: GoogleFonts.ubuntu(fontSize: 20, height: 1.5, fontWeight: FontWeight.w600)),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 25,
              height: 25,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDarkMode ? vibrantBlue.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Image.asset(
                'icons/dumbbells.png',
                fit: BoxFit.contain,
                height: 14,
                color: isDarkMode ? vibrantBlue : Colors.white, // Adjust the height as needed
              ),
            ),
          ],
        ),
      ]),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile();

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: isDarkMode ? vibrantBlue.withValues(alpha: 0.1) : vibrantBlue, borderRadius: BorderRadius.circular(5)),
      child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        Text("Manage your preferences",
            style: GoogleFonts.ubuntu(fontSize: 20, height: 1.5, fontWeight: FontWeight.w600)),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDarkMode ? vibrantBlue.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Center(
                child: FaIcon(
                  FontAwesomeIcons.gear,
                  color: isDarkMode ? vibrantBlue : Colors.white,
                  size: 20,
                ),
              ),
            )
          ],
        ),
      ]),
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile();

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: isDarkMode ? Colors.yellow.withValues(alpha: 0.1) : Colors.yellow,
          borderRadius: BorderRadius.circular(5)),
      child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        Text("Start a fresh session",
            style: GoogleFonts.ubuntu(fontSize: 20, height: 1.5, fontWeight: FontWeight.w600)),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.yellow.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Center(
                child: FaIcon(
                  FontAwesomeIcons.plus,
                  color: isDarkMode ? Colors.yellow : Colors.white,
                  size: 20,
                ),
              ),
            )
          ],
        ),
      ]),
    );
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
        widget = RoutineLogWidget(log: routineLog, trailing: routineLog.duration().hmsAnalog());
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

    return Column(crossAxisAlignment: CrossAxisAlignment.center, spacing: 16, children: [
      Text("Training and Activities".toUpperCase(),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
      ...children
    ]);
  }
}
