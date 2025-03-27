import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/controllers/exercise_log_controller.dart';
import 'package:tracker_app/dtos/appsync/routine_log_dto.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/utils/dialog_utils.dart';
import 'package:tracker_app/utils/exercise_logs_utils.dart';
import 'package:tracker_app/utils/routine_editors_utils.dart';
import 'package:tracker_app/widgets/routine/editors/exercise_log_widget_lite.dart';
import 'package:tracker_app/widgets/timers/stopwatch_timer.dart';

import '../../colors.dart';
import '../../controllers/exercise_and_routine_controller.dart';
import '../../dtos/appsync/exercise_dto.dart';
import '../../enums/posthog_analytics_event.dart';
import '../../enums/routine_editor_type_enums.dart';
import '../../openAI/open_ai.dart';
import '../../openAI/open_ai_response_format.dart';
import '../../strings/ai_prompts.dart';
import '../../utils/general_utils.dart';
import '../../utils/notifications_utils.dart';
import '../../utils/readiness_utils.dart';
import '../../utils/routine_log_utils.dart';
import '../../utils/routine_utils.dart';
import '../../widgets/buttons/opacity_button_widget.dart';
import '../../widgets/empty_states/no_list_empty_state.dart';

class RoutineLogEditorScreen extends StatefulWidget {
  static const routeName = '/routine-log-editor';

  final RoutineLogDto log;
  final RoutineEditorMode mode;
  final bool cached;

  const RoutineLogEditorScreen({super.key, required this.log, required this.mode, this.cached = false});

  @override
  State<RoutineLogEditorScreen> createState() => _RoutineLogEditorScreenState();
}

class _RoutineLogEditorScreenState extends State<RoutineLogEditorScreen> with WidgetsBindingObserver {
  late Function _onDisposeCallback;

  final _minimisedExerciseLogCards = <String>[];

  void _selectExercisesInLibrary() async {
    final controller = Provider.of<ExerciseLogController>(context, listen: false);
    final excludeExercises = controller.exerciseLogs.map((procedure) => procedure.exercise).toList();

    showExercisesInLibrary(
        context: context,
        excludeExercises: excludeExercises,
        onSelected: (List<ExerciseDto> selectedExercises) {
          final onlyExercise = selectedExercises.first;
          final pastSets = Provider.of<ExerciseAndRoutineController>(context, listen: false)
              .whereRecentSetsForExercise(exercise: onlyExercise);
          controller.addExerciseLog(exercise: onlyExercise, pastSets: pastSets);
        });
  }

  void _showSuperSetExercisePicker({required ExerciseLogDto firstExerciseLog}) {
    final controller = Provider.of<ExerciseLogController>(context, listen: false);
    final otherExercises = whereOtherExerciseLogsExcept(exerciseLog: firstExerciseLog, others: controller.exerciseLogs);
    showSuperSetExercisePicker(
        context: context,
        firstExerciseLog: firstExerciseLog,
        otherExerciseLogs: otherExercises,
        onSelected: (secondExerciseLog) {
          _closeDialog();
          final id = superSetId(firstExerciseLog: firstExerciseLog, secondExerciseLog: secondExerciseLog);
          controller.superSetExerciseLogs(
              firstExerciseLogId: firstExerciseLog.id, secondExerciseLogId: secondExerciseLog.id, superSetId: id);
        },
        selectExercisesInLibrary: () {
          _closeDialog();
          _selectExercisesInLibrary();
        });
  }

  void _showReplaceExercisePicker({required ExerciseLogDto oldExerciseLog}) {
    final controller = Provider.of<ExerciseLogController>(context, listen: false);
    final excludeExercises = controller.exerciseLogs.map((procedure) => procedure.exercise).toList();

    showExercisesInLibrary(
        context: context,
        excludeExercises: excludeExercises,
        onSelected: (List<ExerciseDto> selectedExercises) {
          final pastSets = Provider.of<ExerciseAndRoutineController>(context, listen: false)
              .whereRecentSetsForExercise(exercise: selectedExercises.first);
          controller.replaceExerciseLog(
              oldExerciseId: oldExerciseLog.id, newExercise: selectedExercises.first, pastSets: pastSets);
        });
  }

  RoutineLogDto _routineLog() {
    final exerciseLogController = Provider.of<ExerciseLogController>(context, listen: false);

    final exerciseLogs = exerciseLogController.exerciseLogs;

    final routineLog = widget.log.copyWith(exerciseLogs: exerciseLogs);

    return routineLog;
  }

  Future<void> _doCreateRoutineLog() async {
    final routineLogToBeCreated = _routineLog().copyWith(endTime: DateTime.now());

    if (mounted) {
      final createdRoutineLog = await Provider.of<ExerciseAndRoutineController>(context, listen: false)
          .saveLog(logDto: routineLogToBeCreated);

      _navigateBack(routineLog: createdRoutineLog);
    }
  }

