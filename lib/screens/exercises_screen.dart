import 'package:flutter/cupertino.dart';
import 'package:tracker_app/dtos/exercise_dto.dart';

import '../widgets/exercise_list_section.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();

}

class _ExercisesScreenState extends State<ExercisesScreen> {
  final _exercises = <Exercise>[
    Exercise("Incline Dumbbells", BodyPart.chest),
    Exercise("Chest Flys", BodyPart.chest),
    Exercise("Decline Smith machine press", BodyPart.chest),
    Exercise("Chest Dips", BodyPart.chest),
    Exercise("Lateral Raises", BodyPart.shoulders),
    Exercise("Military press", BodyPart.shoulders),
    Exercise("Single Lateral Raises", BodyPart.shoulders),
    Exercise("Double Lateral Raises", BodyPart.shoulders),
    Exercise("Skull Crushers", BodyPart.triceps),
    Exercise("Tricep Extensions", BodyPart.triceps),
    Exercise("Tricep Dips", BodyPart.triceps),
    Exercise("Pulldowns", BodyPart.triceps),
    Exercise("Deadlift", BodyPart.legs),
    Exercise("Hamstring Curls", BodyPart.legs),
    Exercise("Romanian Deadlift", BodyPart.legs),
    Exercise("Single Leg Curl", BodyPart.legs),
  ];

  List<Exercise> _filteredExercises = [];

  final List<Exercise> _selectedExercises = [];

  void _whereExercises({required String searchTerm}) {
    setState(() {
      _filteredExercises = _exercises
          .where((exercise) =>
              exercise.name.toLowerCase().contains(searchTerm.toLowerCase()))
          .toList();
      ;
    });
  }

  void _onSelectExercise({required Exercise exercise}) {
    setState(() {
      _selectedExercises.add(exercise);
    });
  }

  void _onRemoveExercise({required Exercise exercise}) {
    setState(() {
      _selectedExercises.remove(exercise);
    });
  }

  void _navigateBack() {
    Navigator.of(context).pop(_selectedExercises);
  }

  @override
  Widget build(BuildContext context) {
    final chestExercises = _filteredExercises
        .where((exercise) => exercise.bodyPart == BodyPart.chest)
        .toList();

    final shouldersExercises = _filteredExercises
        .where((exercise) => exercise.bodyPart == BodyPart.shoulders)
        .toList();

    final tricepsExercises = _filteredExercises
        .where((exercise) => exercise.bodyPart == BodyPart.triceps)
        .toList();

    final legsExercises = _filteredExercises
        .where((exercise) => exercise.bodyPart == BodyPart.legs)
        .toList();

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        trailing: GestureDetector(
          onTap: _navigateBack ,
            child: Text(
          "Add (${_selectedExercises.length})",
          style: const TextStyle(color: CupertinoColors.white),
        )),
      ),
      child: ListView(
        children: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: CupertinoSearchTextField(
                  onChanged: (searchTerm) =>
                      _whereExercises(searchTerm: searchTerm))),
          ExerciseListSection(
            exercises: chestExercises,
            bodyPart: BodyPart.chest,
            onSelect: (Exercise exerciseToBeAdded) =>
                _onSelectExercise(exercise: exerciseToBeAdded),
            onRemove: (Exercise exerciseToBeRemoved) =>
                _onRemoveExercise(exercise: exerciseToBeRemoved),
          ),
          ExerciseListSection(
            exercises: shouldersExercises,
            bodyPart: BodyPart.shoulders,
            onSelect: (Exercise exerciseToBeAdded) =>
                _onSelectExercise(exercise: exerciseToBeAdded),
            onRemove: (Exercise exerciseToBeRemoved) =>
                _onRemoveExercise(exercise: exerciseToBeRemoved),
          ),
          ExerciseListSection(
            exercises: tricepsExercises,
            bodyPart: BodyPart.triceps,
            onSelect: (Exercise exerciseToBeAdded) =>
                _onSelectExercise(exercise: exerciseToBeAdded),
            onRemove: (Exercise exerciseToBeRemoved) =>
                _onRemoveExercise(exercise: exerciseToBeRemoved),
          ),
          ExerciseListSection(
            exercises: legsExercises,
            bodyPart: BodyPart.legs,
            onSelect: (Exercise exerciseToBeAdded) =>
                _onSelectExercise(exercise: exerciseToBeAdded),
            onRemove: (Exercise exerciseToBeRemoved) =>
                _onRemoveExercise(exercise: exerciseToBeRemoved),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _filteredExercises = _exercises;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
