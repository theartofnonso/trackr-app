import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/controllers/exercise_log_controller.dart';
import 'package:tracker_app/dtos/appsync/routine_log_dto.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/shared_prefs.dart';
import 'package:tracker_app/utils/dialog_utils.dart';
import 'package:tracker_app/utils/routine_editors_utils.dart';
import 'package:tracker_app/widgets/routine/editors/exercise_log_widget_lite.dart';

import '../../colors.dart';
import '../../controllers/analytics_controller.dart';
import '../../controllers/exercise_and_routine_controller.dart';
import '../../dtos/appsync/exercise_dto.dart';
import '../../dtos/set_dtos/set_dto.dart';
import '../../dtos/set_dtos/weight_and_reps_dto.dart';
import '../../enums/posthog_analytics_event.dart';
import '../../enums/routine_editor_type_enums.dart';
import '../../openAI/open_ai.dart';
import '../../openAI/open_ai_response_format.dart';
import '../../strings/ai_prompts.dart';
import '../../utils/general_utils.dart';
import '../../utils/routine_log_utils.dart';
import '../../utils/routine_utils.dart';
import '../../widgets/buttons/opacity_button_widget.dart';
import '../../widgets/empty_states/no_list_empty_state.dart';
import '../../widgets/routine/editors/exercise_log_widget.dart';
import '../../widgets/timers/routine_timer.dart';
import '../../widgets/weight_plate_calculator.dart';

class RoutineLogEditorScreen extends StatefulWidget {
  static const routeName = '/routine-log-editor';

  final RoutineLogDto log;
  final RoutineEditorMode mode;

  const RoutineLogEditorScreen({super.key, required this.log, required this.mode});

  @override
  State<RoutineLogEditorScreen> createState() => _RoutineLogEditorScreenState();
}

class _RoutineLogEditorScreenState extends State<RoutineLogEditorScreen> with WidgetsBindingObserver {
  late Function _onDisposeCallback;

  final _minimisedExerciseLogCards = <String>[];

  SetDto? _selectedSetDto;

