import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/exercise_dto.dart';
import 'package:tracker_app/dtos/procedure_dto.dart';
import 'package:tracker_app/dtos/routine_dto.dart';
import 'package:tracker_app/providers/workout_provider.dart';
import 'package:tracker_app/utils/datetime_utils.dart';
import 'package:tracker_app/widgets/helper_widgets/dialog_helper.dart';
import 'package:tracker_app/screens/reorder_procedures_screen.dart';
import '../app_constants.dart';
import '../dtos/set_dto.dart';
import '../widgets/empty_states/list_tile_empty_state.dart';
import '../widgets/workout/editor/procedure_widget.dart';
import 'exercise_library_screen.dart';

enum RoutineEditorMode { editing, routine }

class RoutineEditorScreen extends StatefulWidget {
  final RoutineDto? routine;
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

  late Timer _workoutTimer;
  Duration? _intervalDuration;

  RoutineDto? _previousRoutine;

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

  void _showExercisesInWorkoutPicker({required ProcedureDto firstExercise}) {
    final exercises = _whereOtherExercisesToSuperSetWith(firstExercise: firstExercise);
    showModalPopup(
        context: context,
        child: _ListOfExercises(
          exercises: exercises,
          onSelect: (ProcedureDto secondExercise) {
            Navigator.of(context).pop();
            _addSuperSet(firstExerciseId: firstExercise.exercise.id, secondExerciseId: secondExercise.exercise.id);
          },
          onSelectExercisesInLibrary: () {
            Navigator.of(context).pop();
            _selectExercisesInLibrary();
          },
        ));
  }

