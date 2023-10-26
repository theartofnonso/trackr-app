import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/dtos/routine_log_dto.dart';
import 'package:tracker_app/providers/exercises_provider.dart';
import 'package:tracker_app/providers/routine_log_provider.dart';
import 'package:tracker_app/screens/routine_log_preview_screen.dart';
import 'package:tracker_app/utils/datetime_utils.dart';
import 'package:tracker_app/widgets/buttons/text_button_widget.dart';
import 'package:tracker_app/widgets/routine/preview/procedure_widget.dart';

import '../dtos/procedure_dto.dart';
import '../dtos/set_dto.dart';
import '../widgets/routine/editor/procedure_widget.dart';
import '../widgets/routine/preview/procedure_display_widget.dart';

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

    final logs = Provider.of<RoutineLogProvider>(context, listen: false)
        .logs
        .where((log) => log.procedures.any((procedure) => exercise.id == exerciseId))
        .toList();

    final procedures = _whereProcedureDto(logs: logs);

    final heaviestLog = _heaviestLog(logs: logs);

    final heaviestSet = _heaviestSet(procedures: procedures);

    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: Text(exercise.name,
                  style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
              bottom: const TabBar(
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
              HistoryWidget(procedures: procedures,)
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
  final List<ProcedureDto> procedures;
  const HistoryWidget({super.key, required this.procedures});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
                itemBuilder: (BuildContext context, int index) =>
                    _procedureToWidget(procedure: procedures[index], otherProcedures: procedures),
                separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 18),
                itemCount: procedures.length),
          ),
        ],
      ),
    );
  }


  /// Convert list of [ExerciseInWorkout] to [ExerciseInWorkoutEditor]
  Widget _procedureToWidget({required ProcedureDto procedure, required List<ProcedureDto> otherProcedures}) {
    return ProcedureDisplayWidget(
      procedureDto: procedure,
      otherSuperSetProcedureDto: _whereOtherProcedure(firstProcedure: procedure, procedures: otherProcedures),
    );
  }

  ProcedureDto? _whereOtherProcedure({required ProcedureDto firstProcedure, required List<ProcedureDto> procedures}) {
    return procedures.firstWhereOrNull((procedure) =>
    procedure.superSetId == firstProcedure.superSetId && procedure.exercise.id != firstProcedure.exercise.id);
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
      title: Text(label, style: const TextStyle(fontSize: 16, color: Colors.white)),
      trailing: Text(summary, style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w700)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
    );
  }
}
