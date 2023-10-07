import 'package:flutter/cupertino.dart';
import 'package:tracker_app/dtos/exercise_dto.dart';

import '../widgets/exercise_library/exercise_library_list_section.dart';
import '../dtos/exercise_in_library_dto.dart';

class ExerciseLibraryScreen extends StatefulWidget {

  final List<ExerciseDto> preSelectedExercises;

  const ExerciseLibraryScreen({super.key, required this.preSelectedExercises});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  final List<ExerciseInLibraryDto> _exerciseItems = <ExerciseInLibraryDto>[
    ExerciseInLibraryDto(exercise: ExerciseDto("Incline Dumbbells", BodyPart.chest)),
    ExerciseInLibraryDto(exercise: ExerciseDto("Chest Flys", BodyPart.chest)),
    ExerciseInLibraryDto(
        exercise: ExerciseDto("Decline Smith machine press", BodyPart.chest)),
    ExerciseInLibraryDto(exercise: ExerciseDto("Chest Dips", BodyPart.chest)),
    ExerciseInLibraryDto(exercise: ExerciseDto("Lateral Raises", BodyPart.shoulders)),
    ExerciseInLibraryDto(exercise: ExerciseDto("Military press", BodyPart.shoulders)),
    ExerciseInLibraryDto(
        exercise: ExerciseDto("Single Lateral Raises", BodyPart.shoulders)),
    ExerciseInLibraryDto(
        exercise: ExerciseDto("Double Lateral Raises", BodyPart.shoulders)),
    ExerciseInLibraryDto(exercise: ExerciseDto("Skull Crushers", BodyPart.triceps)),
    ExerciseInLibraryDto(exercise: ExerciseDto("Tricep Extensions", BodyPart.triceps)),
    ExerciseInLibraryDto(exercise: ExerciseDto("Tricep Dips", BodyPart.triceps)),
    ExerciseInLibraryDto(exercise: ExerciseDto("Pulldowns", BodyPart.triceps)),
    ExerciseInLibraryDto(exercise: ExerciseDto("Deadlift", BodyPart.legs)),
    ExerciseInLibraryDto(exercise: ExerciseDto("Hamstring Curls", BodyPart.legs)),
    ExerciseInLibraryDto(exercise: ExerciseDto("Romanian Deadlift", BodyPart.legs)),
    ExerciseInLibraryDto(exercise: ExerciseDto("Single Leg Curl", BodyPart.legs)),
  ];

  List<ExerciseInLibraryDto> _filteredExercises = [];

  final List<ExerciseInLibraryDto> _selectedExercises = [];

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

  void _onSelectExercise({required ExerciseInLibraryDto exerciseItem}) {
    setState(() {
      _selectedExercises.add(exerciseItem);
    });
  }

  void _onRemoveExercise({required ExerciseInLibraryDto exerciseItem}) {
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
            onSelect: (ExerciseInLibraryDto exerciseItemToBeAdded) =>
                _onSelectExercise(exerciseItem: exerciseItemToBeAdded),
            onRemove: (ExerciseInLibraryDto exerciseItemToBeRemoved) =>
                _onRemoveExercise(exerciseItem: exerciseItemToBeRemoved),
          ),
          ExerciseLibraryListSection(
            exercises: shouldersExercises,
            bodyPart: BodyPart.shoulders,
            onSelect: (ExerciseInLibraryDto exerciseItemToBeAdded) =>
                _onSelectExercise(exerciseItem: exerciseItemToBeAdded),
            onRemove: (ExerciseInLibraryDto exerciseItemToBeRemoved) =>
                _onRemoveExercise(exerciseItem: exerciseItemToBeRemoved),
          ),
          ExerciseLibraryListSection(
            exercises: tricepsExercises,
            bodyPart: BodyPart.triceps,
            onSelect: (ExerciseInLibraryDto exerciseItemToBeAdded) =>
                _onSelectExercise(exerciseItem: exerciseItemToBeAdded),
            onRemove: (ExerciseInLibraryDto exerciseItemToBeRemoved) =>
                _onRemoveExercise(exerciseItem: exerciseItemToBeRemoved),
          ),
          ExerciseLibraryListSection(
            exercises: legsExercises,
            bodyPart: BodyPart.legs,
            onSelect: (ExerciseInLibraryDto exerciseItemToBeAdded) =>
                _onSelectExercise(exerciseItem: exerciseItemToBeAdded),
            onRemove: (ExerciseInLibraryDto exerciseItemToBeRemoved) =>
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
    _filteredExercises = exercisesItems;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
