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
import 'package:tracker_app/models/ModelProvider.dart';
import 'package:tracker_app/providers/routine_provider.dart';
import 'package:tracker_app/providers/settings_provider.dart';
import 'package:tracker_app/utils/datetime_utils.dart';
import 'package:tracker_app/utils/general_utils.dart';
import 'package:tracker_app/utils/snackbar_utils.dart';
import 'package:tracker_app/widgets/buttons/text_button_widget.dart';
import 'package:tracker_app/widgets/helper_widgets/dialog_helper.dart';
import 'package:tracker_app/screens/reorder_procedures_screen.dart';
import '../../app_constants.dart';
import '../../dtos/set_dto.dart';
import '../../providers/routine_log_provider.dart';
import '../../shared_prefs.dart';
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

  List<SetDto> _totalCompletedSets = [];

  late TextEditingController _routineNameController;
  late TextEditingController _routineNotesController;

  TemporalDateTime _routineStartTime = TemporalDateTime.now();

  Duration? _elapsedProcedureRestInterval;

  bool _loading = false;
  String _loadingLabel = "";

  void _showProceduresPicker({required ProcedureDto firstProcedure}) {
    final procedures = _whereOtherProcedures(firstProcedure: firstProcedure);
    displayBottomSheet(
        context: context,
        child: _ProceduresList(
          procedures: procedures,
          onSelect: (ProcedureDto secondProcedure) {
            _addSuperSet(firstProcedureId: firstProcedure.exercise.id, secondProcedureId: secondProcedure.exercise.id);
          },
          onSelectExercisesInLibrary: () {
            Navigator.of(context).pop();
            _selectExercisesInLibrary();
          },
        ));
  }

  /// Navigate to [ExerciseLibraryScreen]
  void _selectExercisesInLibrary() async {
    final exercises = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const ExerciseLibraryScreen())) as List<Exercise>?;

    if (exercises != null && exercises.isNotEmpty) {
      if (mounted) {
        _addProcedures(exercises: exercises);
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

  void _addProcedures({required List<Exercise> exercises}) {
    final proceduresToAdd = exercises.map((exercise) => ProcedureDto(exercise: exercise)).toList();
    setState(() {
      _procedures.addAll(proceduresToAdd);
    });

    _cacheRoutineLog();
  }

  void _removeProcedure({required String procedureId}) {
    final procedureIndex = _indexWhereProcedure(procedureId: procedureId);
    final procedureToBeRemoved = _procedures[procedureIndex];
    if (procedureToBeRemoved.superSetId.isNotEmpty) {
      _removeSuperSet(superSetId: procedureToBeRemoved.superSetId);
    }

    setState(() {
      _procedures.removeAt(procedureIndex);
    });

    _cacheRoutineLog();
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
          _removeSuperSet(superSetId: procedureToBeReplaced.superSetId);
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

  void _addSet({required String procedureId}) {
    final procedureIndex = _indexWhereProcedure(procedureId: procedureId);
    final procedure = _procedures[procedureIndex];
    final previousSet = procedure.sets.lastOrNull;
    final sets = [...procedure.sets, SetDto(reps: previousSet?.reps ?? 0, weight: previousSet?.weight ?? 0)];

    setState(() {
      _procedures[procedureIndex] = procedure.copyWith(sets: sets);
    });

    _cacheRoutineLog();
  }

  void _removeSet({required String procedureId, required int setIndex}) {
    final procedureIndex = _indexWhereProcedure(procedureId: procedureId);
    final procedure = _procedures[procedureIndex];
    final sets = [...procedure.sets];
    sets.removeAt(setIndex);

    setState(() {
      _procedures[procedureIndex] = procedure.copyWith(sets: sets);
      _calculateCompletedSets();
    });

    _cacheRoutineLog();
  }

  void _checkSet({required String procedureId, required int setIndex}) {
    final procedureIndex = _indexWhereProcedure(procedureId: procedureId);
    final procedure = _procedures[procedureIndex];
    final sets = [...procedure.sets];
    final set = sets[setIndex];
    sets[setIndex] = sets[setIndex].copyWith(checked: !set.checked);

    setState(() {
      _procedures[procedureIndex] = procedure.copyWith(sets: sets);
      _calculateCompletedSets();
      _showProcedureRestInterval(setDto: sets[setIndex], duration: procedure.restInterval);
    });

    _cacheRoutineLog();
  }

  void _showProcedureRestInterval({required SetDto setDto, required Duration duration}) {
    if (setDto.checked) {
      if (duration != Duration.zero) {
        _elapsedProcedureRestInterval = duration;
      }
    }
  }

  void _hideProcedureRestInterval() {
    _clearCachedElapsedRestInterval();
    setState(() {
      _elapsedProcedureRestInterval = null;
    });
  }

  void _updateSetRep({required String procedureId, required int setIndex, required int value}) {
    final procedureIndex = _indexWhereProcedure(procedureId: procedureId);
    final procedure = _procedures[procedureIndex];
    final sets = [...procedure.sets];
    sets[setIndex] = sets[setIndex].copyWith(reps: value);
    _procedures[procedureIndex] = procedure.copyWith(sets: sets);

    if (widget.mode == RoutineEditorType.log) {
      _calculateCompletedSets();
    }

    _cacheRoutineLog();
  }

  void _updateWeight({required String procedureId, required int setIndex, required double value}) {
    final procedureIndex = _indexWhereProcedure(procedureId: procedureId);
    final procedure = _procedures[procedureIndex];
    final sets = [...procedure.sets];
    sets[setIndex] = sets[setIndex].copyWith(weight: value);
    _procedures[procedureIndex] = procedure.copyWith(sets: sets);
    if (widget.mode == RoutineEditorType.log) {
      _calculateCompletedSets();
    }

    _cacheRoutineLog();
  }

  void _updateSetType({required String procedureId, required int setIndex, required SetType type}) {
    final procedureIndex = _indexWhereProcedure(procedureId: procedureId);
    final procedure = _procedures[procedureIndex];
    final sets = [...procedure.sets];
    sets[setIndex] = sets[setIndex].copyWith(type: type);

    setState(() {
      _procedures[procedureIndex] = procedure.copyWith(sets: sets);
    });

    _cacheRoutineLog();
  }

  void _addSuperSet({required String firstProcedureId, required String secondProcedureId}) {
    final id = "superset_id_${DateTime.now().millisecondsSinceEpoch}";

    final firstProcedureIndex = _indexWhereProcedure(procedureId: firstProcedureId);
    final firstProcedure = _procedures[firstProcedureIndex];
    final secondProcedureIndex = _indexWhereProcedure(procedureId: secondProcedureId);
    final secondProcedure = _procedures[secondProcedureIndex];

    setState(() {
      _procedures[firstProcedureIndex] = firstProcedure.copyWith(superSetId: id);
      _procedures[secondProcedureIndex] = secondProcedure.copyWith(superSetId: id);
    });

    _cacheRoutineLog();
  }

  void _removeSuperSet({required String superSetId}) {
    for (var procedure in _procedures) {
      if (procedure.superSetId == superSetId) {
        final procedureIndex = _indexWhereProcedure(procedureId: procedure.exercise.id);
        setState(() {
          _procedures[procedureIndex] = procedure.copyWith(superSetId: "");
        });
      }
    }
    _cacheRoutineLog();
  }

  List<ProcedureDto> _whereOtherProcedures({required ProcedureDto firstProcedure}) {
    return _procedures
        .whereNot((procedure) => procedure.exercise.id == firstProcedure.exercise.id || procedure.superSetId.isNotEmpty)
        .toList();
  }

  void _showRestIntervalTimePicker({required ProcedureDto procedure}) {
    displayBottomSheet(
        context: context,
        child: _TimerPicker(
          initialDuration: procedure.restInterval,
          onSelect: (Duration duration) {
            Navigator.of(context).pop();
            _setRestInterval(procedureId: procedure.exercise.id, duration: duration);
          },
        ));
  }

  void _setRestInterval({required String procedureId, required Duration duration}) {
    final procedureIndex = _indexWhereProcedure(procedureId: procedureId);
    final procedure = _procedures[procedureIndex];

    setState(() {
      _procedures[procedureIndex] = procedure.copyWith(restInterval: duration);
    });

    _cacheRoutineLog();
  }

  void _removeRestInterval({required String procedureId}) {
    final procedureIndex = _indexWhereProcedure(procedureId: procedureId);
    final procedure = _procedures[procedureIndex];

    setState(() {
      _procedures[procedureIndex] = procedure.copyWith(restInterval: Duration.zero);
    });

    _cacheRoutineLog();
  }

  void _toggleLoadingState() {
    setState(() {
      _loading = !_loading;
      _loadingLabel = _canUpdate() ? "Updating" : "Creating";
    });
  }

  void _createRoutine() async {
    if (_routineNameController.text.isEmpty) {
      showSnackbar(
          context: context, icon: const Icon(Icons.info_outline), message: 'Please provide a name for this workout');
    } else if (_procedures.isEmpty) {
      showSnackbar(context: context, icon: const Icon(Icons.info_outline), message: "Workout must have exercise(s)");
    } else {
      _toggleLoadingState();
      try {
        await Provider.of<RoutineProvider>(context, listen: false).saveRoutine(
            name: _routineNameController.text, notes: _routineNotesController.text, procedures: _procedures);
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          showSnackbar(context: context, icon: const Icon(Icons.info_outline), message: "Unable to create workout");
        }
      } finally {
        _toggleLoadingState();
      }
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
    if (_routineNameController.text.isEmpty) {
      showSnackbar(
          context: context, message: 'Please provide a name for this workout', icon: const Icon(Icons.info_outline));
    } else if (_procedures.isEmpty) {
      showSnackbar(context: context, message: "Workout must have exercise(s)", icon: const Icon(Icons.info_outline));
    } else {
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
  }

  void _updateRoutineLog({required RoutineLog routineLog}) {
    if (_routineNameController.text.isEmpty) {
      showSnackbar(
          context: context, message: 'Please provide a name for this workout', icon: const Icon(Icons.info_outline));
    } else if (_procedures.isEmpty) {
      showSnackbar(context: context, message: "Workout must have exercise(s)", icon: const Icon(Icons.info_outline));
    } else {
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
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        showSnackbar(
            context: context, icon: const Icon(Icons.info_outline), message: "Oops! we are unable to save changes");
      }
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
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        showSnackbar(
            context: context, icon: const Icon(Icons.info_outline), message: "Oops! we are unable to save changes");
      }
    } finally {
      _toggleLoadingState();
    }
  }

  void _calculateCompletedSets() {
    List<SetDto> completedSets = [];
    for (var procedure in _procedures) {
      final sets = procedure.sets.where((set) => set.checked).toList();
      completedSets.addAll(sets);
    }
    setState(() {
      _totalCompletedSets = completedSets;
    });
  }

  double _totalWeight() {
    double totalWeight = 0;
    for (var set in _totalCompletedSets) {
      final weightPerSet = set.reps * set.weight;
      totalWeight += weightPerSet;
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

  void _clearCachedElapsedRestInterval() {
    SharedPrefs().cachedRoutineRestInterval = 0;
  }

  void _cacheElapsedRestInterval({required int elapsedTime}) {
    if (widget.mode == RoutineEditorType.log) {
      SharedPrefs().cachedRoutineRestInterval = elapsedTime;
    }
  }

  void _cachedElapsedRestInterval() {
    if (widget.mode == RoutineEditorType.log) {
      final elapsedRestIntervalDuration = SharedPrefs().cachedRoutineRestInterval;
      if (elapsedRestIntervalDuration > 0) {
        setState(() {
          _elapsedProcedureRestInterval = Duration(seconds: elapsedRestIntervalDuration);
        });
      }
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
    final elapsedRestInterval = _elapsedProcedureRestInterval;

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
                ? FloatingActionButton(
                    heroTag: "fab_routine_editor_screen",
                    onPressed: _endRoutineLog,
                    backgroundColor: tealBlueLighter,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    child: const Icon(Icons.stop),
                  )
                : null
            : null,
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
                      sets: _totalCompletedSets.length,
                      weight: _totalWeight(),
                      timer: _TimerWidget(
                          TemporalDateTime.now().getDateTimeInUtc().difference(_routineStartTime.getDateTimeInUtc())),
                    ),
                  if (elapsedRestInterval != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: _IntervalTimer(
                        duration: elapsedRestInterval,
                        onElapsed: () => _hideProcedureRestInterval(),
                        onTick: (int seconds) => _cacheElapsedRestInterval(elapsedTime: seconds),
                      ),
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
                  Expanded(
                      child: ListView.separated(
                          itemBuilder: (BuildContext context, int index) {
                            final procedure = _procedures[index];
                            return ProcedureWidget(
                              procedureDto: _procedures[index],
                              editorType: widget.mode,
                              otherSuperSetProcedureDto:
                                  whereOtherSuperSetProcedure(firstProcedure: procedure, procedures: _procedures),
                              onRemoveSuperSet: (String superSetId) =>
                                  _removeSuperSet(superSetId: procedure.superSetId),
                              onRemoveProcedure: () => _removeProcedure(procedureId: procedure.exercise.id),
                              onSuperSet: () => _showProceduresPicker(firstProcedure: procedure),
                              onChangedSetRep: (int setIndex, int value) =>
                                  _updateSetRep(procedureId: procedure.exercise.id, setIndex: setIndex, value: value),
                              onChangedSetWeight: (int setIndex, double value) =>
                                  _updateWeight(procedureId: procedure.exercise.id, setIndex: setIndex, value: value),
                              onChangedSetType: (int setIndex, SetType type) =>
                                  _updateSetType(procedureId: procedure.exercise.id, setIndex: setIndex, type: type),
                              onAddSet: () => _addSet(procedureId: procedure.exercise.id),
                              onRemoveSet: (int setIndex) =>
                                  _removeSet(procedureId: procedure.exercise.id, setIndex: setIndex),
                              onUpdateNotes: (String value) =>
                                  _updateProcedureNotes(procedureId: procedure.exercise.id, value: value),
                              onReplaceProcedure: () => _replaceProcedure(procedureId: procedure.exercise.id),
                              onSetRestInterval: () => _showRestIntervalTimePicker(procedure: procedure),
                              onRemoveProcedureTimer: () => _removeRestInterval(procedureId: procedure.exercise.id),
                              onReOrderProcedures: () => _reOrderProcedures(),
                              onCheckSet: (int setIndex) =>
                                  _checkSet(procedureId: procedure.exercise.id, setIndex: setIndex),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 10),
                          itemCount: _procedures.length)),
                  if (widget.mode == RoutineEditorType.edit)
                    SizedBox(
                      width: double.infinity,
                      child: CTextButton(onPressed: _selectExercisesInLibrary, label: "Select Exercises"),
                    ),
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
        _cachedElapsedRestInterval();
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

class _ProceduresList extends StatefulWidget {
  final List<ProcedureDto> procedures;
  final void Function(ProcedureDto procedure) onSelect;
  final void Function() onSelectExercisesInLibrary;

  const _ProceduresList({required this.procedures, required this.onSelect, required this.onSelectExercisesInLibrary});

  @override
  State<_ProceduresList> createState() => _ProceduresListState();
}

class _ProceduresListState extends State<_ProceduresList> {
  late ProcedureDto? _procedure;

  @override
  Widget build(BuildContext context) {
    return widget.procedures.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  final procedure = _procedure;
                  if (procedure != null) {
                    Navigator.of(context).pop();
                    widget.onSelect(procedure);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Text(
                    "Select",
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ),
              Flexible(
                child: CupertinoPicker(
                  magnification: 1.22,
                  squeeze: 1.2,
                  useMagnifier: true,
                  itemExtent: 32.0,
                  // This is called when selected item is changed.
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      _procedure = widget.procedures[index];
                    });
                  },
                  children: List<Widget>.generate(widget.procedures.length, (int index) {
                    return Center(
                        child: Text(
                      widget.procedures[index].exercise.name,
                      style: GoogleFonts.lato(color: Colors.white),
                    ));
                  }),
                ),
              ),
            ],
          )
        : _ExercisesInWorkoutEmptyState(onPressed: widget.onSelectExercisesInLibrary);
  }

  @override
  void initState() {
    super.initState();
    _procedure = widget.procedures.firstOrNull;
  }
}

class _TimerPicker extends StatefulWidget {
  final Duration? initialDuration;
  final void Function(Duration duration) onSelect;

  const _TimerPicker({required this.onSelect, required this.initialDuration});

  @override
  State<_TimerPicker> createState() => _TimerPickerState();
}

class _TimerPickerState extends State<_TimerPicker> {
  late Duration _duration;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () => widget.onSelect(_duration),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Text(
              "Select",
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        ),
        Flexible(
          child: CupertinoTheme(
            data: const CupertinoThemeData(
              brightness: Brightness.dark,
            ),
            child: CupertinoTimerPicker(
              initialTimerDuration: _duration,
              backgroundColor: tealBlueLight,
              mode: CupertinoTimerPickerMode.ms,
              // This is called when the user changes the timer's
              // duration.
              onTimerDurationChanged: (Duration newDuration) {
                setState(() => _duration = newDuration);
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    final previousDuration = widget.initialDuration;
    _duration = previousDuration ?? Duration.zero;
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
  final Duration elapsedTime;

  const _TimerWidget(this.elapsedTime);

  @override
  State<_TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<_TimerWidget> {
  late Timer _timer;
  int _elapsedTime = 0;

  @override
  Widget build(BuildContext context) {
    return Text(Duration(seconds: _elapsedTime).secondsOrMinutesOrHours(),
        style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.w600));
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedTime = widget.elapsedTime.inSeconds + timer.tick;
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
              Consumer<SettingsProvider>(
                builder: (_, provider, __) {
                  final value = provider.isLbs ? toLbs(weight) : weight;
                  return Text("$value",
                      style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16));
                },
              ),
              timer
            ])
          ],
        ));
  }
}

class _IntervalTimer extends StatefulWidget {
  final Duration duration;
  final void Function(int seconds) onTick;
  final void Function() onElapsed;

  const _IntervalTimer({required this.duration, required this.onTick, required this.onElapsed});

  @override
  State<_IntervalTimer> createState() => _IntervalTimerState();
}

class _IntervalTimerState extends State<_IntervalTimer> {
  late Timer _timer;
  int _duration = 0;

  void _addSeconds() {
    setState(() {
      _duration += 5;
    });
  }

  void _subtractSeconds() {
    setState(() {
      _duration -= 5;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10, right: 10, bottom: 10, left: 10),
      decoration: BoxDecoration(
        color: tealBlueLighter, // Set the background color
        borderRadius: BorderRadius.circular(2), // Set the border radius to make it rounded
      ),
      child: Row(
        children: [
          CTextButton(
            onPressed: _subtractSeconds,
            label: "-5",
            textStyle: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(width: 5),
          CTextButton(
            onPressed: _addSeconds,
            label: "+5",
            textStyle: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Text(Duration(seconds: _duration).secondsOrMinutesOrHours(),
              style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
          const Spacer(),
          CTextButton(
            onPressed: widget.onElapsed,
            label: "Skip",
            buttonColor: Colors.red,
            textStyle: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _duration = widget.duration.inSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_duration > 0) {
          _duration--;
          widget.onTick(_duration);
        } else {
          _timer.cancel();
          widget.onElapsed();
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }
}
