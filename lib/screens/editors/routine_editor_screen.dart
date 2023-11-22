import 'dart:async';
import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/procedure_dto.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/models/ModelProvider.dart';
import 'package:tracker_app/providers/procedures_provider.dart';
import 'package:tracker_app/providers/routine_provider.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/utils/snackbar_utils.dart';
import 'package:tracker_app/widgets/buttons/text_button_widget.dart';
import 'package:tracker_app/widgets/helper_widgets/dialog_helper.dart';
import 'package:tracker_app/screens/reorder_procedures_screen.dart';
import '../../app_constants.dart';
import '../../dtos/unsaved_changes_messages_dto.dart';
import '../../providers/routine_log_provider.dart';
import '../../widgets/empty_states/list_tile_empty_state.dart';
import '../../widgets/helper_widgets/routine_helper.dart';
import '../../widgets/routine/editor/procedure_widget.dart';
import '../exercise/exercise_library_screen.dart';

enum RoutineEditorMode { edit, log }

class RoutineEditorScreen extends StatefulWidget {
  final Routine? routine;
  final RoutineLog? routineLog;
  final RoutineEditorMode mode;
  final TemporalDateTime? createdAt;

  const RoutineEditorScreen(
      {super.key, this.routine, this.routineLog, this.mode = RoutineEditorMode.edit, this.createdAt});

  @override
  State<RoutineEditorScreen> createState() => _RoutineEditorScreenState();
}

class _RoutineEditorScreenState extends State<RoutineEditorScreen> {
  late TextEditingController _routineNameController;
  late TextEditingController _routineNotesController;

  TemporalDateTime _routineStartTime = TemporalDateTime.now();

  bool _loading = false;
  String _loadingLabel = "";

  late Function _onDisposeCallback;

  void _showProceduresPicker({required ProcedureDto firstProcedure}) {
    final procedures = _whereOtherProceduresExcept(firstProcedure: firstProcedure);
    displayBottomSheet(
        height: 216,
        context: context,
        child: _ProceduresPicker(
          procedures: procedures,
          onSelect: (ProcedureDto secondProcedure) {
            final id = "superset_id_${firstProcedure.exercise.id}_${secondProcedure.exercise.id}";
            Navigator.of(context).pop();
            Provider.of<ProceduresProvider>(context, listen: false).superSetProcedures(
                context: context,
                firstProcedureId: firstProcedure.id,
                secondProcedureId: secondProcedure.id,
                superSetId: id);
          },
          onSelectExercisesInLibrary: () {
            Navigator.of(context).pop();
            _selectExercisesInLibrary();
          },
        ));
  }

