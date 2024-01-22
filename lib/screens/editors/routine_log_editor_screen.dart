import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/dtos/routine_log_dto.dart';
import 'package:tracker_app/controllers/exercise_log_controller.dart';
import 'package:tracker_app/shared_prefs.dart';
import 'package:tracker_app/utils/dialog_utils.dart';
import '../../app_constants.dart';
import '../../dtos/exercise_dto.dart';
import '../../enums/routine_editor_type_enums.dart';
import '../../controllers/routine_log_controller.dart';
import '../../utils/exercise_logs_utils.dart';
import '../../widgets/empty_states/exercise_log_empty_state.dart';
import '../../utils/routine_utils.dart';
import '../../widgets/routine/editors/exercise_log_widget.dart';
import '../../widgets/routine/editors/exercise_picker.dart';
import '../../widgets/timers/routine_timer.dart';
import '../exercise/exercise_library_screen.dart';

class RoutineLogEditorScreen extends StatefulWidget {
  final RoutineLogDto log;
  final RoutineEditorMode mode;

  const RoutineLogEditorScreen({super.key, required this.log, required this.mode});

  @override
  State<RoutineLogEditorScreen> createState() => _RoutineLogEditorScreenState();
}

class _RoutineLogEditorScreenState extends State<RoutineLogEditorScreen> {
  late Function _onDisposeCallback;

