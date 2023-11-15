import 'dart:async';
import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/procedure_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/models/ModelProvider.dart';
import 'package:tracker_app/providers/procedures_provider.dart';
import 'package:tracker_app/providers/routine_provider.dart';
import 'package:tracker_app/utils/datetime_utils.dart';
import 'package:tracker_app/utils/general_utils.dart';
import 'package:tracker_app/utils/snackbar_utils.dart';
import 'package:tracker_app/widgets/buttons/text_button_widget.dart';
import 'package:tracker_app/widgets/helper_widgets/dialog_helper.dart';
import 'package:tracker_app/screens/reorder_procedures_screen.dart';
import '../../app_constants.dart';
import '../../dtos/set_dto.dart';
import '../../dtos/double_num_pair.dart';
import '../../providers/routine_log_provider.dart';
import '../../widgets/empty_states/list_tile_empty_state.dart';
import '../../widgets/helper_widgets/routine_helper.dart';
import '../../widgets/routine/editor/procedure_widget.dart';
import '../exercise/exercise_library_screen.dart';

enum RoutineEditorType { edit, log }

class RoutineEditorScreen extends StatefulWidget {
  final Routine? routine;
  final RoutineLog? routineLog;
  final RoutineEditorType mode;
  final TemporalDateTime? createdAt;

  const RoutineEditorScreen(
      {super.key, this.routine, this.routineLog, this.mode = RoutineEditorType.edit, this.createdAt});

  @override
  State<RoutineEditorScreen> createState() => _RoutineEditorScreenState();
}

class _RoutineEditorScreenState extends State<RoutineEditorScreen> {
  List<ProcedureDto> _procedures = [];

  List<SetDto> _completedSets = [];

  late TextEditingController _routineNameController;
  late TextEditingController _routineNotesController;

  TemporalDateTime _routineStartTime = TemporalDateTime.now();

  bool _loading = false;
  String _loadingLabel = "";

  void _showProceduresPicker({required ProcedureDto firstProcedure}) {
    final procedures = _whereOtherProceduresExcept(firstProcedure: firstProcedure);
    displayBottomSheet(
        context: context,
        child: _ProceduresList(
          procedures: procedures,
          onSelect: (ProcedureDto secondProcedure) {
            Navigator.of(context).pop();
            Provider.of<ProceduresProvider>(context, listen: false).superSetProcedures(
                firstExerciseId: firstProcedure.exercise.id, secondExerciseId: secondProcedure.exercise.id);
            _cacheRoutineLog();
          },
          onSelectExercisesInLibrary: () {
            Navigator.of(context).pop();
            _selectExercisesInLibrary();
          },
        ));
  }

