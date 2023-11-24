import 'package:flutter/material.dart';

import '../../enums/exercise_type_enums.dart';

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
                    trailing: _LeadingIcon(type: exerciseTypes[index]),
                    title: Text(exerciseTypes[index].name, style: Theme.of(context).textTheme.bodyMedium),
                    subtitle: Text(exerciseTypes[index].description,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white70)),
                    dense: true),
                separatorBuilder: (BuildContext context, int index) => Divider(color: Colors.white70.withOpacity(0.1)),
                itemCount: exerciseTypes.length),
          ),
        ],
      ),
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  final ExerciseType type;

  const _LeadingIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    List<String> measurements = switch (type) {
      ExerciseType.weightAndReps => ["KG", " | ", "REPS"],
      ExerciseType.bodyWeightAndReps => ["REPS"],
      ExerciseType.weightedBodyWeight => ["KG+", " | ", "REPS"],
      ExerciseType.assistedBodyWeight => ["KG-", " | ", "REPS"],
      ExerciseType.duration => ["TIME"],
      ExerciseType.durationAndDistance => ["MI", " | ", "TIME"],
      ExerciseType.weightAndDistance => ["KG", " | ", "MI"],
    };

    final itemWidgets = measurements
        .map((measurement) => Text(measurement, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)))
        .toList();

    return SizedBox(
      width: 70,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: itemWidgets),
    );
  }
}
