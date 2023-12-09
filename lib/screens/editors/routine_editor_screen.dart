import 'dart:async';
import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/models/ModelProvider.dart';
import 'package:tracker_app/providers/exercise_log_provider.dart';
import 'package:tracker_app/providers/routine_provider.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/utils/snackbar_utils.dart';
import 'package:tracker_app/widgets/buttons/text_button_widget.dart';
import 'package:tracker_app/widgets/helper_widgets/dialog_helper.dart';
import 'package:tracker_app/screens/reorder_procedures_screen.dart';
import '../../app_constants.dart';
import '../../dtos/unsaved_changes_messages_dto.dart';
import '../../providers/routine_log_provider.dart';
import '../../utils/general_utils.dart';
import '../../widgets/empty_states/list_tile_empty_state.dart';
import '../../widgets/helper_widgets/routine_helper.dart';
import '../../widgets/routine/editor/exercise_log_widget.dart';
import '../exercise/exercise_library_screen.dart';

enum RoutineEditorMode { edit, log }

class RoutineEditorScreen extends StatefulWidget {
  final String? routineId;
  final RoutineEditorMode mode;

  const RoutineEditorScreen({super.key, this.routineId, this.mode = RoutineEditorMode.edit});

  @override
  State<RoutineEditorScreen> createState() => _RoutineEditorScreenState();
}

class _RoutineEditorScreenState extends State<RoutineEditorScreen> with WidgetsBindingObserver {
  Routine? _routine;
  RoutineLog? _routineLog;

  late TextEditingController _routineNameController;
  late TextEditingController _routineNotesController;

  TemporalDateTime _routineStartTime = TemporalDateTime.now();

  bool _loading = false;
  String _loadingLabel = "";

  late Function _onDisposeCallback;

  void _showProceduresPicker({required ExerciseLogDto firstProcedure}) {
    final procedures = _whereOtherProceduresExcept(firstProcedure: firstProcedure);
    displayBottomSheet(
        context: context,
        child: _ProceduresPicker(
          procedures: procedures,
          onSelect: (ExerciseLogDto secondProcedure) {
            _closeDialog();
            final id = "superset_id_${firstProcedure.exercise.id}_${secondProcedure.exercise.id}";
            Provider.of<ExerciseLogProvider>(context, listen: false).superSetExerciseLogs(
                firstExerciseLogId: firstProcedure.id, secondExerciseLogId: secondProcedure.id, superSetId: id);
          },
          onSelectExercisesInLibrary: () {
            _closeDialog();
            _selectExercisesInLibrary();
          },
        ));
  }

