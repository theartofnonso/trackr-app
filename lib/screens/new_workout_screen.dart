import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/exercise_dto.dart';
import 'package:tracker_app/dtos/exercise_in_workout_dto.dart';
import 'package:tracker_app/dtos/workout_dto.dart';
import 'package:tracker_app/providers/workout_provider.dart';
import '../app_constants.dart';
import '../dtos/procedure_dto.dart';
import '../widgets/list_tile_empty_state.dart';
import '../widgets/workout/exercise_in_workout_list_section.dart';
import 'exercise_library_screen.dart';

class NewWorkoutScreen extends StatefulWidget {
  final WorkoutDto? workoutDto;

  const NewWorkoutScreen({super.key, this.workoutDto});

  @override
  State<NewWorkoutScreen> createState() => _NewWorkoutScreenState();
}

class _NewWorkoutScreenState extends State<NewWorkoutScreen> {
  final _scrollController = ScrollController();

  List<ExerciseInWorkoutDto> _exercisesInWorkout = [];

  late TextEditingController _workoutNameController;
  late TextEditingController _workoutNotesController;

  /// Show [CupertinoAlertDialog] for creating a workout
  void _showAlertDialog(
      {required String title,
      required String message,
      required List<CupertinoDialogAction> actions}) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: actions,
      ),
    );
  }

  void _showExercisesInWorkoutPicker(
      {required ExerciseInWorkoutDto firstExercise}) {
    final exercises =
        _whereOtherExercisesToSuperSetWith(firstExercise: firstExercise);
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        // The bottom margin is provided to align the popup above the system
        // navigation bar.
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        // Provide a background color for the popup.
        color: tealBlueLight,
        // Use a SafeArea widget to avoid system overlaps.
        child: SafeArea(
          top: false,
          child: _ListOfExercises(
            exercises: exercises,
            onSelect: (ExerciseInWorkoutDto secondExercise) {
              Navigator.of(context).pop();
              _addSuperSet(
                  firstExerciseId: firstExercise.exercise.id,
                  secondExerciseId: secondExercise.exercise.id);

            },
            onSelectExercisesInLibrary: () {
              Navigator.of(context).pop();
              _selectExercisesInLibrary();
            },
          ),
        ),
      ),
    );
  }

  /// Navigate to [ExerciseLibraryScreen]
  Future<void> _selectExercisesInLibrary() async {
    final selectedExercises = await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return ExerciseLibraryScreen(
            preSelectedExercises: _exercisesInWorkout
                .map((exerciseInWorkout) => exerciseInWorkout.exercise)
                .toList());
      },
    ) as List<ExerciseDto>?;

    if (selectedExercises != null) {
      if (mounted) {
        _addExercises(exercises: selectedExercises);
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
    final exercisesToAdd = exercises
        .map((exercise) => ExerciseInWorkoutDto(exercise: exercise))
        .toList();
    setState(() {
      _exercisesInWorkout.addAll(exercisesToAdd);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _replaceExercise({required String exerciseId}) {
    final exerciseToBeReplaced = _exerciseWhere(id: exerciseId);
    if (exerciseToBeReplaced.warmupProcedures.isNotEmpty ||
        exerciseToBeReplaced.workingProcedures.isNotEmpty ||
        exerciseToBeReplaced.notes.isNotEmpty) {
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

    _showAlertDialog(
        title: "Replace Exercise",
        message: "All your data will be replaced",
        actions: alertDialogActions);
  }

  void _handleReplaceExercise({required String exerciseId}) async {
    final selectedExercises = await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return ExerciseLibraryScreen(
            preSelectedExercises: _exercisesInWorkout
                .map((exerciseInWorkout) => exerciseInWorkout.exercise)
                .toList(),
            multiSelect: false);
      },
    ) as List<ExerciseDto>?;

    if (selectedExercises != null) {
      if (mounted) {
        final exerciseInLibrary = selectedExercises.first;
        final oldExerciseInWorkoutIndex =
            _indexWhereExerciseInWorkout(id: exerciseId);
        setState(() {
          _exercisesInWorkout[oldExerciseInWorkoutIndex] =
              ExerciseInWorkoutDto(exercise: exerciseInLibrary);
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
      _exercisesInWorkout.removeWhere(
          (exerciseInWorkout) => exerciseInWorkout.exercise.id == exerciseId);
    });
  }

  ExerciseInWorkoutDto _exerciseWhere({required String id}) {
    return _exercisesInWorkout
        .firstWhere((exerciseInWorkout) => exerciseInWorkout.exercise.id == id);
  }

  int _indexWhereExerciseInWorkout({required String id}) {
    return _exercisesInWorkout
        .indexWhere((exerciseInWorkout) => exerciseInWorkout.exercise.id == id);
  }

  void _addWarmUpSet({required String exerciseId}) {
    final exerciseIndex = _indexWhereExerciseInWorkout(id: exerciseId);
    setState(() {
      _exercisesInWorkout[exerciseIndex].warmupProcedures.add(ProcedureDto());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _removeWarmUpSet({required String exerciseId, required int index}) {
    final exerciseIndex = _indexWhereExerciseInWorkout(id: exerciseId);
    setState(() {
      _exercisesInWorkout[exerciseIndex].warmupProcedures.removeAt(index);
    });
  }

  void _addWorkingSet({required String exerciseId}) {
    final exerciseIndex = _indexWhereExerciseInWorkout(id: exerciseId);
    setState(() {
      _exercisesInWorkout[exerciseIndex].workingProcedures.add(ProcedureDto());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _removeWorkingUpSet({required String exerciseId, required int index}) {
    final exerciseIndex = _indexWhereExerciseInWorkout(id: exerciseId);
    setState(() {
      _exercisesInWorkout[exerciseIndex].workingProcedures.removeAt(index);
    });
  }

  void _updateWarmUpSetRepCount(
      {required String exerciseId, required int index, required int value}) {
    final exerciseIndex = _indexWhereExerciseInWorkout(id: exerciseId);
    _exercisesInWorkout[exerciseIndex].warmupProcedures[index].repCount = value;
  }

  void _updateWarmUpSetWeight(
      {required ExerciseInWorkoutDto exerciseInWorkoutDto,
      required int index,
      required int value}) {
    final exerciseIndex =
        _indexWhereExerciseInWorkout(id: exerciseInWorkoutDto.exercise.id);
    _exercisesInWorkout[exerciseIndex].warmupProcedures[index].weight = value;
  }

  void _updateWorkingSetRepCount(
      {required String exerciseId, required int index, required int value}) {
    final exerciseIndex = _indexWhereExerciseInWorkout(id: exerciseId);
    _exercisesInWorkout[exerciseIndex].workingProcedures[index].repCount =
        value;
  }

  void _updateWorkingSetWeight(
      {required String exerciseId, required int index, required int value}) {
    final exerciseIndex = _indexWhereExerciseInWorkout(id: exerciseId);
    _exercisesInWorkout[exerciseIndex].workingProcedures[index].weight = value;
  }

  void _addSuperSet(
      {required String firstExerciseId, required String secondExerciseId}) {
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
        final index = _exercisesInWorkout
            .indexWhere((item) => item.superSetId == superSetId);
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

  List<ExerciseInWorkoutDto> _whereOtherExercisesToSuperSetWith(
      {required ExerciseInWorkoutDto firstExercise}) {
    return _exercisesInWorkout
        .whereNot((exerciseInWorkout) =>
            exerciseInWorkout.exercise.id == firstExercise.exercise.id ||
            exerciseInWorkout.isSuperSet)
        .toList();
  }

  ExerciseInWorkoutDto? _whereOtherSuperSet(
      {required ExerciseInWorkoutDto firstExercise}) {
    return _exercisesInWorkout.firstWhereOrNull((exerciseInWorkout) =>
        exerciseInWorkout.superSetId == firstExercise.superSetId &&
        exerciseInWorkout.exercise.id != firstExercise.exercise.id);
  }

  /// Convert list of [ExerciseInWorkout] to [ExerciseInWorkoutListSection]
  List<ExerciseInWorkoutListSection> _exercisesToListSection(
      {required List<ExerciseInWorkoutDto> exercisesInWorkout}) {
    final exerciseInWorkoutListSection =
        exercisesInWorkout.map((exerciseInWorkout) {
      return ExerciseInWorkoutListSection(
        exerciseInWorkoutDto: exerciseInWorkout,
        otherExerciseInWorkoutDto:
            _whereOtherSuperSet(firstExercise: exerciseInWorkout),
        onRemoveSuperSetExercises: (String superSetId) =>
            _removeSuperSet(superSetId: superSetId),
        onRemoveExercise: () =>
            _removeExercise(exerciseId: exerciseInWorkout.exercise.id),
        onAddSuperSetExercises: () =>
            _showExercisesInWorkoutPicker(firstExercise: exerciseInWorkout),
        onChangedWorkingSetRepCount: (int index, int value) =>
            _updateWorkingSetRepCount(
                exerciseId: exerciseInWorkout.exercise.id,
                index: index,
                value: value),
        onChangedWorkingSetWeight: (int index, int value) =>
            _updateWorkingSetWeight(
                exerciseId: exerciseInWorkout.exercise.id,
                index: index,
                value: value),
        onChangedWarmUpSetRepCount: (int index, int value) =>
            _updateWarmUpSetRepCount(
                exerciseId: exerciseInWorkout.exercise.id,
                index: index,
                value: value),
        onChangedWarmUpSetWeight: (int index, int value) =>
            _updateWarmUpSetWeight(
                exerciseInWorkoutDto: exerciseInWorkout,
                index: index,
                value: value),
        onAddWorkingSet: () =>
            _addWorkingSet(exerciseId: exerciseInWorkout.exercise.id),
        onRemoveWorkingSet: (int index) => _removeWorkingUpSet(
            exerciseId: exerciseInWorkout.exercise.id, index: index),
        onAddWarmUpSet: () =>
            _addWarmUpSet(exerciseId: exerciseInWorkout.exercise.id),
        onRemoveWarmUpSet: (int index) => _removeWarmUpSet(
            exerciseId: exerciseInWorkout.exercise.id, index: index),
        onUpdateNotes: (String value) => _updateNotes(
            exerciseId: exerciseInWorkout.exercise.id, value: value),
        onReplaceExercise: () =>
            _replaceExercise(exerciseId: exerciseInWorkout.exercise.id),
      );
    }).toList();

    outerLoop:
    for (var i = 0; i < exerciseInWorkoutListSection.length; i++) {
      final firstExerciseSection = exerciseInWorkoutListSection[i];
      final exerciseInWorkoutDto = firstExerciseSection.exerciseInWorkoutDto;
      if (exerciseInWorkoutDto.isSuperSet) {
        final superSetId = exerciseInWorkoutDto.superSetId;
        final otherExerciseSections = exerciseInWorkoutListSection.where(
            (otherExerciseSection) =>
                (otherExerciseSection.exerciseInWorkoutDto.superSetId ==
                    superSetId) &&
                otherExerciseSection.exerciseInWorkoutDto.exercise.id !=
                    firstExerciseSection.exerciseInWorkoutDto.exercise.id);
        if (otherExerciseSections.isNotEmpty) {
          final secondExerciseSection = otherExerciseSections.first;

          final firstExerciseSectionIndex =
              exerciseInWorkoutListSection.indexWhere((exercise) =>
                  exercise.exerciseInWorkoutDto.exercise.id ==
                  firstExerciseSection.exerciseInWorkoutDto.exercise.id);
          final secondExerciseSectionIndex =
              exerciseInWorkoutListSection.indexWhere((exercise) =>
                  exercise.exerciseInWorkoutDto.exercise.id ==
                  secondExerciseSection.exerciseInWorkoutDto.exercise.id);
          exerciseInWorkoutListSection.swap(
              firstExerciseSectionIndex + 1, secondExerciseSectionIndex);
          break outerLoop;
        }
      }
    }
    return exerciseInWorkoutListSection;
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
      _showAlertDialog(
          title: "Alert",
          message: 'Please provide a name for this workout',
          actions: alertDialogActions);
      return;
    }

    if (_exercisesInWorkout.isEmpty) {
      _showAlertDialog(
          title: "Alert",
          message: "Workout must have exercise(s)",
          actions: alertDialogActions);
      return;
    }

    Provider.of<WorkoutProvider>(context, listen: false).createWorkout(
        name: _workoutNameController.text,
        notes: _workoutNotesController.text,
        exercises: _exercisesInWorkout);

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
            title: "Alert",
            message: 'Please provide a name for this workout',
            actions: alertDialogActions);
        return;
      }

      if (_exercisesInWorkout.isEmpty) {
        _showAlertDialog(
            title: "Alert",
            message: "Workout must have exercise(s)",
            actions: alertDialogActions);
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
        navigationBar: CupertinoNavigationBar(
          trailing: GestureDetector(
              onTap:
                  previousWorkoutDto != null ? _updateWorkout : _createWorkout,
              child: Text(previousWorkoutDto != null ? "Update" : "Save")),
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
                    CupertinoTextField(
                      controller: _workoutNameController,
                      expands: true,
                      padding: EdgeInsets.zero,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      keyboardType: TextInputType.text,
                      maxLength: 240,
                      maxLines: null,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.white.withOpacity(0.8),
                          fontSize: 18),
                      placeholder: "New workout",
                      placeholderStyle: const TextStyle(
                          color: CupertinoColors.inactiveGray, fontSize: 18),
                    ),
                    const SizedBox(
                      height: 14,
                    ),
                    CupertinoTextField(
                      controller: _workoutNotesController,
                      expands: true,
                      padding: EdgeInsets.zero,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      keyboardType: TextInputType.text,
                      maxLength: 240,
                      maxLines: null,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                      placeholder: "New notes",
                      placeholderStyle: const TextStyle(
                          color: CupertinoColors.inactiveGray, fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    ..._exercisesToListSection(
                        exercisesInWorkout: _exercisesInWorkout),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                          color: tealBlueLight,
                          onPressed: _selectExercisesInLibrary,
                          child: const Text("Add exercise",
                              textAlign: TextAlign.start,
                              style: TextStyle(fontWeight: FontWeight.bold))),
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

  const _ListOfExercises(
      {required this.exercises,
      required this.onSelect,
      required this.onSelectExercisesInLibrary});

  @override
  State<_ListOfExercises> createState() => _ListOfExercisesState();
}

class _ListOfExercisesState extends State<_ListOfExercises> {

  late ExerciseInWorkoutDto _exerciseInWorkoutDto;

  @override
  Widget build(BuildContext context) {
    return widget.exercises.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => widget.onSelect(_exerciseInWorkoutDto),
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    "Select",
                    style: TextStyle(fontWeight: FontWeight.bold),
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
                  children:
                      List<Widget>.generate(widget.exercises.length, (int index) {
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
                  child: const Text(
                    "Add more exercises",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  )),
            ),
          )
        ],
      ),
    );
  }
}
