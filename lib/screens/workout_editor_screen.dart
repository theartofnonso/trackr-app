import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/exercise_dto.dart';
import 'package:tracker_app/dtos/exercise_in_workout_dto.dart';
import 'package:tracker_app/dtos/workout_dto.dart';
import 'package:tracker_app/providers/workout_provider.dart';
import 'package:tracker_app/widgets/helper_widgets/dialog_helper.dart';
import 'package:tracker_app/widgets/workout/editor/reorder_exercises_in_workout_editor.dart';
import '../app_constants.dart';
import '../dtos/procedure_dto.dart';
import '../widgets/empty_states/list_tile_empty_state.dart';
import '../widgets/workout/editor/exercise_in_workout_editor.dart';
import 'exercise_library_screen.dart';

class WorkoutEditorScreen extends StatefulWidget {
  final WorkoutDto? workoutDto;

  const WorkoutEditorScreen({super.key, this.workoutDto});

  @override
  State<WorkoutEditorScreen> createState() => _WorkoutEditorScreenState();
}

class _WorkoutEditorScreenState extends State<WorkoutEditorScreen> {
  final _scrollController = ScrollController();

  List<ExerciseInWorkoutDto> _exercisesInWorkout = [];

  late TextEditingController _workoutNameController;
  late TextEditingController _workoutNotesController;

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

  void _showExercisesInWorkoutPicker({required ExerciseInWorkoutDto firstExercise}) {
    final exercises = _whereOtherExercisesToSuperSetWith(firstExercise: firstExercise);
    showModalPopup(
        context: context,
        child: _ListOfExercises(
          exercises: exercises,
          onSelect: (ExerciseInWorkoutDto secondExercise) {
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
            preSelectedExercises: _exercisesInWorkout.map((exerciseInWorkout) => exerciseInWorkout.exercise).toList());
      },
    ) as List<ExerciseDto>?;

    if (selectedExercises != null) {
      if (mounted) {
        _addExercises(exercises: selectedExercises);
      }
    }
  }

