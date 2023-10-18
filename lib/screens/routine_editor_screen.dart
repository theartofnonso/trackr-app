import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/procedure_dto.dart';
import 'package:tracker_app/providers/routine_provider.dart';
import 'package:tracker_app/utils/datetime_utils.dart';
import 'package:tracker_app/widgets/helper_widgets/dialog_helper.dart';
import 'package:tracker_app/screens/reorder_procedures_screen.dart';
import '../app_constants.dart';
import '../dtos/set_dto.dart';
import '../models/Exercise.dart';
import '../models/Routine.dart';
import '../providers/routine_log_provider.dart';
import '../widgets/empty_states/list_tile_empty_state.dart';
import '../widgets/workout/editor/procedure_widget.dart';
import 'exercise_library_screen.dart';

enum RoutineEditorMode { editing, routine }

class RoutineEditorScreen extends StatefulWidget {
  final Routine? routine;
  final RoutineEditorMode mode;

  const RoutineEditorScreen({super.key, this.routine, this.mode = RoutineEditorMode.editing});

  @override
  State<RoutineEditorScreen> createState() => _RoutineEditorScreenState();
}

class _RoutineEditorScreenState extends State<RoutineEditorScreen> {
  final _scrollController = ScrollController();

  List<ProcedureDto> _procedures = [];

  late TextEditingController _workoutNameController;
  late TextEditingController _workoutNotesController;

  Duration? _routineDuration;
  
  late DateTime _routineStartTime;

