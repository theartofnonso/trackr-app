import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/dtos/routine_log_dto.dart';
import 'package:tracker_app/enums/template_changes_type_message_enums.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/providers/exercise_log_provider.dart';
import 'package:tracker_app/shared_prefs.dart';
import 'package:tracker_app/widgets/helper_widgets/dialog_helper.dart';
import '../../app_constants.dart';
import '../../dtos/exercise_dto.dart';
import '../../dtos/template_changes_messages_dto.dart';
import '../../enums/routine_editor_type_enums.dart';
import '../../providers/routine_log_provider.dart';
import '../../widgets/backgrounds/overlay_background.dart';
import '../../widgets/empty_states/exercise_log_empty_state.dart';
import '../../widgets/helper_widgets/routine_helper.dart';
import '../../widgets/routine/editors/exercise_log_widget.dart';
import '../../widgets/routine/editors/exercise_picker.dart';
import '../exercise/exercise_library_screen.dart';
import 'helper_utils.dart';

enum RoutineLogEditorMode { log, edit }

class RoutineLogEditorScreen extends StatefulWidget {
  final RoutineLogDto log;
  final RoutineLogEditorMode mode;

  const RoutineLogEditorScreen({super.key, required this.log, this.mode = RoutineLogEditorMode.log});

  @override
  State<RoutineLogEditorScreen> createState() => _RoutineLogEditorScreenState();
}

class _RoutineLogEditorScreenState extends State<RoutineLogEditorScreen> {
  bool _loading = false;
  String _loadingMessage = "";

  late Function _onDisposeCallback;

