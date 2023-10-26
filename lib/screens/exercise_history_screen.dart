import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/dtos/routine_log_dto.dart';
import 'package:tracker_app/providers/exercises_provider.dart';
import 'package:tracker_app/providers/routine_log_provider.dart';
import 'package:tracker_app/screens/routine_log_preview_screen.dart';
import 'package:tracker_app/utils/datetime_utils.dart';
import 'package:tracker_app/widgets/buttons/text_button_widget.dart';

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

  List<ProcedureDto> _whereProcedureDto({required List<RoutineLogDto> logs}) {
    List<ProcedureDto> foundProcedures = [];

    for (RoutineLogDto log in logs) {
      for (ProcedureDto procedure in log.procedures) {
        if (procedure.exercise.id == exerciseId) {
          foundProcedures.add(procedure);
        }
      }
    }
    return foundProcedures;
  }

  @override
  Widget build(BuildContext context) {
    final exercise = Provider.of<ExerciseProvider>(context, listen: false).whereExercise(exerciseId: exerciseId);

    final logs = Provider.of<RoutineLogProvider>(context, listen: false).logs.where((log) =>
        log.procedures.any((procedure) => exercise.id == exerciseId))
        .toList();

    final procedures = _whereProcedureDto(logs: logs);

    final bestLog = _bestLog(logs: logs);

    print(bestLog.name);

    final bestSet = _bestSet(procedures: procedures);

    final oneRepMax = (bestSet.weight * (1 + 0.0333 * bestSet.rep)).round();

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
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                MetricWidget(label: 'Heaviest weight', summary: "${bestSet.weight}kg"),
                const SizedBox(height: 10),
                MetricWidget(label: 'Heaviest Set', summary: "${bestSet.weight}kg x ${bestSet.rep}"),
                const SizedBox(height: 10),
                MetricWidget(label: 'Heaviest Session Volume', summary: "${_totalWeight(procedures: bestLog.procedures)}kg"),
                const SizedBox(height: 10),
                MetricWidget(label: '1RM', summary: '${oneRepMax}kg'),
                const SizedBox(height: 20),
                SizedBox(width: double.infinity, child: CTextButton(onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => RoutineLogPreviewScreen(routineLogId: bestLog.id,)));
                }, label: "See best session"))
              ],
            )
          ],
        ),
      )),
    );
  }
}

class MetricWidget extends StatelessWidget {
  const MetricWidget({
    super.key,required this.label, required this.summary,
  });

  final String label;
  final String summary;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: tealBlueLight,
      title: Text(label, style: const TextStyle(fontSize: 16, color: Colors.white)),
      trailing: Text(summary, style: const TextStyle(fontSize: 16, color: Colors.white,fontWeight: FontWeight.w700)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
    );
  }
}
