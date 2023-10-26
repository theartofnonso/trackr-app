import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/dtos/routine_log_dto.dart';
import 'package:tracker_app/providers/exercises_provider.dart';
import 'package:tracker_app/providers/routine_log_provider.dart';
import 'package:tracker_app/screens/routine_log_preview_screen.dart';
import 'package:tracker_app/widgets/buttons/text_button_widget.dart';

import '../dtos/procedure_dto.dart';
import '../dtos/set_dto.dart';
import '../widgets/routine/preview/routine_log_lite_widget.dart';

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

class ExerciseHistoryScreen extends StatelessWidget {
  final String exerciseId;

  const ExerciseHistoryScreen({super.key, required this.exerciseId});

  RoutineLogDto _heaviestLog({required List<RoutineLogDto> logs}) {
    return logs.reduce((currentMax, log) {
      int maxWeight = currentMax.procedures
          .expand((procedure) => procedure.sets)
          .map((set) => set.weight)
          .reduce((a, b) => a > b ? a : b);

      int logWeight =
          log.procedures.expand((procedure) => procedure.sets).map((set) => set.weight).reduce((a, b) => a > b ? a : b);

      return maxWeight > logWeight ? currentMax : log;
    });
  }

  SetDto _heaviestSet({required List<ProcedureDto> procedures}) {
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

  List<RoutineLogDto> _whereRoutineLogDtos({required List<RoutineLogDto> logs}) {
    return logs
        .map((log) =>
            log.copyWith(procedures: log.procedures.where((procedure) => procedure.exercise.id == exerciseId).toList()))
        .toList();
  }

  List<ProcedureDto> _whereProcedureDtos({required List<RoutineLogDto> logs}) {
    List<ProcedureDto> foundProcedures = [];

    for (RoutineLogDto log in logs) {
      foundProcedures.addAll(log.procedures);
    }
    return foundProcedures;
  }

  @override
  Widget build(BuildContext context) {
    final exercise = Provider.of<ExerciseProvider>(context, listen: false).whereExercise(exerciseId: exerciseId);

    final logs = Provider.of<RoutineLogProvider>(context, listen: false).logs;

    final logsForExercise = _whereRoutineLogDtos(logs: logs);

    final proceduresForExercise = _whereProcedureDtos(logs: logsForExercise);

    final heaviestLog = _heaviestLog(logs: logsForExercise);

    final heaviestSet = _heaviestSet(procedures: proceduresForExercise);

    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: Text(exercise.name,
                  style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
              bottom: const TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(
                    text: "Summary",
                  ),
                  Tab(
                    text: "History",
                  )
                ],
              )),
          body: TabBarView(
            children: [
              SummaryWidget(
                heaviestSet: heaviestSet,
                heaviestLog: heaviestLog,
              ),
              HistoryWidget(logs: logsForExercise)
            ],
          ),
        ));
  }
}

class SummaryWidget extends StatelessWidget {
  final SetDto heaviestSet;
  final RoutineLogDto heaviestLog;

  const SummaryWidget({super.key, required this.heaviestSet, required this.heaviestLog});

  @override
  Widget build(BuildContext context) {
    final oneRepMax = (heaviestSet.weight * (1 + 0.0333 * heaviestSet.rep)).round();

    return SingleChildScrollView(
        child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              MetricWidget(label: 'Heaviest weight', summary: "${heaviestSet.weight}kg"),
              const SizedBox(height: 10),
              MetricWidget(label: 'Heaviest Set', summary: "${heaviestSet.weight}kg x ${heaviestSet.rep}"),
              const SizedBox(height: 10),
              MetricWidget(
                  label: 'Heaviest Session Volume', summary: "${_totalWeight(procedures: heaviestLog.procedures)}kg"),
              const SizedBox(height: 10),
              MetricWidget(label: '1RM', summary: '${oneRepMax}kg'),
              const SizedBox(height: 20),
              SizedBox(
                  width: double.infinity,
                  child: CTextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => RoutineLogPreviewScreen(
                                  routineLogId: heaviestLog.id,
                                )));
                      },
                      label: "See best session"))
            ],
          )
        ],
      ),
    ));
  }
}

class HistoryWidget extends StatelessWidget {
  final List<RoutineLogDto> logs;

  const HistoryWidget({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
                itemBuilder: (BuildContext context, int index) => RoutineLogLiteWidget(
                      routineLogDto: logs[index],
                    ),
                separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 18),
                itemCount: logs.length),
          ),
        ],
      ),
    );
  }
}

class MetricWidget extends StatelessWidget {
  const MetricWidget({
    super.key,
    required this.label,
    required this.summary,
  });

  final String label;
  final String summary;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: tealBlueLight,
      title: Text(label, style: const TextStyle(fontSize: 14, color: Colors.white)),
      trailing: Text(summary, style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
    );
  }
}
