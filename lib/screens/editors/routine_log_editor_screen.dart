import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/controllers/exercise_log_controller.dart';
import 'package:tracker_app/dtos/appsync/routine_log_dto.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/shared_prefs.dart';
import 'package:tracker_app/utils/dialog_utils.dart';
import 'package:tracker_app/utils/routine_editors_utils.dart';
import 'package:tracker_app/widgets/routine/editors/exercise_log_widget_lite.dart';

import '../../colors.dart';
import '../../controllers/exercise_and_routine_controller.dart';
import '../../dtos/appsync/exercise_dto.dart';
import '../../dtos/set_dto.dart';
import '../../enums/routine_editor_type_enums.dart';
import '../../utils/app_analytics.dart';
import '../../utils/routine_utils.dart';
import '../../widgets/routine/editors/exercise_log_widget.dart';
import '../../widgets/timers/routine_timer.dart';
import '../../widgets/weight_plate_calculator.dart';
import '../empty_state_screens/no_list_empty_state.dart';

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
          controller.addExerciseLogs(exercises: selectedExercises);
          _cacheLog();
        });
  }

  void _selectSubstituteExercisesInLibrary({required ExerciseLogDto primaryExerciseLog}) async {
    final controller = Provider.of<ExerciseLogController>(context, listen: false);
    final excludeExercises = controller.exerciseLogs.map((exercise) => exercise.exercise).toList();
    showExercisesInLibrary(
        context: context,
        excludeExercises: excludeExercises,
        onSelected: (List<ExerciseDto> selectedExercises) {
          controller.addAlternates(primaryExerciseId: primaryExerciseLog.id, exercises: selectedExercises);
          _showSubstituteExercisePicker(primaryExerciseLog: primaryExerciseLog);
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

  void _showSubstituteExercisePicker({required ExerciseLogDto primaryExerciseLog}) {
    final controller = Provider.of<ExerciseLogController>(context, listen: false);
    showSubstituteExercisePicker(
        context: context,
        primaryExerciseLog: primaryExerciseLog,
        otherExercises: primaryExerciseLog.substituteExercises,
        onSelected: (secondaryExercise) {
          _closeDialog();
          final foundExerciseLog = controller.exerciseLogs
              .firstWhereOrNull((exerciseLog) => exerciseLog.exercise.id == secondaryExercise.id);
          if (foundExerciseLog == null) {
            controller.replaceExerciseLog(oldExerciseId: primaryExerciseLog.id, newExercise: secondaryExercise);
            _cacheLog();
          } else {
            showSnackbar(
                context: context,
                icon: const FaIcon(FontAwesomeIcons.circleInfo),
                message: "${foundExerciseLog.exercise.name} has already been added");
          }
        },
        onRemoved: (ExerciseDto secondaryExercise) {
          controller.removeAlternates(
              primaryExerciseId: primaryExerciseLog.id, secondaryExerciseId: secondaryExercise.id);
          _cacheLog();
        },
        selectExercisesInLibrary: () {
          _closeDialog();
          _selectSubstituteExercisesInLibrary(primaryExerciseLog: primaryExerciseLog);
        });
  }

  void _showReplaceExercisePicker({required ExerciseLogDto oldExerciseLog}) {
    final controller = Provider.of<ExerciseLogController>(context, listen: false);
    final excludeExercises = controller.exerciseLogs.map((procedure) => procedure.exercise).toList();

    showExercisesInLibrary(
        context: context,
        excludeExercises: excludeExercises,
        onSelected: (List<ExerciseDto> selectedExercises) {
          controller.replaceExerciseLog(oldExerciseId: oldExerciseLog.id, newExercise: selectedExercises.first);
          _cacheLog();
        });
  }

  RoutineLogDto _routineLog() {
    final exerciseLogController = Provider.of<ExerciseLogController>(context, listen: false);

    final exerciseLogs = exerciseLogController.mergeExerciseLogsAndSets();

    final routineLog = widget.log.copyWith(exerciseLogs: exerciseLogs);

    return routineLog;
  }

  Future<void> _doCreateRoutineLog() async {
    final routineLog = _routineLog();

    final routineLogToBeUpdated = routineLog.copyWith(endTime: DateTime.now());

    final updatedRoutineLog =
        await Provider.of<ExerciseAndRoutineController>(context, listen: false).saveLog(logDto: routineLogToBeUpdated);

    workoutSessionLogged();

    _navigateBack(routineLog: updatedRoutineLog);
  }

  Future<void> _doUpdateRoutineLog() async {
    final routineLog = _routineLog();

    await Provider.of<ExerciseAndRoutineController>(context, listen: false).updateLog(log: routineLog);

    _navigateBack(routineLog: routineLog);
  }

  bool _isRoutinePartiallyComplete() {
    final exerciseLogController = Provider.of<ExerciseLogController>(context, listen: false);
    final exerciseLogs = exerciseLogController.mergeExerciseLogsAndSets();
    return exerciseLogs.any((log) => log.sets.any((set) => set.isNotEmpty() && set.checked));
  }

  void _discardLog() {
    showBottomSheetWithMultiActions(
        context: context,
        title: "Discard workout?",
        description: "Do you want to discard this workout",
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
          description: "Do you want to end workout?",
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
      final routineLog = _routineLog();
      final updatedRoutineLog = routineLog.copyWith(endTime: DateTime.now());
      Provider.of<ExerciseAndRoutineController>(context, listen: false).cacheLog(logDto: updatedRoutineLog);
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
    }
    context.pop(routineLog);
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
            backgroundColor: sapphireDark,
            appBar: AppBar(
              backgroundColor: sapphireDark80,
              leading: IconButton(
                  icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
                  onPressed: _discardLog),
              title: Text(
                widget.log.name,
                style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              actions: [
                IconButton(
                    key: const Key('select_exercises_in_library_btn'),
                    onPressed: _selectExercisesInLibrary,
                    icon: const FaIcon(FontAwesomeIcons.plus, color: Colors.white)),
                if (exerciseLogs.length > 1)
                  IconButton(
                      onPressed: () => _reOrderExerciseLogs(exerciseLogs: exerciseLogs),
                      icon: const FaIcon(FontAwesomeIcons.barsStaggered, color: Colors.white))
              ],
            ),
            floatingActionButton: isKeyboardOpen && _selectedSetDto != null
                ? FloatingActionButton.extended(
                    heroTag: UniqueKey(),
                    onPressed: _showWeightCalculator,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    enableFeedback: true,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    icon: Image.asset(
                      'icons/dumbbells.png',
                      fit: BoxFit.contain,
                      color: Colors.white,
                      height: 24, // Adjust the height as needed
                    ),
                    label:
                        Text("Calculator", style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w600)),
                  )
                : FloatingActionButton.extended(
                    heroTag: UniqueKey(),
                    onPressed: widget.mode == RoutineEditorMode.log ? _saveLog : _updateLog,
                    backgroundColor: vibrantGreen.withOpacity(0.1),
                    enableFeedback: true,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    label: Text("Finish workout",
                        style: GoogleFonts.ubuntu(color: vibrantGreen, fontWeight: FontWeight.w600)),
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
              child: Stack(children: [
                SafeArea(
                  minimum: const EdgeInsets.only(right: 10.0, bottom: 10.0, left: 10.0),
                  child: NotificationListener<UserScrollNotification>(
                    onNotification: (scrollNotification) {
                      if (scrollNotification.direction != ScrollDirection.idle) {
                        _dismissKeyboard();
                      }
                      return false;
                    },
                    child: GestureDetector(
                      onTap: _dismissKeyboard,
                      child: Column(
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
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              }),
                              const SizedBox(height: 20),
                            ]),
                          if (exerciseLogs.isNotEmpty)
                            Expanded(
                              child: SingleChildScrollView(
                                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                                padding: const EdgeInsets.only(bottom: 250),
                                child: Column(children: [
                                  ...exerciseLogs.map((exerciseLog) {
                                    final log = exerciseLog;
                                    final exerciseId = log.id;

                                    final isExerciseMinimised = _minimisedExerciseLogCards.contains(exerciseId);

                                    return Padding(
                                        padding: const EdgeInsets.only(bottom: 20),
                                        child: isExerciseMinimised
                                            ? ExerciseLogLiteWidget(
                                                key: ValueKey(exerciseId),
                                                exerciseLogDto: log,
                                                superSet: whereOtherExerciseInSuperSet(
                                                    firstExercise: log, exercises: exerciseLogs),
                                                onMaximise: () =>
                                                    _handleResizedExerciseLogCard(exerciseIdToResize: exerciseId),
                                              )
                                            : ExerciseLogWidget(
                                                key: ValueKey(exerciseId),
                                                exerciseLogDto: log,
                                                editorType: RoutineEditorMode.log,
                                                superSet: whereOtherExerciseInSuperSet(
                                                    firstExercise: log, exercises: exerciseLogs),
                                                onRemoveSuperSet: (String superSetId) {
                                                  exerciseLogController.removeSuperSet(superSetId: log.superSetId);
                                                  _cacheLog();
                                                },
                                                onRemoveLog: () {
                                                  exerciseLogController.removeExerciseLog(logId: exerciseId);
                                                  _cacheLog();
                                                },
                                                onSuperSet: () => _showSuperSetExercisePicker(firstExerciseLog: log),
                                                onCache: _cacheLog,
                                                onReplaceLog: () => _showReplaceExercisePicker(oldExerciseLog: log),
                                                onResize: () =>
                                                    _handleResizedExerciseLogCard(exerciseIdToResize: exerciseId),
                                                isMinimised: _isMinimised(exerciseId),
                                                onAlternate: () =>
                                                    _showSubstituteExercisePicker(primaryExerciseLog: log),
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
                                              ));
                                  })
                                ]),
                              ),
                            ),
                          if (exerciseLogs.isEmpty)
                            const NoListEmptyState(
                              icon: FaIcon(
                                FontAwesomeIcons.solidLightbulb,
                                color: Colors.white70,
                              ),
                              message: "Tap the + button to start adding exercises to your log.",
                            )
                        ],
                      ),
                    ),
                  ),
                )
              ]),
            )));
  }

  void _showWeightCalculator() {
    displayBottomSheet(
        context: context,
        child: WeightPlateCalculator(target: _selectedSetDto?.weight().toDouble() ?? 0),
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
    final updatedExerciseLogs = exerciseLogs.map((exerciseLog) {
      final previousSets = Provider.of<ExerciseAndRoutineController>(context, listen: false)
          .whereSetsForExercise(exercise: exerciseLog.exercise);
      if (previousSets.isNotEmpty) {
        final hasCurrentSets = exerciseLog.sets.isNotEmpty;
        final unCheckedSets = previousSets
            .take(exerciseLog.sets.length)
            .mapIndexed((index, set) => set.copyWith(checked: hasCurrentSets ? exerciseLog.sets[index].checked : false))
            .toList();
        return exerciseLog.copyWith(sets: unCheckedSets);
      }
      return exerciseLog;
    }).toList();
    Provider.of<ExerciseLogController>(context, listen: false)
        .loadExerciseLogs(exerciseLogs: updatedExerciseLogs, mode: widget.mode);
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
        FlutterLocalNotificationsPlugin().periodicallyShow(
            999,
            "${widget.log.name} is still running",
            "Tap to continue training",
            RepeatInterval.hourly,
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
    return Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(5), // rounded border
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        child: Table(
          border: TableBorder(verticalInside: BorderSide(color: Colors.white.withOpacity(0.1), width: 1)),
          columnWidths: const <int, TableColumnWidth>{
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
          },
          children: [
            TableRow(children: [
              Text("EXERCISES",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ubuntu(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w600)),
              Text("SETS",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ubuntu(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w600)),
              Text("DURATION",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ubuntu(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w600))
            ]),
            const TableRow(children: [SizedBox(height: 4), SizedBox(height: 4), SizedBox(height: 4)]),
            TableRow(children: [
              Text(exercisesSummary,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w600)),
              Text(setsSummary,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w600)),
              Center(child: timer)
            ])
          ],
        ));
  }
}
