import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/providers/exercise_provider.dart';
import 'package:tracker_app/screens/editor/exercise_editor_screen.dart';
import 'package:tracker_app/widgets/search_bar.dart';

import '../../app_constants.dart';
import '../../models/Exercise.dart';
import '../../widgets/buttons/text_button_widget.dart';
import '../../widgets/empty_states/screen_empty_state.dart';
import '../../widgets/exercise/exercise_widget.dart';
import '../../widgets/exercise/selectable_exercise_widget.dart';
import 'exercise_history_screen.dart';

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

  late TextEditingController _searchController;

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
    if (selected) {
      setState(() {
        _exercisesInLibrary[exerciseIndex] = exerciseInLibraryDto.copyWith(selected: true);
      });
    } else {
      setState(() {
        _exercisesInLibrary[exerciseIndex] = exerciseInLibraryDto.copyWith(selected: false);
      });
    }
  }

  Widget _exerciseWidget(ExerciseInLibraryDto exerciseInLibraryDto) {
    if (widget.multiSelect) {
      return SelectableExerciseWidget(
          exerciseInLibraryDto: exerciseInLibraryDto,
          onTap: (selected) => _selectCheckedExercise(selected: selected, exerciseInLibraryDto: exerciseInLibraryDto),
          onNavigateToExercise: () {
            _navigateToExerciseHistory(exerciseInLibraryDto);
          });
    }
    return ExerciseWidget(
        exerciseInLibraryDto: exerciseInLibraryDto,
        onTap: () => _navigateBackWithSelectedExercise(selectedExercise: exerciseInLibraryDto),
        onNavigateToExercise: () {
          _navigateToExerciseHistory(exerciseInLibraryDto);
        });
  }

  void _dismissKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  void _navigateToExerciseEditor() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ExerciseEditorScreen()));
    if (mounted) {
      setState(() {
        _exercisesInLibrary = _updateSelections();
        _filteredExercises = _synchronizeFilteredList();
      });
    }
  }

  void _navigateToExerciseHistory(ExerciseInLibraryDto exerciseInLibraryDto) async {
    await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => ExerciseHistoryScreen(exercise: exerciseInLibraryDto.exercise)));
    if (mounted) {
      setState(() {
        _exercisesInLibrary = _updateSelections();
        _filteredExercises = _synchronizeFilteredList();
      });
    }
  }

  List<ExerciseInLibraryDto> _updateSelections() {
    final exercises = Provider.of<ExerciseProvider>(context, listen: false).exercises;
    return exercises.map((exercise) {
      final exerciseInLibrary =
          _exercisesInLibrary.firstWhereOrNull((exerciseInLibrary) => exerciseInLibrary.exercise.id == exercise.id);
      if (exerciseInLibrary != null) {
        if (exerciseInLibrary.selected) {
          return ExerciseInLibraryDto(exercise: exercise, selected: true);
        }
      }
      return ExerciseInLibraryDto(exercise: exercise);
    }).toList();
  }

  List<ExerciseInLibraryDto> _synchronizeFilteredList() {
    var idsInFilteredList = _filteredExercises.map((e) => e.exercise.id).toSet();
    final filteredExercises = _exercisesInLibrary.where((e) => idsInFilteredList.contains(e.exercise.id)).toList();
    return _filteredExercises = _searchController.text.isNotEmpty ? filteredExercises : _exercisesInLibrary;
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
          if (scrollNotification is UserScrollNotification) {
            _dismissKeyboard(context);
          }
          return false;
        },
        child: Padding(
          padding: const EdgeInsets.only(right: 10.0, bottom: 10, left: 10),
          child: Column(
            children: [
              CSearchBar(hintText: "Search exercises", onChanged: _runSearch,),
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
  void initState() {
    super.initState();

    _searchController = TextEditingController();

    _exercisesInLibrary = Provider.of<ExerciseProvider>(context, listen: false)
        .exercises
        .map((exercise) => ExerciseInLibraryDto(exercise: exercise))
        .toList();
    _filteredExercises = _exercisesInLibrary;
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }
}
