import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/providers/exercises_provider.dart';

import '../app_constants.dart';
import '../models/BodyPart.dart';
import '../models/Exercise.dart';
import '../widgets/exercise/exercise_library_list_section.dart';

class ExerciseInLibraryDto {

  bool? isSelected;
  final Exercise exercise;

  ExerciseInLibraryDto({this.isSelected = false, required this.exercise});
}

class ExerciseLibraryScreen extends StatefulWidget {
  final List<Exercise> preSelectedExercises;
  final bool multiSelect;

  const ExerciseLibraryScreen(
      {super.key, required this.preSelectedExercises, this.multiSelect = true});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  final List<ExerciseInLibraryDto> _exercisesInLibrary = [];

  /// Holds a list of [ExerciseInLibraryDto] when filtering through a search
  List<ExerciseInLibraryDto> _filteredExercises = [];

  /// Holds a list of selected [ExerciseInLibraryDto]
  final List<ExerciseInLibraryDto> _selectedExercises = [];

  /// Search through the list of exercises
  void _whereExercises({required String searchTerm}) {
    setState(() {
      _filteredExercises = _exercisesInLibrary
          .where((exerciseItem) => exerciseItem.exercise.name
              .toLowerCase()
              .contains(searchTerm.toLowerCase()))
          .toList();
    });
  }

  /// Select an exercise
  void _selectExercise({required ExerciseInLibraryDto exerciseInLibrary}) {
    if (widget.multiSelect) {
      setState(() {
        _selectedExercises.add(exerciseInLibrary);
      });
    } else {
      Navigator.of(context).pop([exerciseInLibrary.exercise]);
    }
  }

  /// Remove an exercise
  void _removeExercise({required ExerciseInLibraryDto exerciseInLibrary}) {
    setState(() {
      _selectedExercises.remove(exerciseInLibrary);
    });
  }

  /// Navigate to previous screen
  void _addSelectedExercises() {
    final exercises = _selectedExercises
        .map((exerciseInLibrary) => exerciseInLibrary.exercise)
        .toList();
    Navigator.of(context).pop(exercises);
  }

  @override
  Widget build(BuildContext context) {
    final chestExercises = _filteredExercises
        .where(
            (exerciseItem) => exerciseItem.exercise.bodyPart == BodyPart.CHEST)
        .toList();

    final shouldersExercises = _filteredExercises
        .where((exerciseItem) =>
            exerciseItem.exercise.bodyPart == BodyPart.SHOULDERS)
        .toList();

    final tricepsExercises = _filteredExercises
        .where((exerciseItem) =>
            exerciseItem.exercise.bodyPart == BodyPart.TRICEPS)
        .toList();

    final legsExercises = _filteredExercises
        .where(
            (exerciseItem) => exerciseItem.exercise.bodyPart == BodyPart.LEGS)
        .toList();

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: tealBlueDark,
        trailing: GestureDetector(
            onTap: _addSelectedExercises,
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
            bodyPart: BodyPart.CHEST,
            onSelect: (ExerciseInLibraryDto exerciseItemToBeAdded) =>
                _selectExercise(exerciseInLibrary: exerciseItemToBeAdded),
            onRemove: (ExerciseInLibraryDto exerciseItemToBeRemoved) =>
                _removeExercise(exerciseInLibrary: exerciseItemToBeRemoved),
            multiSelect: widget.multiSelect,
          ),
          ExerciseLibraryListSection(
              exercises: shouldersExercises,
              bodyPart: BodyPart.SHOULDERS,
              onSelect: (ExerciseInLibraryDto exerciseItemToBeAdded) =>
                  _selectExercise(exerciseInLibrary: exerciseItemToBeAdded),
              onRemove: (ExerciseInLibraryDto exerciseItemToBeRemoved) =>
                  _removeExercise(exerciseInLibrary: exerciseItemToBeRemoved),
              multiSelect: widget.multiSelect),
          ExerciseLibraryListSection(
              exercises: tricepsExercises,
              bodyPart: BodyPart.TRICEPS,
              onSelect: (ExerciseInLibraryDto exerciseItemToBeAdded) =>
                  _selectExercise(exerciseInLibrary: exerciseItemToBeAdded),
              onRemove: (ExerciseInLibraryDto exerciseItemToBeRemoved) =>
                  _removeExercise(exerciseInLibrary: exerciseItemToBeRemoved),
              multiSelect: widget.multiSelect),
          ExerciseLibraryListSection(
              exercises: legsExercises,
              bodyPart: BodyPart.LEGS,
              onSelect: (ExerciseInLibraryDto exerciseItemToBeAdded) =>
                  _selectExercise(exerciseInLibrary: exerciseItemToBeAdded),
              onRemove: (ExerciseInLibraryDto exerciseItemToBeRemoved) =>
                  _removeExercise(exerciseInLibrary: exerciseItemToBeRemoved),
              multiSelect: widget.multiSelect),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final exercises = Provider.of<ExerciseProvider>(context, listen: false).exercises.map((exercise) => ExerciseInLibraryDto(exercise: exercise));
    _exercisesInLibrary.addAll(exercises);
    _filteredExercises = _exercisesInLibrary
        .whereNot((exerciseInLibrary) =>
            widget.preSelectedExercises.contains(exerciseInLibrary.exercise))
        .toList();
  }
}