  /// Navigate to [ExerciseLibraryScreen]
  void _selectExercisesInLibrary() async {
    final provider = Provider.of<ProceduresProvider>(context, listen: false);
    final preSelectedExercises = provider.procedures.map((procedure) => procedure.exercise).toList();

    final exercises = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ExerciseLibraryScreen(preSelectedExercises: preSelectedExercises)))
        as List<Exercise>?;

    if (exercises != null && exercises.isNotEmpty) {
      if (mounted) {
        provider.addProcedures(context: context, exercises: exercises);
      }
    }
  }

  void _reOrderProcedures() async {
    final provider = Provider.of<ProceduresProvider>(context, listen: false);
    final reOrderedList = await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return ReOrderProceduresScreen(procedures: List.from(provider.procedures));
      },
    ) as List<ProcedureDto>?;

    if (reOrderedList != null) {
      if (mounted) {
        provider.refreshProcedures(procedures: reOrderedList);
      }
    }
  }

  void _replaceProcedure({required String procedureId}) async {
    final preSelectedExercises = Provider.of<ProceduresProvider>(context, listen: false)
        .mergeSetsIntoProcedures()
        .map((procedure) => procedure.exercise)
        .toList();
    final selectedExercises = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ExerciseLibraryScreen(
              multiSelect: false,
              preSelectedExercises: preSelectedExercises,
            ))) as List<Exercise>?;

    if (selectedExercises != null) {
      if (selectedExercises.isNotEmpty) {
        if (mounted) {
          Provider.of<ProceduresProvider>(context, listen: false)
              .replaceProcedure(context: context, procedureId: procedureId, exercise: selectedExercises.first);
        }
      }
    }
  }

  void _removeProcedureSuperSets({required String superSetId}) {
    Provider.of<ProceduresProvider>(context, listen: false)
        .removeProcedureSuperSet(context: context, superSetId: superSetId);
  }

  void _removeProcedure({required String procedureId}) {
    Provider.of<ProceduresProvider>(context, listen: false).removeProcedure(context: context, procedureId: procedureId);
  }

  List<ProcedureDto> _whereOtherProceduresExcept({required ProcedureDto firstProcedure}) {
    return Provider.of<ProceduresProvider>(context, listen: false)
        .procedures
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
    final procedureProviders = Provider.of<ProceduresProvider>(context, listen: false);
    final procedures = procedureProviders.procedures;

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
    final procedureProvider = Provider.of<ProceduresProvider>(context, listen: false);
    final routineProvider = Provider.of<RoutineProvider>(context, listen: false);
    if (!_validateRoutineInputs()) return;
    _toggleLoadingState();
    try {
      await routineProvider.saveRoutine(
          name: _routineNameController.text,
          notes: _routineNotesController.text,
          procedures: procedureProvider.mergeSetsIntoProcedures());
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      _handleRoutineCreationError("Unable to create workout");
    } finally {
      _toggleLoadingState();
    }
  }

  void _createRoutineLog() {
    showAlertDialog(
        context: context,
        message: "Finish workout?",
        leftAction: () {
          Navigator.of(context).pop();
          _navigateBackAndClearCache();
        },
        rightAction: () {
          Navigator.of(context).pop();
          _doCreateRoutineLog();
        },
        leftActionLabel: 'Discard',
        isLeftActionDestructive: true,
        rightActionLabel: 'Finish');
  }

  void _doCreateRoutineLog() {
    final routine = widget.routineLog?.routine;
    final completedProcedures = _totalCompletedProceduresAndSets();
    Provider.of<RoutineLogProvider>(context, listen: false).saveRoutineLog(
        context: context,
        name: routine?.name ?? "${DateTime.now().timeOfDay()} Workout",
        notes: routine?.notes ?? "",
        procedures: completedProcedures,
        startTime: _routineStartTime,
        createdAt: widget.createdAt,
        routine: routine);
    Navigator.of(context).pop();
  }

  void _updateRoutine({required Routine routine}) {
    if (!_validateRoutineInputs()) return;

    showAlertDialog(
        context: context,
        message: "Update workout?",
        leftAction: Navigator.of(context).pop,
        rightAction: () {
          Navigator.of(context).pop();
          _doUpdateRoutine(routine: routine);
        },
        leftActionLabel: 'Cancel',
        rightActionLabel: 'Update');
  }

  void _updateRoutineLog({required RoutineLog routineLog}) {
    if (!_validateRoutineInputs()) return;

    showAlertDialog(
        context: context,
        message: "Update log?",
        leftAction: Navigator.of(context).pop,
        rightAction: () {
          Navigator.of(context).pop();
          _doUpdateRoutineLog(routineLog: routineLog);
        },
        leftActionLabel: 'Cancel',
        rightActionLabel: 'Update');
  }

  void _doUpdate() {
    final previousRoutine = widget.routine;
    final previousRoutineLog = widget.routineLog;

    if (previousRoutine != null) {
      _updateRoutine(routine: previousRoutine);
    } else {
      if (previousRoutineLog != null) {
        _updateRoutineLog(routineLog: previousRoutineLog);
      }
    }
  }

  void _doUpdateRoutine({required Routine routine}) async {
    final procedureProvider = Provider.of<ProceduresProvider>(context, listen: false);
    final routineProvider = Provider.of<RoutineProvider>(context, listen: false);
    final procedures = procedureProvider.mergeSetsIntoProcedures();
    _toggleLoadingState();
    try {
      final updatedRoutine = routine.copyWith(
          name: _routineNameController.text,
          notes: _routineNotesController.text,
          procedures: procedures.map((procedure) => procedure.toJson()).toList(),
          updatedAt: TemporalDateTime.now());

      await routineProvider.updateRoutine(routine: updatedRoutine);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      _handleRoutineCreationError("Unable to update workout");
    } finally {
      _toggleLoadingState();
    }
  }

  void _doUpdateRoutineLog({required RoutineLog routineLog}) async {
    final procedureProvider = Provider.of<ProceduresProvider>(context, listen: false);
    final routineLogProvider = Provider.of<RoutineLogProvider>(context, listen: false);
    final procedures = procedureProvider.mergeSetsIntoProcedures();
    _toggleLoadingState();
    try {
      final updatedRoutineLog = routineLog.copyWith(
          name: _routineNameController.text,
          notes: _routineNotesController.text,
          procedures: procedures.map((procedure) => procedure.toJson()).toList(),
          updatedAt: TemporalDateTime.now());
      await routineLogProvider.updateLog(log: updatedRoutineLog);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      _handleRoutineCreationError("Unable to update log");
    } finally {
      _toggleLoadingState();
    }
  }

  bool _isRoutinePartiallyComplete() {
    final procedureProvider = Provider.of<ProceduresProvider>(context, listen: false);
    final procedures = procedureProvider.mergeSetsIntoProcedures();
    return procedures.any((procedure) => procedure.sets.any((set) => set.checked));
  }

  List<ProcedureDto> _totalCompletedProceduresAndSets() {
    final procedureProvider = Provider.of<ProceduresProvider>(context, listen: false);
    final procedures = procedureProvider.mergeSetsIntoProcedures();
    final completedProcedures = <ProcedureDto>[];
    for (var procedure in procedures) {
      final completedSets = procedure.sets.where((set) => set.isNotEmpty() && set.checked).toList();
      if (completedSets.isNotEmpty) {
        final completedProcedure = procedure.copyWith(sets: completedSets);
        completedProcedures.add(completedProcedure);
      }
    }
    return completedProcedures;
  }

  void _endRoutineLog() {
    final isRoutinePartiallyComplete = _isRoutinePartiallyComplete();
    if (isRoutinePartiallyComplete) {
      _createRoutineLog();
    } else {
      showAlertDialog(
          context: context,
          message: "You have not completed any sets",
          leftAction: () {
            Navigator.of(context).pop();
            _navigateBackAndClearCache();
          },
          rightAction: Navigator.of(context).pop,
          leftActionLabel: 'Discard',
          isLeftActionDestructive: true,
          rightActionLabel: 'Continue');
    }
  }

  void _cacheRoutineLog() {
    if (widget.mode == RoutineEditorMode.log) {

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final procedureProvider = Provider.of<ProceduresProvider>(context, listen: false);
        final procedures = procedureProvider.mergeSetsIntoProcedures();
        final routine = widget.routine;
        Provider.of<RoutineLogProvider>(context, listen: false).cacheRoutineLog(
            name: routine?.name ?? "",
            notes: routine?.notes ?? "",
            procedures: procedures,
            startTime: _routineStartTime,
            createdAt: widget.createdAt,
            routine: routine);
      });
    }
  }

  void _checkForUnsavedChanges() {
    List<UnsavedChangesMessageDto> unsavedChangesMessage = [];
    if (widget.mode == RoutineEditorMode.edit) {
      final procedureProvider = Provider.of<ProceduresProvider>(context, listen: false);
      final procedures = widget.routine?.procedures ?? widget.routineLog?.procedures;

      final oldProcedures = procedures?.map((json) => ProcedureDto.fromJson(jsonDecode(json))).toList() ?? [];
      final newProcedures = procedureProvider.mergeSetsIntoProcedures();

      /// Check if [ProcedureDto]'s have been added or removed
      final differentProceduresChangeMessage =
          procedureProvider.hasDifferentProceduresLength(procedures1: oldProcedures, procedures2: newProcedures);
      if (differentProceduresChangeMessage != null) {
        unsavedChangesMessage.add(differentProceduresChangeMessage);
      }

      /// Check if [SetDto]'s have been added or removed
      final differentSetsChangeMessage =
          procedureProvider.hasDifferentSetsLength(procedures1: oldProcedures, procedures2: newProcedures);
      if (differentSetsChangeMessage != null) {
        unsavedChangesMessage.add(differentSetsChangeMessage);
      }

      /// Check if [SetType] for [SetDto] has been changed
      final differentSetTypesChangeMessage =
          procedureProvider.hasSetTypeChange(procedures1: oldProcedures, procedures2: newProcedures);
      if (differentSetTypesChangeMessage != null) {
        unsavedChangesMessage.add(differentSetTypesChangeMessage);
      }

      /// Check if [ExerciseType] for [Exercise] in [ProcedureDto] has been changed
      final differentExerciseTypesChangeMessage =
          procedureProvider.hasExercisesChanged(procedures1: oldProcedures, procedures2: newProcedures);
      if (differentExerciseTypesChangeMessage != null) {
        unsavedChangesMessage.add(differentExerciseTypesChangeMessage);
      }

      /// Check if superset in [ProcedureDto] has been changed
      final differentSuperSetIdsChangeMessage =
          procedureProvider.hasSuperSetIdChanged(procedures1: oldProcedures, procedures2: newProcedures);
      if (differentSuperSetIdsChangeMessage != null) {
        unsavedChangesMessage.add(differentSuperSetIdsChangeMessage);
      }

      /// Check if [SetDto] value has been changed
      final differentSetValueChangeMessage =
          procedureProvider.hasSetValueChanged(procedures1: oldProcedures, procedures2: newProcedures);
      if (differentSetValueChangeMessage != null) {
        unsavedChangesMessage.add(differentSetValueChangeMessage);
      }
      if (unsavedChangesMessage.isNotEmpty) {
        showAlertDialog(
            context: context,
            message: "You have unsaved changes",
            leftAction: Navigator.of(context).pop,
            leftActionLabel: 'Cancel',
            rightAction: () {
              Navigator.of(context).pop();

              /// Close dialog
              Navigator.of(context).pop();

              /// Navigate back
            },
            rightActionLabel: 'Discard',
            isRightActionDestructive: true);
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  void _navigateBackAndClearCache() {
    Provider.of<RoutineLogProvider>(context, listen: false).clearCachedLog();
    Navigator.of(context).pop();
  }

  bool _canUpdate() {
    final previousRoutine = widget.routine;
    final previousRoutineLog = widget.routineLog;
    return previousRoutine != null || previousRoutineLog != null;
  }

  String? _editorTitle() {
    final previousRoutine = widget.routine;
    final previousRoutineLog = widget.routineLog;

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

  @override
  Widget build(BuildContext context) {

    _cacheRoutineLog();

    final procedures = context.select((ProceduresProvider provider) => provider.procedures);

    bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom != 0;

    return Scaffold(
        backgroundColor: tealBlueDark,
        appBar: widget.mode == RoutineEditorMode.edit
            ? AppBar(
                leading: IconButton(icon: const Icon(Icons.arrow_back_outlined), onPressed: _checkForUnsavedChanges),
                actions: [
                  CTextButton(
                      onPressed: _canUpdate() ? _doUpdate : _createRoutine,
                      label: _canUpdate() ? "Update" : "Save",
                      buttonColor: Colors.transparent,
                      loading: _loading,
                      loadingLabel: _loadingLabel)
                ],
              )
            : AppBar(
                leading: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
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
                ? FloatingActionButton.extended(
                    heroTag: "fab_routine_log_editor_screen",
                    onPressed: _endRoutineLog,
                    backgroundColor: tealBlueLighter,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    label: Text("End Workout", style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
                  )
                : FloatingActionButton.extended(
                    heroTag: "fab_routine_template_editor_screen",
                    onPressed: _selectExercisesInLibrary,
                    backgroundColor: tealBlueLighter,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    label: Text("Add Exercises", style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
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
                    Consumer<ProceduresProvider>(
                        builder: (BuildContext context, ProceduresProvider provider, Widget? child) {
                      return _RoutineLogOverview(
                        sets: provider.completedSets().length,
                        timer: _RoutineTimer(
                            TemporalDateTime.now().getDateTimeInUtc().difference(_routineStartTime.getDateTimeInUtc())),
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
                          padding: const EdgeInsets.only(bottom: 150),
                          itemBuilder: (BuildContext context, int index) {
                            final procedure = procedures[index];
                            final procedureId = procedure.id;
                            return ProcedureWidget(
                                procedureDto: procedure,
                                editorType: widget.mode,
                                otherSuperSetProcedureDto:
                                    whereOtherSuperSetProcedure(context: context, firstProcedure: procedure),
                                onRemoveSuperSet: (String superSetId) =>
                                    _removeProcedureSuperSets(superSetId: procedure.superSetId),
                                onRemoveProcedure: () => _removeProcedure(procedureId: procedureId),
                                onSuperSet: () => _showProceduresPicker(firstProcedure: procedure),
                                onCache: _cacheRoutineLog,
                                onReplaceProcedure: () => _replaceProcedure(procedureId: procedureId),
                                onReOrderProcedures: _reOrderProcedures);
                          },
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemCount: procedures.length)),
                ],
              ),
            ),
          ),
        ));
  }

  @override
  void initState() {
    super.initState();

    _initializeProcedureData();
    _initializeTextControllers();

    _onDisposeCallback = Provider.of<ProceduresProvider>(context, listen: false).onClearProvider;
  }

  void _initializeProcedureData() {
    final proceduresProvider = Provider.of<ProceduresProvider>(context, listen: false);

    final procedures = widget.routine?.procedures ?? widget.routineLog?.procedures;
    if (procedures != null) {
      proceduresProvider.loadProcedures(context: context, procedures: procedures);
    }

    final routineLog = widget.routineLog;
    if (routineLog != null) {
      _routineStartTime = routineLog.startTime;
    }
  }

  void _initializeTextControllers() {
    if (widget.mode == RoutineEditorMode.edit) {
      Routine? routine = widget.routine;
      RoutineLog? routineLog = widget.routineLog;
      _routineNameController = TextEditingController(text: routine?.name ?? routineLog?.name);
      _routineNotesController = TextEditingController(text: routine?.notes ?? routineLog?.notes);
    }
  }

  @override
  void dispose() {
    _onDisposeCallback();
    if (widget.mode == RoutineEditorMode.edit) {
      _routineNameController.dispose();
      _routineNotesController.dispose();
    }
    super.dispose();
  }
}

class _ProceduresPicker extends StatelessWidget {
  final List<ProcedureDto> procedures;
  final void Function(ProcedureDto procedure) onSelect;
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
        ? Column(
            children: [
              Expanded(child: ListView(children: listTiles)),
            ],
          )
        : _ProceduresPickerEmptyState(onPressed: onSelectExercisesInLibrary);
  }
}

class _ProceduresPickerEmptyState extends StatelessWidget {
  final Function() onPressed;

  const _ProceduresPickerEmptyState({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 18.0),
            child: ListStyleEmptyState(),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.only(left: 18.0),
            child: ListStyleEmptyState(),
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
  final Duration elapsedDuration;

  const _RoutineTimer(this.elapsedDuration);

  @override
  State<_RoutineTimer> createState() => _RoutineTimerState();
}

class _RoutineTimerState extends State<_RoutineTimer> {
  late Timer _timer;
  int _elapsedSeconds = 0;

  @override
  Widget build(BuildContext context) {
    return Text(Duration(seconds: _elapsedSeconds).secondsOrMinutesOrHours(),
        style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.w600));
  }

  @override
  void initState() {
    super.initState();
    _elapsedSeconds = widget.elapsedDuration.inSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _elapsedSeconds++;
        });
      }
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
