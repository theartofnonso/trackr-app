import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/enums/exercise/set_type_enums.dart';
import 'package:tracker_app/screens/empty_state_screens/no_list_empty_state.dart';
import 'package:tracker_app/widgets/search_bar.dart';

import '../../../colors.dart';
import '../../../controllers/exercise_and_routine_controller.dart';
import '../../../dtos/exercise_dto.dart';
import '../../../enums/muscle_group_enums.dart';
import '../../../utils/navigation_utils.dart';
import '../../../widgets/buttons/opacity_button_widget.dart';
import '../../../widgets/exercise/exercise_widget.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  final bool readOnly;
  final List<String> exercisesToExclude;
  final SetType? exerciseMetric;
  final MuscleGroup? muscleGroup;

  const ExerciseLibraryScreen(
      {super.key, this.readOnly = false, this.exercisesToExclude = const [], this.exerciseMetric, this.muscleGroup});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  late TextEditingController _searchController;

  final List<MuscleGroup> _selectedMuscleGroups = [];

  /// Holds a list of [ExerciseDTO] when filtering through a search
  List<ExerciseDTO> _filteredExercises = [];

  /// Search through the list of exercises
  void _runSearch(_) {
    final query = _searchController.text.toLowerCase().trim();

    List<ExerciseDTO> searchResults = [];

    final muscleGroup = widget.muscleGroup;

    searchResults = Provider.of<ExerciseAndRoutineController>(context, listen: false)
        .exercises
        .where((exercise) => !widget.exercisesToExclude.contains(exercise.name))
        .where((exercise) => exercise.name.toLowerCase().contains(query.toLowerCase()))
        .where((exercise) => muscleGroup != null
            ? exercise.primaryMuscleGroups.any((muscleGroup) => _selectedMuscleGroups.contains(muscleGroup))
            : true)
        .toList();

    if (_selectedMuscleGroups.isNotEmpty) {
      searchResults = searchResults
          .where((exercise) =>
              exercise.primaryMuscleGroups.any((muscleGroup) => _selectedMuscleGroups.contains(muscleGroup)))
          .toList();
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


    final muscleGroups = MuscleGroup.values
        .sorted((a, b) => a.name.compareTo(b.name))
        .map((muscleGroup) => Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: OpacityButtonWidget(
                  onPressed: () => _onSelectMuscleGroup(newMuscleGroup: muscleGroup),
                  padding: EdgeInsets.symmetric(horizontal: 0),
                  textStyle: GoogleFonts.ubuntu(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      color: _getMuscleGroup(muscleGroup: muscleGroup) != null ? vibrantGreen : Colors.white70),
                  buttonColor: _getMuscleGroup(muscleGroup: muscleGroup) != null ? vibrantGreen : null,
                  label: muscleGroup.name.toUpperCase()),
            ))
        .toList();

    final muscleGroupScrollViewHalf = MuscleGroup.values.length ~/ 2;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: sapphireDark80,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
          onPressed: context.pop,
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
                SingleChildScrollView(
                    scrollDirection: Axis.horizontal, child: Row(children: muscleGroups.sublist(0, muscleGroupScrollViewHalf))),
                SingleChildScrollView(
                    scrollDirection: Axis.horizontal, child: Row(children: muscleGroups.sublist(muscleGroupScrollViewHalf))),
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
                    : Expanded(
                        child: const NoListEmptyState(
                            icon: FaIcon(
                              FontAwesomeIcons.solidLightbulb,
                              color: Colors.white12,
                              size: 48,
                            ),
                            message: "It might feel quiet now, but your exercises will soon appear here."),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
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
      _runSearch("");
    });
  }

  MuscleGroup? _getMuscleGroup({required MuscleGroup muscleGroup}) =>
      _selectedMuscleGroups.firstWhereOrNull((previousMuscleGroup) => previousMuscleGroup == muscleGroup);

  void _loadOrSyncExercises() {
    final muscleGroup = widget.muscleGroup;

    _filteredExercises = Provider.of<ExerciseAndRoutineController>(context, listen: false)
        .exercises
        .where((exercise) => !widget.exercisesToExclude.contains(exercise.name))
        .where((exercise) => muscleGroup != null
            ? exercise.primaryMuscleGroups.any((muscleGroup) => _selectedMuscleGroups.contains(muscleGroup))
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
