import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/exercise_dto.dart';
import 'package:tracker_app/dtos/exercise_in_workout_dto.dart';
import 'package:tracker_app/dtos/workout_dto.dart';
import 'package:tracker_app/providers/exercise_in_workout_provider.dart';
import '../app_constants.dart';
import '../widgets/workout/exercise_in_workout_list_section.dart';
import 'exercise_library_screen.dart';

class NewWorkoutScreen extends StatefulWidget {

  final WorkoutDto? workoutDto;
  const NewWorkoutScreen({super.key, this.workoutDto});

  @override
  State<NewWorkoutScreen> createState() => _NewWorkoutScreenState();
}

class _NewWorkoutScreenState extends State<NewWorkoutScreen> {
  late TextEditingController _workoutNameController;
  late TextEditingController _workoutNotesController;

  /// Show [CupertinoAlertDialog] for creating a workout
  void _showCreateAlertDialog({required String message}) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Alert'),
        content: Text(message),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }

  /// Show list of [ExerciseInWorkoutDto] to superset with
  void _showExercisesInWorkoutPicker(
      {required ExerciseInWorkoutDto firstSuperSetExercise}) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        decoration: const BoxDecoration(
            color: tealBlueDark,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12), topRight: Radius.circular(12))),
        height: 150,
        padding: const EdgeInsets.only(top: 6.0),
        // The Bottom margin is provided to align the popup above the system navigation bar.
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Provider.of<ExerciseInWorkoutProvider>(context, listen: false)
                .canSuperSet()
            ? _ListOfExercises(
                exercises: Provider.of<ExerciseInWorkoutProvider>(context, listen: false)
                    .whereOtherExercisesToSuperSetWith(
                        firstExercise: firstSuperSetExercise),
                onSelect: (ExerciseInWorkoutDto exercise) =>
                    Provider.of<ExerciseInWorkoutProvider>(context, listen: false)
                        .addSuperSets(
                            firstExercise: firstSuperSetExercise,
                            secondExercise: exercise),
              )
            : _ExercisesInWorkoutEmptyState(onPressed: () {
                Navigator.of(context).pop();
                _showListOfExercisesInLibrary();
              }),
      ),
    );
  }

  /// Navigate to [ExerciseLibraryScreen]
  Future<void> _showListOfExercisesInLibrary() async {
    final selectedExercises = await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return ExerciseLibraryScreen(
            preSelectedExercises:
                Provider.of<ExerciseInWorkoutProvider>(context, listen: false)
                    .exercisesInWorkout
                    .map((exerciseInWorkout) => exerciseInWorkout.exercise)
                    .toList());
      },
    ) as List<ExerciseDto>?;

    if (selectedExercises != null) {
      if (mounted) {
        Provider.of<ExerciseInWorkoutProvider>(context, listen: false)
            .addExercises(exercises: selectedExercises);
      }
    }
  }

  /// Convert list of [ExerciseInWorkout] to [ExerciseInWorkoutListSection]
  List<ExerciseInWorkoutListSection> _exercisesToExerciseInWorkoutListSection(
      {required List<ExerciseInWorkoutDto> exercisesInWorkout}) {
    final exerciseInWorkoutListSection = exercisesInWorkout
        .mapIndexed((index, exerciseInWorkout) => ExerciseInWorkoutListSection(
              index: index,
              keyValue: Key(exerciseInWorkout.exercise.name),
              exerciseInWorkoutDto: exerciseInWorkout,
              onAddSuperSetExercises:
                  (ExerciseInWorkoutDto firstSuperSetExercise) {
                _showExercisesInWorkoutPicker(
                    firstSuperSetExercise: firstSuperSetExercise);
              },
              onRemoveSuperSetExercises: (String superSetId) =>
                  Provider.of<ExerciseInWorkoutProvider>(context, listen: false)
                      .removeSuperSet(superSetId: superSetId),
              onRemoveExerciseInWorkout:
                  (ExerciseInWorkoutDto exerciseInWorkoutDto) {
                Provider.of<ExerciseInWorkoutProvider>(context, listen: false)
                    .removeExercise(exerciseToRemove: exerciseInWorkoutDto);
              },
            ))
        .toList();

    outerLoop:
    for (var i = 0; i < exerciseInWorkoutListSection.length; i++) {
      final exerciseSection = exerciseInWorkoutListSection[i];
      final exerciseInWorkoutDto = exerciseSection.exerciseInWorkoutDto;
      if (exerciseInWorkoutDto.isSuperSet) {
        final superSetId = exerciseInWorkoutDto.superSetId;
        final otherExerciseSections = exerciseInWorkoutListSection.where(
            (otherExerciseSection) =>
                (otherExerciseSection.exerciseInWorkoutDto.superSetId ==
                    superSetId) &&
                otherExerciseSection.exerciseInWorkoutDto.exercise !=
                    exerciseSection.exerciseInWorkoutDto.exercise);
        if (otherExerciseSections.isNotEmpty) {
          final otherExerciseSection = otherExerciseSections.first;
          exerciseInWorkoutListSection.swap(
              exerciseSection.index + 1, otherExerciseSection.index);
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
    if (_workoutNameController.text.isEmpty) {
      _showCreateAlertDialog(message: 'Please provide a name for this workout');
      return;
    }

    if (Provider.of<ExerciseInWorkoutProvider>(context, listen: false)
        .exercisesInWorkout
        .isEmpty) {
      _showCreateAlertDialog(message: "Workout can't have no exercise(s)");
      return;
    }

    Provider.of<ExerciseInWorkoutProvider>(context, listen: false).createWorkout(
        name: _workoutNameController.text, notes: _workoutNotesController.text);

    _navigateBack();
  }

  void _updateWorkout() {

    final workout = widget.workoutDto;

    if(workout != null) {
      if (_workoutNameController.text.isEmpty) {
        _showCreateAlertDialog(message: 'Please provide a name for this workout');
        return;
      }

      if (Provider.of<ExerciseInWorkoutProvider>(context, listen: false)
          .exercisesInWorkout
          .isEmpty) {
        _showCreateAlertDialog(message: "Workout can't have no exercise(s)");
        return;
      }

      Provider.of<ExerciseInWorkoutProvider>(context, listen: false).updateWorkout(
          id: workout.id,
          name: _workoutNameController.text, notes: _workoutNotesController.text);

      _navigateBack();
    }
  }

  @override
  Widget build(BuildContext context) {

    final previousWorkoutDto = widget.workoutDto;

    final exercises =
        Provider.of<ExerciseInWorkoutProvider>(context, listen: true).exercisesInWorkout;

    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          trailing: GestureDetector(
              onTap: previousWorkoutDto != null ? _updateWorkout : _createWorkout,
              child: Text(previousWorkoutDto != null ? "Update" : "Save")),
        ),
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: SafeArea(
            child: SingleChildScrollView(
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
                      height: 12,
                    ),
                    CupertinoTextField(
                      controller: _workoutNotesController,
                      expands: true,
                      padding: EdgeInsets.zero,
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
                    ..._exercisesToExerciseInWorkoutListSection(exercisesInWorkout: exercises),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                          color: tealBlueLight,
                          onPressed: _showListOfExercisesInLibrary,
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

    if(workout != null) {
      Provider.of<ExerciseInWorkoutProvider>(context, listen: false)
          .addExercisesInWorkout(exercises: workout.exercises);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _workoutNameController.dispose();
    _workoutNotesController.dispose();
  }
}

class _ListOfExercises extends StatelessWidget {
  final List<ExerciseInWorkoutDto> exercises;
  final void Function(ExerciseInWorkoutDto exercise) onSelect;

  const _ListOfExercises({required this.exercises, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ...exercises
            .map((exerciseInWorkout) => CupertinoListTile(
                  onTap: () {
                    Navigator.of(context).pop();
                    onSelect(exerciseInWorkout);
                  },
                  title: Text(exerciseInWorkout.exercise.name,
                      style: const TextStyle(
                          color: CupertinoColors.white, fontSize: 16)),
                ))
            .toList()
      ],
    );
  }
}

class _ExercisesInWorkoutEmptyState extends StatelessWidget {
  final Function() onPressed;

  const _ExercisesInWorkoutEmptyState({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Add an exercise to superset with"),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
                color: tealBlueLight,
                onPressed: onPressed,
                child: const Text(
                  "Add new exercise",
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
          )
        ],
      ),
    );
  }
}
