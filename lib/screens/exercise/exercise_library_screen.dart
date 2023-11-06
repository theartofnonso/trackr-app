import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/providers/exercise_provider.dart';
import 'package:tracker_app/screens/editor/exercise_editor_screen.dart';

import '../../app_constants.dart';
import '../../models/Exercise.dart';
import '../../widgets/buttons/text_button_widget.dart';
import '../../widgets/exercise/exercise_widget.dart';
import '../../widgets/exercise/selectable_exercise_widget.dart';

class ExerciseInLibraryDto {
  final bool selected;
  final Exercise exercise;

  ExerciseInLibraryDto({this.selected = false, required this.exercise});

  ExerciseInLibraryDto copyWith({bool? selected, Exercise? exercise}) {
    return ExerciseInLibraryDto(
      selected: selected ?? this.selected,
      exercise: exercise ?? this.exercise,
    );
  }
}

class ExerciseLibraryScreen extends StatefulWidget {
  final bool multiSelect;

  const ExerciseLibraryScreen({super.key, this.multiSelect = true});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  List<ExerciseInLibraryDto> _exercisesInLibrary = [];

  /// Holds a list of [ExerciseInLibraryDto] when filtering through a search
  List<ExerciseInLibraryDto> _filteredExercises = [];

  /// Search through the list of exercises
  void _runSearch({required String searchTerm}) {
    setState(() {
      _filteredExercises = _exercisesInLibrary
          .where((exerciseItem) => (exerciseItem.exercise.name.toLowerCase().contains(searchTerm.toLowerCase()) ||
              exerciseItem.exercise.name.toLowerCase().startsWith(searchTerm.toLowerCase()) ||
              exerciseItem.exercise.name.toLowerCase() == searchTerm.toLowerCase()))
          .toList();
    });
  }

  /// Navigate to previous screen
  void _addSelectedExercises() {
    final exercises = _whereSelectedExercises().map((exerciseInLibrary) => exerciseInLibrary.exercise).toList();
    Navigator.of(context).pop(exercises);
  }

  int _indexWhereExercise({required String exerciseId}) {
    return _exercisesInLibrary.indexWhere((exerciseInLibrary) => exerciseInLibrary.exercise.id == exerciseId);
  }

  int _indexWhereFilteredExercise({required String exerciseId}) {
    return _filteredExercises.indexWhere((exerciseInLibrary) => exerciseInLibrary.exercise.id == exerciseId);
  }

  List<ExerciseInLibraryDto> _whereSelectedExercises() {
    return _exercisesInLibrary.where((exerciseInLibrary) => exerciseInLibrary.selected).toList();
  }

  /// Select up to many exercise
  void _selectCheckedExercise({required bool selected, required ExerciseInLibraryDto exerciseInLibraryDto}) {
    final exerciseIndex = _indexWhereExercise(exerciseId: exerciseInLibraryDto.exercise.id);
    final filteredExerciseIndex = _indexWhereFilteredExercise(exerciseId: exerciseInLibraryDto.exercise.id);
    if (selected) {
      setState(() {
        _exercisesInLibrary[exerciseIndex] = exerciseInLibraryDto.copyWith(selected: true);
        _filteredExercises[filteredExerciseIndex] = exerciseInLibraryDto.copyWith(selected: true);
      });
    } else {
      setState(() {
        _exercisesInLibrary[exerciseIndex] = exerciseInLibraryDto.copyWith(selected: false);
        _filteredExercises[filteredExerciseIndex] = exerciseInLibraryDto.copyWith(selected: false);
      });
    }
  }

  /// Select an exercise
  void _selectExercise({required ExerciseInLibraryDto selectedExercise}) {
    Navigator.of(context).pop([selectedExercise.exercise]);
  }

  /// Convert [ExerciseInLibraryDto] to [SelectableExerciseWidget]
  Widget _exercisesToWidgets() {
    if (widget.multiSelect) {
      return ListView.separated(
          itemBuilder: (BuildContext context, int index) => SelectableExerciseWidget(
              exerciseInLibraryDto: _filteredExercises[index],
              onTap: (selected) => _selectCheckedExercise(selected: selected, exerciseInLibraryDto: _filteredExercises[index])),
          separatorBuilder: (BuildContext context, int index) => Divider(color: Colors.white70.withOpacity(0.1)),
          itemCount: _filteredExercises.length);
    }
    return ListView.separated(
        itemBuilder: (BuildContext context, int index) => ExerciseWidget(
            exerciseInLibraryDto: _filteredExercises[index],
            onTap: () => _selectExercise(selectedExercise: _filteredExercises[index])),
        separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 14),
        itemCount: _filteredExercises.length);
  }

  void _dismissKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  void _navigateToExerciseEditor() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ExerciseEditorScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          _whereSelectedExercises().isNotEmpty
              ? CTextButton(
                  onPressed: _addSelectedExercises,
                  label: "Add (${_whereSelectedExercises().length})",
                  buttonColor: Colors.transparent,
                )
              : const SizedBox.shrink()
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "fab_exercise_library_screen",
        onPressed: _navigateToExerciseEditor,
        backgroundColor: tealBlueLighter,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        child: const Icon(Icons.add),
      ),
      body: NotificationListener(
        onNotification: (scrollNotification) {
          if (scrollNotification is ScrollStartNotification) {
            _dismissKeyboard(context);
          }
          return false;
        },
        child: Padding(
          padding: const EdgeInsets.only(right: 10.0, bottom: 10, left: 10),
          child: Column(
            children: [
              SearchBar(
                onChanged: (searchTerm) => _runSearch(searchTerm: searchTerm),
                leading: const Icon(
                  Icons.search_rounded,
                  color: Colors.white70,
                ),
                hintText: "Search exercises",
                hintStyle: MaterialStatePropertyAll<TextStyle>(GoogleFonts.lato(color: Colors.white70)),
                textStyle: MaterialStatePropertyAll<TextStyle>(GoogleFonts.lato(color: Colors.white)),
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
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _exercisesInLibrary = Provider.of<ExerciseProvider>(context, listen: false)
        .exercises
        .map((exercise) => ExerciseInLibraryDto(exercise: exercise))
        .toList();
    _filteredExercises = _exercisesInLibrary;
  }
}