  /// Navigate to [ExerciseLibraryScreen]
  void _selectExercisesInLibrary() async {
    final provider = Provider.of<ExerciseLogProvider>(context, listen: false);
    final preSelectedExercises = provider.exerciseLogs.map((procedure) => procedure.exercise).toList();

    final exercises = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ExerciseLibraryScreen(preSelectedExercises: preSelectedExercises)))
        as List<Exercise>?;

    if (exercises != null && exercises.isNotEmpty) {
      if (mounted) {
        provider.addExerciseLogs(exercises: exercises);
      }
    }
  }

  void _reOrderProcedures() async {
    final provider = Provider.of<ExerciseLogProvider>(context, listen: false);
    final reOrderedList = await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return ReOrderProceduresScreen(procedures: List.from(provider.exerciseLogs));
      },
    ) as List<ExerciseLogDto>?;

    if (reOrderedList != null) {
      if (mounted) {
        provider.loadExerciseLogs(logs: reOrderedList, shouldNotifyListeners: true);
      }
    }
  }

  void _removeProcedureSuperSets({required String superSetId}) {
    Provider.of<ExerciseLogProvider>(context, listen: false).removeSuperSetForLogs(superSetId: superSetId);
  }

  void _removeProcedure({required String procedureId}) {
    Provider.of<ExerciseLogProvider>(context, listen: false).removeExerciseLog(logId: procedureId);
  }

  List<ExerciseLogDto> _whereOtherProceduresExcept({required ExerciseLogDto firstProcedure}) {
    return Provider.of<ExerciseLogProvider>(context, listen: false)
        .exerciseLogs
        .where((procedure) => procedure.id != firstProcedure.id && procedure.superSetId.isEmpty)
        .toList();
  }

  void _toggleLoadingState() {
    setState(() {
      _loading = !_loading;
      _loadingLabel = _canUpdate() ? "Updating" : "Creating";
    });
  }

  bool _validateRoutineInputs() {
    final procedureProviders = Provider.of<ExerciseLogProvider>(context, listen: false);
    final procedures = procedureProviders.exerciseLogs;

    if (_routineNameController.text.isEmpty) {
      _showSnackbar('Please provide a name for this workout');
      return false;
    }
    if (procedures.isEmpty) {
      _showSnackbar("Workout must have exercise(s)");
      return false;
    }
    return true;
  }

  void _showSnackbar(String message) {
    showSnackbar(context: context, icon: const Icon(Icons.info_outline), message: message);
  }

  void _handleRoutineCreationError(String message) {
    if (mounted) {
      _showSnackbar(message);
    }
  }

  void _createRoutine() async {
    final procedureProvider = Provider.of<ExerciseLogProvider>(context, listen: false);
    final routineProvider = Provider.of<RoutineProvider>(context, listen: false);
    if (!_validateRoutineInputs()) return;
    _toggleLoadingState();
    try {
      await routineProvider.saveRoutine(
          name: _routineNameController.text.trim(),
          notes: _routineNotesController.text.trim(),
          procedures: procedureProvider.mergeSetsIntoExerciseLogs());
      if (mounted) _navigateBack();
    } catch (e) {
      _handleRoutineCreationError("Unable to create workout");
    } finally {
      _toggleLoadingState();
    }
  }

  void _doCreateRoutineLog() async {
    final completedExerciseLogs = _completedExerciseLogsAndSets();

    Provider.of<RoutineLogProvider>(context, listen: false).saveRoutineLog(
        context: context,
        name: _routine?.name ?? "${DateTime.now().timeOfDay()} Workout",
        notes: _routine?.notes ?? "",
        procedures: completedExerciseLogs,
        startTime: _routineStartTime,
        routine: _routine);
  }

  void _updateRoutine() {
    if (!_validateRoutineInputs()) return;
    final routine = _routine;
    if (routine != null) {
      showAlertDialogWithMultiActions(
          context: context,
          message: "Update workout?",
          leftAction: _closeDialog,
          rightAction: () {
            _closeDialog();
            _doUpdateRoutine(routine: routine);
            _navigateBack();
          },
          leftActionLabel: 'Cancel',
          rightActionLabel: 'Update');
    }
  }

  void _doUpdateRoutine({required Routine routine, List<ExerciseLogDto>? updatedExerciseLogs}) async {
    final procedureProvider = Provider.of<ExerciseLogProvider>(context, listen: false);
    final exerciseLogs = updatedExerciseLogs ?? procedureProvider.mergeSetsIntoExerciseLogs();
    final routineProvider = Provider.of<RoutineProvider>(context, listen: false);
    _toggleLoadingState();
    try {
      final updatedRoutine = routine.copyWith(
          name: _routineNameController.text.trim(),
          notes: _routineNotesController.text.trim(),
          procedures: exerciseLogs.map((procedure) => procedure.toJson()).toList(),
          updatedAt: TemporalDateTime.now());
      await routineProvider.updateRoutine(routine: updatedRoutine);
    } catch (e) {
      _handleRoutineCreationError("Unable to update workout");
    } finally {
      _toggleLoadingState();
    }
  }

  bool _isRoutinePartiallyComplete() {
    final exerciseLogsProvider = Provider.of<ExerciseLogProvider>(context, listen: false);
    final exerciseLogs = exerciseLogsProvider.mergeSetsIntoExerciseLogs();
    return exerciseLogs.any((log) => log.sets.any((set) => set.checked));
  }

  List<ExerciseLogDto> _completedExerciseLogsAndSets() {
    final exerciseLogsProvider = Provider.of<ExerciseLogProvider>(context, listen: false);
    final exerciseLogs = exerciseLogsProvider.mergeSetsIntoExerciseLogs();
    final completedExerciseLogs = <ExerciseLogDto>[];
    for (var log in exerciseLogs) {
      final completedSets = log.sets.where((set) => set.isNotEmpty() && set.checked).toList();
      if (completedSets.isNotEmpty) {
        final completedExerciseLog = log.copyWith(sets: completedSets);
        completedExerciseLogs.add(completedExerciseLog);
      }
    }
    return completedExerciseLogs;
  }

  void _cancelRoutineLog() {
    showAlertDialogWithMultiActions(
        context: context,
        message: "Do you want to discard workout?",
        leftAction: _closeDialog,
        rightAction: () {
          _closeDialog();
          _navigateBack();
        },
        leftActionLabel: 'Cancel',
        rightActionLabel: 'Discard',
        isRightActionDestructive: true);
  }

  void _endRoutineLog() {
    final isRoutinePartiallyComplete = _isRoutinePartiallyComplete();
    if (isRoutinePartiallyComplete) {
      final routine = _routine;
      if (routine != null) {
        _checkForUpdates();
      } else {
        _doCreateRoutineLog();
        _navigateBack();
      }
    } else {
      showAlertDialogWithSingleAction(
          context: context, message: "You have not completed any sets", actionLabel: 'Ok', action: _closeDialog);
    }
  }

  void _cacheRoutineLog() {
    if (widget.mode == RoutineEditorMode.log) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final procedureProvider = Provider.of<ExerciseLogProvider>(context, listen: false);
        final procedures = procedureProvider.mergeSetsIntoExerciseLogs();
        final routine = _routine;
        Provider.of<RoutineLogProvider>(context, listen: false).cacheRoutineLog(
            name: routine?.name ?? "",
            notes: routine?.notes ?? "",
            procedures: procedures,
            startTime: _routineStartTime,
            routine: routine);
      });
    }
  }

  List<UnsavedChangesMessageDto> _checkForChanges(
      {required List<ExerciseLogDto> exerciseLog1, required List<ExerciseLogDto> exerciseLog2}) {
    List<UnsavedChangesMessageDto> unsavedChangesMessage = [];
    final procedureProvider = Provider.of<ExerciseLogProvider>(context, listen: false);

    /// Check if [ProcedureDto]'s have been added or removed
    final differentProceduresChangeMessage =
        procedureProvider.hasDifferentExerciseLogsLength(exerciseLog1: exerciseLog1, exerciseLog2: exerciseLog2);
    if (differentProceduresChangeMessage != null) {
      unsavedChangesMessage.add(differentProceduresChangeMessage);
    }

    /// Check if [SetDto]'s have been added or removed
    final differentSetsChangeMessage =
        procedureProvider.hasDifferentSetsLength(exerciseLog1: exerciseLog1, exerciseLog2: exerciseLog2);
    if (differentSetsChangeMessage != null) {
      unsavedChangesMessage.add(differentSetsChangeMessage);
    }

    /// Check if [SetType] for [SetDto] has been changed
    final differentSetTypesChangeMessage =
        procedureProvider.hasSetTypeChange(exerciseLog1: exerciseLog1, exerciseLog2: exerciseLog2);
    if (differentSetTypesChangeMessage != null) {
      unsavedChangesMessage.add(differentSetTypesChangeMessage);
    }

    /// Check if [ExerciseType] for [Exercise] in [ProcedureDto] has been changed
    final differentExerciseTypesChangeMessage =
        procedureProvider.hasExercisesChanged(exerciseLog1: exerciseLog1, exerciseLog2: exerciseLog2);
    if (differentExerciseTypesChangeMessage != null) {
      unsavedChangesMessage.add(differentExerciseTypesChangeMessage);
    }

    /// Check if superset in [ProcedureDto] has been changed
    final differentSuperSetIdsChangeMessage =
        procedureProvider.hasSuperSetIdChanged(exerciseLog1: exerciseLog1, exerciseLog2: exerciseLog2);
    if (differentSuperSetIdsChangeMessage != null) {
      unsavedChangesMessage.add(differentSuperSetIdsChangeMessage);
    }

    /// Check if [SetDto] value has been changed
    final differentSetValueChangeMessage =
        procedureProvider.hasSetValueChanged(exerciseLog1: exerciseLog1, exerciseLog2: exerciseLog2);
    if (differentSetValueChangeMessage != null) {
      unsavedChangesMessage.add(differentSetValueChangeMessage);
    }
    return unsavedChangesMessage;
  }

  void _checkForUnsavedChanges() {
    if (widget.mode == RoutineEditorMode.edit) {
      final procedureProvider = Provider.of<ExerciseLogProvider>(context, listen: false);
      final oldProcedures = _routineLog?.procedures ?? _routine?.procedures;
      final exerciseLog1 = oldProcedures
          ?.map((json) => ExerciseLogDto.fromJson(routineLog: _routineLog, json: jsonDecode(json)))
          .toList();
      final exerciseLog2 = procedureProvider.mergeSetsIntoExerciseLogs();
      final unsavedChangesMessage = _checkForChanges(exerciseLog1: exerciseLog1 ?? [], exerciseLog2: exerciseLog2);
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
  }

  bool _canUpdate() {
    final previousRoutine = _routine;
    final previousRoutineLog = _routineLog;
    return previousRoutine != null || previousRoutineLog != null;
  }

  String? _editorTitle() {
    final previousRoutine = _routine;
    final previousRoutineLog = _routineLog;

    String title = "";

    /// We are editing a [Routine]
    if (previousRoutine != null) {
      title = previousRoutine.name;
    } else {
      if (previousRoutineLog != null) {
        title = previousRoutineLog.name;
      }
    }
    return title;
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void _closeDialog() {
    Navigator.of(context).pop();
  }

  void _navigateBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    _cacheRoutineLog();

    final exerciseLogs = context.select((ExerciseLogProvider provider) => provider.exerciseLogs);

    bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom != 0;

    return Scaffold(
        backgroundColor: tealBlueDark,
        appBar: widget.mode == RoutineEditorMode.edit
            ? AppBar(
                leading: IconButton(icon: const Icon(Icons.arrow_back_outlined), onPressed: _checkForUnsavedChanges),
                actions: [
                  CTextButton(
                      onPressed: _canUpdate() ? _updateRoutine : _createRoutine,
                      label: _canUpdate() ? "Update" : "Save",
                      buttonColor: Colors.transparent,
                      loading: _loading,
                      loadingLabel: _loadingLabel)
                ],
              )
            : AppBar(
                leading: GestureDetector(
                  onTap: _cancelRoutineLog,
                  child: const Icon(
                    Icons.arrow_back_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                title: Text(
                  "${_editorTitle()}",
                  style: GoogleFonts.lato(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                actions: [IconButton(onPressed: _selectExercisesInLibrary, icon: const Icon(Icons.add))],
              ),
        floatingActionButton: isKeyboardOpen
            ? null
            : widget.mode == RoutineEditorMode.log
                ? FloatingActionButton(
                    heroTag: "fab_end_routine_log_screen",
                    onPressed: _endRoutineLog,
                    backgroundColor: tealBlueLighter,
                    enableFeedback: true,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    child: const Icon(Icons.check_box_rounded, size: 32, color: Colors.green),
                  )
                : FloatingActionButton(
                    heroTag: "fab_select_exercise_log_screen",
                    onPressed: _selectExercisesInLibrary,
                    backgroundColor: tealBlueLighter,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    child: const Icon(Icons.add, size: 28),
                  ),
        body: NotificationListener<UserScrollNotification>(
          onNotification: (scrollNotification) {
            if (scrollNotification.direction != ScrollDirection.idle) {
              _dismissKeyboard();
            }
            return false;
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 10.0, bottom: 10.0, left: 10.0),
            child: GestureDetector(
              onTap: _dismissKeyboard,
              child: Column(
                children: [
                  if (widget.mode == RoutineEditorMode.log)
                    Consumer<ExerciseLogProvider>(
                        builder: (BuildContext context, ExerciseLogProvider provider, Widget? child) {
                      return _RoutineLogOverview(
                        sets: provider.completedSets().length,
                        timer: _RoutineTimer(startTime: _routineStartTime.getDateTimeInUtc()),
                      );
                    }),
                  if (widget.mode == RoutineEditorMode.edit)
                    Column(
                      children: [
                        TextField(
                          controller: _routineNameController,
                          decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(2),
                                  borderSide: const BorderSide(color: tealBlueLighter)),
                              filled: true,
                              fillColor: tealBlueLighter,
                              hintText: "New workout",
                              hintStyle: GoogleFonts.lato(color: Colors.grey, fontSize: 14)),
                          cursorColor: Colors.white,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.words,
                          style: GoogleFonts.lato(
                              fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.8), fontSize: 14),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _routineNotesController,
                          decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(2),
                                  borderSide: const BorderSide(color: tealBlueLighter)),
                              filled: true,
                              fillColor: tealBlueLighter,
                              hintText: "Notes",
                              hintStyle: GoogleFonts.lato(color: Colors.grey, fontSize: 14)),
                          maxLines: null,
                          cursorColor: Colors.white,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.sentences,
                          style: GoogleFonts.lato(
                              fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.8), fontSize: 14),
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  Expanded(
                      child: ListView.separated(
                          padding: const EdgeInsets.only(bottom: 250),
                          itemBuilder: (BuildContext context, int index) {
                            final procedure = exerciseLogs[index];
                            final procedureId = procedure.id;
                            return ExerciseLogWidget(
                                exerciseLogDto: procedure,
                                editorType: widget.mode,
                                superSet:
                                    whereOtherSuperSetProcedure(firstProcedure: procedure, procedures: exerciseLogs),
                                onRemoveSuperSet: (String superSetId) =>
                                    _removeProcedureSuperSets(superSetId: procedure.superSetId),
                                onRemoveLog: () => _removeProcedure(procedureId: procedureId),
                                onSuperSet: () => _showProceduresPicker(firstProcedure: procedure),
                                onCache: _cacheRoutineLog,
                                onReOrderLogs: _reOrderProcedures);
                          },
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemCount: exerciseLogs.length)),
                ],
              ),
            ),
          ),
        ));
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _fetchRoutine();
    _fetchRoutineLog();

    _initializeProcedureData();
    _initializeTextControllers();

    _loadRoutineStartTime();

    _onDisposeCallback = Provider.of<ExerciseLogProvider>(context, listen: false).onClearProvider;
  }

  void _fetchRoutine() {
    _routine = Provider.of<RoutineProvider>(context, listen: false).routineWhere(id: widget.routineId ?? "");
  }

  void _fetchRoutineLog() {
    if (widget.mode == RoutineEditorMode.log) {
      _routineLog = cachedRoutineLog();
    }
  }

  void _loadRoutineStartTime() {
    final routineLog = _routineLog;
    if (routineLog != null) {
      _routineStartTime = routineLog.startTime;
    }
  }

  void _initializeProcedureData() {
    final procedureJsons = _routineLog?.procedures ?? _routine?.procedures;
    final procedures = procedureJsons
        ?.map((json) => ExerciseLogDto.fromJson(routineLog: _routineLog, json: jsonDecode(json)))
        .toList();
    if (procedures != null) {
      Provider.of<ExerciseLogProvider>(context, listen: false).loadExerciseLogs(logs: procedures);
    }
  }

  void _checkForUpdates() async {
    final oldProcedures = _routine?.procedures;
    final exerciseLog1 = oldProcedures
            ?.map((json) => ExerciseLogDto.fromJson(routineLog: _routineLog, json: jsonDecode(json)))
            .toList() ??
        [];
    final exerciseLog2 =
        Provider.of<ExerciseLogProvider>(context, listen: false).mergeSetsIntoExerciseLogs(updateRoutineSets: true);

    final changes = _checkForChanges(exerciseLog1: exerciseLog1, exerciseLog2: exerciseLog2);
    if (changes.isNotEmpty) {
      _displayNotificationsDialog(changes: changes, exerciseLogs: exerciseLog2);
    } else {
      _doCreateRoutineLog();
      _navigateBack();
    }
  }

  void _displayNotificationsDialog(
      {required List<UnsavedChangesMessageDto> changes, required List<ExerciseLogDto> exerciseLogs}) {
    displayBottomSheet(
        context: context,
        child: _NotificationsDialog(
            onUpdate: () {
              final routine = _routine;
              if (routine != null) {
                _closeDialog();
                _doCreateRoutineLog();
                _doUpdateRoutine(routine: routine, updatedExerciseLogs: exerciseLogs);
                _navigateBack();
              }
            },
            messages: changes));
  }

  void _initializeTextControllers() {
    Routine? routine = _routine;
    RoutineLog? routineLog = _routineLog;
    _routineNameController = TextEditingController(text: routine?.name ?? routineLog?.name);
    _routineNotesController = TextEditingController(text: routine?.notes ?? routineLog?.notes);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _onDisposeCallback();
    if (widget.mode == RoutineEditorMode.edit) {
      _routineNameController.dispose();
      _routineNotesController.dispose();
    }
    super.dispose();
  }
}

