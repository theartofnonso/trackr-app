import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/providers/exercises_provider.dart';

import '../app_constants.dart';
import '../models/Exercise.dart';
import '../widgets/exercise/exercise_library_list_item.dart';
import '../widgets/exercise/selectable_exercise_library_list_item.dart';

class ExerciseInLibraryDto {
  bool? isSelected;
  final Exercise exercise;

  ExerciseInLibraryDto({this.isSelected = false, required this.exercise});
}

class ExerciseLibraryScreen extends StatefulWidget {
  final List<Exercise> preSelectedExercises;
  final bool multiSelect;

  const ExerciseLibraryScreen({super.key, required this.preSelectedExercises, this.multiSelect = true});

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
          .where((exerciseItem) => exerciseItem.exercise.name.toLowerCase().contains(searchTerm.toLowerCase()))
          .toList();
    });
  }

  /// Navigate to previous screen
  void _addSelectedExercises() {
    final exercises = _selectedExercises.map((exerciseInLibrary) => exerciseInLibrary.exercise).toList();
    Navigator.of(context).pop(exercises);
  }

  /// Select up to many exercise
  void _selectCheckedExercise({required bool isSelected, required ExerciseInLibraryDto selectedExercise}) {
    if (isSelected) {
      selectedExercise.isSelected = true;
      setState(() {
        _selectedExercises.add(selectedExercise);
      });
    } else {
      selectedExercise.isSelected = false;
      setState(() {
        _selectedExercises.remove(selectedExercise);
      });
    }
  }

  /// Select an exercise
  void _selectExercise({required ExerciseInLibraryDto selectedExercise}) {
    setState(() {
      _selectedExercises.add(selectedExercise);
    });
  }

  /// Convert [ExerciseInLibraryDto] to [SelectableExrLibraryListItem]
  Widget _exercisesToWidgets() {
    if (widget.multiSelect) {
      return ListView.separated(
          itemBuilder: (BuildContext context, int index) => SelectableExrLibraryListItem(
              exerciseInLibrary: _filteredExercises[index],
              onTap: (isSelected) =>
                  _selectCheckedExercise(isSelected: isSelected, selectedExercise: _filteredExercises[index])),
          separatorBuilder: (BuildContext context, int index) => Divider(color: Colors.white70.withOpacity(0.1)),
          itemCount: _filteredExercises.length);
    }
    return ListView.separated(
        itemBuilder: (BuildContext context, int index) => ExrLibraryListItem(
            exerciseInLibrary: _filteredExercises[index],
            onTap: () => _selectExercise(selectedExercise: _filteredExercises[index])),
        separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 14),
        itemCount: _filteredExercises.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        backgroundColor: tealBlueDark,
        trailing: GestureDetector(
            onTap: _addSelectedExercises,
            child: _selectedExercises.isNotEmpty
                ? Text(
                    "Add (${_selectedExercises.length})",
                    style: const TextStyle(color: Colors.white),
                  )
                : const SizedBox.shrink()),
      ),
      body: Padding(
        padding: const EdgeInsets.only(right: 10.0, bottom: 10, left: 10),
        child: Column(
          children: [
            SearchBar(
              onChanged: (searchTerm) => _whereExercises(searchTerm: searchTerm),
              leading: const Icon(
                Icons.search_rounded,
                color: Colors.white70,
              ),
              hintText: "Search exercises",
              hintStyle: const MaterialStatePropertyAll<TextStyle>(TextStyle(color: Colors.white70)),
              textStyle: const MaterialStatePropertyAll<TextStyle>(TextStyle(color: Colors.white)),
              surfaceTintColor: const MaterialStatePropertyAll<Color>(tealBlueLight),
              backgroundColor: const MaterialStatePropertyAll<Color>(tealBlueLight),
              shape: MaterialStatePropertyAll<OutlinedBorder>(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              )),
              constraints: const BoxConstraints(minHeight: 50),
            ),
            const SizedBox(height: 12),
            Expanded(child: _exercisesToWidgets())
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final exercises = Provider.of<ExerciseProvider>(context, listen: false)
        .exercises
        .map((exercise) => ExerciseInLibraryDto(exercise: exercise));

    _exercisesInLibrary.addAll(exercises);

    _filteredExercises = _exercisesInLibrary
        .whereNot((exerciseInLibrary) => widget.preSelectedExercises.contains(exerciseInLibrary.exercise))
        .toList();
  }
}