  Future<void> _doUpdateRoutineLog() async {
    final routineLogToBeUpdated = _routineLog();

    await Provider.of<ExerciseAndRoutineController>(context, listen: false).updateLog(log: routineLogToBeUpdated);

    _navigateBack(routineLog: routineLogToBeUpdated);
  }

  bool _isRoutinePartiallyComplete() {
    final exerciseLogController = Provider.of<ExerciseLogController>(context, listen: false);
    final exerciseLogs = exerciseLogController.exerciseLogs;
    return exerciseLogs.any((log) => log.sets.any((set) => set.isNotEmpty() && set.checked));
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
      showBottomSheetWithNoAction(context: context, description: "Complete some sets!", title: 'Running Session');
    }
  }

  void _updateLog() {
    final isRoutinePartiallyComplete = _isRoutinePartiallyComplete();
    if (isRoutinePartiallyComplete) {
      _closeDialog();
      _doUpdateRoutineLog();
    } else {
      showBottomSheetWithNoAction(context: context, description: "Complete some sets!", title: 'Update Workout');
    }
  }

  void _closeDialog() {
    Navigator.of(context).pop();
  }

  void _reOrderExerciseLogs({required List<ExerciseLogDto> exerciseLogs}) async {
    final orderedList = await reOrderExerciseLogs(context: context, exerciseLogs: exerciseLogs);
    if (mounted) {
      if (orderedList != null) {
        Provider.of<ExerciseLogController>(context, listen: false).reOrderExerciseLogs(reOrderedList: orderedList);
      }
    }
  }

  void _navigateBack({RoutineLogDto? routineLog}) async {
    if (widget.mode == RoutineEditorMode.log) {
      final log = routineLog;
      if (log != null) {
        if (Platform.isIOS) {
          _generateReport(routineLog: log);
        }
      }
    }
    context.pop(routineLog);
  }

  void _generateReport({required RoutineLogDto routineLog}) async {
    String instruction = prepareLogInstruction(context: context, routineLog: routineLog);

    runMessage(system: routineLogSystemInstruction, user: instruction, responseFormat: routineLogReportResponseFormat)
        .then((response) {
      if (response != null) {
        Posthog().capture(eventName: PostHogAnalyticsEvent.generateRoutineLogReport.displayName);

        FlutterLocalNotificationsPlugin().show(
            900,
            "${routineLog.name} report is ready",
            "Your report is now ready for review",
            const NotificationDetails(
              iOS: DarwinNotificationDetails(
                  presentAlert: true,
                  presentBadge: false,
                  presentSound: false,
                  presentBanner: true,
                  interruptionLevel: InterruptionLevel.active),
            ),
            payload: jsonEncode({"report": response, "log": routineLog.id}));
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final routineLogEditorController = Provider.of<ExerciseAndRoutineController>(context, listen: true);

    if (routineLogEditorController.errorMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showSnackbar(
            context: context,
            icon: const FaIcon(FontAwesomeIcons.circleInfo),
            message: routineLogEditorController.errorMessage);
      });
    }

    final exerciseLogController = Provider.of<ExerciseLogController>(context, listen: false);

    final exerciseLogs = context.select((ExerciseLogController controller) => controller.exerciseLogs);

    final log = widget.log;

    print(log.readiness);

    return PopScope(
        canPop: false,
        child: Scaffold(
            appBar: AppBar(
              leading: IconButton(icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, size: 28), onPressed: _discardLog),
              title: Text(
                log.name,
              ),
              actions: [
                IconButton(
                    key: const Key('select_exercises_in_library_btn'),
                    onPressed: _selectExercisesInLibrary,
                    icon: const FaIcon(FontAwesomeIcons.solidSquarePlus)),
                if (exerciseLogs.length > 1)
                  IconButton(
                      onPressed: () => _reOrderExerciseLogs(exerciseLogs: exerciseLogs),
                      icon: const FaIcon(FontAwesomeIcons.barsStaggered))
              ],
            ),
            body: Container(
              decoration: BoxDecoration(
                gradient: themeGradient(context: context),
              ),
              child: SafeArea(
                minimum: EdgeInsets.all(10),
                child: Column(
                  spacing: 12,
                  children: [
                    if (widget.mode == RoutineEditorMode.log)
                      Consumer<ExerciseLogController>(
                          builder: (BuildContext context, ExerciseLogController provider, Widget? child) {
                        return SizedBox(
                          height: 80,
                          child: GridView(
                              scrollDirection: Axis.horizontal,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 1,
                                childAspectRatio: 0.5, // for square shape
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              children: [
                                _StatisticWidget(
                                    title: Text("${log.readiness}%",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(color: lowToHighIntensityColor(log.readiness / 100))),
                                    subtitle: "Readiness"),
                                _StatisticWidget(
                                    title: Text(
                                        "${provider.completedExerciseLog().length} of ${provider.exerciseLogs.length}",
                                        style: Theme.of(context).textTheme.titleLarge),
                                    subtitle: "Exercises"),
                                _StatisticWidget(
                                    title: Text(
                                        "${provider.completedSets().length} of ${provider.exerciseLogs.expand((exerciseLog) => exerciseLog.sets).length}",
                                        style: Theme.of(context).textTheme.titleLarge),
                                    subtitle: "Sets"),
                                _StatisticWidget(
                                    title: StopwatchTimer(
                                      digital: true,
                                      startTime: widget.log.startTime,
                                      textStyle: Theme.of(context).textTheme.titleLarge,
                                    ),
                                    subtitle: "Duration")
                              ]),
                        );
                      }),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(getTrainingGuidance(readinessScore: log.readiness),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400, color: isDarkMode ? Colors.white70 : Colors.grey.shade200)),
                    ),
                    if (exerciseLogs.isNotEmpty)
                      Expanded(
                        child: ListView.separated(
                          itemBuilder: (BuildContext context, int index) {
                            final exerciseLog = exerciseLogs[index];
                            return ExerciseLogLiteWidget(
                              editorType: widget.mode,
                              exerciseLogDto: exerciseLog,
                              superSet:
                                  whereOtherExerciseInSuperSet(firstExercise: exerciseLog, exercises: exerciseLogs),
                              onRemoveSuperSet: (String superSetId) {
                                exerciseLogController.removeSuperSet(superSetId: exerciseLog.superSetId);
                              },
                              onRemoveLog: () {
                                exerciseLogController.removeExerciseLog(logId: exerciseLog.id);
                              },
                              onSuperSet: () => _showSuperSetExercisePicker(firstExerciseLog: exerciseLog),
                              onReplaceLog: () => _showReplaceExercisePicker(oldExerciseLog: exerciseLog),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return SizedBox(height: 12);
                          },
                          itemCount: exerciseLogs.length,
                        ),
                      ),
                    if (exerciseLogs.isNotEmpty)
                      SafeArea(
                        minimum: EdgeInsets.all(10),
                        child: SizedBox(
                            width: double.infinity,
                            child: OpacityButtonWidget(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              buttonColor: vibrantGreen,
                              label: widget.mode == RoutineEditorMode.log ? "Finish Session" : "Update Session",
                              onPressed: widget.mode == RoutineEditorMode.log ? _saveLog : _updateLog,
                            )),
                      ),
                    if (exerciseLogs.isEmpty)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: const NoListEmptyState(
                              message: "Tap the + button to start adding exercises to your workout session"),
                        ),
                      ),
                  ],
                ),
              ),
            )));
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _loadRoutineAndExerciseLogs();

    _onDisposeCallback = Provider.of<ExerciseLogController>(context, listen: false).onClear;
  }

  void _loadRoutineAndExerciseLogs() {
    final exerciseAndRoutineController = Provider.of<ExerciseAndRoutineController>(context, listen: false);

    final exerciseLogController = Provider.of<ExerciseLogController>(context, listen: false);

    exerciseLogController.loadRoutineLog(routineLog: widget.log);

    final exerciseLogs = widget.mode == RoutineEditorMode.log
        ? widget.log.exerciseLogs.map((exerciseLog) {
            if (!widget.cached) {
              final pastSets = exerciseAndRoutineController.whereRecentSetsForExercise(exercise: exerciseLog.exercise);
              final uncheckedSets = pastSets.map((set) => set.copyWith(checked: false)).toList();

              /// Don't add any previous set for [ExerciseType.Duration]
              /// Duration is captured in realtime from a fresh instance
              return exerciseLog.copyWith(sets: withReps(type: exerciseLog.exercise.type) ? uncheckedSets : []);
            }
            return exerciseLog;
          }).toList()
        : widget.log.exerciseLogs;
    exerciseLogController.loadExerciseLogs(exerciseLogs: exerciseLogs);
    _minimiseOrMaximiseCards();
  }

  void _minimiseOrMaximiseCards() {
    Provider.of<ExerciseLogController>(context, listen: false).exerciseLogs.forEach((exerciseLog) {
      final completedSets = exerciseLog.sets.where((set) => set.checked).length;
      final isExerciseCompleted = completedSets == exerciseLog.sets.length;
      if (isExerciseCompleted) {
        setState(() {
          _minimisedExerciseLogCards.add(exerciseLog.id);
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _onDisposeCallback();
    if (Platform.isIOS) {
      FlutterLocalNotificationsPlugin().cancel(notificationIDLongRunningSession);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (Platform.isIOS) {
        FlutterLocalNotificationsPlugin().cancel(notificationIDLongRunningSession);
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
}

class _StatisticWidget extends StatelessWidget {
  final Widget title;
  final String subtitle;

  const _StatisticWidget({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
        // Background color of the container
        borderRadius: BorderRadius.circular(5), // Border radius for rounded corners
      ),
      child: Stack(children: [
        title,
        Positioned.fill(
          child: Align(
              alignment: Alignment.bottomRight,
              child: Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12))),
        ),
      ]),
    );
  }
}
