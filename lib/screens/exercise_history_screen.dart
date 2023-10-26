import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/providers/exercises_provider.dart';
import 'package:tracker_app/providers/routine_log_provider.dart';

class ExerciseHistoryScreen extends StatelessWidget {
  final String exerciseId;

  const ExerciseHistoryScreen({super.key, required this.exerciseId});

  @override
  Widget build(BuildContext context) {
    final exercise = Provider.of<ExerciseProvider>(context, listen: false).whereExercise(exerciseId: exerciseId);
    final logs = Provider.of<RoutineLogProvider>(context, listen: false).logs;
    final listOfProcedures = [];
    for (var log in logs) {
      final procedures = log.procedures.where((procedure) => procedure.exercise.id == exerciseId).toList();
      listOfProcedures.add(procedures);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title:
            Text(exercise.name, style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            ListTile(
              tileColor: tealBlueLight,
              title: Text("Heaviest weight", style: const TextStyle(fontSize: 16, color: Colors.white)),
              subtitle: Text("Heaviest weight since 24th, Oct 2023",
                  style: const TextStyle(fontSize: 12, color: Colors.white70)),
              trailing: Text("160kg", style: const TextStyle(fontSize: 16, color: Colors.white)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 10),
            ListTile(
              tileColor: tealBlueLight,
              title: Text("Best Set Volume", style: TextStyle(fontSize: 16, color: Colors.white)),
              subtitle: Text("Heaviest set since 20th Oct 2023", style: TextStyle(fontSize: 12, color: Colors.white70)),
              trailing: Text("160kg x 8", style: TextStyle(fontSize: 16, color: Colors.white)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 10),
            ListTile(
              tileColor: tealBlueLight,
              title: Text("Best Session Volume", style: TextStyle(fontSize: 16, color: Colors.white)),
              subtitle:
                  Text("Heaviest session since 20th Oct 2023", style: TextStyle(fontSize: 12, color: Colors.white70)),
              trailing: Text("2345kg", style: TextStyle(fontSize: 16, color: Colors.white)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 10),
            ListTile(
              tileColor: tealBlueLight,
              title: Text("Best 1RM", style: TextStyle(fontSize: 16, color: Colors.white)),
              subtitle: Text("Heaviest 1RM since 20th Oct 2023", style: TextStyle(fontSize: 12, color: Colors.white70)),
              trailing: Text("235kg", style: TextStyle(fontSize: 16, color: Colors.white)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
            )
          ],
        ),
      )),
    );
  }
}