  void _selectExercisesInLibrary() async {
    final provider = Provider.of<ExerciseLogProvider>(context, listen: false);
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
    final exercises = whereOtherExerciseLogsExcept(context: context, firstProcedure: firstExerciseLog);
    displayBottomSheet(
        context: context,
        child: ExercisePicker(
          selectedExercise: firstExerciseLog,
          exercises: exercises,
          onSelect: (ExerciseLogDto secondExercise) {
            _closeDialog();
            final id = "superset_id_${firstExerciseLog.exercise.id}_${secondExercise.exercise.id}";
            Provider.of<ExerciseLogProvider>(context, listen: false).superSetExerciseLogs(
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
    final exerciseLogsProvider = Provider.of<ExerciseLogProvider>(context, listen: false);
    final exerciseLogs = exerciseLogsProvider.mergeSetsIntoExerciseLogs();

    final log = widget.log;

    final routineLog = log.copyWith(
        exerciseLogs: exerciseLogs,
        endTime: widget.mode == RoutineLogEditorMode.log ? DateTime.now() : log.endTime,
        updatedAt: DateTime.now());
    return routineLog;
  }

  Future<void> _doCreateRoutineLog() async {
    _toggleLoadingState(message: "Saving log...");

    final routineLog = _routineLog();
    try {
      final createdLog =
          await Provider.of<RoutineLogProvider>(context, listen: false).saveRoutineLog(logDto: routineLog);

      _navigateBack(log: createdLog);
    } catch (_) {
      _handleRoutineLogError("Unable to log workout");
    } finally {
      _toggleLoadingState();
    }
  }

  Future<void> _doUpdateRoutineLog() async {
    _toggleLoadingState(message: "Updating log...");

    final routineLog = _routineLog();

    try {
      await Provider.of<RoutineLogProvider>(context, listen: false).updateRoutineLog(log: routineLog);

      _navigateBack();
    } catch (_) {
      _handleRoutineLogError("Unable to update log");
    } finally {
      _toggleLoadingState();
    }
  }

  bool _isRoutinePartiallyComplete() {
    final exerciseLogsProvider = Provider.of<ExerciseLogProvider>(context, listen: false);
    final exerciseLogs = exerciseLogsProvider.mergeSetsIntoExerciseLogs();
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

  void _handleRoutineLogError(String message) {
    if (mounted) {
      _showSnackbar(message);
    }
  }

  void _cacheLog() {
    if (widget.mode == RoutineLogEditorMode.edit) return;
    final routineLog = _routineLog();
    Provider.of<RoutineLogProvider>(context, listen: false).cacheRoutineLog(logDto: routineLog);
  }

  TemplateChangesMessageDto? _completedSetsChanged(
      {required List<ExerciseLogDto> exerciseLog1, required List<ExerciseLogDto> exerciseLog2}) {
    final exerciseLog1CompletedSets = exerciseLog1.expand((log) => log.sets).where((set) => set.checked).toList();
    final exerciseLog2CompletedSets = exerciseLog2.expand((log) => log.sets).where((set) => set.checked).toList();

    if (exerciseLog1CompletedSets.length > exerciseLog2CompletedSets.length) {
      return TemplateChangesMessageDto(type: TemplateChangesMessageType.checkedSets, message: 'Removed completed sets');
    } else if (exerciseLog1CompletedSets.length < exerciseLog2CompletedSets.length) {
      return TemplateChangesMessageDto(type: TemplateChangesMessageType.checkedSets, message: 'Added completed sets');
    }

    return null;
  }

  void _checkForUnsavedChanges() {
    final procedureProvider = Provider.of<ExerciseLogProvider>(context, listen: false);
    final exerciseLog1 = widget.log.exerciseLogs;
    final exerciseLog2 = procedureProvider.mergeSetsIntoExerciseLogs();
    final unsavedChangesMessage =
        checkForChanges(context: context, exerciseLog1: exerciseLog1, exerciseLog2: exerciseLog2);
    final completedSetsChanged = _completedSetsChanged(exerciseLog1: exerciseLog1, exerciseLog2: exerciseLog2);
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

  void _navigateBack({RoutineLogDto? log}) {
    SharedPrefs().remove(key: SharedPrefs().cachedRoutineLogKey);
    Navigator.of(context).pop(log);
  }

  void _toggleLoadingState({String message = ""}) {
    setState(() {
      _loading = !_loading;
      _loadingMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final exerciseLogs = context.select((ExerciseLogProvider provider) => provider.exerciseLogs);

    bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom != 0;

    return PopScope(
        canPop: false,
        child: Scaffold(
            backgroundColor: tealBlueDark,
            appBar: AppBar(
              leading: IconButton(
                  icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
                  onPressed: widget.mode == RoutineLogEditorMode.log ? _discardLog : _checkForUnsavedChanges),
              title: Text(
                widget.log.name,
                style: GoogleFonts.montserrat(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              actions: [IconButton(onPressed: _selectExercisesInLibrary, icon: const FaIcon(FontAwesomeIcons.plus, color: Colors.white))],
            ),
            floatingActionButton: isKeyboardOpen || _loading
                ? null
                : FloatingActionButton(
                    heroTag: UniqueKey(),
                    onPressed: widget.mode == RoutineLogEditorMode.log ? _saveLog : _updateLog,
                    backgroundColor: tealBlueLighter,
                    enableFeedback: true,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    child: const Icon(Icons.check_box_rounded, size: 32, color: Colors.green),
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
                        if (widget.mode == RoutineLogEditorMode.log)
                          Column(children: [
                            Consumer<ExerciseLogProvider>(
                                builder: (BuildContext context, ExerciseLogProvider provider, Widget? child) {
                                  return _RoutineLogOverview(
                                    sets: provider.completedSets().length,
                                    timer: _RoutineTimer(startTime: widget.log.startTime),
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
                                      superSet: whereOtherExerciseInSuperSet(
                                          firstExercise: log, exercises: exerciseLogs),
                                      onRemoveSuperSet: (String superSetId) {
                                        removeExerciseFromSuperSet(context: context, superSetId: log.superSetId);
                                        _cacheLog();
                                      },
                                      onRemoveLog: () {
                                        removeExercise(context: context, exerciseId: exerciseId);
                                        _cacheLog();
                                      },
                                      onReOrder: () {
                                        reOrderExercises(context: context);
                                        _cacheLog();
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
              ),
              if (_loading) OverlayBackground(loadingMessage: _loadingMessage)
            ])));
  }

  @override
  void initState() {
    super.initState();

    _initializeProcedureData();

    _onDisposeCallback = Provider.of<ExerciseLogProvider>(context, listen: false).onClearProvider;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cacheLog();
    });
  }

  void _initializeProcedureData() {
    final exerciseLogs = widget.log.exerciseLogs;
    Provider.of<ExerciseLogProvider>(context, listen: false).loadExercises(logs: exerciseLogs);
  }

  @override
  void dispose() {
    _onDisposeCallback();
    super.dispose();
  }
}

class _RoutineTimer extends StatefulWidget {
  final DateTime startTime;

  const _RoutineTimer({required this.startTime});

  @override
  State<_RoutineTimer> createState() => _RoutineTimerState();
}

class _RoutineTimerState extends State<_RoutineTimer> {
  late Timer _timer;
  Duration _elapsedDuration = Duration.zero;

  @override
  Widget build(BuildContext context) {
    return Text(_elapsedDuration.secondsOrMinutesOrHours(),
        style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w600));
  }

  @override
  void initState() {
    super.initState();
    _elapsedDuration = DateTime.now().difference(widget.startTime);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsedDuration = DateTime.now().difference(widget.startTime);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
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
