import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/providers/exercise_provider.dart';
import 'package:tracker_app/screens/editors/exercise_editor_screen.dart';
import 'package:tracker_app/widgets/empty_states/exercise_empty_state.dart';
import 'package:tracker_app/widgets/search_bar.dart';

import '../../app_constants.dart';
import '../../dtos/exercise_dto.dart';
import '../../enums/muscle_group_enums.dart';
import '../../widgets/buttons/text_button_widget.dart';
import '../../widgets/exercise/exercise_widget.dart';
import '../../widgets/exercise/selectable_exercise_widget.dart';
import 'history/home_screen.dart';

class ExerciseInLibraryDto {
  final bool selected;
  final ExerciseDto exercise;

  ExerciseInLibraryDto({this.selected = false, required this.exercise});

  ExerciseInLibraryDto copyWith({bool? selected, ExerciseDto? exercise}) {
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
  final bool readOnly;
  final List<ExerciseDto> preSelectedExercises;

  const ExerciseLibraryScreen(
      {super.key, this.multiSelect = true, this.readOnly = false, this.preSelectedExercises = const []});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  late TextEditingController _searchController;

  List<ExerciseInLibraryDto> _exercisesInLibrary = [];

  MuscleGroup? _selectedMuscleGroup;

  /// Holds a list of [ExerciseInLibraryDto] when filtering through a search
  List<ExerciseInLibraryDto> _filteredExercises = [];

  final List<ExerciseInLibraryDto> _selectedExercises = [];

  /// Search through the list of exercises
  void _runSearch(String? text) {
    setState(() {
      final searchTerm = text ?? _searchController.text;
      final query = searchTerm.toLowerCase().trim();
      List<ExerciseInLibraryDto> searchResults = query.isNotEmpty
          ? _exercisesInLibrary
              .where((exerciseItem) => (exerciseItem.exercise.name.toLowerCase().contains(query) ||
                  exerciseItem.exercise.name.toLowerCase().startsWith(query) ||
                  exerciseItem.exercise.name.toLowerCase().endsWith(query) ||
                  exerciseItem.exercise.name.toLowerCase() == query))
              .sorted((a, b) => a.exercise.name.compareTo(b.exercise.name))
          : _exercisesInLibrary;

      searchResults = _selectedMuscleGroup != null
          ? searchResults
              .where((exerciseItem) =>
                  exerciseItem.exercise.primaryMuscleGroup == _selectedMuscleGroup ||
                  exerciseItem.exercise.primaryMuscleGroup.family == _selectedMuscleGroup?.family)
              .sorted((a, b) => a.exercise.name.compareTo(b.exercise.name))
          : searchResults;

      _filteredExercises = searchResults;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _filteredExercises = _exercisesInLibrary;
    });
  }

  /// Navigate to previous screen
  void _navigateBackWithSelectedExercises() {
    final exercisesFromLibrary = _selectedExercises.map((exerciseInLibrary) => exerciseInLibrary.exercise).toList();
    Navigator.of(context).pop(exercisesFromLibrary);
  }

  /// Select an exercise
  void _navigateBackWithSelectedExercise({required ExerciseInLibraryDto selectedExercise}) {
    Navigator.of(context).pop([selectedExercise.exercise]);
  }

  /// Select up to many exercise
  void _selectCheckedExercise({required bool selected, required ExerciseInLibraryDto exerciseInLibraryDto}) {
    final exerciseIndex = _exercisesInLibrary
        .indexWhere((exerciseInLibrary) => exerciseInLibrary.exercise.id == exerciseInLibraryDto.exercise.id);
    final filteredIndex = _filteredExercises
        .indexWhere((filteredInLibrary) => filteredInLibrary.exercise.id == exerciseInLibraryDto.exercise.id);
    if (selected) {
      _selectedExercises.add(exerciseInLibraryDto);
      setState(() {
        _exercisesInLibrary[exerciseIndex] = exerciseInLibraryDto.copyWith(selected: true);
        _filteredExercises[filteredIndex] = exerciseInLibraryDto.copyWith(selected: true);
      });
    } else {
      _selectedExercises.removeWhere((exercise) => exercise.exercise.id == exerciseInLibraryDto.exercise.id);
      setState(() {
        _exercisesInLibrary[exerciseIndex] = exerciseInLibraryDto.copyWith(selected: false);
        _filteredExercises[filteredIndex] = exerciseInLibraryDto.copyWith(selected: false);
      });
    }
  }

  Widget _exerciseWidget(ExerciseInLibraryDto exerciseInLibraryDto) {
    if (widget.multiSelect) {
      return SelectableExerciseWidget(
          exerciseInLibraryDto: exerciseInLibraryDto,
          onTap: (selected) {
            if (!widget.readOnly) {
              _selectCheckedExercise(selected: selected, exerciseInLibraryDto: exerciseInLibraryDto);
            }
          },
          onNavigateToExercise: () {
            _navigateToExerciseHistory(exerciseInLibraryDto);
          });
    }
    return ExerciseWidget(
        exerciseInLibraryDto: exerciseInLibraryDto,
        onTap: () {
          if (!widget.readOnly) {
            _navigateBackWithSelectedExercise(selectedExercise: exerciseInLibraryDto);
          }
        },
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
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => HomeScreen(exercise: exerciseInLibraryDto.exercise)));
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
    final muscleGroups = MuscleGroup.values
        .whereNot((muscleGroup) =>
            muscleGroup == MuscleGroup.glutes ||
            muscleGroup == MuscleGroup.abductors ||
            muscleGroup == MuscleGroup.adductors ||
            muscleGroup == MuscleGroup.hamstrings ||
            muscleGroup == MuscleGroup.quadriceps ||
            muscleGroup == MuscleGroup.calves ||
            muscleGroup == MuscleGroup.traps ||
            muscleGroup == MuscleGroup.lats)
        .sorted((a, b) => a.name.compareTo(b.name));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          _selectedExercises.isNotEmpty
              ? CTextButton(
                  onPressed: _navigateBackWithSelectedExercises,
                  label: "Add (${_selectedExercises.length})",
                  buttonColor: Colors.transparent,
                  buttonBorderColor: Colors.transparent,
                )
              : const SizedBox.shrink()
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "fab_exercise_library_screen",
        onPressed: _navigateToExerciseEditor,
        backgroundColor: tealBlueLighter,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        child: const FaIcon(FontAwesomeIcons.plus, color: Colors.white, size: 28),
      ),
      body: NotificationListener(
        onNotification: (scrollNotification) {
          if (scrollNotification is UserScrollNotification) {
            _dismissKeyboard(context);
          }
          return false;
        },
        child: SafeArea(
          minimum: const EdgeInsets.only(right: 10.0, bottom: 10, left: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CSearchBar(
                  hintText: "Search exercises",
                  onChanged: _runSearch,
                  onClear: _clearSearch,
                  controller: _searchController),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: tealBlueLighter, // Background color
                  borderRadius: BorderRadius.circular(5), // Border radius
                ),
                child: DropdownButton<MuscleGroup>(
                  isExpanded: true,
                  isDense: true,
                  value: _selectedMuscleGroup,
                  hint: Text("Filter by muscle group",
                      style: GoogleFonts.montserrat(color: Colors.white70, fontWeight: FontWeight.w500, fontSize: 14)),
                  icon: GestureDetector(
                    onTap: () {
                      _selectedMuscleGroup = null;
                      _runSearch(null);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: _selectedMuscleGroup == null
                          ? const FaIcon(FontAwesomeIcons.chevronDown, color: Colors.white70, size: 16)
                          : const FaIcon(FontAwesomeIcons.circleXmark, color: Colors.white, size: 18),
                    ),
                  ),
                  underline: Container(
                    color: Colors.transparent,
                  ),
                  style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14),
                  onChanged: (MuscleGroup? value) {
                    _selectedMuscleGroup = value;
                    _runSearch(null);
                  },
                  items: muscleGroups.map<DropdownMenuItem<MuscleGroup>>((MuscleGroup muscleGroup) {
                    return DropdownMenuItem<MuscleGroup>(
                      value: muscleGroup,
                      child: Text(muscleGroup.name,
                          style: GoogleFonts.montserrat(
                              color: _selectedMuscleGroup == muscleGroup ? Colors.white : Colors.white70,
                              fontWeight: _selectedMuscleGroup == muscleGroup ? FontWeight.bold : FontWeight.w500,
                              fontSize: 14)),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              _filteredExercises.isNotEmpty
                  ? Expanded(
                      child: ListView.separated(
                          padding: const EdgeInsets.only(bottom: 250),
                          itemBuilder: (BuildContext context, int index) => _exerciseWidget(_filteredExercises[index]),
                          separatorBuilder: (BuildContext context, int index) => const Divider(
                                thickness: 1.0,
                                color: tealBlueLight,
                              ),
                          itemCount: _filteredExercises.length),
                    )
                  : const ExerciseEmptyState(),
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

    final preSelectedExerciseIds = widget.preSelectedExercises.map((exercise) => exercise.id).toList();

    _exercisesInLibrary = Provider.of<ExerciseProvider>(context, listen: false)
        .exercises
        .whereNot((exercise) => preSelectedExerciseIds.contains(exercise.id))
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