  void _selectExercisesInLibrary() async {
    final controller = Provider.of<ExerciseLogController>(context, listen: false);
    final excludeExercises = controller.exerciseLogs.map((procedure) => procedure.exercise).toList();

    showExercisesInLibrary(
        context: context,
        excludeExercises: excludeExercises,
        onSelected: (List<ExerciseDto> selectedExercises) {
          final onlyExercise = selectedExercises.first;
          final pastSets = Provider.of<ExerciseAndRoutineController>(context, listen: false)
              .whereSetsForExercise(exercise: onlyExercise);
          controller.addExerciseLog(exercise: onlyExercise, pastSets: pastSets);
          _cacheLog();
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
          _cacheLog();
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
              .whereSetsForExercise(exercise: selectedExercises.first);
          controller.replaceExerciseLog(
              oldExerciseId: oldExerciseLog.id, newExercise: selectedExercises.first, pastSets: pastSets);
          _cacheLog();
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

    final createdRoutineLog =
        await Provider.of<ExerciseAndRoutineController>(context, listen: false).saveLog(logDto: routineLogToBeCreated);

    AnalyticsController.workoutSessionEvent(eventAction: "workout_session_logged");

    _navigateBack(routineLog: createdRoutineLog);
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
          leftAction: context.pop,
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
      _doUpdateRoutineLog();
    } else {
      showBottomSheetWithNoAction(context: context, description: "Complete some sets!", title: 'Update Workout');
    }
  }

  void _cacheLog() {
    if (widget.mode == RoutineEditorMode.log) {
      final routineLogToBeCached = _routineLog().copyWith(endTime: DateTime.now());
      Provider.of<ExerciseAndRoutineController>(context, listen: false).cacheLog(logDto: routineLogToBeCached);
    }
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void _closeDialog() {
    Navigator.of(context).pop();
  }

  void _reOrderExerciseLogs({required List<ExerciseLogDto> exerciseLogs}) async {
    final orderedList = await reOrderExerciseLogs(context: context, exerciseLogs: exerciseLogs);
    if (mounted) {
      if (orderedList != null) {
        Provider.of<ExerciseLogController>(context, listen: false).reOrderExerciseLogs(reOrderedList: orderedList);
        _cacheLog();
      }
    }
  }

  void _cleanUpSession() {
    SharedPrefs().remove(key: SharedPrefs().cachedRoutineLogKey);
    if (Platform.isIOS) {
      FlutterLocalNotificationsPlugin().cancel(999);
    }
  }

  void _navigateBack({RoutineLogDto? routineLog}) async {
    if (widget.mode == RoutineEditorMode.log) {
      _cleanUpSession();
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
        if (kReleaseMode) {
          Posthog().capture(eventName: PostHogAnalyticsEvent.generateRoutineLogReport.displayName);
        }
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
                interruptionLevel: InterruptionLevel.active
              ),
            ),
            payload: response);
      }
    });
  }

  /// Handle collapsed ExerciseLogWidget
  void _handleResizedExerciseLogCard({required String exerciseIdToResize}) {
    setState(() {
      final foundExercise =
          _minimisedExerciseLogCards.firstWhereOrNull((exerciseId) => exerciseId == exerciseIdToResize);
      if (foundExercise != null) {
        _minimisedExerciseLogCards.remove(exerciseIdToResize);
      } else {
        _minimisedExerciseLogCards.add(exerciseIdToResize);
      }
    });
  }

  bool _isMinimised(String id) {
    return _minimisedExerciseLogCards.firstWhereOrNull((exerciseId) => exerciseId == id) != null;
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

    bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom != 0;

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
            floatingActionButton: isKeyboardOpen && _selectedSetDto != null
                ? FloatingActionButton(
                    heroTag: UniqueKey(),
                    onPressed: _showWeightCalculator,
                    enableFeedback: true,
              child: Image.asset(
                'icons/dumbbells.png',
                fit: BoxFit.contain,
                color: isDarkMode ? Colors.white : Colors.white,
                height: 24, // Adjust the height as needed
              ),
                  )
                : null,
            body: Container(
              decoration: BoxDecoration(
                gradient: themeGradient(context: context),
              ),
              child: SafeArea(
                bottom: false,
                minimum: const EdgeInsets.only(right: 10.0, bottom: 10.0, left: 10.0),
                child: GestureDetector(
                  onTap: _dismissKeyboard,
                  child: Column(
                    spacing: 20,
                    children: [
                      if (widget.mode == RoutineEditorMode.log)
                        Column(children: [
                          Consumer<ExerciseLogController>(
                              builder: (BuildContext context, ExerciseLogController provider, Widget? child) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: _RoutineLogOverview(
                                exercisesSummary:
                                    "${provider.completedExerciseLog().length}/${provider.exerciseLogs.length}",
                                setsSummary:
                                    "${provider.completedSets().length}/${provider.exerciseLogs.expand((exerciseLog) => exerciseLog.sets).length}",
                                timer: RoutineTimer(
                                  startTime: widget.log.startTime,
                                ),
                              ),
                            );
                          }),
                        ]),
                      if (exerciseLogs.isNotEmpty)
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(bottom: 250),
                            child: Column(spacing: 20, children: [
                              ...exerciseLogs.map((exerciseLog) {

                                final isExerciseMinimised = _minimisedExerciseLogCards.contains(exerciseLog.id);

                                return isExerciseMinimised
                                    ? ExerciseLogLiteWidget(
                                        key: ValueKey(exerciseLog.id),
                                        exerciseLogDto: exerciseLog,
                                        superSet: whereOtherExerciseInSuperSet(
                                            firstExercise: exerciseLog, exercises: exerciseLogs),
                                        onMaximise: () =>
                                            _handleResizedExerciseLogCard(exerciseIdToResize: exerciseLog.id),
                                      )
                                    : ExerciseLogWidget(
                                        key: ValueKey(exerciseLog.id),
                                        exerciseLogDto: exerciseLog,
                                        editorType: RoutineEditorMode.log,
                                        superSet: whereOtherExerciseInSuperSet(
                                            firstExercise: exerciseLog, exercises: exerciseLogs),
                                        onRemoveSuperSet: (String superSetId) {
                                          exerciseLogController.removeSuperSet(superSetId: exerciseLog.superSetId);
                                          _cacheLog();
                                        },
                                        onRemoveLog: () {
                                          exerciseLogController.removeExerciseLog(logId: exerciseLog.id);
                                          _cacheLog();
                                        },
                                        onSuperSet: () => _showSuperSetExercisePicker(firstExerciseLog: exerciseLog),
                                        onCache: _cacheLog,
                                        onReplaceLog: () => _showReplaceExercisePicker(oldExerciseLog: exerciseLog),
                                        onResize: () => _handleResizedExerciseLogCard(exerciseIdToResize: exerciseLog.id),
                                        isMinimised: _isMinimised(exerciseLog.id),
                                        onTapWeightEditor: (SetDto setDto) {
                                          setState(() {
                                            _selectedSetDto = setDto;
                                          });
                                        },
                                        onTapRepsEditor: (SetDto setDto) {
                                          setState(() {
                                            _selectedSetDto = null;
                                          });
                                        },
                                      );
                              }),
                              SizedBox(
                                  width: double.infinity,
                                  child: OpacityButtonWidget(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    buttonColor: vibrantGreen,
                                    label: widget.mode == RoutineEditorMode.log ? "Finish Session" : "Update Session",
                                    onPressed: widget.mode == RoutineEditorMode.log ? _saveLog : _updateLog,
                                  ))
                            ]),
                          ),
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
              ),
            )));
  }

  void _showWeightCalculator() {
    displayBottomSheet(
        context: context,
        child: WeightPlateCalculator(target: (_selectedSetDto as WeightAndRepsSetDto?)?.weight ?? 0),
        padding: EdgeInsets.zero);
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _loadExerciseLogs();

    _onDisposeCallback = Provider.of<ExerciseLogController>(context, listen: false).onClear;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cacheLog();
    });
  }

  void _loadExerciseLogs() {
    final exerciseLogs = widget.log.exerciseLogs;
    Provider.of<ExerciseLogController>(context, listen: false).loadExerciseLogs(exerciseLogs: exerciseLogs);
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
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (Platform.isIOS) {
        FlutterLocalNotificationsPlugin().cancel(999);
      }
    }

    if (state == AppLifecycleState.paused) {
      if (Platform.isIOS) {
        FlutterLocalNotificationsPlugin().periodicallyShowWithDuration(
            999,
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

  const _RoutineLogOverview({required this.exercisesSummary, required this.setsSummary, required this.timer});

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.black12 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(5), // rounded border
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        child: Table(
          border: TableBorder(
              verticalInside:
                  BorderSide(color: isDarkMode ? sapphireLighter.withValues(alpha:0.4) : Colors.white, width: 1)),
          columnWidths: const <int, TableColumnWidth>{
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
          },
          children: [
            TableRow(children: [
              Text("EXERCISES", textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
              Text("SETS", textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
              Text("DURATION", textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
            ]),
            const TableRow(children: [SizedBox(height: 4), SizedBox(height: 4), SizedBox(height: 4)]),
            TableRow(children: [
              Text(exercisesSummary, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
              Text(setsSummary, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
              Center(child: timer)
            ])
          ],
        ));
  }
}