  /// Navigate to [ExerciseLibraryScreen]
  void _selectExercisesInLibrary() async {
    final preSelectedExercises = _procedures.map((procedure) => procedure.exercise).toList();

    final exercises = await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ExerciseLibraryScreen(preSelectedExercises: preSelectedExercises)))
        as List<Exercise>?;

    if (exercises != null && exercises.isNotEmpty) {
      if (mounted) {
        Provider.of<ProceduresProvider>(context, listen: false).addProcedures(exercises: exercises);
        _cacheRoutineLog();
      }
    }
  }

  // Navigate to [ReOrderProceduresScreen]
  void _reOrderProcedures() async {
    final reOrderedList = await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return ReOrderProceduresScreen(procedures: _procedures);
      },
    ) as List<ProcedureDto>?;

    if (reOrderedList != null) {
      if (mounted) {
        setState(() {
          _procedures = reOrderedList;
        });
      }
      _cacheRoutineLog();
    }
  }

  void _updateProcedureNotes({required String procedureId, required String value}) {
    final procedureIndex = _indexWhereProcedure(procedureId: procedureId);
    final procedure = _procedures[procedureIndex];
    _procedures[procedureIndex] = procedure.copyWith(notes: value);
    _cacheRoutineLog();
  }

  void _replaceProcedure({required String procedureId}) {
    final procedureIndex = _indexWhereProcedure(procedureId: procedureId);
    final procedureToBeReplaced = _procedures[procedureIndex];
    if (procedureToBeReplaced.isNotEmpty()) {
      _showReplaceProcedureAlert(procedureId: procedureId);
    } else {
      _doReplaceProcedure(procedureId: procedureId);
    }
  }

  void _showReplaceProcedureAlert({required String procedureId}) {
    final alertDialogActions = <Widget>[
      TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text('Cancel', style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      TextButton(
        onPressed: () {
          Navigator.pop(context);
          _doReplaceProcedure(procedureId: procedureId);
        },
        child: Text('Replace', style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.red)),
      )
    ];

    showAlertDialog(context: context, message: "All your data will be replaced", actions: alertDialogActions);
  }

  void _doReplaceProcedure({required String procedureId}) async {
    final selectedExercises = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const ExerciseLibraryScreen())) as List<Exercise>?;

    if (selectedExercises != null) {
      if (mounted) {
        final procedureIndex = _indexWhereProcedure(procedureId: procedureId);
        final procedureToBeReplaced = _procedures[procedureIndex];
        if (procedureToBeReplaced.superSetId.isNotEmpty) {
          //_removeSuperSet(superSetId: procedureToBeReplaced.superSetId);
        }

        final selectedExercise = selectedExercises.first;
        final oldProcedureIndex = _indexWhereProcedure(procedureId: procedureId);
        setState(() {
          _procedures[oldProcedureIndex] = ProcedureDto(exercise: selectedExercise);
        });
      }
      _cacheRoutineLog();
    }
  }

  int _indexWhereProcedure({required String procedureId}) {
    return _procedures.indexWhere((procedure) => procedure.exercise.id == procedureId);
  }

  void _removeProcedureSuperSets({required String superSetId}) {
    Provider.of<ProceduresProvider>(context, listen: false).removeProcedureSuperSet(superSetId: superSetId);
    _cacheRoutineLog();
  }

  void _removeProcedure({required String procedureId}) {
    Provider.of<ProceduresProvider>(context, listen: false).removeProcedure(exerciseId: procedureId);
    _calculateCompletedSets();
    _cacheRoutineLog();
  }

  void _addSet({required String exerciseId}) {
    _dismissKeyboard();
    Provider.of<ProceduresProvider>(context, listen: false).addSetForProcedure(exerciseId: exerciseId);
    _cacheRoutineLog();
  }

  void _removeSet({required String exerciseId, required int setIndex}) {
    Provider.of<ProceduresProvider>(context, listen: false)
        .removeSetForProcedure(exerciseId: exerciseId, setIndex: setIndex);
    _calculateCompletedSets();
    _cacheRoutineLog();
  }

  void _updateWeight({required String exerciseId, required int setIndex, required double value}) {
    Provider.of<ProceduresProvider>(context, listen: false)
        .updateWeight(exerciseId: exerciseId, setIndex: setIndex, value: value);
    _calculateCompletedSets();
    _cacheRoutineLog();
  }

  void _updateReps({required String exerciseId, required int setIndex, required num value}) {
    Provider.of<ProceduresProvider>(context, listen: false)
        .updateReps(exerciseId: exerciseId, setIndex: setIndex, value: value);
    _calculateCompletedSets();
    _cacheRoutineLog();
  }

  void _updateDuration({required String exerciseId, required int setIndex, required Duration duration}) {
    Provider.of<ProceduresProvider>(context, listen: false)
        .updateDuration(exerciseId: exerciseId, setIndex: setIndex, duration: duration);
    _calculateCompletedSets();
    _cacheRoutineLog();
  }

  void _updateDistance({required String exerciseId, required int setIndex, required double distance}) {
    Provider.of<ProceduresProvider>(context, listen: false)
        .updateDistance(exerciseId: exerciseId, setIndex: setIndex, distance: distance);
    _calculateCompletedSets();
    _cacheRoutineLog();
  }

  void _updateSetType({required String exerciseId, required int setIndex, required SetType type}) {
    Provider.of<ProceduresProvider>(context, listen: false)
        .updateSetType(exerciseId: exerciseId, setIndex: setIndex, type: type);
    _calculateCompletedSets();
    _cacheRoutineLog();
  }

  void _checkSet({required String exerciseId, required int setIndex}) {
    _dismissKeyboard();

    Provider.of<ProceduresProvider>(context, listen: false).checkSet(procedureId: exerciseId, setIndex: setIndex);
    _calculateCompletedSets();
    _cacheRoutineLog();
  }

  List<ProcedureDto> _whereOtherProceduresExcept({required ProcedureDto firstProcedure}) {
    return Provider.of<ProceduresProvider>(context, listen: false)
        .procedures
        .whereNot((procedure) => procedure.exercise.id == firstProcedure.exercise.id || procedure.superSetId.isNotEmpty)
        .toList();
  }

  void _toggleLoadingState() {
    setState(() {
      _loading = !_loading;
      _loadingLabel = _canUpdate() ? "Updating" : "Creating";
    });
  }

  bool _validateRoutineInputs() {
    if (_routineNameController.text.isEmpty) {
      _showSnackbar('Please provide a name for this workout');
      return false;
    }
    if (_procedures.isEmpty) {
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
      // Optionally log the error e for debugging
    }
  }

  void _createRoutine() async {
    if (!_validateRoutineInputs()) return;
    _toggleLoadingState();
    try {
      await Provider.of<RoutineProvider>(context, listen: false)
          .saveRoutine(name: _routineNameController.text, notes: _routineNotesController.text, procedures: _procedures);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      _handleRoutineCreationError("Unable to create workout");
    } finally {
      _toggleLoadingState();
    }
  }

  void _createRoutineLog() {
    final actions = <Widget>[
      TextButton(
        onPressed: () {
          Navigator.pop(context);
          _navigateBackAndClearCache();
        },
        child: Text('Discard workout', style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.red)),
      ),
      TextButton(
        onPressed: () {
          Navigator.pop(context);
          final routine = widget.routine;
          final completedProcedures = _totalCompletedProceduresAndSets();
          Provider.of<RoutineLogProvider>(context, listen: false).saveRoutineLog(
              name: routine?.name ?? "${DateTime.now().timeOfDay()} Workout",
              notes: routine?.notes ?? "",
              procedures: completedProcedures,
              startTime: _routineStartTime,
              createdAt: widget.createdAt,
              routine: routine);
          Navigator.of(context).pop();
        },
        child: Text('Finish', style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white)),
      )
    ];
    showAlertDialog(context: context, message: "Finish workout?", actions: actions);
  }

  void _updateRoutine({required Routine routine}) {
    if (!_validateRoutineInputs()) return;

    final alertDialogActions = <Widget>[
      TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text('Cancel', style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      CTextButton(
          onPressed: () {
            Navigator.pop(context);
            _doUpdateRoutine(routine: routine);
          },
          label: "Update")
    ];
    showAlertDialog(context: context, message: "Update workout?", actions: alertDialogActions);
  }

  void _updateRoutineLog({required RoutineLog routineLog}) {
    if (!_validateRoutineInputs()) return;

    final alertDialogActions = <Widget>[
      TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text('Cancel', style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      CTextButton(
          onPressed: () {
            Navigator.pop(context);
            _doUpdateRoutineLog(routineLog: routineLog);
          },
          label: 'Update'),
    ];
    showAlertDialog(context: context, message: "Update log?", actions: alertDialogActions);
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
    _toggleLoadingState();
    try {
      final updatedRoutine = routine.copyWith(
          name: _routineNameController.text,
          notes: _routineNotesController.text,
          procedures: _procedures.map((procedure) => procedure.toJson()).toList(),
          updatedAt: TemporalDateTime.now());

      await Provider.of<RoutineProvider>(context, listen: false).updateRoutine(routine: updatedRoutine);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      _handleRoutineCreationError("Unable to update workout");
    } finally {
      _toggleLoadingState();
    }
  }

  void _doUpdateRoutineLog({required RoutineLog routineLog}) async {
    _toggleLoadingState();
    try {
      final updatedRoutineLog = routineLog.copyWith(
          name: _routineNameController.text,
          notes: _routineNotesController.text,
          procedures: _procedures.map((procedure) => procedure.toJson()).toList(),
          updatedAt: TemporalDateTime.now());
      await Provider.of<RoutineLogProvider>(context, listen: false).updateLog(log: updatedRoutineLog);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      _handleRoutineCreationError("Unable to update log");
    } finally {
      _toggleLoadingState();
    }
  }

  void _calculateCompletedSets() {
    if (widget.mode == RoutineEditorType.log) {
      setState(() {
        _completedSets = _procedures.expand((procedure) => procedure.sets).where((set) => set.checked).toList();
      });
    }
  }

  double _totalWeight() {
    double totalWeight = 0.0;

    for (var procedure in _procedures) {
      final exerciseType = ExerciseType.fromString(procedure.exercise.type);

      for (var set in procedure.sets) {
        if (set.checked) {
          double weightPerSet = 0.0;

          if (exerciseType == ExerciseType.weightAndReps || exerciseType == ExerciseType.weightedBodyWeight) {
            weightPerSet = (set as DoubleNumPair).value1 * set.value2;
          }

          // Add cases for other exercise types if needed

          totalWeight += weightPerSet;
        }
      }
    }

    return totalWeight;
  }

  bool _isRoutinePartiallyComplete() {
    return _procedures.any((procedure) => procedure.sets.any((set) => set.checked));
  }

  List<ProcedureDto> _totalCompletedProceduresAndSets() {
    final completedProcedures = <ProcedureDto>[];
    for (var procedure in _procedures) {
      final completedSets = procedure.sets.where((set) => set.checked).toList();
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
      final actions = <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            _navigateBackAndClearCache();
          },
          child: Text('Discard', style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.red)),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Continue', style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white)),
        )
      ];
      showAlertDialog(context: context, message: "You have not completed any sets", actions: actions);
    }
  }

  void _cacheRoutineLog() {
    if (widget.mode == RoutineEditorType.log) {
      final routine = widget.routine;
      Provider.of<RoutineLogProvider>(context, listen: false).cacheRoutineLog(
          name: routine?.name ?? "",
          notes: routine?.notes ?? "",
          procedures: _procedures,
          startTime: _routineStartTime,
          createdAt: widget.createdAt,
          routine: routine);
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
    return Scaffold(
        backgroundColor: tealBlueDark,
        appBar: widget.mode == RoutineEditorType.edit
            ? AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_outlined),
                  onPressed: () => Navigator.of(context).pop(),
                ),
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
        floatingActionButton: widget.mode == RoutineEditorType.log
            ? MediaQuery.of(context).viewInsets.bottom <= 0
                ? FloatingActionButton.extended(
                    heroTag: "fab_routine_log_editor_screen",
                    onPressed: _endRoutineLog,
                    backgroundColor: tealBlueLighter,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    label: Text("End Workout", style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
                  )
                : null
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
                  if (widget.mode == RoutineEditorType.log)
                    RunningRoutineSummaryWidget(
                      sets: _completedSets.length,
                      weight: _totalWeight(),
                      timer: _TimerWidget(
                          TemporalDateTime.now().getDateTimeInUtc().difference(_routineStartTime.getDateTimeInUtc())),
                    ),
                  if (widget.mode == RoutineEditorType.edit)
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
                  Expanded(child: Consumer<ProceduresProvider>(
                    builder: (BuildContext context, ProceduresProvider value, Widget? child) {
                      final procedures = value.procedures;
                      return ListView.separated(
                          itemBuilder: (BuildContext context, int index) {
                            final procedure = procedures[index];
                            final exerciseId = procedure.exercise.id;
                            return ProcedureWidget(
                              procedureDto: procedure,
                              editorType: widget.mode,
                              otherSuperSetProcedureDto:
                                  whereOtherSuperSetProcedure(context: context, firstProcedure: procedure),
                              onRemoveSuperSet: (String superSetId) =>
                                  _removeProcedureSuperSets(superSetId: procedure.superSetId),
                              onRemoveProcedure: () => _removeProcedure(procedureId: procedure.exercise.id),
                              onSuperSet: () => _showProceduresPicker(firstProcedure: procedure),
                              onChangedReps: (int setIndex, num value) =>
                                  _updateReps(exerciseId: exerciseId, setIndex: setIndex, value: value),
                              onChangedWeight: (int setIndex, double value) =>
                                  _updateWeight(exerciseId: exerciseId, setIndex: setIndex, value: value),
                              onChangedSetType: (int setIndex, SetType type) =>
                                  _updateSetType(exerciseId: exerciseId, setIndex: setIndex, type: type),
                              onAddSet: () => _addSet(exerciseId: exerciseId),
                              onRemoveSet: (int setIndex) => _removeSet(exerciseId: exerciseId, setIndex: setIndex),
                              onUpdateNotes: (String value) =>
                                  _updateProcedureNotes(procedureId: exerciseId, value: value),
                              onReplaceProcedure: () => _replaceProcedure(procedureId: exerciseId),
                              onReOrderProcedures: () => _reOrderProcedures(),
                              onCheckSet: (int setIndex) => _checkSet(exerciseId: exerciseId, setIndex: setIndex),
                              onChangedDuration: (int setIndex, Duration duration) =>
                                  _updateDuration(exerciseId: exerciseId, setIndex: setIndex, duration: duration),
                              onChangedDistance: (int setIndex, double distance) =>
                                  _updateDistance(exerciseId: exerciseId, setIndex: setIndex, distance: distance),
                            );
                          },
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemCount: procedures.length);
                    },
                  )),
                ],
              ),
            ),
          ),
        ));
  }

  @override
  void initState() {
    super.initState();

    final previousRoutine = widget.routine;
    final previousRoutineLog = widget.routineLog;

    /// In [RoutineEditorMode.editing] mode
    if (widget.mode == RoutineEditorType.edit) {
      if (previousRoutine != null) {
        _procedures
            .addAll([...previousRoutine.procedures.map((json) => ProcedureDto.fromJson(jsonDecode(json))).toList()]);
      } else {
        if (previousRoutineLog != null) {
          _procedures.addAll(
              [...previousRoutineLog.procedures.map((json) => ProcedureDto.fromJson(jsonDecode(json))).toList()]);
        }
      }
    } else {
      /// In [RoutineEditorMode.routine] mode
      if (previousRoutineLog != null) {
        _procedures
            .addAll([...previousRoutineLog.procedures.map((json) => ProcedureDto.fromJson(jsonDecode(json))).toList()]);
        _routineStartTime = previousRoutineLog.startTime;
      } else if (previousRoutine != null) {
        _procedures
            .addAll([...previousRoutine.procedures.map((json) => ProcedureDto.fromJson(jsonDecode(json))).toList()]);
      }
    }

    if (widget.mode == RoutineEditorType.edit) {
      if (previousRoutineLog != null) {
        _routineNameController = TextEditingController(text: previousRoutineLog.name);
        _routineNotesController = TextEditingController(text: previousRoutineLog.notes);
      } else {
        _routineNameController = TextEditingController(text: previousRoutine?.name);
        _routineNotesController = TextEditingController(text: previousRoutine?.notes);
      }
    }

    if (widget.mode == RoutineEditorType.log) {
      /// Show progress of resumed routine
      /// Show any previous running timers
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _calculateCompletedSets();
      });

      /// Cache initial state of running routine
      _cacheRoutineLog();
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.mode == RoutineEditorType.edit) {
      _routineNameController.dispose();
      _routineNotesController.dispose();
    }
  }
}

