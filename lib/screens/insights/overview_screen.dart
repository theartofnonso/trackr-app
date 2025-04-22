import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/dtos/daily_readiness.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/screens/editors/past_routine_log_editor_screen.dart';
import 'package:tracker_app/utils/dialog_utils.dart';
import 'package:tracker_app/widgets/ai_widgets/trkr_coach_widget.dart';

import '../../controllers/exercise_and_routine_controller.dart';
import '../../dtos/appsync/routine_log_dto.dart';
import '../../dtos/appsync/routine_template_dto.dart';
import '../../dtos/viewmodels/routine_log_arguments.dart';
import '../../enums/routine_editor_type_enums.dart';
import '../../utils/general_utils.dart';
import '../../utils/navigation_utils.dart';
import '../../utils/string_utils.dart';
import '../../widgets/ai_widgets/trkr_coach_text_widget.dart';
import '../../widgets/backgrounds/trkr_loading_screen.dart';
import '../../widgets/calendar/calendar.dart';
import '../../widgets/dividers/label_divider.dart';
import '../../widgets/monthly_insights/log_streak_chart.dart';
import '../../widgets/monthly_insights/volume_chart.dart';
import '../../widgets/routine/preview/routine_log_widget.dart';
import '../AI/trkr_coach_chat_screen.dart';
import '../routines/readiness_screen.dart';

enum TrainingAndVolume {
  training,
  volume;
}

class OverviewScreen extends StatefulWidget {
  static const routeName = '/overview_screen';

  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  bool _loading = false;

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

    final templates = exerciseAndRoutineController.templates;

    final logsForCurrentDay =
        exerciseAndRoutineController.whereLogsIsSameDay(dateTime: DateTime.now().withoutTime()).toList();

    List<RoutineLogDto> routineLogs = [];
    for (final template in templates) {
      final logs = exerciseAndRoutineController.whereLogsWithTemplateName(templateName: template.name).toList();
      routineLogs.addAll(logs);
    }

    final predictedTemplateName = _predictTemplate(logs: routineLogs);

    final predictedTemplate = templates.firstWhereOrNull((template) => template.name == predictedTemplateName);

    final hasTodayScheduleBeenLogged =
        logsForCurrentDay.firstWhereOrNull((log) => log.name == predictedTemplate?.name) != null;

    return SingleChildScrollView(
      child: Column(spacing: 12, children: [
        Calendar(
          onSelectDate: _onSelectCalendarDateTime),
        StaggeredGrid.count(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: [
            StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: predictedTemplate != null
                  ? _ScheduledTitle(schedule: predictedTemplate, isLogged: hasTodayScheduleBeenLogged)
                  : const _NoScheduledTitle(),
            ),
            StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: GestureDetector(
                onTap: () => navigateToRoutineHome(context: context),
                child: _TemplatesTile(),
              ),
            ),
            StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 2,
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(5)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    switch (_trainingAndVolume) {
                      TrainingAndVolume.training => LogStreakChart(),
                      TrainingAndVolume.volume => VolumeChart(),
                    },
                    const Spacer(),
                    CupertinoSlidingSegmentedControl<TrainingAndVolume>(
                      backgroundColor: isDarkMode ? sapphireDark : Colors.grey.shade400,
                      thumbColor: isDarkMode ? sapphireDark80 : Colors.white,
                      groupValue: _trainingAndVolume,
                      children: {
                        TrainingAndVolume.training: SizedBox(
                            width: 80,
                            child: Text("Training",
                                style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center)),
                        TrainingAndVolume.volume: SizedBox(
                            width: 80,
                            child: Text("Volume",
                                style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center)),
                      },
                      onValueChanged: (TrainingAndVolume? value) {
                        if (value != null) {
                          setState(() {
                            _trainingAndVolume = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
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
              child: GestureDetector(
                onTap: () => navigateToProfile(context: context),
                child: _ProfileTile(),
              ),
            ),
          ],
        ),
      ]),
    );
  }

  void _hideLoadingScreen() {
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
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
                logEmptyRoutine(context: context);
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

  void _showLogsBottomSheet({required DateTime dateTime}) {
    displayBottomSheet(
        isScrollControlled: true,
        context: context,
        child: SafeArea(
          child: _LogsListView(dateTime: dateTime),
        ));
  }

  void _switchToAIContext() async {
    final result =
        await navigateWithSlideTransition(context: context, child: const TRKRCoachChatScreen()) as RoutineTemplateDto?;
    if (result != null) {
      if (mounted) {
        final readiness =
            await navigateWithSlideTransition(context: context, child: ReadinessScreen()) as DailyReadiness? ??
                DailyReadiness.empty();
        final fatigue = readiness.perceivedFatigue;
        final soreness = readiness.muscleSoreness;
        final sleep = readiness.sleepDuration;
        final log = result.toLog();
        final logWithReadinessScore = log.copyWith(fatigueLevel: fatigue, sorenessLevel: soreness, sleepLevel: sleep);
        final arguments = RoutineLogArguments(log: logWithReadinessScore, editorMode: RoutineEditorMode.log);
        if (mounted) {
          navigateToRoutineLogEditor(context: context, arguments: arguments);
        }
      }
    }
  }

  void _onSelectCalendarDateTime(DateTime date) {
    _showLogsBottomSheet(dateTime: date);
  }
}

class _NoScheduledTitle extends StatelessWidget {
  const _NoScheduledTitle();

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(5)),
      child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        Text("Keep training to see future workout schedules",
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
                color: isDarkMode ? Colors.black.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Center(
                child: FaIcon(
                  FontAwesomeIcons.calendarDay,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ]),
    );
  }
}

class _ScheduledTitle extends StatelessWidget {
  const _ScheduledTitle({required this.schedule, required this.isLogged});

  final RoutineTemplateDto schedule;

  final bool isLogged;

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return GestureDetector(
      onTap: () => navigateToRoutineTemplatePreview(context: context, template: schedule),
      child: isLogged
          ? Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: isDarkMode ? vibrantGreen.withValues(alpha: 0.1) : vibrantGreen,
                  borderRadius: BorderRadius.circular(5)),
              child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                Text("${substringByLength(text: schedule.name, length: 10)} has been completed. Great job!",
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
                Text("${schedule.name} is scheduled today. Time to get moving!",
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
            ),
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
        Text("Manage your training experience",
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
                color: isDarkMode ? vibrantBlue : Colors.white, // Adjust the height as needed
              ),
            ),
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

class _ProfileTile extends StatelessWidget {
  const _ProfileTile();

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: isDarkMode ? Colors.red.withValues(alpha: 0.1) : Colors.red, borderRadius: BorderRadius.circular(5)),
      child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        Text("Personalise\nyour fitness profile",
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
                color: isDarkMode ? Colors.red.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Center(
                child: FaIcon(
                  FontAwesomeIcons.personWalking,
                  color: isDarkMode ? Colors.red : Colors.white,
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

    final children = routineLogsForCurrentDate.map((log) {
      Widget widget;

      widget = RoutineLogWidget(log: log, trailing: log.duration().hmsAnalog());

      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: widget,
      );
    }).toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.center, spacing: 16, children: [
      Text("Training Logs".toUpperCase(),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
      ...children
    ]);
  }
}