  void _selectExercisesInLibrary() async {
    final provider = Provider.of<ExerciseLogController>(context, listen: false);
    final preSelectedExercises = provider.exerciseLogs.map((procedure) => procedure.exercise).toList();

    final exercises = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ExerciseLibraryScreen(preSelectedExercises: preSelectedExercises)))
        as List<ExerciseDto>?;

    if (exercises != null && exercises.isNotEmpty) {
      if (context.mounted) {
        provider.addExerciseLogs(exercises: exercises);
        _cacheLog();
      }
    }
  }

  void _showExercisePicker({required ExerciseLogDto firstExerciseLog}) {
    final controller = Provider.of<ExerciseLogController>(context, listen: false);
    final exercises = whereOtherExerciseLogsExcept(exerciseLog: firstExerciseLog, others: controller.exerciseLogs);
    displayBottomSheet(
        context: context,
        child: ExercisePicker(
          selectedExercise: firstExerciseLog,
          exercises: exercises,
          onSelect: (ExerciseLogDto secondExercise) {
            _closeDialog();
            final id = "superset_id_${firstExerciseLog.exercise.id}_${secondExercise.exercise.id}";
            controller.superSetExerciseLogs(
                firstExerciseLogId: firstExerciseLog.id, secondExerciseLogId: secondExercise.id, superSetId: id);
            _cacheLog();
          },
          onSelectExercisesInLibrary: () {
            _closeDialog();
            _selectExercisesInLibrary();
          },
        ));
  }

  RoutineLogDto _routineLog() {
    final exerciseLogController = Provider.of<ExerciseLogController>(context, listen: false);
    final exerciseLogs = exerciseLogController.mergeExerciseLogsAndSets();

    final log = widget.log;

    final routineLog = log.copyWith(exerciseLogs: exerciseLogs, endTime: DateTime.now(), updatedAt: DateTime.now());
    return routineLog;
  }

  Future<void> _doCreateRoutineLog() async {
    final routineLog = _routineLog();

    final createdLog = await Provider.of<RoutineLogController>(context, listen: false).saveLog(logDto: routineLog);

    _navigateBack(log: createdLog);
  }

  Future<void> _doUpdateRoutineLog() async {
    final routineLog = _routineLog();

    await Provider.of<RoutineLogController>(context, listen: false).updateLog(log: routineLog);

    _navigateBack();
  }

  bool _isRoutinePartiallyComplete() {
    final exerciseLogController = Provider.of<ExerciseLogController>(context, listen: false);
    final exerciseLogs = exerciseLogController.mergeExerciseLogsAndSets();
    return exerciseLogs.any((log) => log.sets.any((set) => set.checked));
  }

  void _discardLog() {
    showAlertDialogWithMultiActions(
        context: context,
        message: "Discard workout?",
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
      _doCreateRoutineLog();
    } else {
      showAlertDialogWithSingleAction(
          context: context, message: "Complete some sets!", actionLabel: 'Ok', action: _closeDialog);
    }
  }

  void _updateLog() {
    final isRoutinePartiallyComplete = _isRoutinePartiallyComplete();
    if (isRoutinePartiallyComplete) {
      _doUpdateRoutineLog();
    } else {
      showAlertDialogWithSingleAction(
          context: context, message: "Completed some sets!", actionLabel: 'Ok', action: _closeDialog);
    }
  }

  void _showSnackbar(String message) {
    showSnackbar(context: context, icon: const Icon(Icons.info_outline), message: message);
  }

  void _cacheLog() {
    if (widget.mode == RoutineEditorMode.edit) return;
    final routineLog = _routineLog();
    Provider.of<RoutineLogController>(context, listen: false).cacheLog(logDto: routineLog);
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
      showAlertDialogWithMultiActions(
          context: context,
          message: "You have unsaved changes",
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

  void _navigateBack({RoutineLogDto? log}) {
    SharedPrefs().remove(key: SharedPrefs().cachedRoutineLogKey);
    Navigator.of(context).pop(log);
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

    final exerciseLogs = context.select((ExerciseLogController provider) => provider.exerciseLogs);

    bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom != 0;

    return PopScope(
        canPop: false,
        child: Scaffold(
            backgroundColor: tealBlueDark,
            appBar: AppBar(
              leading: IconButton(
                  icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
                  onPressed: widget.mode == RoutineEditorMode.log ? _discardLog : _checkForUnsavedChanges),
              title: Text(
                widget.log.name,
                style: GoogleFonts.montserrat(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              actions: [
                IconButton(
                    onPressed: _selectExercisesInLibrary,
                    icon: const FaIcon(FontAwesomeIcons.plus, color: Colors.white))
              ],
            ),
            floatingActionButton: isKeyboardOpen
                ? null
                : FloatingActionButton(
                    heroTag: UniqueKey(),
                    onPressed: widget.mode == RoutineEditorMode.log ? _saveLog : _updateLog,
                    backgroundColor: tealBlueLighter,
                    enableFeedback: true,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    child: const FaIcon(FontAwesomeIcons.solidSquareCheck, size: 32, color: Colors.green),
                  ),
            body: Stack(children: [
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
                                sets: provider.completedSets().length,
                                timer: RoutineTimer(startTime: widget.log.startTime),
                              );
                            }),
                            const SizedBox(height: 20),
                          ]),
                        exerciseLogs.isNotEmpty
                            ? Expanded(
                                child: ListView.separated(
                                    padding: const EdgeInsets.only(bottom: 250),
                                    itemBuilder: (BuildContext context, int index) {
                                      final log = exerciseLogs[index];
                                      final exerciseId = log.id;
                                      return ExerciseLogWidget(
                                          key: ValueKey(exerciseId),
                                          exerciseLogDto: log,
                                          editorType: RoutineEditorMode.log,
                                          superSet:
                                              whereOtherExerciseInSuperSet(firstExercise: log, exercises: exerciseLogs),
                                          onRemoveSuperSet: (String superSetId) {
                                            exerciseLogController.removeSuperSet(superSetId: log.superSetId);
                                            _cacheLog();
                                          },
                                          onRemoveLog: () {
                                            exerciseLogController.removeExerciseLog(logId: exerciseId);
                                            _cacheLog();
                                          },
                                          onReOrder: () {
                                            _reOrderExerciseLogs(exerciseLogs: exerciseLogs);
                                          },
                                          onSuperSet: () => _showExercisePicker(firstExerciseLog: log),
                                          onCache: _cacheLog);
                                    },
                                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                                    itemCount: exerciseLogs.length))
                            : const ExerciseLogEmptyState(
                                mode: RoutineEditorMode.log,
                                message: "Tap the + button to start adding exercises to your log"),
                      ],
                    ),
                  ),
                ),
              )
            ])));
  }

  @override
  void initState() {
    super.initState();

    _initializeProcedureData();

    _onDisposeCallback = Provider.of<ExerciseLogController>(context, listen: false).onClear;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cacheLog();
    });
  }

  void _initializeProcedureData() {
    final exerciseLogs = widget.log.exerciseLogs;
    Provider.of<ExerciseLogController>(context, listen: false).loadExercises(logs: exerciseLogs, mode: widget.mode);
  }

  @override
  void dispose() {
    _onDisposeCallback();
    super.dispose();
  }
}

class _RoutineLogOverview extends StatelessWidget {
  final int sets;
  final Widget timer;

  const _RoutineLogOverview({required this.sets, required this.timer});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Table(
          columnWidths: const <int, TableColumnWidth>{
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(2),
          },
          children: [
            TableRow(children: [
              Text("Sets",
                  style: GoogleFonts.montserrat(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
              Text("Duration",
                  style: GoogleFonts.montserrat(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500))
            ]),
            TableRow(children: [
              Text("$sets",
                  style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
              timer
            ])
          ],
        ));
  }
}
