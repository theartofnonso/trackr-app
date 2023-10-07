import 'package:flutter/cupertino.dart';
import 'package:tracker_app/dtos/exercise_dto.dart';
import 'package:tracker_app/dtos/exercise_in_library_dto.dart';
import 'package:tracker_app/dtos/procedure_dto.dart';
import '../widgets/workout/set_list_section.dart';
import 'exercise_library_screen.dart';

class NewWorkoutScreen extends StatefulWidget {
  const NewWorkoutScreen({super.key});

  @override
  State<NewWorkoutScreen> createState() => _NewWorkoutScreenState();
}

class _NewWorkoutScreenState extends State<NewWorkoutScreen> {
  final List<ExerciseDto> _exercises = [];

  Future<void> _showListOfExercises(BuildContext context) async {
    final selectedExercises = await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return ExerciseLibraryScreen(preSelectedExercises: _exercises);
      },
    ) as List<ExerciseDto>?;

    if (selectedExercises != null) {
      setState(() {
        _exercises.addAll(selectedExercises);
      });
    }
  }

  List<SetListSection> _exercisesToProcedureListSection() {
    return _exercises
        .map((procedure) => SetListSection(exerciseDto: procedure))
        .toList();
  }

  void _navigateBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text(
            'New Workout',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: GestureDetector(
              onTap: _navigateBack,
              child: const Icon(
                CupertinoIcons.check_mark_circled,
                size: 24,
              )),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ..._exercisesToProcedureListSection(),
                GestureDetector(
                    onTap: () => _showListOfExercises(context),
                    child: const Center(
                        child: Text(
                      "Add new exercise",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ))),
              ],
            ),
          ),
        ));
  }
}