  /// Show [CupertinoAlertDialog] for creating a workout
  void _showAlertDialog(
      {required String title, required String message, required List<CupertinoDialogAction> actions}) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: actions,
      ),
    );
  }

  void _showProceduresPicker({required ProcedureDto firstProcedure}) {
    final procedures = _whereOtherProcedures(firstProcedure: firstProcedure);
    showModalPopup(
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
    final exercisesFromLibrary = await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return ExerciseLibraryScreen(
            preSelectedExercises: _procedures.map((procedure) => procedure.exercise).toList());
      },
    ) as List<Exercise>?;

    if (exercisesFromLibrary != null) {
      if (mounted) {
        _addProcedures(exercises: exercisesFromLibrary);
      }
    }
  }

  // Navigate to [ReOrderProcedures]
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
    }
  }

  void _scrollToBottom() {
    var scrollPosition = _scrollController.position;

    if (scrollPosition.viewportDimension > scrollPosition.maxScrollExtent) {
      var scrollPosition = _scrollController.position;
      _scrollController.animateTo(
        scrollPosition.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  void _addProcedures({required List<Exercise> exercises}) {
    final proceduresToAdd = exercises.map((exercise) => ProcedureDto(exercise: exercise)).toList();
    setState(() {
      _procedures.addAll(proceduresToAdd);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
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
  }

  void _updateProcedureNotes({required String procedureId, required String value}) {
    final procedureIndex = _indexWhereProcedure(procedureId: procedureId);
    final procedure = _procedures[procedureIndex];
    _procedures[procedureIndex] = procedure.copyWith(notes: value);
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
    final alertDialogActions = <CupertinoDialogAction>[
      CupertinoDialogAction(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text('Cancel', style: TextStyle(color: CupertinoColors.black)),
      ),
      CupertinoDialogAction(
        isDestructiveAction: true,
        onPressed: () {
          Navigator.pop(context);
          _doReplaceProcedure(procedureId: procedureId);
        },
        child: const Text('Replace'),
      )
    ];

    _showAlertDialog(title: "Replace Exercise", message: "All your data will be replaced", actions: alertDialogActions);
  }

  void _doReplaceProcedure({required String procedureId}) async {
    final selectedExercises = await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return ExerciseLibraryScreen(
            preSelectedExercises: _procedures.map((procedure) => procedure.exercise).toList(), multiSelect: false);
      },
    ) as List<Exercise>?;

    if (selectedExercises != null) {
      if (mounted) {
        final procedureIndex = _indexWhereProcedure(procedureId: procedureId);
        final procedureToBeReplaced = _procedures[procedureIndex];
        if (procedureToBeReplaced.superSetId.isNotEmpty) {
          _removeSuperSet(superSetId: procedureToBeReplaced.superSetId);
        }

        final exerciseInLibrary = selectedExercises.first;
        final oldProcedureIndex = _indexWhereProcedure(procedureId: procedureId);
        setState(() {
          _procedures[oldProcedureIndex] = ProcedureDto(exercise: exerciseInLibrary);
        });
      }
    }
  }

  int _indexWhereProcedure({required String procedureId}) {
    return _procedures.indexWhere((procedure) => procedure.exercise.id == procedureId);
  }

  void _addSet({required String procedureId}) {
    final procedureIndex = _indexWhereProcedure(procedureId: procedureId);
    final procedure = _procedures[procedureIndex];
    final sets = [...procedure.sets, SetDto()];
    setState(() {
      _procedures[procedureIndex] = procedure.copyWith(sets: sets);
    });
  }

  void _removeSet({required String procedureId, required int setIndex}) {
    final procedureIndex = _indexWhereProcedure(procedureId: procedureId);
    final procedure = _procedures[procedureIndex];
    final sets = [...procedure.sets];
    sets.removeAt(setIndex);
    setState(() {
      _procedures[procedureIndex] = procedure.copyWith(sets: sets);
    });
  }

  void _checkSet({required String procedureId, required int setIndex}) {
    final procedureIndex = _indexWhereProcedure(procedureId: procedureId);
    final procedure = _procedures[procedureIndex];
    final sets = [...procedure.sets];
    final set = sets[setIndex];
    sets[setIndex] = sets[setIndex].copyWith(checked: !set.checked);
    setState(() {
      _procedures[procedureIndex] = procedure.copyWith(sets: sets);
    });
  }

  void _updateSetRep({required String procedureId, required int setIndex, required int value}) {
    final procedureIndex = _indexWhereProcedure(procedureId: procedureId);
    final procedure = _procedures[procedureIndex];
    final sets = [...procedure.sets];
    sets[setIndex] = sets[setIndex].copyWith(rep: value);
    _procedures[procedureIndex] = procedure.copyWith(sets: sets);
  }

  void _updateWeight({required String procedureId, required int setIndex, required int value}) {
    final procedureIndex = _indexWhereProcedure(procedureId: procedureId);
    final procedure = _procedures[procedureIndex];
    final sets = [...procedure.sets];
    sets[setIndex] = sets[setIndex].copyWith(weight: value);
    _procedures[procedureIndex] = procedure.copyWith(sets: sets);
  }

  void _updateSetType({required String procedureId, required int setIndex, required SetType type}) {
    final procedureIndex = _indexWhereProcedure(procedureId: procedureId);
    final procedure = _procedures[procedureIndex];
    final sets = [...procedure.sets];
    sets[setIndex] = sets[setIndex].copyWith(type: type);
    setState(() {
      _procedures[procedureIndex] = procedure.copyWith(sets: sets);
    });
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
  }

  List<ProcedureDto> _whereOtherProcedures({required ProcedureDto firstProcedure}) {
    return _procedures
        .whereNot((procedure) => procedure.exercise.id == firstProcedure.exercise.id || procedure.superSetId.isNotEmpty)
        .toList();
  }

  ProcedureDto? _whereOtherProcedure({required ProcedureDto firstProcedure}) {
    return _procedures.firstWhereOrNull((procedure) =>
        procedure.superSetId == firstProcedure.superSetId && procedure.exercise.id != firstProcedure.exercise.id);
  }

  void _showRoutineIntervalPicker() {
    showModalPopup(
        context: context,
        child: _TimerPicker(
            initialDuration: _routineDuration,
            onSelect: (Duration duration) {
              Navigator.of(context).pop();
              setState(() {
                _routineDuration = duration;
              });
            }));
  }

  void _showRestIntervalTimePicker({required ProcedureDto procedure}) {
    showModalPopup(
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
  }

  void _removeRestInterval({required String procedureId}) {
    final procedureIndex = _indexWhereProcedure(procedureId: procedureId);
    final procedure = _procedures[procedureIndex];
    setState(() {
      _procedures[procedureIndex] = procedure.copyWith(restInterval: Duration.zero);
    });
  }

  /// Convert list of [ExerciseInWorkout] to [ProcedureWidget]
  Widget _procedureToWidget({required ProcedureDto procedure}) {
    return ProcedureWidget(
      procedureDto: procedure,
      editorType: widget.mode,
      otherSuperSetProcedureDto: _whereOtherProcedure(firstProcedure: procedure),
      onRemoveSuperSet: (String superSetId) => _removeSuperSet(superSetId: procedure.superSetId),
      onRemoveProcedure: () => _removeProcedure(procedureId: procedure.exercise.id),
      onSuperSet: () => _showProceduresPicker(firstProcedure: procedure),
      onChangedSetRep: (int setIndex, int value) =>
          _updateSetRep(procedureId: procedure.exercise.id, setIndex: setIndex, value: value),
      onChangedSetWeight: (int setIndex, int value) =>
          _updateWeight(procedureId: procedure.exercise.id, setIndex: setIndex, value: value),
      onChangedSetType: (int setIndex, SetType type) =>
          _updateSetType(procedureId: procedure.exercise.id, setIndex: setIndex, type: type),
      onAddSet: () => _addSet(procedureId: procedure.exercise.id),
      onRemoveSet: (int setIndex) => _removeSet(procedureId: procedure.exercise.id, setIndex: setIndex),
      onUpdateNotes: (String value) => _updateProcedureNotes(procedureId: procedure.exercise.id, value: value),
      onReplaceProcedure: () => _replaceProcedure(procedureId: procedure.exercise.id),
      onSetRestInterval: () => _showRestIntervalTimePicker(procedure: procedure),
      onRemoveProcedureTimer: () => _removeRestInterval(procedureId: procedure.exercise.id),
      onReOrderProcedures: () => _reOrderProcedures(),
      onCheckSet: (int setIndex) => _checkSet(procedureId: procedure.exercise.id, setIndex: setIndex),
    );
  }

  void _createRoutine() {
    final alertDialogActions = <CupertinoDialogAction>[
      CupertinoDialogAction(
        isDefaultAction: true,
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text('Ok', style: TextStyle(color: CupertinoColors.activeBlue)),
      ),
    ];

    if (_workoutNameController.text.isEmpty) {
      _showAlertDialog(title: "Alert", message: 'Please provide a name for this workout', actions: alertDialogActions);
    } else if (_procedures.isEmpty) {
      _showAlertDialog(title: "Alert", message: "Workout must have exercise(s)", actions: alertDialogActions);
    } else {
      Provider.of<RoutineProvider>(context, listen: false).saveRoutine(
          name: _workoutNameController.text, notes: _workoutNotesController.text, procedures: _procedures);

      _navigateBack();
    }
  }

  void _updateRoutine() {
    final alertDialogActions = <CupertinoDialogAction>[
      CupertinoDialogAction(
        isDefaultAction: true,
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text('Ok', style: TextStyle(color: CupertinoColors.activeBlue)),
      ),
    ];

    final previousWorkout = widget.routine;
    if (previousWorkout != null) {
      if (_workoutNameController.text.isEmpty) {
        _showAlertDialog(
            title: "Alert", message: 'Please provide a name for this workout', actions: alertDialogActions);
      } else if (_procedures.isEmpty) {
        _showAlertDialog(title: "Alert", message: "Workout must have exercise(s)", actions: alertDialogActions);
      } else {
        Provider.of<RoutineProvider>(context, listen: false).updateRoutine(
            id: previousWorkout.id,
            name: _workoutNameController.text,
            notes: _workoutNotesController.text,
            exercises: _procedures);

        _navigateBack();
      }
    }
  }

  bool _isRoutineComplete() {
    return _procedures.every((procedure) => procedure.sets.every((set) => set.checked));
  }

  bool _isRoutineInComplete() {
    return _procedures.any((procedure) => procedure.sets.any((set) => set.checked));
  }

  void _endRoutine() {
    final isCompleted = _isRoutineComplete();
    if(isCompleted) {
      final routine = widget.routine;
      if(routine != null) {
        Provider.of<RoutineLogProvider>(context, listen: false).logRoutine(routineId: routine.id, startTime: _routineStartTime);
      }
    } else {
      final actions = <CupertinoDialogAction>[
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Ok', style: TextStyle(color: CupertinoColors.activeBlue)),
        )
      ];
      _showAlertDialog(title: "End Workout", message: "You have not completed any sets", actions: actions);
    }
  }

  void _cancelRoutine() {
    final isIncomplete = _isRoutineInComplete();
    if(isIncomplete) {
      final actions = <CupertinoDialogAction>[
        CupertinoDialogAction(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Ok', style: TextStyle(color: CupertinoColors.activeBlue)),
        ),
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: () {
            Navigator.pop(context);
            _navigateBack();
          },
          child: const Text('Cancel Workout', style: TextStyle(fontWeight: FontWeight.bold)),
        )
      ];
      _showAlertDialog(title: "Cancel Workout", message: "You will lose all your progress", actions: actions);
    } else {
      _navigateBack();
    }
  }

  void _navigateBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final previousWorkout = widget.routine;

    return Scaffold(
        backgroundColor: tealBlueDark,
        appBar: widget.mode == RoutineEditorMode.editing
            ? CupertinoNavigationBar(
                backgroundColor: tealBlueDark,
                trailing: GestureDetector(
                    onTap: previousWorkout != null ? _updateRoutine : _createRoutine,
                    child: Text(previousWorkout != null ? "Update" : "Save",
                        style: Theme.of(context).textTheme.labelMedium)),
              )
            : CupertinoNavigationBar(
                backgroundColor: tealBlueDark,
                leading: GestureDetector(
                  onTap: _cancelRoutine,
                  child: const Icon(
                    CupertinoIcons.clear_thick,
                    color: CupertinoColors.white,
                    size: 24,
                  ),
                ),
                trailing: GestureDetector(
                    onTap: _showRoutineIntervalPicker,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _routineDuration != null
                            ? Text("10mins 11s", style: Theme.of(context).textTheme.labelLarge)
                            : const SizedBox.shrink(),
                        const SizedBox(width: 4),
                        const Icon(
                          CupertinoIcons.timer,
                          color: CupertinoColors.white,
                          size: 24,
                        )
                      ],
                    )),
              ),
        floatingActionButton: widget.mode == RoutineEditorMode.routine
            ? FloatingActionButton(
                onPressed: _endRoutine,
                backgroundColor: tealBlueLighter,
                child: const Icon(CupertinoIcons.stop_fill),
              )
            : null,
        body: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Padding(
            padding: const EdgeInsets.only(right: 10, bottom: 10, left: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.mode == RoutineEditorMode.editing)
                  CupertinoListSection.insetGrouped(
                    hasLeading: false,
                    margin: EdgeInsets.zero,
                    backgroundColor: Colors.transparent,
                    children: [
                      CupertinoListTile(
                        backgroundColor: tealBlueLight,
                        title: CupertinoTextField.borderless(
                          controller: _workoutNameController,
                          expands: true,
                          padding: const EdgeInsets.only(left: 20),
                          textCapitalization: TextCapitalization.sentences,
                          keyboardType: TextInputType.text,
                          maxLength: 240,
                          maxLines: null,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          style: TextStyle(
                              fontWeight: FontWeight.w600, color: CupertinoColors.white.withOpacity(0.8), fontSize: 18),
                          placeholder: "New workout",
                          placeholderStyle: const TextStyle(color: CupertinoColors.inactiveGray, fontSize: 18),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      CupertinoListTile(
                        backgroundColor: tealBlueLight,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        title: CupertinoTextField.borderless(
                          controller: _workoutNotesController,
                          expands: true,
                          padding: EdgeInsets.zero,
                          textCapitalization: TextCapitalization.sentences,
                          keyboardType: TextInputType.text,
                          maxLength: 240,
                          maxLines: null,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          style: TextStyle(
                            height: 1.5,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.white.withOpacity(0.8),
                            fontSize: 16,
                          ),
                          placeholder: "New notes",
                          placeholderStyle: const TextStyle(color: CupertinoColors.inactiveGray, fontSize: 14),
                        ),
                      ),
                    ],
                  )
                else
                  CupertinoListSection.insetGrouped(
                    hasLeading: false,
                    margin: EdgeInsets.zero,
                    backgroundColor: Colors.transparent,
                    children: [
                      CupertinoListTile(
                        backgroundColor: tealBlueLight,
                        title: Text(previousWorkout!.name,
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: CupertinoColors.white.withOpacity(0.8),
                                fontSize: 18)),
                        trailing: _TimerWidget(started: widget.mode == RoutineEditorMode.routine)
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    controller: _scrollController,
                      itemBuilder: (BuildContext context, int index) {
                        // Build the item widget based on the data at the specified index.
                        final procedure = _procedures[index];
                        return _procedureToWidget(procedure: procedure);
                      },
                      separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 12),
                      itemCount: _procedures.length),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                      color: tealBlueLight,
                      onPressed: _selectExercisesInLibrary,
                      child: Text("Add exercise",
                          textAlign: TextAlign.start, style: Theme.of(context).textTheme.labelLarge)),
                ),
              ],
            ),
          ),
        ));
  }

  @override
  void initState() {
    super.initState();

    _routineStartTime = DateTime.now();
    
    final previousRoutine = widget.routine;
    final procedures = previousRoutine?.procedures.map((procedureJson) => ProcedureDto.fromJson(json.decode(procedureJson), context)).toList();
    _procedures.addAll([...?procedures]);

    if (widget.mode == RoutineEditorMode.editing) {
      _workoutNameController = TextEditingController(text: previousRoutine?.name);
      _workoutNotesController = TextEditingController(text: previousRoutine?.notes);
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.mode == RoutineEditorMode.editing) {
      _workoutNameController.dispose();
      _workoutNotesController.dispose();
    }
    _scrollController.dispose();
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
                      style: const TextStyle(color: CupertinoColors.white),
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
          const ListStyleEmptyState(),
          const ListStyleEmptyState(),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: SizedBox(
              width: double.infinity,
              child: CupertinoButton(
                  color: tealBlueLighter,
                  onPressed: onPressed,
                  child: Text(
                    "Add more exercises",
                    style: Theme.of(context).textTheme.labelLarge,
                  )),
            ),
          )
        ],
      ),
    );
  }
}

class _TimerWidget extends StatefulWidget {
  final bool started;
  const _TimerWidget({required this.started});

  @override
  State<_TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<_TimerWidget> {

  Timer? _timer;

  @override
  Widget build(BuildContext context) {
    return Text(Duration(seconds: _timer?.tick ?? 0).secondsOrMinutesOrHours());
  }

  @override
  void initState() {
    super.initState();
    if(widget.started) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }
}

