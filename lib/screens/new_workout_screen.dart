import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/exercise_dto.dart';
import 'package:tracker_app/dtos/exercise_in_workout_dto.dart';
import 'package:tracker_app/providers/exercise_in_workout_provider.dart';
import '../app_constants.dart';
import '../widgets/workout/exercise_in_workout_list_section.dart';
import 'exercise_library_screen.dart';

class NewWorkoutScreen extends StatefulWidget {
  const NewWorkoutScreen({super.key});

  @override
  State<NewWorkoutScreen> createState() => _NewWorkoutScreenState();
}

class _NewWorkoutScreenState extends State<NewWorkoutScreen> {
  /// Show [CupertinoAlertDialog]
  void _showRemoveExerciseAlertDialog(
      {required ExerciseInWorkoutDto exerciseDto}) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Alert'),
        content: const Text("Do you want to remove this exercise"),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('No'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              Provider.of<ExerciseInWorkoutProvider>(context, listen: false)
                  .removeExercise(exerciseToRemove: exerciseDto);
            },
            child: const Text('Yes'),
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
            ? ListOfExercises(
                exercises: Provider.of<ExerciseInWorkoutProvider>(context,
                        listen: false)
                    .whereOtherExercisesToSuperSetWith(
                        firstExercise: firstSuperSetExercise),
                onSelect: (ExerciseInWorkoutDto exercise) =>
                    Provider.of<ExerciseInWorkoutProvider>(context,
                            listen: false)
                        .addSuperSets(
                            firstExercise: firstSuperSetExercise,
                            secondExercise: exercise),
              )
            : ListOfExercisesEmptyState(onPress: _showListOfExercisesInLibrary),
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
      // setState(() {
      //   _exercisesInWorkout.addAll(selectedExercises
      //       .map((exercise) =>
      //           ExerciseInWorkoutDto(exercise: exercise, procedures: []))
      //       .toList());
      // });
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
                _showRemoveExerciseAlertDialog(
                    exerciseDto: exerciseInWorkoutDto);
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

  void _saveWorkout() {

  }

  @override
  Widget build(BuildContext context) {
    final exercises =
        Provider.of<ExerciseInWorkoutProvider>(context, listen: true)
            .exercisesInWorkout;

    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          trailing: GestureDetector(
              onTap: _navigateBack,
              child: const Icon(
                CupertinoIcons.check_mark_circled,
                size: 24,
              )),
        ),
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 10, left: 20.0, bottom: 20),
                    child: CupertinoTextField(
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
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Notes",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        CupertinoTextField(
                          expands: true,
                          padding: EdgeInsets.zero,
                          decoration: const BoxDecoration(
                              color: Colors.transparent,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8))),
                          keyboardType: TextInputType.text,
                          maxLength: 240,
                          maxLines: null,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.white.withOpacity(0.8),
                              fontSize: 14,
                              height: 1.8),
                          placeholder: "New notes",
                          placeholderStyle: const TextStyle(
                              color: CupertinoColors.inactiveGray,
                              fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  ..._exercisesToExerciseInWorkoutListSection(
                      exercisesInWorkout: exercises),
                  const SizedBox(height: 18),
                  GestureDetector(
                    onTap: _showListOfExercisesInLibrary,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 20),
                      margin: const EdgeInsets.only(
                          left: 10, right: 10, bottom: 20),
                      width: double.infinity,
                      decoration: const BoxDecoration(
                          color: tealBlueLight,
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      height: 40,
                      child: const Text("Add exercise",
                          textAlign: TextAlign.start,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

class ListOfExercises extends StatelessWidget {
  final List<ExerciseInWorkoutDto> exercises;
  final void Function(ExerciseInWorkoutDto exercise) onSelect;

  const ListOfExercises(
      {super.key, required this.exercises, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: false,
        child: ListView(
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
        ));
  }
}

class ListOfExercisesEmptyState extends StatelessWidget {
  final Function() onPress;

  const ListOfExercisesEmptyState({super.key, required this.onPress});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Add an exercise to superset with"),
          const SizedBox(height: 16),
          GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                onPress();
              },
              child: const Center(
                  child: Text(
                "Add new exercise",
                style: TextStyle(fontWeight: FontWeight.bold),
              )))
        ],
      ),
    );
  }
}
