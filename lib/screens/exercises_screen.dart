import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/exercise_dto.dart';
import 'package:tracker_app/widgets/exercise_list.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  final listSectionStyle =
      TextStyle(color: CupertinoColors.white.withOpacity(0.7));

  final listTileStyle = const TextStyle(color: CupertinoColors.white);

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

  void _exercisesWhere({required String searchTerm}) {
    setState(() {
      _filteredExercises = _exercises.where((exercise) => exercise.name.toLowerCase().contains(searchTerm.toLowerCase())).toList();;
    });
  }

  @override
  Widget build(BuildContext context) {
    final chestExercises = _filteredExercises
        .where((exercise) => exercise.bodyPart == BodyPart.chest)
        .toList();

    final shoulderExercises = _filteredExercises
        .where((exercise) => exercise.bodyPart == BodyPart.shoulders)
        .toList();

    final tricepsExercises = _filteredExercises
        .where((exercise) => exercise.bodyPart == BodyPart.triceps)
        .toList();

    final legsExercises = _filteredExercises
        .where((exercise) => exercise.bodyPart == BodyPart.legs)
        .toList();

    return Scaffold(
      body: ListView(
        children: [
          SearchBar(onChanged: (searchTerm) => _exercisesWhere(searchTerm: searchTerm)),
          ExerciseList(exercises: chestExercises, bodyPart: BodyPart.chest),
          ExerciseList(
              exercises: shoulderExercises, bodyPart: BodyPart.shoulders),
          ExerciseList(exercises: tricepsExercises, bodyPart: BodyPart.triceps),
          ExerciseList(exercises: legsExercises, bodyPart: BodyPart.legs),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _filteredExercises = _exercises;
  }
}
