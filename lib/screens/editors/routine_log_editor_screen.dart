import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/controllers/exercise_log_controller.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/dtos/routine_log_dto.dart';
import 'package:tracker_app/enums/routine_schedule_type_enums.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/shared_prefs.dart';
import 'package:tracker_app/utils/dialog_utils.dart';
import 'package:tracker_app/utils/routine_editors_utils.dart';
import 'package:tracker_app/widgets/routine/editors/exercise_log_widget_lite.dart';

import '../../colors.dart';
import '../../controllers/routine_log_controller.dart';
import '../../controllers/routine_template_controller.dart';
import '../../dtos/exercise_dto.dart';
import '../../enums/routine_editor_type_enums.dart';
import '../../utils/app_analytics.dart';
import '../../utils/exercise_logs_utils.dart';
import '../../utils/health_utils.dart';
import '../../utils/routine_utils.dart';
import '../../widgets/empty_states/exercise_log_empty_state.dart';
import '../../widgets/routine/editors/exercise_log_widget.dart';
import '../../widgets/timers/routine_timer.dart';

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

  void _selectExercisesInLibrary() async {
    final controller = Provider.of<ExerciseLogController>(context, listen: false);
    final preSelectedExercises = controller.exerciseLogs.map((procedure) => procedure.exercise).toList();

    showExercisesInLibrary(
        context: context,
        exclude: preSelectedExercises,
        onSelected: (List<ExerciseDto> selectedExercises) {
          controller.addExerciseLogs(exercises: selectedExercises);
          _cacheLog();
        },
        multiSelect: true);
  }

  void _selectSubstituteExercisesInLibrary({required ExerciseLogDto primaryExerciseLog}) async {
    final controller = Provider.of<ExerciseLogController>(context, listen: false);
    final preSelectedExercises = controller.exerciseLogs.map((exercise) => exercise.exercise).toList();

    showExercisesInLibrary(
        context: context,
        exclude: preSelectedExercises,
        multiSelect: true,
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
          controller.replaceExerciseLog(oldExerciseId: primaryExerciseLog.id, newExercise: secondaryExercise);
          _cacheLog();
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
    final preSelectedExercises = controller.exerciseLogs.map((procedure) => procedure.exercise).toList();

    showExercisesInLibrary(
        context: context,
        exclude: preSelectedExercises,
        multiSelect: false,
        onSelected: (List<ExerciseDto> selectedExercises) {
          controller.replaceExerciseLog(oldExerciseId: oldExerciseLog.id, newExercise: selectedExercises.first);
          _cacheLog();
        });
  }

  RoutineLogDto _routineLog() {
    final exerciseLogController = Provider.of<ExerciseLogController>(context, listen: false);

    final exerciseLogs = exerciseLogController.mergeExerciseLogsAndSets();

    final routineLog = widget.log.copyWith(exerciseLogs: exerciseLogs, updatedAt: DateTime.now());

    return routineLog;
  }

  Future<void> _doCreateRoutineLog() async {
    final routineLog = _routineLog();

    final updatedRoutineLog = routineLog.copyWith(endTime: DateTime.now());

    final createdLog =
        await Provider.of<RoutineLogController>(context, listen: false).saveLog(logDto: updatedRoutineLog);

    workoutSessionLogged();

    if (routineLog.templateId.isNotEmpty) {
      await _updateRoutineTemplateSchedule(routineTemplateId: routineLog.templateId);
    }

    _navigateBack(log: createdLog);
  }

  Future<void> _doUpdateRoutineLog() async {
    final routineLog = _routineLog();

    if (mounted) {
      final updatedRoutineLog = routineLog.copyWith(endTime: widget.log.endTime);
      await Provider.of<RoutineLogController>(context, listen: false).updateLog(log: updatedRoutineLog);
    }
    _navigateBack();
  }

  Future<void> _updateRoutineTemplateSchedule({required String routineTemplateId}) async {
    final template =
        Provider.of<RoutineTemplateController>(context, listen: false).templateWhere(id: routineTemplateId);
    if (template == null) return;
    if (template.scheduleType == RoutineScheduleType.intervals) {
      final scheduledDate = DateTime.now().add(Duration(days: template.scheduleIntervals)).withoutTime();
      final scheduledTemplate = template.copyWith(scheduledDate: scheduledDate);
      await Provider.of<RoutineTemplateController>(context, listen: false).updateTemplate(template: scheduledTemplate);
    }
  }

  bool _isRoutinePartiallyComplete() {
    final exerciseLogController = Provider.of<ExerciseLogController>(context, listen: false);
    final exerciseLogs = exerciseLogController.mergeExerciseLogsAndSets();
    return exerciseLogs.any((log) => log.sets.any((set) => set.checked));
  }

  void _discardLog() {
    showBottomSheetWithMultiActions(
        context: context,
        title: "Discard workout?",
        description: "You have unsaved changes",
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
      _doUpdateRoutineLog();
    } else {
      showBottomSheetWithNoAction(context: context, description: "Complete some sets!", title: 'Update Workout');
    }
  }

  void _showSnackbar(String message) {
    showSnackbar(context: context, icon: const Icon(Icons.info_outline), message: message);
  }

  void _cacheLog() {
    if (widget.mode == RoutineEditorMode.edit) return;
    final routineLog = _routineLog();
    final updatedRoutineLog = routineLog.copyWith(endTime: DateTime.now());
    Provider.of<RoutineLogController>(context, listen: false).cacheLog(logDto: updatedRoutineLog);
  }

  void _checkForUnsavedChanges() {
    final procedureProvider = Provider.of<ExerciseLogController>(context, listen: false);
    final exerciseLog1 = widget.log.exerciseLogs;
    final exerciseLog2 = procedureProvider.mergeExerciseLogsAndSets();
    final unsavedChangesMessage = checkForChanges(exerciseLog1: exerciseLog1, exerciseLog2: exerciseLog2);
    final completedSetsChanged = hasCheckedSetsChanged(exerciseLogs1: exerciseLog1, exerciseLogs2: exerciseLog2);
    if (completedSetsChanged != null) {
      unsavedChangesMessage.add(completedSetsChanged);
    }
    if (unsavedChangesMessage.isNotEmpty) {
      showBottomSheetWithMultiActions(
          context: context,
          title: 'Unsaved Changes',
          description: "You have unsaved changes",
          leftAction: _closeDialog,
          leftActionLabel: 'Cancel',
          rightAction: () {
            _closeDialog();
            _navigateBack();
          },
          rightActionLabel: 'Discard',
          isRightActionDestructive: true);
    } else {
      _navigateBack();
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
    if (!mounted) {
      return;
    }
    if (orderedList != null) {
      Provider.of<ExerciseLogController>(context, listen: false).reOrderExerciseLogs(reOrderedList: orderedList);
      _cacheLog();
    }
  }

  void _navigateBack({RoutineLogDto? log}) async {
    SharedPrefs().remove(key: SharedPrefs().cachedRoutineLogKey);
    FlutterLocalNotificationsPlugin().cancel(999);
    if (log != null) {
      if (Platform.isIOS) {
        syncWorkoutWithAppleHealth(log: log);
      }
    }
    if (mounted) {
      Navigator.of(context).pop(log);
    }
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
    final routineLogEditorController = Provider.of<RoutineLogController>(context, listen: true);

    if (routineLogEditorController.errorMessage.isNotEmpty) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _showSnackbar(routineLogEditorController.errorMessage);
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
                  onPressed: widget.mode == RoutineEditorMode.log ? _discardLog : _checkForUnsavedChanges),
              title: Text(
                widget.log.name,
                style: GoogleFonts.montserrat(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
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
            floatingActionButton: isKeyboardOpen
                ? null
                : FloatingActionButton.extended(
                    heroTag: UniqueKey(),
                    onPressed: widget.mode == RoutineEditorMode.log ? _saveLog : _updateLog,
                    backgroundColor: sapphireDark.withOpacity(0.8),
                    enableFeedback: true,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    label: Text("Finish workout",
                        style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600)),
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
                                return _RoutineLogOverview(
                                  exercisesSummary:
                                      "${provider.completedExerciseLog().length}/${provider.exerciseLogs.length}",
                                  setsSummary:
                                      "${provider.completedSets().length}/${provider.exerciseLogs.expand((exerciseLog) => exerciseLog.sets).length}",
                                  timer: RoutineTimer(startTime: widget.log.startTime),
                                );
                              }),
                              const SizedBox(height: 20),
                            ]),
                          if (exerciseLogs.isNotEmpty)
                            Expanded(
                              child: SingleChildScrollView(
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
                                              ));
                                  })
                                ]),
                              ),
                            ),
                          if (exerciseLogs.isEmpty)
                            const ExerciseLogEmptyState(
                                mode: RoutineEditorMode.log,
                                message: "Tap the + button to start adding exercises to your log"),
                        ],
                      ),
                    ),
                  ),
                )
              ]),
            )));
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _initializeProcedureData();

    _onDisposeCallback = Provider.of<ExerciseLogController>(context, listen: false).onClear;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cacheLog();
    });
  }

  void _initializeProcedureData() {
    final exerciseLogs = widget.log.exerciseLogs;
    final updatedExerciseLogs = exerciseLogs.map((exerciseLog) {
      final previousSets = Provider.of<RoutineLogController>(context, listen: false)
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
      FlutterLocalNotificationsPlugin().cancel(999);
    }

    if (state == AppLifecycleState.paused) {
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
          ));
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
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Table(
          columnWidths: const <int, TableColumnWidth>{
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(2),
          },
          children: [
            TableRow(children: [
              Text("Exercises",
                  style: GoogleFonts.montserrat(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
              Text("Sets",
                  style: GoogleFonts.montserrat(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
              Text("Duration",
                  style: GoogleFonts.montserrat(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500))
            ]),
            TableRow(children: [
              Text(exercisesSummary,
                  style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
              Text(setsSummary,
                  style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
              timer
            ])
          ],
        ));
  }
}
