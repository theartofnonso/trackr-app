import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/controllers/exercise_controller.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/widgets/empty_states/exercise_empty_state.dart';
import 'package:tracker_app/widgets/search_bar.dart';

import '../../../colors.dart';
import '../../../dtos/appsync/exercise_dto.dart';
import '../../../enums/muscle_group_enums.dart';
import '../../../utils/navigation_utils.dart';
import '../../../widgets/exercise/exercise_widget.dart';
import '../../editors/exercise_editor_screen.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  final bool readOnly;
  final List<ExerciseDto> excludeExercises;
  final ExerciseType type;

  const ExerciseLibraryScreen(
      {super.key, this.readOnly = false, this.excludeExercises = const [], this.type = ExerciseType.all});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  late TextEditingController _searchController;

  MuscleGroup? _selectedMuscleGroup;

  /// Holds a list of [ExerciseDto] when filtering through a search
  List<ExerciseDto> _filteredExercises = [];

  /// Search through the list of exercises
  void _runSearch() {
    final query = _searchController.text.toLowerCase().trim();

    List<ExerciseDto> searchResults = [];

    searchResults = Provider.of<ExerciseController>(context, listen: false)
        .exercises
        .where((exercise) => !widget.excludeExercises.contains(exercise))
        .where((exercise) => exercise.name.toLowerCase().contains(query.toLowerCase()))
        .where((exercise) => widget.type == ExerciseType.all ? true : exercise.type == widget.type)
        .toList();

    if (_selectedMuscleGroup != null) {
      searchResults = searchResults.where((exercise) => exercise.primaryMuscleGroup == _selectedMuscleGroup).toList();
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
    final muscleGroups = MuscleGroup.values;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: sapphireDark80,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
          onPressed: () => context.pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "fab_exercise_library_screen",
        onPressed: _navigateToExerciseEditor,
        backgroundColor: sapphireDark,
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
                    onChanged: (_) => _runSearch(),
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
                        _runSearch();
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
                      _runSearch();
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
    _filteredExercises = Provider.of<ExerciseController>(context, listen: false)
        .exercises
        .where((exercise) => !widget.excludeExercises.contains(exercise))
        .where((exercise) => widget.type == ExerciseType.all ? true : exercise.type == widget.type)
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
    super.dispose();
    _searchController.dispose();
  }
}