class _ProceduresPicker extends StatelessWidget {
  final List<ExerciseLogDto> procedures;
  final void Function(ExerciseLogDto procedure) onSelect;
  final void Function() onSelectExercisesInLibrary;

  const _ProceduresPicker({required this.procedures, required this.onSelect, required this.onSelectExercisesInLibrary});

  @override
  Widget build(BuildContext context) {
    final listTiles = procedures
        .map((procedure) => ListTile(
            onTap: () => onSelect(procedure),
            dense: true,
            title: Text(procedure.exercise.name, style: GoogleFonts.lato(color: Colors.white))))
        .toList();

    return procedures.isNotEmpty
        ? SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [...listTiles],
            ),
          )
        : _ProceduresPickerEmptyState(onPressed: onSelectExercisesInLibrary);
  }
}

class _ProceduresPickerEmptyState extends StatelessWidget {
  final VoidCallback onPressed;

  const _ProceduresPickerEmptyState({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 18.0),
            child: ListTileEmptyState(),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.only(left: 18.0),
            child: ListTileEmptyState(),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SizedBox(
              width: double.infinity,
              child: CTextButton(onPressed: onPressed, label: "Add more exercises", buttonColor: tealBlueLighter),
            ),
          )
        ],
      ),
    );
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
        style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.w600));
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
              Text("Sets", style: GoogleFonts.lato(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
              Text("Duration",
                  style: GoogleFonts.lato(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500))
            ]),
            TableRow(children: [
              Text("$sets", style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
              timer
            ])
          ],
        ));
  }
}

class _NotificationsDialog extends StatelessWidget {
  final List<UnsavedChangesMessageDto> messages;
  final VoidCallback onUpdate;

  const _NotificationsDialog({required this.onUpdate, required this.messages});

  @override
  Widget build(BuildContext context) {
    final listTiles = messages
        .map((item) => ListTile(
            leading: const Icon(Icons.info_outline),
            dense: true,
            title: Text(item.message, style: GoogleFonts.lato(color: Colors.white))))
        .toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          ...listTiles,
          CTextButton(
            onPressed: onUpdate,
            label: "Update workout",
            visualDensity: VisualDensity.standard,
          )
        ],
      ),
    );
  }
}
