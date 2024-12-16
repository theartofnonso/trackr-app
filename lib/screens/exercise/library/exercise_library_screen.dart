import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/widgets/search_bar.dart';

import '../../../colors.dart';
import '../../../controllers/exercise_and_routine_controller.dart';
import '../../../dtos/appsync/exercise_dto.dart';
import '../../../enums/muscle_group_enums.dart';
import '../../../utils/general_utils.dart';
import '../../../utils/navigation_utils.dart';
import '../../../widgets/buttons/opacity_button_widget.dart';
import '../../../widgets/empty_states/no_list_empty_state.dart';
import '../../../widgets/exercise/exercise_widget.dart';
import '../../editors/exercise_editor_screen.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  final bool readOnly;
  final List<ExerciseDto> excludeExercises;
  final ExerciseType? type;

  const ExerciseLibraryScreen({super.key, this.readOnly = false, this.excludeExercises = const [], this.type});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  late TextEditingController _searchController;

  final List<MuscleGroup> _selectedMuscleGroups = [];

  /// Holds a list of [ExerciseDto] when filtering through a search
  List<ExerciseDto> _filteredExercises = [];

  bool _shouldShowOwnerExercises = false;

  /// Search through the list of exercises
  void _runSearch() {
    final query = _searchController.text.toLowerCase().trim();

    List<ExerciseDto> searchResults = [];

    final exerciseType = widget.type;

    searchResults = Provider.of<ExerciseAndRoutineController>(context, listen: false)
        .exercises
        .where((exercise) => !widget.excludeExercises.contains(exercise))
        .where((exercise) {
          if (query.isEmpty) return true;

          final exerciseParts = exercise.name.toLowerCase().split(RegExp(r'[\s-]+'));
          final queryParts = query.toLowerCase().split(RegExp(r'[\s-]+'));

          return queryParts.every((queryPart) => exerciseParts.contains(queryPart));
        })
        .where((exercise) => exerciseType != null ? exercise.type == widget.type : true)
        .toList();

    if (_selectedMuscleGroups.isNotEmpty) {
      searchResults =
          searchResults.where((exercise) => _selectedMuscleGroups.contains(exercise.primaryMuscleGroup)).toList();
    }

    if (_shouldShowOwnerExercises) {
      searchResults = searchResults.where((exercise) => exercise.owner.isNotEmpty).toList();
    }

    searchResults.sort((a, b) => a.name.compareTo(b.name));

    setState(() {
      _filteredExercises = searchResults;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _runSearch();
  }

  /// Select an exercise
  void _navigateBackWithSelectedExercise(ExerciseDto selectedExercise) {
    Navigator.of(context).pop([selectedExercise]);
  }

  void _dismissKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  void _navigateToExerciseEditor() async {
    await context.push(ExerciseEditorScreen.routeName);
    setState(() {
      _loadOrSyncExercises();
    });
  }

  void _navigateToExerciseHistory(ExerciseDto exercise) async {
    _dismissKeyboard(context);
    await navigateToExerciseHome(context: context, exercise: exercise);
    setState(() {
      _loadOrSyncExercises();
    });
  }

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final muscleGroups = MuscleGroup.values
        .sorted((a, b) => a.name.compareTo(b.name))
        .map((muscleGroup) => Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: OpacityButtonWidget(
                  onPressed: () => _onSelectMuscleGroup(newMuscleGroup: muscleGroup),
                  padding: EdgeInsets.symmetric(horizontal: 0),
                  buttonColor: _getMuscleGroup(muscleGroup: muscleGroup) != null ? vibrantGreen : null,
                  label: muscleGroup.name.toUpperCase()),
            ))
        .toList();

    final muscleGroupScrollViewHalf = MuscleGroup.values.length ~/ 2;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, size: 28),
          onPressed: () => context.pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "fab_exercise_library_screen",
        onPressed: _navigateToExerciseEditor,
        child: const FaIcon(FontAwesomeIcons.plus, size: 28),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: themeGradient(context: context),
        ),
        child: SafeArea(
          bottom: false,
          minimum: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: CSearchBar(
                    hintText: "Search exercises",
                    onChanged: (_) => _runSearch(),
                    onClear: _clearSearch,
                    controller: _searchController),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    const SizedBox(width: 10),
                    OpacityButtonWidget(
                        onPressed: _toggleOwnerExercises,
                        padding: EdgeInsets.symmetric(horizontal: 0),
                        buttonColor: _shouldShowOwnerExercises ? vibrantGreen : vibrantBlue,
                        label: "Your Exercises".toUpperCase()),
                    const SizedBox(width: 6),
                    ...muscleGroups.sublist(0, muscleGroupScrollViewHalf),
                    const SizedBox(width: 10)
                  ])),
              SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    const SizedBox(width: 10),
                    ...muscleGroups.sublist(muscleGroupScrollViewHalf),
                    const SizedBox(width: 10)
                  ])),
              const SizedBox(height: 18),
              _filteredExercises.isNotEmpty
                  ? Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: ListView.separated(
                            padding: const EdgeInsets.only(bottom: 250),
                            itemBuilder: (BuildContext context, int index) => ExerciseWidget(
                                exerciseDto: _filteredExercises[index],
                                onNavigateToExercise: _navigateToExerciseHistory,
                                onSelect: widget.readOnly ? null : _navigateBackWithSelectedExercise),
                            separatorBuilder: (BuildContext context, int index) => Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20.0),
                                  child:
                                      Divider(height: 0.5, color: isDarkMode ? sapphireLighter : Colors.grey.shade200),
                                ),
                            itemCount: _filteredExercises.length),
                      ),
                    )
                  : Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: const NoListEmptyState(
                            message: "It might feel quiet now, but exercises including yours will soon appear here."),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void _loadOrSyncExercises() {
    final exerciseType = widget.type;

    _filteredExercises = Provider.of<ExerciseAndRoutineController>(context, listen: false)
        .exercises
        .where((exercise) => !widget.excludeExercises.contains(exercise))
        .where((exercise) => exerciseType != null ? exercise.type == widget.type : true)
        .toList();

    _runSearch();
  }

  void _toggleOwnerExercises() {
    setState(() {
      _shouldShowOwnerExercises = !_shouldShowOwnerExercises;
    });
    _runSearch();
  }

  void _onSelectMuscleGroup({required MuscleGroup newMuscleGroup}) {
    final oldMuscleGroup =
        _selectedMuscleGroups.firstWhereOrNull((previousMuscleGroup) => previousMuscleGroup == newMuscleGroup);
    setState(() {
      if (oldMuscleGroup != null) {
        _selectedMuscleGroups.remove(oldMuscleGroup);
      } else {
        _selectedMuscleGroups.add(newMuscleGroup);
      }
      _runSearch();
    });
  }

  MuscleGroup? _getMuscleGroup({required MuscleGroup muscleGroup}) =>
      _selectedMuscleGroups.firstWhereOrNull((previousMuscleGroup) => previousMuscleGroup == muscleGroup);

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadOrSyncExercises();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