  /// Navigate to [ExerciseLibraryScreen]
  void _selectExercisesInLibrary() async {
    final selectedExercises = await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return ExerciseLibraryScreen(
            preSelectedExercises: _procedures.map((exerciseInWorkout) => exerciseInWorkout.exercise).toList());
      },
    ) as List<ExerciseDto>?;

    if (selectedExercises != null) {
      if (mounted) {
        _addExercises(exercises: selectedExercises);
      }
    }
  }

  // Navigate to [ReOrderProcedures]
  void _reOrderExercises() async {
    final reOrderedExercises = await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return ReOrderProceduresScreen(procedures: _procedures);
      },
    ) as List<ProcedureDto>?;

    if (reOrderedExercises != null) {
      if (mounted) {
        setState(() {
          _procedures = reOrderedExercises;
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

  void _addExercises({required List<ExerciseDto> exercises}) {
    final exercisesToAdd = exercises.map((exercise) => ProcedureDto(exercise: exercise)).toList();
    setState(() {
      _procedures.addAll(exercisesToAdd);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _replaceExercise({required String exerciseId}) {
    final exerciseToBeReplaced = _whereExercise(id: exerciseId);
    if (exerciseToBeReplaced.sets.isNotEmpty || exerciseToBeReplaced.notes.isNotEmpty) {
      _showReplaceExerciseAlert(exerciseId: exerciseId);
    } else {
      _handleReplaceExercise(exerciseId: exerciseId);
    }
  }

  void _showReplaceExerciseAlert({required String exerciseId}) {
    final alertDialogActions = <CupertinoDialogAction>[
      CupertinoDialogAction(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text('Cancel'),
      ),
      CupertinoDialogAction(
        isDestructiveAction: true,
        onPressed: () {
          Navigator.pop(context);
          _handleReplaceExercise(exerciseId: exerciseId);
        },
        child: const Text('Replace'),
      )
    ];

    _showAlertDialog(title: "Replace Exercise", message: "All your data will be replaced", actions: alertDialogActions);
  }

  void _handleReplaceExercise({required String exerciseId}) async {
    final selectedExercises = await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return ExerciseLibraryScreen(
            preSelectedExercises: _procedures.map((exerciseInWorkout) => exerciseInWorkout.exercise).toList(),
            multiSelect: false);
      },
    ) as List<ExerciseDto>?;

    if (selectedExercises != null) {
      if (mounted) {
        final exerciseInLibrary = selectedExercises.first;
        final oldExerciseInWorkoutIndex = _whereExerciseIndex(id: exerciseId);
        setState(() {
          _procedures[oldExerciseInWorkoutIndex] = ProcedureDto(exercise: exerciseInLibrary);
        });
      }
    }
  }

  void _removeExercise({required String exerciseId}) {
    final exercise = _whereExercise(id: exerciseId);
    if (exercise.isSuperSet) {
      _removeSuperSet(superSetId: exercise.superSetId);
    }
    setState(() {
      _procedures.removeWhere((exerciseInWorkout) => exerciseInWorkout.exercise.id == exerciseId);
    });
  }

  ProcedureDto _whereExercise({required String id}) {
    return _procedures.firstWhere((exerciseInWorkout) => exerciseInWorkout.exercise.id == id);
  }

  int _whereExerciseIndex({required String id}) {
    return _procedures.indexWhere((exerciseInWorkout) => exerciseInWorkout.exercise.id == id);
  }

  void _addProcedure({required String exerciseId}) {
    final exerciseIndex = _whereExerciseIndex(id: exerciseId);
    setState(() {
      _procedures[exerciseIndex].sets.add(SetDto());
    });
  }

  void _removeProcedure({required String exerciseId, required int index}) {
    final exerciseIndex = _whereExerciseIndex(id: exerciseId);
    setState(() {
      _procedures[exerciseIndex].sets.removeAt(index);
    });
  }

  void _checkProcedure({required String exerciseId, required int index}) {
    final exerciseIndex = _whereExerciseIndex(id: exerciseId);
    final isChecked = _procedures[exerciseIndex].sets[index].checked;
    setState(() {
      _procedures[exerciseIndex].sets[index].checked = !isChecked;
    });
  }

  void _updateProcedureRepCount({required String exerciseId, required int index, required int value}) {
    final exerciseIndex = _whereExerciseIndex(id: exerciseId);
    _procedures[exerciseIndex].sets[index].rep = value;
  }

  void _updateProcedureWeight({required String exerciseId, required int index, required int value}) {
    final exerciseIndex = _whereExerciseIndex(id: exerciseId);
    _procedures[exerciseIndex].sets[index].weight = value;
  }

  void _updateProcedureType({required String exerciseId, required int index, required SetType type}) {
    final exerciseIndex = _whereExerciseIndex(id: exerciseId);
    Navigator.of(context).pop();
    setState(() {
      _procedures[exerciseIndex].sets[index].type = type;
    });
  }

  void _addSuperSet({required String firstExerciseId, required String secondExerciseId}) {
    final id = "id_${DateTime.now().millisecond}";

    final firstIndex = _whereExerciseIndex(id: firstExerciseId);
    final secondIndex = _whereExerciseIndex(id: secondExerciseId);

    setState(() {
      _procedures[firstIndex].isSuperSet = true;
      _procedures[firstIndex].superSetId = id;

      _procedures[secondIndex].isSuperSet = true;
      _procedures[secondIndex].superSetId = id;
    });
  }

  void _removeSuperSet({required String superSetId}) {
    for (var exerciseInWorkout in _procedures) {
      if (exerciseInWorkout.superSetId == superSetId) {
        final index = _procedures.indexWhere((item) => item.superSetId == superSetId);
        setState(() {
          _procedures[index].isSuperSet = false;
          _procedures[index].superSetId = "";
        });
      }
    }
  }

  void _updateNotes({required String exerciseId, required String value}) {
    final index = _whereExerciseIndex(id: exerciseId);
    _procedures[index].notes = value;
  }

  List<ProcedureDto> _whereOtherExercisesToSuperSetWith({required ProcedureDto firstExercise}) {
    return _procedures
        .whereNot((exerciseInWorkout) =>
            exerciseInWorkout.exercise.id == firstExercise.exercise.id || exerciseInWorkout.isSuperSet)
        .toList();
  }

  ProcedureDto? _whereOtherSuperSet({required ProcedureDto firstExercise}) {
    return _procedures.firstWhereOrNull((exerciseInWorkout) =>
        exerciseInWorkout.superSetId == firstExercise.superSetId &&
        exerciseInWorkout.exercise.id != firstExercise.exercise.id);
  }

  void _showIntervalTimePicker() {
    showModalPopup(
        context: context,
        child: _TimerPicker(
            previousDuration: _intervalDuration,
            onSelect: (Duration duration) {
              Navigator.of(context).pop();
              setState(() {
                _intervalDuration = duration;
              });
            }));
  }

  void _showWorkingTimePicker({required ProcedureDto exerciseInWorkoutDto}) {
    showModalPopup(
        context: context,
        child: _TimerPicker(
          previousDuration: exerciseInWorkoutDto.procedureDuration,
          onSelect: (Duration duration) =>
              _setWorkingTimer(exerciseId: exerciseInWorkoutDto.exercise.id, duration: duration),
        ));
  }

  void _setWorkingTimer({required String exerciseId, required Duration duration}) {
    final exerciseIndex = _whereExerciseIndex(id: exerciseId);
    Navigator.of(context).pop();
    setState(() {
      _procedures[exerciseIndex].procedureDuration = duration;
    });
  }

  void _removeWorkingTimer({required String exerciseId}) {
    final exerciseIndex = _whereExerciseIndex(id: exerciseId);
    setState(() {
      _procedures[exerciseIndex].procedureDuration = null;
    });
  }

  /// Convert list of [ExerciseInWorkout] to [ProcedureWidget]
  List<ProcedureWidget> _proceduresToWidgets({required List<ProcedureDto> procedures}) {
    return procedures.map((procedure) {
      return ProcedureWidget(
        procedureDto: procedure,
        editorType: widget.mode,
        superSetProcedureDto: _whereOtherSuperSet(firstExercise: procedure),
        onRemoveSuperSetProcedure: (String superSetId) => _removeSuperSet(superSetId: superSetId),
        onRemoveProcedure: () => _removeExercise(exerciseId: procedure.exercise.id),
        onAddSuperSetProcedure: () => _showExercisesInWorkoutPicker(firstExercise: procedure),
        onChangedSetRep: (int procedureIndex, int value) => _updateProcedureRepCount(exerciseId: procedure.exercise.id, index: procedureIndex, value: value),
        onChangedSetWeight: (int procedureIndex, int value) => _updateProcedureWeight(exerciseId: procedure.exercise.id, index: procedureIndex, value: value),
        onAddSet: () => _addProcedure(exerciseId: procedure.exercise.id),
        onRemoveSet: (int procedureIndex) => _removeProcedure(exerciseId: procedure.exercise.id, index: procedureIndex),
        onUpdateNotes: (String value) => _updateNotes(exerciseId: procedure.exercise.id, value: value),
        onReplaceProcedure: () => _replaceExercise(exerciseId: procedure.exercise.id),
        onSetProcedureTimer: () => _showWorkingTimePicker(exerciseInWorkoutDto: procedure),
        onRemoveProcedureTimer: () => _removeWorkingTimer(exerciseId: procedure.exercise.id),
        onChangedSetType: (int procedureIndex, SetType type) => _updateProcedureType(exerciseId: procedure.exercise.id, index: procedureIndex, type: type),
        onReOrderProcedures: () => _reOrderExercises(),
        onCheckSet: (int procedureIndex) => _checkProcedure(exerciseId: procedure.exercise.id, index: procedureIndex),
      );
    }).toList();
  }

  void _navigateBack() {
    Navigator.of(context).pop();
  }

  void _createRoutine() {
    final alertDialogActions = <CupertinoDialogAction>[
      CupertinoDialogAction(
        isDefaultAction: true,
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text('Ok'),
      ),
    ];

    if (_workoutNameController.text.isEmpty) {
      _showAlertDialog(title: "Alert", message: 'Please provide a name for this workout', actions: alertDialogActions);
    } else if (_procedures.isEmpty) {
      _showAlertDialog(title: "Alert", message: "Workout must have exercise(s)", actions: alertDialogActions);
    } else {
      Provider.of<RoutineProvider>(context, listen: false).createWorkout(name: _workoutNameController.text, notes: _workoutNotesController.text, exercises: _procedures);

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
        child: const Text('Ok'),
      ),
    ];

    final previousWorkout = _previousRoutine;
    if (previousWorkout != null) {
      if (_workoutNameController.text.isEmpty) {
        _showAlertDialog(title: "Alert", message: 'Please provide a name for this workout', actions: alertDialogActions);
      } else if (_procedures.isEmpty) {
        _showAlertDialog(title: "Alert", message: "Workout must have exercise(s)", actions: alertDialogActions);
      } else {
        Provider.of<RoutineProvider>(context, listen: false).updateWorkout(
            id: previousWorkout.id,
            name: _workoutNameController.text,
            notes: _workoutNotesController.text,
            exercises: _procedures);

        _navigateBack();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final previousWorkout = _previousRoutine;

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
                  onTap: _navigateBack,
                  child: const Icon(
                    CupertinoIcons.clear_thick,
                    color: CupertinoColors.white,
                    size: 24,
                  ),
                ),
                trailing: GestureDetector(
                    onTap: _showIntervalTimePicker,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _intervalDuration != null
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
                onPressed: _navigateBack,
                backgroundColor: tealBlueLight,
                child: const Icon(CupertinoIcons.stop_fill),
              )
            : null,
        body: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Container(
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
                                  fontWeight: FontWeight.w600,
                                  color: CupertinoColors.white.withOpacity(0.8),
                                  fontSize: 18),
                              placeholder: "New workout",
                              placeholderStyle: const TextStyle(color: CupertinoColors.inactiveGray, fontSize: 18),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          CupertinoListTile.notched(
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
                            trailing: widget.mode == RoutineEditorMode.routine
                                ? Text(Duration(seconds: _workoutTimer.tick).secondsOrMinutesOrHours())
                                : null,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          CupertinoListTile(
                            backgroundColor: tealBlueLight,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            title: Text(previousWorkout.notes,
                                style: TextStyle(
                                  height: 1.5,
                                  fontWeight: FontWeight.w600,
                                  color: CupertinoColors.white.withOpacity(0.8),
                                  fontSize: 16,
                                )),
                          ),
                        ],
                      ),
                    const SizedBox(height: 12),
                    ..._proceduresToWidgets(procedures: _procedures),
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
            ),
          ),
        ));
  }

  RoutineDto? _fetchRoutine() {
    RoutineDto? workoutDto;
    final routine = widget.routine?.id;
    // if (routine != null) {
    //   final routines = Provider.of<RoutineProvider>(context, listen: false).workouts;
    //   workoutDto = routines.firstWhere((workout) => workout.id == routineId);
    //   // print(workoutDto.procedures[0].notes);
    // }
    return workoutDto;
  }

  @override
  void initState() {
    super.initState();
    _previousRoutine = widget.routine;//_fetchRoutine();

    _procedures = [...?_previousRoutine?.procedures];

    if (widget.mode == RoutineEditorMode.editing) {
      _workoutNameController = TextEditingController(text: _previousRoutine?.name);
      _workoutNotesController = TextEditingController(text: _previousRoutine?.notes);
    } else {
      _workoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          //setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.mode == RoutineEditorMode.editing) {
      _workoutNameController.dispose();
      _workoutNotesController.dispose();
    } else {
      _workoutTimer.cancel();
    }
    _scrollController.dispose();
  }
}