class _ProceduresList extends StatelessWidget {
  final List<ProcedureDto> procedures;
  final void Function(ProcedureDto procedure) onSelect;
  final void Function() onSelectExercisesInLibrary;

  const _ProceduresList({required this.procedures, required this.onSelect, required this.onSelectExercisesInLibrary});

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
        : _ExercisesInWorkoutEmptyState(onPressed: onSelectExercisesInLibrary);
  }
}

class _ExercisesInWorkoutEmptyState extends StatelessWidget {
  final Function() onPressed;

  const _ExercisesInWorkoutEmptyState({required this.onPressed});

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
              child: CTextButton(onPressed: onPressed, label: "Add more exercises"),
            ),
          )
        ],
      ),
    );
  }
}

class _TimerWidget extends StatefulWidget {
  final Duration elapsedDuration;

  const _TimerWidget(this.elapsedDuration);

  @override
  State<_TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<_TimerWidget> {
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

class RunningRoutineSummaryWidget extends StatelessWidget {
  final int sets;
  final double weight;
  final Widget timer;

  const RunningRoutineSummaryWidget({super.key, required this.sets, required this.weight, required this.timer});

  @override
  Widget build(BuildContext context) {
    final value = isDefaultWeightUnit() ? weight : toLbs(weight);

    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Table(
          columnWidths: const <int, TableColumnWidth>{
            0: FixedColumnWidth(55),
            1: FlexColumnWidth(),
            2: FlexColumnWidth(),
          },
          children: [
            TableRow(children: [
              Text("Sets", style: GoogleFonts.lato(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
              Text("Volume", style: GoogleFonts.lato(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
              Text("Duration",
                  style: GoogleFonts.lato(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500))
            ]),
            TableRow(children: [
              Text("$sets", style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
              Text("$value", style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
              timer
            ])
          ],
        ));
  }
}
