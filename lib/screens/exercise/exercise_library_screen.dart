import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/providers/exercise_provider.dart';
import 'package:tracker_app/screens/editor/exercise_editor_screen.dart';

import '../../app_constants.dart';
import '../../models/Exercise.dart';
import '../../widgets/buttons/text_button_widget.dart';
import '../../widgets/empty_states/screen_empty_state.dart';
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

  @override
  String toString() {
    return 'ExerciseInLibraryDto{selected: $selected, exercise: ${exercise.name}}';
  }
}

class ExerciseLibraryScreen extends StatefulWidget {
  final bool multiSelect;

  const ExerciseLibraryScreen({super.key, this.multiSelect = true});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  final _searchController = TextEditingController();

  List<ExerciseInLibraryDto> _exercisesInLibrary = [];

  /// Holds a list of [ExerciseInLibraryDto] when filtering through a search
  List<ExerciseInLibraryDto> _filteredExercises = [];

  /// Search through the list of exercises
  void _runSearch(String searchTerm) {
    setState(() {
      final query = searchTerm.toLowerCase();
      _filteredExercises = _exercisesInLibrary
          .where((exerciseItem) => (exerciseItem.exercise.name.toLowerCase().contains(query) ||
              exerciseItem.exercise.name.toLowerCase().startsWith(query) ||
              exerciseItem.exercise.name.toLowerCase().endsWith(query) ||
              exerciseItem.exercise.name.toLowerCase() == query))
          .toList();
    });
  }

  /// Navigate to previous screen
  void _navigateBackWithSelectedExercises() {
    final exercisesFromLibrary = _filteredExercises
        .where((exerciseInLibrary) => exerciseInLibrary.selected)
        .map((exerciseInLibrary) => exerciseInLibrary.exercise)
        .toList();
    Navigator.of(context).pop(exercisesFromLibrary);
  }

  /// Select an exercise
  void _navigateBackWithSelectedExercise({required ExerciseInLibraryDto selectedExercise}) {
    Navigator.of(context).pop([selectedExercise.exercise]);
  }

  /// Select up to many exercise
  void _selectCheckedExercise({required bool selected, required ExerciseInLibraryDto exerciseInLibraryDto}) {
    final exerciseIndex =
        _exercisesInLibrary.indexWhere((exercise) => exercise.exercise.id == exerciseInLibraryDto.exercise.id);
    final filteredExerciseIndex = _filteredExercises
        .indexWhere((filteredExercise) => filteredExercise.exercise.id == exerciseInLibraryDto.exercise.id);
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

  Widget _exerciseWidget(ExerciseInLibraryDto exerciseInLibraryDto) {
    if (widget.multiSelect) {
      return SelectableExerciseWidget(
          exerciseInLibraryDto: exerciseInLibraryDto,
          onTap: (selected) => _selectCheckedExercise(selected: selected, exerciseInLibraryDto: exerciseInLibraryDto));
    }
    return ExerciseWidget(
        exerciseInLibraryDto: exerciseInLibraryDto,
        onTap: () => _navigateBackWithSelectedExercise(selectedExercise: exerciseInLibraryDto));
  }

  void _dismissKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  void _navigateToExerciseEditor() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ExerciseEditorScreen()));
    if (mounted) {
      setState(() {
        final exercises = Provider.of<ExerciseProvider>(context, listen: false).exercises;
        _exercisesInLibrary = _updateSelections(exercises);
      });
    }
  }

  List<ExerciseInLibraryDto> _updateSelections(List<Exercise> allExercises) {
    final updatedExercises = allExercises.map((exercise) {
      final exerciseInLibrary =
          _exercisesInLibrary.firstWhereOrNull((exerciseInLibrary) => exerciseInLibrary.exercise.id == exercise.id);
      if (exerciseInLibrary != null) {
        if (exerciseInLibrary.selected) {
          return ExerciseInLibraryDto(exercise: exercise, selected: true);
        }
      }
      return ExerciseInLibraryDto(exercise: exercise);
    }).toList();

    _synchronizeFilteredList();
    return updatedExercises;
  }

  void _synchronizeFilteredList() {
    var idsInFilteredList = _filteredExercises.map((e) => e.exercise.id).toSet();
    _filteredExercises = _exercisesInLibrary.where((e) => idsInFilteredList.contains(e.exercise.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final exercises = Provider.of<ExerciseProvider>(context, listen: true).exercises;
    _exercisesInLibrary = _updateSelections(exercises);

    final selectedExercises = _filteredExercises.where((exerciseInLibrary) => exerciseInLibrary.selected).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          selectedExercises.isNotEmpty
              ? CTextButton(
                  onPressed: _navigateBackWithSelectedExercises,
                  label: "Add (${selectedExercises.length})",
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
          if (scrollNotification is UserScrollNotification) {
            _dismissKeyboard(context);
          }
          return false;
        },
        child: Padding(
          padding: const EdgeInsets.only(right: 10.0, bottom: 10, left: 10),
          child: Column(
            children: [
              SearchBar(
                controller: _searchController,
                onChanged: _runSearch,
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
              _filteredExercises.isNotEmpty
                  ? Expanded(
                      child: ListView.separated(
                          itemBuilder: (BuildContext context, int index) => _exerciseWidget(_filteredExercises[index]),
                          separatorBuilder: (BuildContext context, int index) =>
                              Divider(color: Colors.white70.withOpacity(0.1)),
                          itemCount: _filteredExercises.length))
                  : const Expanded(
                      child: Center(child: ScreenEmptyState(message: "Start adding your favourite exercises")))
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
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
