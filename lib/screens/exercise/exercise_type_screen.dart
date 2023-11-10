import 'package:flutter/material.dart';
import 'package:tracker_app/models/ExerciseType.dart';

class ExerciseTypeScreen extends StatefulWidget {
  const ExerciseTypeScreen({super.key});

  @override
  State<ExerciseTypeScreen> createState() => _ExerciseTypeScreenState();
}

class _ExerciseTypeScreenState extends State<ExerciseTypeScreen> {
  /// Select an muscle group
  void _selectExerciseType({required ExerciseType type}) {
    Navigator.of(context).pop(type);
  }

  @override
  Widget build(BuildContext context) {
    const exerciseTypes = ExerciseType.values;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
                itemBuilder: (BuildContext context, int index) => ListTile(
                    onTap: () => _selectExerciseType(type: exerciseTypes[index]),
                    title: Text(exerciseTypes[index].name, style: Theme.of(context).textTheme.bodyMedium),
                    dense: true),
                separatorBuilder: (BuildContext context, int index) => Divider(color: Colors.white70.withOpacity(0.1)),
                itemCount: exerciseTypes.length),
          ),
        ],
      ),
    );
  }
}
