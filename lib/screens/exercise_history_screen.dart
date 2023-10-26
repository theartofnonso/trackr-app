import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/dtos/routine_log_dto.dart';
import 'package:tracker_app/providers/exercises_provider.dart';
import 'package:tracker_app/providers/routine_log_provider.dart';
import 'package:tracker_app/utils/datetime_utils.dart';

import '../dtos/procedure_dto.dart';
import '../dtos/set_dto.dart';

class ExerciseHistoryScreen extends StatelessWidget {
  final String exerciseId;

  const ExerciseHistoryScreen({super.key, required this.exerciseId});

  RoutineLogDto _bestLog({required List<RoutineLogDto> logs}) {

    return logs.reduce((currentMax, log) {
      int maxWeight = currentMax.procedures
          .expand((procedure) => procedure.sets)
          .map((set) => set.weight)
          .reduce((a, b) => a > b ? a : b);

      int logWeight = log.procedures
          .expand((procedure) => procedure.sets)
          .map((set) => set.weight)
          .reduce((a, b) => a > b ? a : b);

      return maxWeight > logWeight ? currentMax : log;
    });
  }

  SetDto _bestSet({required List<ProcedureDto> procedures}) {
    SetDto maxWeightSet = SetDto();

    for (var procedure in procedures) {
      for (var set in procedure.sets) {
        if (set.weight > maxWeightSet.weight) {
          maxWeightSet = set;
        }
      }
    }
    return maxWeightSet;
  }

  List<SetDto> _calculateCompletedSets({required List<ProcedureDto> procedures}) {
    List<SetDto> completedSets = [];
    for (var procedure in procedures) {
      completedSets.addAll(procedure.sets);
    }
    return completedSets;
  }

  int _totalWeight({required List<ProcedureDto> procedures}) {

    final sets = _calculateCompletedSets(procedures: procedures);

    int totalWeight = 0;
    for (var set in sets) {
      final weightPerSet = set.rep * set.weight;
      totalWeight += weightPerSet;
    }
    return totalWeight;
  }

  @override
  Widget build(BuildContext context) {
    final exercise = Provider.of<ExerciseProvider>(context, listen: false).whereExercise(exerciseId: exerciseId);
    final logs = Provider.of<RoutineLogProvider>(context, listen: false).logs;

    final bestLog = _bestLog(logs: logs);

    final bestSet = _bestSet(procedures: bestLog.procedures);

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
              title: const Text("Heaviest weight", style: TextStyle(fontSize: 16, color: Colors.white)),
              subtitle: Text("Since ${bestLog.createdAt.formattedDayAndMonthAndYear()}",
                  style: const TextStyle(fontSize: 12, color: Colors.white70)),
              trailing: Text("${bestSet.weight}kg", style: const TextStyle(fontSize: 16, color: Colors.white)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 10),
            ListTile(
              tileColor: tealBlueLight,
              title: const Text("Heaviest Set", style: TextStyle(fontSize: 16, color: Colors.white)),
              subtitle: Text("Since ${bestLog.createdAt.formattedDayAndMonthAndYear()}", style: const TextStyle(fontSize: 12, color: Colors.white70)),
              trailing: Text("${bestSet.weight}kg x ${bestSet.rep}", style: const TextStyle(fontSize: 16, color: Colors.white)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 10),
            ListTile(
              tileColor: tealBlueLight,
              title: const Text("Heaviest Session Volume", style: TextStyle(fontSize: 16, color: Colors.white)),
              subtitle:
                  Text("Since ${bestLog.createdAt.formattedDayAndMonthAndYear()}", style: const TextStyle(fontSize: 12, color: Colors.white70)),
              trailing: Text("${bestSet.weight * bestSet.rep}kg", style: const TextStyle(fontSize: 16, color: Colors.white)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 10),
            ListTile(
              tileColor: tealBlueLight,
              title: Text("Best 1RM", style: TextStyle(fontSize: 16, color: Colors.white)),
              subtitle: Text("Since ${bestLog.createdAt.formattedDayAndMonthAndYear()}", style: TextStyle(fontSize: 12, color: Colors.white70)),
              trailing: Text("${_totalWeight(procedures: bestLog.procedures)}", style: TextStyle(fontSize: 16, color: Colors.white)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
            )
          ],
        ),
      )),
    );
  }
}
