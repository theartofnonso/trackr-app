import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/controllers/exercise_log_controller.dart';
import 'package:tracker_app/dtos/db/routine_log_dto.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/utils/dialog_utils.dart';
import 'package:tracker_app/utils/exercise_logs_utils.dart';
import 'package:tracker_app/widgets/routine/editors/exercise_log_list_item.dart';
import 'package:tracker_app/widgets/timers/stopwatch_timer.dart';

import '../../colors.dart';
import '../../controllers/exercise_and_routine_controller.dart';
import '../../enums/routine_editor_type_enums.dart';
import '../../utils/date_utils.dart';
import '../../utils/notifications_utils.dart';
import '../../utils/routine_utils.dart';
import '../../widgets/buttons/opacity_button_widget_two.dart';
import '../../widgets/empty_states/no_list_empty_state.dart';

class RoutineLogEditorScreen extends StatefulWidget {
  static const routeName = '/routine-log-editor';

  final RoutineLogDto log;
  final RoutineEditorMode mode;
  final bool cached;

  const RoutineLogEditorScreen(
      {super.key, required this.log, required this.mode, this.cached = false});

  @override
  State<RoutineLogEditorScreen> createState() => _RoutineLogEditorScreenState();
}

class _RoutineLogEditorScreenState extends State<RoutineLogEditorScreen>
    with WidgetsBindingObserver {
  late Function _onDisposeCallback;

  RoutineLogDto _routineLog() {
    final exerciseLogController =
        Provider.of<ExerciseLogController>(context, listen: false);

    final exerciseLogs = exerciseLogController.exerciseLogs;

    final routineLog = widget.log.copyWith(exerciseLogs: exerciseLogs);

    return routineLog;
  }

  Future<void> _doCreateRoutineLog() async {
    final routineLogToBeCreated =
        _routineLog().copyWith(endTime: DateTime.now());

    if (mounted) {
      final createdRoutineLog = await Provider.of<ExerciseAndRoutineController>(
              context,
              listen: false)
          .saveLog(logDto: routineLogToBeCreated);

      _navigateBack(routineLog: createdRoutineLog);
    }
  }

  Future<void> _doUpdateRoutineLog() async {
    final routineLogToBeUpdated = _routineLog();

    await Provider.of<ExerciseAndRoutineController>(context, listen: false)
        .updateLog(log: routineLogToBeUpdated);

    _navigateBack(routineLog: routineLogToBeUpdated);
  }

  bool _isRoutinePartiallyComplete() {
    final exerciseLogController =
        Provider.of<ExerciseLogController>(context, listen: false);
    final exerciseLogs = exerciseLogController.exerciseLogs;
    return exerciseLogs
        .any((log) => log.sets.any((set) => set.isNotEmpty() && set.checked));
  }

  void _discardLog() {
    showBottomSheetWithMultiActions(
        context: context,
        title: "Discard session?",
        description: "Do you want to discard this session",
        leftAction: _closeDialog,
        rightAction: () {
          _closeDialog();
          _navigateBack();
        },
        leftActionLabel: 'Cancel',
        rightActionLabel: 'Discard',
        isRightActionDestructive: true);
  }

  void _saveLog() {
    final isRoutinePartiallyComplete = _isRoutinePartiallyComplete();
    if (isRoutinePartiallyComplete) {
      showBottomSheetWithMultiActions(
          context: context,
          title: 'Running Session',
          description: "Do you want to end session?",
          leftAction: Navigator.of(context).pop,
          rightAction: () {
            _closeDialog();
            _doCreateRoutineLog();
          },
          leftActionLabel: 'Cancel',
          rightActionLabel: 'End',
          rightActionColor: vibrantGreen);
    } else {
      showBottomSheetWithNoAction(
          context: context,
          description: "Complete some sets!",
          title: 'Running Session');
    }
  }

  void _updateLog() {
    final isRoutinePartiallyComplete = _isRoutinePartiallyComplete();
    if (isRoutinePartiallyComplete) {
      _closeDialog();
      _doUpdateRoutineLog();
    } else {
      showBottomSheetWithNoAction(
          context: context,
          description: "Complete some sets!",
          title: 'Update Workout');
    }
  }

  void _closeDialog() {
    Navigator.of(context).pop();
  }

  void _reOrderExerciseLogs(
      {required List<ExerciseLogDto> exerciseLogs}) async {
    final orderedList =
        await reOrderExerciseLogs(context: context, exerciseLogs: exerciseLogs);
    if (mounted) {
      if (orderedList != null) {
        Provider.of<ExerciseLogController>(context, listen: false)
            .reOrderExerciseLogs(reOrderedList: orderedList);
      }
    }
  }

  void _navigateBack({RoutineLogDto? routineLog}) async {
    context.pop(routineLog);
  }

  int _averageWorkoutDuration() {
    final dateRange = lastQuarterDateTimeRange();
    final weeksInLastQuarter =
        generateWeeksInRange(range: dateRange).toList(); // chronological order

    final List<int> allDurations = <int>[]; // in minutes

    final exerciseLogController =
        Provider.of<ExerciseAndRoutineController>(context, listen: false);

    for (final week in weeksInLastQuarter) {
      final weekLogs =
          exerciseLogController.whereLogsIsWithinRange(range: week);
      allDurations.addAll(weekLogs.map((log) => log.duration().inMinutes));
    }

    int safeAverage(List<int> values) => values.isEmpty
        ? 0
        : (values.reduce((a, b) => a + b) / values.length).round();

    return safeAverage(allDurations);
  }

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final routineLogEditorController =
        Provider.of<ExerciseAndRoutineController>(context, listen: true);

    if (routineLogEditorController.errorMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showSnackbar(
            context: context, message: routineLogEditorController.errorMessage);
      });
    }

    final exerciseLogController =
        Provider.of<ExerciseLogController>(context, listen: false);

    final exerciseLogs = context
        .select((ExerciseLogController controller) => controller.exerciseLogs);

    final avgWorkoutDuration = _averageWorkoutDuration();

    final children = exerciseLogs.asMap().entries.map((entry) {
      final index = entry.key;
      final exerciseLog = entry.value;
      final isLastItem = index == exerciseLogs.length - 1;

      return ExerciseLogListItemWidget(
        editorType: widget.mode,
        exerciseLogDto: exerciseLog,
        superSet: whereOtherExerciseInSuperSet(
            firstExercise: exerciseLog, exercises: exerciseLogs),
        onRemoveLog: () {
          exerciseLogController.removeExerciseLog(logId: exerciseLog.id);
        },
        isLastItem: isLastItem,
      );
    }).toList();

    return PopScope(
        canPop: false,
        child: Scaffold(
            body: Stack(children: [
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? darkBackground : Colors.white,
            ),
            child: SafeArea(
              minimum: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
                bottom: 20,
              ),
              child: Column(
                spacing: 20,
                children: [
                  // Top action row replacing former AppBar actions
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (exerciseLogs.length > 1)
                          IconButton(
                              onPressed: () => _reOrderExerciseLogs(
                                  exerciseLogs: exerciseLogs),
                              icon:
                                  const FaIcon(FontAwesomeIcons.barsStaggered))
                      ],
                    ),
                  ),
                  if (widget.mode == RoutineEditorMode.log)
                    GestureDetector(
                      onTap: _showRoutineTimerInfo,
                      child: Center(
                        child: StopwatchTimer(
                          digital: true,
                          startTime: widget.log.startTime,
                          textStyle: Theme.of(context).textTheme.headlineLarge,
                          maxDuration: Duration(minutes: avgWorkoutDuration),
                          warningThreshold: const Duration(minutes: 15),
                        ),
                      ),
                    ),
                  if (exerciseLogs.isNotEmpty)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ListView.builder(
                          itemCount: children.length,
                          itemBuilder: (context, index) => children[index],
                        ),
                      ),
                    ),
                  if (exerciseLogs.isNotEmpty)
                    SafeArea(
                      minimum: EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                          width: double.infinity,
                          child: OpacityButtonWidgetTwo(
                            buttonColor: vibrantGreen,
                            label: widget.mode == RoutineEditorMode.log
                                ? "Finish Session"
                                : "Update Session",
                            onPressed: widget.mode == RoutineEditorMode.log
                                ? _saveLog
                                : _updateLog,
                          )),
                    ),
                  if (exerciseLogs.isEmpty)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: const NoListEmptyState(
                            message:
                                "Tap the + button to start adding exercises to your workout session"),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Overlay close button (discard)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode
                    ? darkSurface.withValues(alpha: 0.9)
                    : Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.squareXmark,
                  size: 20,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                onPressed: _discardLog,
                tooltip: 'Close',
              ),
            ),
          ),
        ])));
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _loadRoutineAndExerciseLogs();

    _onDisposeCallback =
        Provider.of<ExerciseLogController>(context, listen: false).onClear;
  }

  void _loadRoutineAndExerciseLogs() {
    final exerciseAndRoutineController =
        Provider.of<ExerciseAndRoutineController>(context, listen: false);

    final exerciseLogController =
        Provider.of<ExerciseLogController>(context, listen: false);

    exerciseLogController.loadRoutineLog(routineLog: widget.log);

    final exerciseLogs = widget.mode == RoutineEditorMode.log
        ? widget.log.exerciseLogs.map((exerciseLog) {
            if (!widget.cached) {
              final pastSets =
                  exerciseAndRoutineController.whereRecentSetsForExercise(
                      exercise: exerciseLog
                          .exercise); // Finds sets by exercise name from workout logs
              final uncheckedSets =
                  pastSets.map((set) => set.copyWith(checked: false)).toList();

              /// Don't add any previous set for [ExerciseType.Duration]
              /// Duration is captured in realtime from a fresh instance
              return exerciseLog.copyWith(
                  sets: withReps(type: exerciseLog.exercise.type)
                      ? uncheckedSets
                      : []);
            }
            return exerciseLog;
          }).toList()
        : widget.log.exerciseLogs;
    exerciseLogController.loadExerciseLogs(exerciseLogs: exerciseLogs);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _onDisposeCallback();
    if (Platform.isIOS) {
      FlutterLocalNotificationsPlugin()
          .cancel(notificationIDLongRunningSession);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (Platform.isIOS) {
        FlutterLocalNotificationsPlugin()
            .cancel(notificationIDLongRunningSession);
      }
    }

    if (state == AppLifecycleState.paused) {
      if (Platform.isIOS) {
        FlutterLocalNotificationsPlugin().periodicallyShowWithDuration(
            notificationIDLongRunningSession,
            "${widget.log.name} is still running",
            "Tap to continue training",
            const Duration(minutes: 10),
            const NotificationDetails(
              iOS: DarwinNotificationDetails(
                presentAlert: false,
                presentBadge: false,
                presentSound: false,
                presentBanner: false,
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.exact);
      }
    }
  }

  void _showRoutineTimerInfo() {
    // ── 1.  Gather data ────────────────────────────────────────────────────────────
    final Duration elapsed = DateTime.now().difference(widget.log.startTime);
    final Duration average = Duration(minutes: _averageWorkoutDuration());

    // ── 2.  Calculate differences ─────────────────────────────────────────────────
    final Duration overTime = elapsed - average; // positive  ⇒ exceeded
    final Duration remaining = average - elapsed; // positive  ⇒ still within

    // Short local helper for h:m:s; keeps later lines compact.
    String fmt(Duration d) => d.hmsDigital();

    // ── 3.  Decide colour & message ───────────────────────────────────────────────
    late final String infoText;

    if (overTime >= Duration.zero) {
      // Exceeded the average
      infoText =
          "You're training ${fmt(overTime)} longer than your average session.";
    } else if (remaining <= const Duration(minutes: 15)) {
      // Inside the last 15-minute window
      infoText = "You'll reach your average session time in ${fmt(remaining)}.";
    } else {
      // Comfortably within the average
      infoText = "Your average training duration is ${fmt(average)}.";
    }

    final textInfoTextStyle = GoogleFonts.ubuntu(
      fontSize: 14,
      fontWeight: FontWeight.w400,
    );
    showBottomSheetWithNoAction(
        context: context,
        title: "Workout Timer",
        description: infoText,
        textStyle: textInfoTextStyle);
  }
}
