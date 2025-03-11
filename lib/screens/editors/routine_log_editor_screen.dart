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
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

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
import '../../utils/routine_log_utils.dart';
import '../../utils/routine_utils.dart';
import '../../widgets/buttons/opacity_button_widget.dart';
import '../../widgets/empty_states/no_list_empty_state.dart';
import '../../widgets/timers/stopwatch_timer.dart';

class RoutineLogEditorScreen extends StatefulWidget {
  static const routeName = '/routine-log-editor';

  final RoutineLogDto log;
  final RoutineEditorMode mode;
  final bool cached;
  final String workoutVideoUrl;

  const RoutineLogEditorScreen(
      {super.key, required this.log, required this.mode, this.workoutVideoUrl = "", this.cached = false});

  @override
  State<RoutineLogEditorScreen> createState() => _RoutineLogEditorScreenState();
}

class _RoutineLogEditorScreenState extends State<RoutineLogEditorScreen> with WidgetsBindingObserver {
  late Function _onDisposeCallback;

  late YoutubePlayerController _videoController;

  final _minimisedExerciseLogCards = <String>[];

  bool _muted = false;

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
    final sleep = await calculateSleepDuration();

    final routineLogToBeCreated =
        _routineLog().copyWith(endTime: DateTime.now(), sleepFrom: sleep?.start, sleepTo: sleep?.end);

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

    final workoutVideoUrl = widget.workoutVideoUrl;

    return PopScope(
        canPop: false,
        child: Scaffold(
            appBar: AppBar(
              leading: IconButton(icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, size: 28), onPressed: _discardLog),
              title: Text(
                widget.log.name,
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
                  spacing: 8,
                  children: [
                    if (widget.mode == RoutineEditorMode.log)
                      workoutVideoUrl.isNotEmpty
                          ? Stack(children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: YoutubePlayer(
                                  progressIndicatorColor: Colors.white,
                                  showVideoProgressIndicator: true,
                                  topActions: [
                                    Consumer<ExerciseLogController>(
                                        builder: (BuildContext context, ExerciseLogController provider, Widget? child) {
                                      return Expanded(
                                        child: Wrap(
                                          children: [
                                            _RoutineLogOverview(
                                              exercisesSummary:
                                                  "${provider.completedExerciseLog().length} of ${provider.exerciseLogs.length}",
                                              setsSummary:
                                                  "${provider.completedSets().length} of ${provider.exerciseLogs.expand((exerciseLog) => exerciseLog.sets).length}",
                                              timer: StopwatchTimer(
                                                forceLightMode: true,
                                                startTime: widget.log.startTime,
                                              ),
                                              forceLightMode: true,
                                            )
                                          ],
                                        ),
                                      );
                                    })
                                  ],
                                  controller: _videoController,
                                ),
                              ),
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: IconButton(
                                      onPressed: _toggleVolume,
                                      icon: FaIcon(_muted ? FontAwesomeIcons.volumeHigh : FontAwesomeIcons.volumeXmark,
                                          color: Colors.white, size: 16)))
                            ])
                          : Consumer<ExerciseLogController>(
                              builder: (BuildContext context, ExerciseLogController provider, Widget? child) {
                              return _RoutineLogOverview(
                                exercisesSummary:
                                    "${provider.completedExerciseLog().length} of ${provider.exerciseLogs.length}",
                                setsSummary:
                                    "${provider.completedSets().length} of ${provider.exerciseLogs.expand((exerciseLog) => exerciseLog.sets).length}",
                                timer: StopwatchTimer(
                                  startTime: widget.log.startTime,
                                ),
                              );
                            }),
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

  void _toggleVolume() {
    setState(() {
      if (_muted) {
        _videoController.unMute();
        _muted = false;
      } else {
        _videoController.mute();
        _muted = true;
      }
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _loadRoutineAndExerciseLogs();

    _onDisposeCallback = Provider.of<ExerciseLogController>(context, listen: false).onClear;

    final videoId = YoutubePlayer.convertUrlToId(widget.workoutVideoUrl) ?? "";

    _videoController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
          autoPlay: false, mute: false, forceHD: true, hideControls: false, showLiveFullscreenButton: false),
    );
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
    _videoController.dispose();
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

class _RoutineLogOverview extends StatelessWidget {
  final String exercisesSummary;
  final String setsSummary;
  final Widget timer;
  final bool forceLightMode;

  const _RoutineLogOverview(
      {required this.exercisesSummary, required this.setsSummary, required this.timer, this.forceLightMode = false});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5), // rounded border
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        child: Table(
          // border: TableBorder(
          //     verticalInside: BorderSide(color: isDarkMode ? Colors.white70 : Colors.grey.shade200, width: 0.5)),
          columnWidths: const <int, TableColumnWidth>{
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
          },
          children: [
            TableRow(children: [
              Text("Exercises",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: forceLightMode ? Colors.white : null)),
              Text("Sets",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: forceLightMode ? Colors.white : null)),
              Text("Duration",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: forceLightMode ? Colors.white : null)),
            ]),
            const TableRow(children: [SizedBox(height: 4), SizedBox(height: 4), SizedBox(height: 4)]),
            TableRow(children: [
              Text(exercisesSummary,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: forceLightMode ? Colors.white : null)),
              Text(setsSummary,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: forceLightMode ? Colors.white : null)),
              Center(child: timer)
            ])
          ],
        ));
  }
}
