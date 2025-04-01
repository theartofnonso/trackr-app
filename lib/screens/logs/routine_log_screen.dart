import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/open_ai_response_schema_dtos/exercise_performance_report.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/openAI/open_ai_response_format.dart';
import 'package:tracker_app/screens/logs/routine_log_summary_screen.dart';
import 'package:tracker_app/shared_prefs.dart';
import 'package:tracker_app/utils/https_utils.dart';
import 'package:tracker_app/utils/navigation_utils.dart';
import 'package:tracker_app/widgets/backgrounds/trkr_loading_screen.dart';

import '../../../colors.dart';
import '../../../dtos/exercise_log_dto.dart';
import '../../controllers/exercise_and_routine_controller.dart';
import '../../dtos/appsync/routine_log_dto.dart';
import '../../dtos/appsync/routine_template_dto.dart';
import '../../dtos/set_dtos/set_dto.dart';
import '../../dtos/viewmodels/exercise_log_view_model.dart';
import '../../dtos/viewmodels/routine_log_arguments.dart';
import '../../enums/posthog_analytics_event.dart';
import '../../enums/routine_editor_type_enums.dart';
import '../../models/RoutineLog.dart';
import '../../openAI/open_ai.dart';
import '../../strings/ai_prompts.dart';
import '../../utils/data_trend_utils.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/exercise_logs_utils.dart';
import '../../utils/general_utils.dart';
import '../../utils/readiness_utils.dart';
import '../../utils/routine_log_utils.dart';
import '../../utils/routine_utils.dart';
import '../../utils/string_utils.dart';
import '../../widgets/ai_widgets/trkr_coach_widget.dart';
import '../../widgets/ai_widgets/trkr_information_container.dart';
import '../../widgets/empty_states/not_found.dart';
import '../../widgets/monthly_insights/muscle_groups_family_frequency_widget.dart';
import '../../widgets/routine/preview/exercise_log_listview.dart';
import '../AI/routine_log_report_screen.dart';

class _StatisticsInformation {
  final String title;
  final String description;

