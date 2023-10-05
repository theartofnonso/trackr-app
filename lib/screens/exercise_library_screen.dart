import 'package:flutter/cupertino.dart';
import 'package:tracker_app/dtos/exercise_dto.dart';

import '../widgets/exercise_list_section.dart';
import '../widgets/exercise_item.dart';

class ExerciseLibraryScreen extends StatefulWidget {

  final List<Exercise> preSelectedExercises;

  const ExerciseLibraryScreen({super.key, required this.preSelectedExercises});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  List<ExerciseItem> _exerciseItems = <ExerciseItem>[
    ExerciseItem(exercise: Exercise("Incline Dumbbells", BodyPart.chest)),
    ExerciseItem(exercise: Exercise("Chest Flys", BodyPart.chest)),
    ExerciseItem(
        exercise: Exercise("Decline Smith machine press", BodyPart.chest)),
    ExerciseItem(exercise: Exercise("Chest Dips", BodyPart.chest)),
    ExerciseItem(exercise: Exercise("Lateral Raises", BodyPart.shoulders)),
    ExerciseItem(exercise: Exercise("Military press", BodyPart.shoulders)),
    ExerciseItem(
        exercise: Exercise("Single Lateral Raises", BodyPart.shoulders)),
    ExerciseItem(
        exercise: Exercise("Double Lateral Raises", BodyPart.shoulders)),
    ExerciseItem(exercise: Exercise("Skull Crushers", BodyPart.triceps)),
    ExerciseItem(exercise: Exercise("Tricep Extensions", BodyPart.triceps)),
    ExerciseItem(exercise: Exercise("Tricep Dips", BodyPart.triceps)),
    ExerciseItem(exercise: Exercise("Pulldowns", BodyPart.triceps)),
    ExerciseItem(exercise: Exercise("Deadlift", BodyPart.legs)),
    ExerciseItem(exercise: Exercise("Hamstring Curls", BodyPart.legs)),
    ExerciseItem(exercise: Exercise("Romanian Deadlift", BodyPart.legs)),
    ExerciseItem(exercise: Exercise("Single Leg Curl", BodyPart.legs)),
  ];

  List<ExerciseItem> _filteredExercises = [];

  final List<ExerciseItem> _selectedExercises = [];

  void _whereExercises({required String searchTerm}) {
    setState(() {
      _filteredExercises = _exerciseItems
          .where((exerciseItem) => exerciseItem.exercise.name
              .toLowerCase()
              .contains(searchTerm.toLowerCase()))
          .toList();
      ;
    });
  }

  void _onSelectExercise({required ExerciseItem exerciseItem}) {
    setState(() {
      _selectedExercises.add(exerciseItem);
    });
  }

  void _onRemoveExercise({required ExerciseItem exerciseItem}) {
    setState(() {
      _selectedExercises.remove(exerciseItem);
    });
  }

  void _navigateBack() {
    final exercises = _selectedExercises.map((exerciseItem) => exerciseItem.exercise).toList();
    Navigator.of(context).pop(exercises);
  }

  @override
  Widget build(BuildContext context) {
    final chestExercises = _filteredExercises
        .where(
            (exerciseItem) => exerciseItem.exercise.bodyPart == BodyPart.chest)
        .toList();

    final shouldersExercises = _filteredExercises
        .where((exerciseItem) =>
            exerciseItem.exercise.bodyPart == BodyPart.shoulders)
        .toList();

    final tricepsExercises = _filteredExercises
        .where((exerciseItem) =>
            exerciseItem.exercise.bodyPart == BodyPart.triceps)
        .toList();

    final legsExercises = _filteredExercises
        .where(
            (exerciseItem) => exerciseItem.exercise.bodyPart == BodyPart.legs)
        .toList();

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        trailing: GestureDetector(
            onTap: _navigateBack,
            child: _selectedExercises.isNotEmpty
                ? Text(
                    "Add (${_selectedExercises.length})",
                    style: const TextStyle(color: CupertinoColors.white),
                  )
                : const SizedBox.shrink()),
      ),
      child: ListView(
        children: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: CupertinoSearchTextField(
                  onChanged: (searchTerm) =>
                      _whereExercises(searchTerm: searchTerm))),
          ExerciseListSection(
            exercises: chestExercises,
            bodyPart: BodyPart.chest,
            onSelect: (ExerciseItem exerciseItemToBeAdded) =>
                _onSelectExercise(exerciseItem: exerciseItemToBeAdded),
            onRemove: (ExerciseItem exerciseItemToBeRemoved) =>
                _onRemoveExercise(exerciseItem: exerciseItemToBeRemoved),
          ),
          ExerciseListSection(
            exercises: shouldersExercises,
            bodyPart: BodyPart.shoulders,
            onSelect: (ExerciseItem exerciseItemToBeAdded) =>
                _onSelectExercise(exerciseItem: exerciseItemToBeAdded),
            onRemove: (ExerciseItem exerciseItemToBeRemoved) =>
                _onRemoveExercise(exerciseItem: exerciseItemToBeRemoved),
          ),
          ExerciseListSection(
            exercises: tricepsExercises,
            bodyPart: BodyPart.triceps,
            onSelect: (ExerciseItem exerciseItemToBeAdded) =>
                _onSelectExercise(exerciseItem: exerciseItemToBeAdded),
            onRemove: (ExerciseItem exerciseItemToBeRemoved) =>
                _onRemoveExercise(exerciseItem: exerciseItemToBeRemoved),
          ),
          ExerciseListSection(
            exercises: legsExercises,
            bodyPart: BodyPart.legs,
            onSelect: (ExerciseItem exerciseItemToBeAdded) =>
                _onSelectExercise(exerciseItem: exerciseItemToBeAdded),
            onRemove: (ExerciseItem exerciseItemToBeRemoved) =>
                _onRemoveExercise(exerciseItem: exerciseItemToBeRemoved),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final exercisesItems = _exerciseItems.where((exerciseItem) => !widget.preSelectedExercises.contains(exerciseItem.exercise)).toList();
    if(exercisesItems.isNotEmpty) {
      _exerciseItems = exercisesItems;
      _filteredExercises = _exerciseItems;
    } else {
      _filteredExercises = _exerciseItems;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
