import 'package:flutter/cupertino.dart';
import 'package:tracker_app/dtos/exercise_dto.dart';

import '../widgets/exercise_library/exercise_library_list_section.dart';
import '../widgets/exercise_library/exercise_library_item.dart';

class ExerciseLibraryScreen extends StatefulWidget {

  final List<Exercise> preSelectedExercises;

  const ExerciseLibraryScreen({super.key, required this.preSelectedExercises});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  List<ExerciseLibraryItem> _exerciseItems = <ExerciseLibraryItem>[
    ExerciseLibraryItem(exercise: Exercise("Incline Dumbbells", BodyPart.chest)),
    ExerciseLibraryItem(exercise: Exercise("Chest Flys", BodyPart.chest)),
    ExerciseLibraryItem(
        exercise: Exercise("Decline Smith machine press", BodyPart.chest)),
    ExerciseLibraryItem(exercise: Exercise("Chest Dips", BodyPart.chest)),
    ExerciseLibraryItem(exercise: Exercise("Lateral Raises", BodyPart.shoulders)),
    ExerciseLibraryItem(exercise: Exercise("Military press", BodyPart.shoulders)),
    ExerciseLibraryItem(
        exercise: Exercise("Single Lateral Raises", BodyPart.shoulders)),
    ExerciseLibraryItem(
        exercise: Exercise("Double Lateral Raises", BodyPart.shoulders)),
    ExerciseLibraryItem(exercise: Exercise("Skull Crushers", BodyPart.triceps)),
    ExerciseLibraryItem(exercise: Exercise("Tricep Extensions", BodyPart.triceps)),
    ExerciseLibraryItem(exercise: Exercise("Tricep Dips", BodyPart.triceps)),
    ExerciseLibraryItem(exercise: Exercise("Pulldowns", BodyPart.triceps)),
    ExerciseLibraryItem(exercise: Exercise("Deadlift", BodyPart.legs)),
    ExerciseLibraryItem(exercise: Exercise("Hamstring Curls", BodyPart.legs)),
    ExerciseLibraryItem(exercise: Exercise("Romanian Deadlift", BodyPart.legs)),
    ExerciseLibraryItem(exercise: Exercise("Single Leg Curl", BodyPart.legs)),
  ];

  List<ExerciseLibraryItem> _filteredExercises = [];

  final List<ExerciseLibraryItem> _selectedExercises = [];

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

  void _onSelectExercise({required ExerciseLibraryItem exerciseItem}) {
    setState(() {
      _selectedExercises.add(exerciseItem);
    });
  }

  void _onRemoveExercise({required ExerciseLibraryItem exerciseItem}) {
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
          ExerciseLibraryListSection(
            exercises: chestExercises,
            bodyPart: BodyPart.chest,
            onSelect: (ExerciseLibraryItem exerciseItemToBeAdded) =>
                _onSelectExercise(exerciseItem: exerciseItemToBeAdded),
            onRemove: (ExerciseLibraryItem exerciseItemToBeRemoved) =>
                _onRemoveExercise(exerciseItem: exerciseItemToBeRemoved),
          ),
          ExerciseLibraryListSection(
            exercises: shouldersExercises,
            bodyPart: BodyPart.shoulders,
            onSelect: (ExerciseLibraryItem exerciseItemToBeAdded) =>
                _onSelectExercise(exerciseItem: exerciseItemToBeAdded),
            onRemove: (ExerciseLibraryItem exerciseItemToBeRemoved) =>
                _onRemoveExercise(exerciseItem: exerciseItemToBeRemoved),
          ),
          ExerciseLibraryListSection(
            exercises: tricepsExercises,
            bodyPart: BodyPart.triceps,
            onSelect: (ExerciseLibraryItem exerciseItemToBeAdded) =>
                _onSelectExercise(exerciseItem: exerciseItemToBeAdded),
            onRemove: (ExerciseLibraryItem exerciseItemToBeRemoved) =>
                _onRemoveExercise(exerciseItem: exerciseItemToBeRemoved),
          ),
          ExerciseLibraryListSection(
            exercises: legsExercises,
            bodyPart: BodyPart.legs,
            onSelect: (ExerciseLibraryItem exerciseItemToBeAdded) =>
                _onSelectExercise(exerciseItem: exerciseItemToBeAdded),
            onRemove: (ExerciseLibraryItem exerciseItemToBeRemoved) =>
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