  // Navigate to [ReOrderExercises]
  void _reOrderExercises() async {
    final reOrderedExercises = await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return ReOrderExercisesInWorkoutEditor(exercises: _exercisesInWorkout);
      },
    ) as List<ExerciseInWorkoutDto>?;

    if (reOrderedExercises != null) {
      if (mounted) {
        setState(() {
          _exercisesInWorkout = reOrderedExercises;
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
    final exercisesToAdd = exercises.map((exercise) => ExerciseInWorkoutDto(exercise: exercise)).toList();
    setState(() {
      _exercisesInWorkout.addAll(exercisesToAdd);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _replaceExercise({required String exerciseId}) {
    final exerciseToBeReplaced = _exerciseWhere(id: exerciseId);
    if (exerciseToBeReplaced.procedures.isNotEmpty || exerciseToBeReplaced.notes.isNotEmpty) {
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
            preSelectedExercises: _exercisesInWorkout.map((exerciseInWorkout) => exerciseInWorkout.exercise).toList(),
            multiSelect: false);
      },
    ) as List<ExerciseDto>?;

    if (selectedExercises != null) {
      if (mounted) {
        final exerciseInLibrary = selectedExercises.first;
        final oldExerciseInWorkoutIndex = _indexWhereExerciseInWorkout(id: exerciseId);
        setState(() {
          _exercisesInWorkout[oldExerciseInWorkoutIndex] = ExerciseInWorkoutDto(exercise: exerciseInLibrary);
        });
      }
    }
  }

  void _removeExercise({required String exerciseId}) {
    final exercise = _exerciseWhere(id: exerciseId);
    if (exercise.isSuperSet) {
      _removeSuperSet(superSetId: exercise.superSetId);
    }
    setState(() {
      _exercisesInWorkout.removeWhere((exerciseInWorkout) => exerciseInWorkout.exercise.id == exerciseId);
    });
  }

  ExerciseInWorkoutDto _exerciseWhere({required String id}) {
    return _exercisesInWorkout.firstWhere((exerciseInWorkout) => exerciseInWorkout.exercise.id == id);
  }

  int _indexWhereExerciseInWorkout({required String id}) {
    return _exercisesInWorkout.indexWhere((exerciseInWorkout) => exerciseInWorkout.exercise.id == id);
  }

  void _addProcedure({required String exerciseId}) {
    final exerciseIndex = _indexWhereExerciseInWorkout(id: exerciseId);
    setState(() {
      _exercisesInWorkout[exerciseIndex].procedures.add(ProcedureDto());
    });
  }

  void _removeProcedure({required String exerciseId, required int index}) {
    final exerciseIndex = _indexWhereExerciseInWorkout(id: exerciseId);
    setState(() {
      _exercisesInWorkout[exerciseIndex].procedures.removeAt(index);
    });
  }

  void _updateProcedureRepCount({required String exerciseId, required int index, required int value}) {
    final exerciseIndex = _indexWhereExerciseInWorkout(id: exerciseId);
    _exercisesInWorkout[exerciseIndex].procedures[index].repCount = value;
  }

  void _updateProcedureWeight({required String exerciseId, required int index, required int value}) {
    final exerciseIndex = _indexWhereExerciseInWorkout(id: exerciseId);
    _exercisesInWorkout[exerciseIndex].procedures[index].weight = value;
  }

  void _updateProcedureType({required String exerciseId, required int index, required ProcedureType type}) {
    final exerciseIndex = _indexWhereExerciseInWorkout(id: exerciseId);
    Navigator.of(context).pop();
    setState(() {
      _exercisesInWorkout[exerciseIndex].procedures[index].type = type;
    });
  }

  void _addSuperSet({required String firstExerciseId, required String secondExerciseId}) {
    final id = "id_${DateTime.now().millisecond}";

    final firstIndex = _indexWhereExerciseInWorkout(id: firstExerciseId);
    final secondIndex = _indexWhereExerciseInWorkout(id: secondExerciseId);

    setState(() {
      _exercisesInWorkout[firstIndex].isSuperSet = true;
      _exercisesInWorkout[firstIndex].superSetId = id;

      _exercisesInWorkout[secondIndex].isSuperSet = true;
      _exercisesInWorkout[secondIndex].superSetId = id;
    });
  }

  void _removeSuperSet({required String superSetId}) {
    for (var exerciseInWorkout in _exercisesInWorkout) {
      if (exerciseInWorkout.superSetId == superSetId) {
        final index = _exercisesInWorkout.indexWhere((item) => item.superSetId == superSetId);
        setState(() {
          _exercisesInWorkout[index].isSuperSet = false;
          _exercisesInWorkout[index].superSetId = "";
        });
      }
    }
  }

  void _updateNotes({required String exerciseId, required String value}) {
    final index = _indexWhereExerciseInWorkout(id: exerciseId);
    _exercisesInWorkout[index].notes = value;
  }

  List<ExerciseInWorkoutDto> _whereOtherExercisesToSuperSetWith({required ExerciseInWorkoutDto firstExercise}) {
    return _exercisesInWorkout
        .whereNot((exerciseInWorkout) =>
            exerciseInWorkout.exercise.id == firstExercise.exercise.id || exerciseInWorkout.isSuperSet)
        .toList();
  }

  ExerciseInWorkoutDto? _whereOtherSuperSet({required ExerciseInWorkoutDto firstExercise}) {
    return _exercisesInWorkout.firstWhereOrNull((exerciseInWorkout) =>
        exerciseInWorkout.superSetId == firstExercise.superSetId &&
        exerciseInWorkout.exercise.id != firstExercise.exercise.id);
  }

  void _setWorkingTimer({required String exerciseId, required Duration duration}) {
    final exerciseIndex = _indexWhereExerciseInWorkout(id: exerciseId);
    Navigator.of(context).pop();
    setState(() {
      _exercisesInWorkout[exerciseIndex].procedureDuration = duration;
    });
  }

  void _removeWorkingTimer({required String exerciseId}) {
    final exerciseIndex = _indexWhereExerciseInWorkout(id: exerciseId);
    setState(() {
      _exercisesInWorkout[exerciseIndex].procedureDuration = null;
    });
  }

  /// Convert list of [ExerciseInWorkout] to [ExerciseInWorkoutEditor]
  List<ExerciseInWorkoutEditor> _exercisesToWidgets({required List<ExerciseInWorkoutDto> exercisesInWorkout}) {
    return exercisesInWorkout.map((exerciseInWorkout) {
      return ExerciseInWorkoutEditor(
        exerciseInWorkoutDto: exerciseInWorkout,
        superSetExerciseInWorkoutDto: _whereOtherSuperSet(firstExercise: exerciseInWorkout),
        onRemoveSuperSetExercises: (String superSetId) => _removeSuperSet(superSetId: superSetId),
        onRemoveExercise: () => _removeExercise(exerciseId: exerciseInWorkout.exercise.id),
        onAddSuperSetExercises: () => _showExercisesInWorkoutPicker(firstExercise: exerciseInWorkout),
        onChangedProcedureRepCount: (int procedureIndex, int value) =>
            _updateProcedureRepCount(exerciseId: exerciseInWorkout.exercise.id, index: procedureIndex, value: value),
        onChangedProcedureWeight: (int procedureIndex, int value) =>
            _updateProcedureWeight(exerciseId: exerciseInWorkout.exercise.id, index: procedureIndex, value: value),
        onAddProcedure: () => _addProcedure(exerciseId: exerciseInWorkout.exercise.id),
        onRemoveProcedure: (int procedureIndex) =>
            _removeProcedure(exerciseId: exerciseInWorkout.exercise.id, index: procedureIndex),
        onUpdateNotes: (String value) => _updateNotes(exerciseId: exerciseInWorkout.exercise.id, value: value),
        onReplaceExercise: () => _replaceExercise(exerciseId: exerciseInWorkout.exercise.id),
        onSetProcedureTimer: () => showModalPopup(
            context: context,
            child: _Timer(
              previousDuration: exerciseInWorkout.procedureDuration,
              onSelect: (Duration duration) =>
                  _setWorkingTimer(exerciseId: exerciseInWorkout.exercise.id, duration: duration),
            )),
        onRemoveProcedureTimer: () => _removeWorkingTimer(exerciseId: exerciseInWorkout.exercise.id),
        onChangedProcedureType: (int procedureIndex, ProcedureType type) =>
            _updateProcedureType(exerciseId: exerciseInWorkout.exercise.id, index: procedureIndex, type: type),
        onReOrderExercises: () => _reOrderExercises(),
      );
    }).toList();
  }

  void _navigateBack() {
    Navigator.of(context).pop();
  }

  void _createWorkout() {
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
      return;
    }

    if (_exercisesInWorkout.isEmpty) {
      _showAlertDialog(title: "Alert", message: "Workout must have exercise(s)", actions: alertDialogActions);
      return;
    }

    Provider.of<WorkoutProvider>(context, listen: false).createWorkout(
        name: _workoutNameController.text, notes: _workoutNotesController.text, exercises: _exercisesInWorkout);

    _navigateBack();
  }

  void _updateWorkout() {
    final alertDialogActions = <CupertinoDialogAction>[
      CupertinoDialogAction(
        isDefaultAction: true,
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text('Ok'),
      ),
    ];

    final workout = widget.workoutDto;

    if (workout != null) {
      if (_workoutNameController.text.isEmpty) {
        _showAlertDialog(
            title: "Alert", message: 'Please provide a name for this workout', actions: alertDialogActions);
        return;
      }

      if (_exercisesInWorkout.isEmpty) {
        _showAlertDialog(title: "Alert", message: "Workout must have exercise(s)", actions: alertDialogActions);
        return;
      }

      Provider.of<WorkoutProvider>(context, listen: false).updateWorkout(
          id: workout.id,
          name: _workoutNameController.text,
          notes: _workoutNotesController.text,
          exercises: _exercisesInWorkout);

      _navigateBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    final previousWorkoutDto = widget.workoutDto;

    return CupertinoPageScaffold(
        backgroundColor: tealBlueDark,
        navigationBar: CupertinoNavigationBar(
          backgroundColor: tealBlueDark,
          trailing: GestureDetector(
              onTap: previousWorkoutDto != null ? _updateWorkout : _createWorkout,
              child:
                  Text(previousWorkoutDto != null ? "Update" : "Save", style: Theme.of(context).textTheme.labelMedium)),
        ),
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    ),
                    const SizedBox(height: 10),
                    ..._exercisesToWidgets(exercisesInWorkout: _exercisesInWorkout),
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

  @override
  void initState() {
    super.initState();

    final workout = widget.workoutDto;

    _workoutNameController = TextEditingController(text: workout?.name);
    _workoutNotesController = TextEditingController(text: workout?.notes);

    if (workout != null) {
      _exercisesInWorkout = workout.exercises;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _workoutNameController.dispose();
    _workoutNotesController.dispose();
  }
}

class _ListOfExercises extends StatefulWidget {
  final List<ExerciseInWorkoutDto> exercises;
  final void Function(ExerciseInWorkoutDto exercise) onSelect;
  final void Function() onSelectExercisesInLibrary;

  const _ListOfExercises({required this.exercises, required this.onSelect, required this.onSelectExercisesInLibrary});

  @override
  State<_ListOfExercises> createState() => _ListOfExercisesState();
}

class _ListOfExercisesState extends State<_ListOfExercises> {
  late ExerciseInWorkoutDto? _exerciseInWorkoutDto;

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

class _Timer extends StatefulWidget {
  final Duration? previousDuration;
  final void Function(Duration duration) onSelect;

  const _Timer({required this.onSelect, required this.previousDuration});

  @override
  State<_Timer> createState() => _TimerState();
}

class _TimerState extends State<_Timer> {
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