  _StatisticsInformation({required this.title, required this.description});
}

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

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    if (_loading) return TRKRLoadingScreen(action: _hideLoadingScreen);

    final exerciseAndRoutineController = Provider.of<ExerciseAndRoutineController>(context, listen: false);

    if (exerciseAndRoutineController.errorMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showSnackbar(
            context: context,
            icon: const FaIcon(FontAwesomeIcons.circleInfo),
            message: exerciseAndRoutineController.errorMessage);
      });
    }

    final log = _log;

    if (log == null) return const NotFound();

    // We only want to see all logged exercises and sets
    final completedExerciseLogs = loggedExercises(exerciseLogs: log.exerciseLogs);

    final updatedLog = log.copyWith(exerciseLogs: completedExerciseLogs);

    final numberOfCompletedSets = completedExerciseLogs.expand((exerciseLog) => exerciseLog.sets);

    final muscleGroupFamilyFrequencies = muscleGroupFrequency(exerciseLogs: completedExerciseLogs);

    final pbs = updatedLog.exerciseLogs.map((exerciseLog) {
      final pastExerciseLogs = exerciseAndRoutineController.whereExerciseLogsBefore(
          exercise: exerciseLog.exercise, date: exerciseLog.createdAt);

      return calculatePBs(
          pastExerciseLogs: loggedExercises(exerciseLogs: pastExerciseLogs),
          exerciseType: exerciseLog.exercise.type,
          exerciseLog: exerciseLog);
    }).expand((pbs) => pbs);

    final logs = exerciseAndRoutineController
        .whereLogsWithTemplateId(templateId: updatedLog.templateId)
        .map((log) => routineWithLoggedExercises(log: log))
        .toList();

    final allLoggedVolumesForTemplate = logs.map((log) => log.volume).toList();

    final avgVolume = allLoggedVolumesForTemplate.isNotEmpty ? allLoggedVolumesForTemplate.average : 0.0;

    final trendSummary = _analyzeWeeklyTrends(volumes: allLoggedVolumesForTemplate);

    final readiness = calculateReadinessScore(fatigue: log.fatigueLevel, soreness: log.sorenessLevel);

    return Scaffold(
        appBar: AppBar(
            leading: IconButton(
              icon: const FaIcon(FontAwesomeIcons.squareXmark, size: 28),
              onPressed: context.pop,
            ),
            title: Text(updatedLog.name),
            actions: updatedLog.owner == SharedPrefs().userId && widget.isEditable
                ? [
                    IconButton(
                        onPressed: () => _onShareLog(log: updatedLog),
                        icon: const FaIcon(FontAwesomeIcons.arrowUpFromBracket, size: 18)),
                  ]
                : []),
        floatingActionButton: updatedLog.owner == SharedPrefs().userId && widget.isEditable
            ? FloatingActionButton(
                heroTag: "routine_log_screen",
                onPressed: _showBottomSheet,
                child: const FaIcon(FontAwesomeIcons.penToSquare))
            : null,
        body: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: themeGradient(context: context),
          ),
          child: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: Column(
                spacing: 20,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(spacing: 6, crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.deepOrange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Center(
                              child: FaIcon(
                                FontAwesomeIcons.calendarDay,
                                color: Colors.deepOrange,
                                size: 14,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          Text(
                            updatedLog.createdAt.formattedDayMonthTime(),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.yellow.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Center(
                              child: FaIcon(
                                FontAwesomeIcons.solidNoteSticky,
                                color: Colors.yellow,
                                size: 14,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          Expanded(
                            child: Text(
                              updatedLog.notes.isNotEmpty ? "${updatedLog.notes}." : "No notes",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ]),
                  ),
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      spacing: 10,
                      children: [
                        _StatisticWidget(
                          title: "${completedExerciseLogs.length}",
                          subtitle: "Exercises",
                          image: "dumbbells",
                          information: _StatisticsInformation(
                              title: "Exercises",
                              description:
                                  "The total number of different exercises you completed in a workout session."),
                        ),
                        _StatisticWidget(
                          title: "${numberOfCompletedSets.length}",
                          subtitle: "Sets",
                          icon: FontAwesomeIcons.hashtag,
                          information: _StatisticsInformation(
                              title: "Sets",
                              description:
                                  "The number of rounds you performed for each exercise. A “set” consists of a group of repetitions (reps)."),
                        ),
                        _StatisticWidget(
                          title: volumeInKOrM(log.volume),
                          subtitle: "Volume",
                          icon: FontAwesomeIcons.weightHanging,
                          information: _StatisticsInformation(
                              title: "Volume",
                              description:
                                  "The total amount of work performed during a workout, typically calculated as: Volume = Sets × Reps × Weight."),
                        ),
                        _StatisticWidget(
                          title: updatedLog.duration().hmsDigital(),
                          subtitle: "Duration",
                          icon: FontAwesomeIcons.solidClock,
                          information: _StatisticsInformation(
                              title: "Duration",
                              description: "The total time you spent on your workout session, from start to finish."),
                        ),
                        _StatisticWidget(
                          title: "${pbs.length}",
                          subtitle: "PBs",
                          icon: FontAwesomeIcons.solidStar,
                          information: _StatisticsInformation(
                              title: "Personal Bests",
                              description:
                                  "Your highest achievement in an exercise, like the heaviest weight lifted, most reps performed, or highest training volume."),
                        ),
                        if (readiness > 0)
                          _StatisticWidget(
                          title: "$readiness%",
                          subtitle: "Readiness",
                          icon: FontAwesomeIcons.boltLightning,
                          information: _StatisticsInformation(
                              title: "Readiness",
                              description:
                              "A readiness check helps you assess how prepared you are for training intensity—helping you train smarter, avoid overtraining, and reduce the risk of injury."),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      spacing: 20,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MuscleGroupSplitChart(
                            title: "Muscle Groups Split",
                            description:
                                "Here's a breakdown of the muscle groups in your ${updatedLog.name} workout session.",
                            muscleGroup: muscleGroupFamilyFrequencies,
                            minimized: false),
                        if (updatedLog.templateId.isNotEmpty && updatedLog.owner == SharedPrefs().userId)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 10,
                            children: [
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 10,
                                children: [
                                  trendSummary.trend == Trend.none
                                      ? const SizedBox.shrink()
                                      : getTrendIcon(trend: trendSummary.trend),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          text: volumeInKOrM(avgVolume),
                                          style: Theme.of(context).textTheme.headlineSmall,
                                          children: [
                                            TextSpan(
                                              text: " ",
                                            ),
                                            TextSpan(
                                              text: weightLabel().toUpperCase(),
                                              style: Theme.of(context).textTheme.bodyMedium,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        "Session AVERAGE".toUpperCase(),
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              Text(trendSummary.summary,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w400, color: isDarkMode ? Colors.white70 : Colors.black)),
                            ],
                          ),
                        if (updatedLog.owner == SharedPrefs().userId && widget.isEditable)
                          TRKRInformationContainer(
                            color: vibrantGreen,
                              ctaLabel: "Ask for feedback",
                              description:
                                  "Completing a workout is an achievement, however consistent progress is what drives you toward your ultimate fitness goals.",
                              onTap: () => _generateReport(log: updatedLog)),
                        ExerciseLogListView(
                            exerciseLogs: _exerciseLogsToViewModels(exerciseLogs: completedExerciseLogs)),
                        const SizedBox(
                          height: 60,
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }

  void _generateReport({required RoutineLogDto log}) async {
    _showLoadingScreen();

    String instruction = prepareLogInstruction(context: context, routineLog: log);

    runMessage(system: routineLogSystemInstruction, user: instruction, responseFormat: routineLogReportResponseFormat)
        .then((response) {
      _hideLoadingScreen();
      if (response != null) {
        Posthog().capture(eventName: PostHogAnalyticsEvent.generateRoutineLogReport.displayName);
        if (mounted) {
          // Deserialize the JSON string
          Map<String, dynamic> json = jsonDecode(response);

          // Create an instance of ExerciseLogsResponse
          ExercisePerformanceReport report = ExercisePerformanceReport.fromJson(json);
          navigateWithSlideTransition(
              context: context,
              child: RoutineLogReportScreen(
                report: report,
                routineLog: log,
              ));
        }
      }
    }).catchError((e) {
      _hideLoadingScreen();
      if (mounted) {
        showSnackbar(
            context: context,
            icon: TRKRCoachWidget(),
            message: "Oops! I am unable to generate your ${log.name} report");
      }
    });
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
          final routineLogJson = body["getRoutineLog"];
          if (routineLogJson != null) {
            final log = RoutineLog.fromJson(routineLogJson);
            setState(() {
              _loading = false;
              _log = RoutineLogDto.toDto(log);
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
              contentPadding: EdgeInsets.zero,
              leading: const FaIcon(FontAwesomeIcons.solidPenToSquare, size: 18),
              horizontalTitleGap: 6,
              title: Text("Edit Log"),
              onTap: _editLog,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const FaIcon(FontAwesomeIcons.solidClock, size: 18),
              horizontalTitleGap: 6,
              title: Text("Edit duration"),
              onTap: _editDuration,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const FaIcon(FontAwesomeIcons.download, size: 18),
              horizontalTitleGap: 6,
              title: Text("Save as template"),
              onTap: _createTemplate,
            ),
            ListTile(
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
    if (!mounted) return;
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
      final copyOfLog = log.copyWith();
      final arguments = RoutineLogArguments(log: copyOfLog, editorMode: RoutineEditorMode.edit);
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

  TrendSummary _analyzeWeeklyTrends({required List<double> volumes}) {
    // 1. Handle the case when there's no volume data at all
    if (volumes.isEmpty) {
      return TrendSummary(
        trend: Trend.none,
        average: 0,
        summary: "No training data available yet. Log some sessions to start tracking your progress!",
      );
    }

    // 2. Handle the case when there's only one logged volume
    if (volumes.length == 1) {
      return TrendSummary(
        trend: Trend.none,
        average: volumes.first,
        summary: "You've logged your first session's volume (${volumes.first.toStringAsFixed(1)}). "
            "Great job! Keep logging more data to see trends over time.",
      );
    }

    // 3. Now we can safely assume volumes has 2 or more entries
    final previousVolumes = volumes.sublist(0, volumes.length - 1);
    final averageOfPrevious = previousVolumes.reduce((a, b) => a + b) / previousVolumes.length;
    final lastWeekVolume = volumes.last;

    if (lastWeekVolume == 0) {
      return TrendSummary(
        trend: Trend.none,
        average: averageOfPrevious,
        summary: "No training data available for this session. Log some workouts to continue tracking your progress!",
      );
    }

    final difference = lastWeekVolume - averageOfPrevious;
    final double percentageChange = averageOfPrevious == 0 ? 100.0 : (difference / averageOfPrevious) * 100;

    // Decide the trend
    const threshold = 5; // threshold for stable vs up/down
    late final Trend trend;

    if (percentageChange > threshold) {
      trend = Trend.up;
    } else if (percentageChange < -threshold) {
      trend = Trend.down;
    } else {
      trend = Trend.stable;
    }

    final variation = "${percentageChange.abs().toStringAsFixed(1)}%";
    switch (trend) {
      case Trend.up:
        return TrendSummary(
          trend: Trend.up,
          average: averageOfPrevious,
          summary: "🌟🌟 This session's volume is $variation higher than your average. Nice job building momentum!",
        );
      case Trend.down:
        return TrendSummary(
          trend: Trend.down,
          average: averageOfPrevious,
          summary:
              "📉 This session's volume is $variation lower than your average. Consider extra rest or checking your form.",
        );
      case Trend.stable:
        return TrendSummary(
          trend: Trend.stable,
          average: averageOfPrevious,
          summary: "🔄 Your volume changed by about $variation compared to your session average. "
              "Stay consistent to see long-term progress.",
        );
      case Trend.none:
        return TrendSummary(
          trend: Trend.none,
          average: averageOfPrevious,
          summary: "🤔 Unable to identify trends.",
        );
    }
  }
}

class _StatisticWidget extends StatelessWidget {
  final IconData? icon;
  final String? image;
  final String title;
  final String subtitle;
  final _StatisticsInformation information;

  const _StatisticWidget(
      {this.icon, this.image, required this.title, required this.subtitle, required this.information});

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final leading = image != null
        ? Image.asset(
            'icons/$image.png',
            fit: BoxFit.contain,
            color: isDarkMode ? Colors.white : Colors.black,
            height: 14, // Adjust the height as needed
          )
        : FaIcon(icon, size: 14);

    return GestureDetector(
      onTap: () =>
          showBottomSheetWithNoAction(context: context, title: information.title, description: information.description),
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? sapphireDark80 : Colors.grey.shade200, // Background color of the container
          borderRadius: BorderRadius.circular(5), // Border radius for rounded corners
        ),
        child: Stack(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  leading,
                  const SizedBox(
                    width: 6,
                  ),
                  Text(subtitle.toUpperCase(), style: Theme.of(context).textTheme.bodySmall)
                ],
              ),
              const SizedBox(
                height: 6,
              ),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(
                height: 16,
              ),
            ],
          ),
          Positioned.fill(
            child: const Align(alignment: Alignment.bottomRight, child: FaIcon(FontAwesomeIcons.lightbulb, size: 10)),
          ),
        ]),
      ),
    );
  }
}