class _ListOfExercises extends StatefulWidget {
  final List<ProcedureDto> exercises;
  final void Function(ProcedureDto exercise) onSelect;
  final void Function() onSelectExercisesInLibrary;

  const _ListOfExercises({required this.exercises, required this.onSelect, required this.onSelectExercisesInLibrary});

  @override
  State<_ListOfExercises> createState() => _ListOfExercisesState();
}

class _ListOfExercisesState extends State<_ListOfExercises> {
  late ProcedureDto? _exerciseInWorkoutDto;

  @override
  Widget build(BuildContext context) {
    return widget.exercises.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  final exerciseInWorkoutDto = _exerciseInWorkoutDto;
                  if (exerciseInWorkoutDto != null) {
                    widget.onSelect(exerciseInWorkoutDto);
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
                      _exerciseInWorkoutDto = widget.exercises[index];
                    });
                  },
                  children: List<Widget>.generate(widget.exercises.length, (int index) {
                    return Center(
                        child: Text(
                      widget.exercises[index].exercise.name,
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
    _exerciseInWorkoutDto = widget.exercises.firstOrNull;
  }
}

class _TimerPicker extends StatefulWidget {
  final Duration? previousDuration;
  final void Function(Duration duration) onSelect;

  const _TimerPicker({required this.onSelect, required this.previousDuration});

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
    final previousDuration = widget.previousDuration;
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
