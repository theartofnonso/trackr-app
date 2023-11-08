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
}

class ExerciseLibraryScreen extends StatefulWidget {
  final bool multiSelect;

  const ExerciseLibraryScreen({super.key, this.multiSelect = true});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  final TextEditingController _searchEditingController = TextEditingController();

  List<ExerciseInLibraryDto> _exercisesInLibrary = [];

  /// Holds a list of [ExerciseInLibraryDto] when filtering through a search
  List<ExerciseInLibraryDto> _filteredExercises = [];

  /// Search through the list of exercises
  void _runSearch(String searchTerm) {
    setState(() {
      _filteredExercises = Provider.of<ExerciseProvider>(context, listen: false)
          .exercises
          .map((exercise) => ExerciseInLibraryDto(exercise: exercise))
          .where((exerciseItem) => (
              exerciseItem.exercise.name.toLowerCase().contains(searchTerm.toLowerCase()) ||
              exerciseItem.exercise.name.toLowerCase().startsWith(searchTerm.toLowerCase()) ||
              exerciseItem.exercise.name.toLowerCase().endsWith(searchTerm.toLowerCase()) ||
              exerciseItem.exercise.name.toLowerCase() == searchTerm.toLowerCase()))
          .toList();
    });
  }

  /// Navigate to previous screen
  void _navigateBackWithSelectedExercises() {
    final exercisesFromLibrary =
    _filteredExercises.where((exerciseInLibrary) => exerciseInLibrary.selected).map((exerciseInLibrary) => exerciseInLibrary.exercise).toList();
    Navigator.of(context).pop(exercisesFromLibrary);
  }

  /// Select an exercise
  void _navigateBackWithSelectedExercise({required ExerciseInLibraryDto selectedExercise}) {
    Navigator.of(context).pop([selectedExercise.exercise]);
  }

  int _indexWhereFilteredExercise({required String exerciseId}) {
    return _filteredExercises.indexWhere((exerciseInLibrary) => exerciseInLibrary.exercise.id == exerciseId);
  }

  /// Select up to many exercise
  void _selectCheckedExercise({required bool selected, required ExerciseInLibraryDto exerciseInLibraryDto}) {
    final filteredExerciseIndex = _indexWhereFilteredExercise(exerciseId: exerciseInLibraryDto.exercise.id);
    if (selected) {
      setState(() {
        _filteredExercises[filteredExerciseIndex] = exerciseInLibraryDto.copyWith(selected: true);
      });
    } else {
      setState(() {
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

  void _navigateToExerciseEditor() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ExerciseEditorScreen()));
  }

  List<ExerciseInLibraryDto> _combineExercises({required List<Exercise> exercises}) {

    final exercisesInLibrary = exercises.map((exercise) => ExerciseInLibraryDto(exercise: exercise)).toList();

    // Create a map from the full list
    final Map<String, ExerciseInLibraryDto> combinedMap = {
      for (ExerciseInLibraryDto dto in exercisesInLibrary) dto.exercise.id: dto,
    };

    // Replace entries with the ones from the filtered list
    for (ExerciseInLibraryDto filteredDto in _filteredExercises) {
      combinedMap[filteredDto.exercise.id] = filteredDto;
    }

    // Convert the map back to a list
    return combinedMap.values.toList();
  }

  @override
  Widget build(BuildContext context) {
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
                controller: _searchEditingController,
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
              Consumer<ExerciseProvider>(
                builder: (BuildContext context, ExerciseProvider value, Widget? child) {
                  final exercises = value.exercises;
                  final exercisesInLibrary = exercises.map((exercise) => ExerciseInLibraryDto(exercise: exercise)).toList();
                  _filteredExercises = _searchEditingController.text.isNotEmpty
                      ? _filteredExercises
                      : exercisesInLibrary;
                  return exercises.isNotEmpty
                      ? Expanded(
                          child: ListView.separated(
                              itemBuilder: (BuildContext context, int index) =>
                                  _exerciseWidget(_filteredExercises[index]),
                              separatorBuilder: (BuildContext context, int index) =>
                                  Divider(color: Colors.white70.withOpacity(0.1)),
                              itemCount: _filteredExercises.length))
                      : const Expanded(
                          child: Center(child: ScreenEmptyState(message: "Start adding your favourite exercises")));
                },
              )
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

  @override
  void dispose() {
    super.dispose();
    _searchEditingController.dispose();
  }
}
