import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/enums/exercise/exercise_metrics_enums.dart';
import 'package:tracker_app/widgets/empty_states/exercise_empty_state.dart';
import 'package:tracker_app/widgets/search_bar.dart';

import '../../../colors.dart';
import '../../../controllers/exercise_and_routine_controller.dart';
import '../../../dtos/exercise_dto.dart';
import '../../../enums/muscle_group_enums.dart';
import '../../../utils/navigation_utils.dart';
import '../../../widgets/exercise/exercise_widget.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  final bool readOnly;
  final List<ExerciseDTO> excludeExercises;
  final ExerciseMetric? exerciseMetric;
  final MuscleGroupFamily? muscleGroupFamily;
  final MuscleGroup? muscleGroup;

  const ExerciseLibraryScreen(
      {super.key,
      this.readOnly = false,
      this.excludeExercises = const [],
      this.exerciseMetric,
      this.muscleGroupFamily,
      this.muscleGroup});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  late TextEditingController _searchController;

  MuscleGroup? _selectedMuscleGroup;

  /// Holds a list of [ExerciseDTO] when filtering through a search
  List<ExerciseDTO> _filteredExercises = [];

  /// Search through the list of exercises
  void _runSearch(_) {
    final query = _searchController.text.toLowerCase().trim();

    List<ExerciseDTO> searchResults = [];

    final exerciseType = widget.exerciseMetric;
    final muscleGroup = widget.muscleGroup;
    final muscleGroupFamily = widget.muscleGroupFamily;

    searchResults = Provider.of<ExerciseAndRoutineController>(context, listen: false)
        .exercises
        .where((exercise) => !widget.excludeExercises.contains(exercise))
        .where((exercise) => exercise.name.toLowerCase().contains(query.toLowerCase()))
        .where((exercise) => exerciseType != null ? exercise.metric == widget.exerciseMetric : true)
        .where((exercise) => muscleGroup != null ? exercise.primaryMuscleGroups.contains(_selectedMuscleGroup) : true)
        .where((exercise) => muscleGroupFamily != null
            ? exercise.primaryMuscleGroups.firstWhereOrNull((muscleGroup) => muscleGroup.family == muscleGroupFamily) !=
                null
            : true)
        .toList();

    if (_selectedMuscleGroup != null) {
      searchResults =
          searchResults.where((exercise) => exercise.primaryMuscleGroups.contains(_selectedMuscleGroup)).toList();
    }

    searchResults.sort((a, b) => a.name.compareTo(b.name));

    setState(() {
      _filteredExercises = searchResults;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _runSearch("Nil");
  }

  /// Select an exercise
  void _navigateBackWithSelectedExercise(ExerciseDTO selectedExercise) {
    Navigator.of(context).pop([selectedExercise]);
  }

  void _dismissKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  void _navigateToExerciseHistory(ExerciseDTO exercise) async {
    _dismissKeyboard(context);
    await navigateToExerciseHome(context: context, exercise: exercise);
    setState(() {
      _loadOrSyncExercises();
    });
  }

  @override
  Widget build(BuildContext context) {
    final muscleGroups = MuscleGroup.values;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: sapphireDark80,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
          onPressed: () => context.pop(),
        ),
      ),
      body: NotificationListener(
        onNotification: (scrollNotification) {
          if (scrollNotification is UserScrollNotification) {
            _dismissKeyboard(context);
          }
          return false;
        },
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                sapphireDark80,
                sapphireDark,
              ],
            ),
          ),
          child: SafeArea(
            minimum: const EdgeInsets.only(right: 10.0, bottom: 10, left: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    color: sapphireDark, // Background color
                    borderRadius: BorderRadius.circular(5), // Border radius
                  ),
                  child: DropdownButton<MuscleGroup>(
                    menuMaxHeight: 400,
                    isExpanded: true,
                    isDense: true,
                    value: _selectedMuscleGroup,
                    hint: Text("Filter by muscle group",
                        style: GoogleFonts.ubuntu(color: Colors.white70, fontWeight: FontWeight.w500, fontSize: 14)),
                    icon: GestureDetector(
                      onTap: () {
                        _selectedMuscleGroup = null;
                        _runSearch("Nil");
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
                    style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14),
                    onChanged: (MuscleGroup? value) {
                      _selectedMuscleGroup = value;
                      _runSearch("Nil");
                    },
                    items: muscleGroups.map<DropdownMenuItem<MuscleGroup>>((MuscleGroup muscleGroup) {
                      return DropdownMenuItem<MuscleGroup>(
                        value: muscleGroup,
                        child: Text(muscleGroup.name,
                            style: GoogleFonts.ubuntu(
                                color: _selectedMuscleGroup == muscleGroup ? Colors.white : Colors.white70,
                                fontWeight: _selectedMuscleGroup == muscleGroup ? FontWeight.bold : FontWeight.w500,
                                fontSize: 14)),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 18),
                _filteredExercises.isNotEmpty
                    ? Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ListView.separated(
                              padding: const EdgeInsets.only(bottom: 250),
                              itemBuilder: (BuildContext context, int index) => ExerciseWidget(
                                  exerciseDto: _filteredExercises[index],
                                  onNavigateToExercise: _navigateToExerciseHistory,
                                  onSelect: widget.readOnly ? null : _navigateBackWithSelectedExercise),
                              separatorBuilder: (BuildContext context, int index) => const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20.0),
                                    child: Divider(
                                      height: 0.5,
                                      color: sapphireLighter,
                                    ),
                                  ),
                              itemCount: _filteredExercises.length),
                        ),
                      )
                    : const ExerciseEmptyState(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _loadOrSyncExercises() {
    final exerciseMetric = widget.exerciseMetric;
    final muscleGroup = widget.muscleGroup;
    final muscleGroupFamily = widget.muscleGroupFamily;

    _filteredExercises = Provider.of<ExerciseAndRoutineController>(context, listen: false)
        .exercises
        .where((exercise) => !widget.excludeExercises.contains(exercise))
        .where((exercise) => exerciseMetric != null ? exercise.metric == widget.exerciseMetric : true)
        .where((exercise) => muscleGroup != null ? exercise.primaryMuscleGroups.contains(_selectedMuscleGroup) : true)
        .where((exercise) => muscleGroupFamily != null
            ? exercise.primaryMuscleGroups.firstWhereOrNull((muscleGroup) => muscleGroup.family == muscleGroupFamily) !=
                null
            : true)
        .toList();
  }

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
