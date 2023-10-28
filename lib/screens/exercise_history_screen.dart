import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/dtos/routine_log_dto.dart';
import 'package:tracker_app/providers/exercises_provider.dart';
import 'package:tracker_app/providers/routine_log_provider.dart';
import 'package:tracker_app/utils/datetime_utils.dart';
import 'package:tracker_app/widgets/buttons/text_button_widget.dart';

import '../dtos/procedure_dto.dart';
import '../dtos/set_dto.dart';
import '../models/Exercise.dart';
import '../widgets/chart/line_chart_widget.dart';
import '../widgets/routine/preview/routine_log_lite_widget.dart';
import '../dtos/graph/chart_point_dto.dart';

List<SetDto> _allSets({required List<ProcedureDto> procedures}) {
  List<SetDto> completedSets = [];
  for (var procedure in procedures) {
    completedSets.addAll(procedure.sets);
  }
  return completedSets;
}

/// Highest value per [RoutineLogDto]

int _heaviestWeightPerLog({required RoutineLogDto log}) {
  int heaviestWeight = 0;

  final sets = _allSets(procedures: log.procedures);

  for (var set in sets) {
    final weight = set.weight;
    if(weight > heaviestWeight) {
      heaviestWeight = weight;
    }
  }
  return heaviestWeight;
}

int _repsPerLog({required RoutineLogDto log}) {
  int totalReps = 0;

  final sets = _allSets(procedures: log.procedures);

  for (var set in sets) {
    final weight = set.rep;
    totalReps += weight;
  }
  return totalReps;
}

int _heaviestVolumePerLog({required RoutineLogDto log}) {
  int heaviestVolume = 0;

  final sets = _allSets(procedures: log.procedures);

  for (var set in sets) {
    final volume = set.rep * set.weight;
    if(volume > heaviestVolume) {
      heaviestVolume = volume;
    }
  }
  return heaviestVolume;
}

double _oneRepMaxPerLog({required RoutineLogDto log}) {
  SetDto heaviestSet = SetDto();
  int heaviestVolume = 0;

  final sets = _allSets(procedures: log.procedures);

  for (var set in sets) {
    final volume = set.rep * set.weight;
    if(volume > heaviestVolume) {
      heaviestVolume = volume;
      set = set;
    }
  }

  return (heaviestSet.weight * (1 + 0.0333 * heaviestSet.rep));
}

DateTime _dateTimePerLog({required RoutineLogDto log}) {
  return log.endTime!;
}

int _totalVolumePerLog({required RoutineLogDto log}) {
  int totalVolume = 0;

  final sets = _allSets(procedures: log.procedures);

  for (var set in sets) {
    final volume = set.rep * set.weight;
    totalVolume += volume;
  }
  return totalVolume;
}

/// Highest value across all [RoutineLogDto]

SetDto _heaviestSet({required List<RoutineLogDto> logs}) {
  SetDto heaviestSet = SetDto();

  for (var log in logs) {
    final sets = _allSets(procedures: log.procedures);
    for (var set in sets) {
      final volume = set.rep * set.weight;
      if (volume > (heaviestSet.rep * heaviestSet.weight)) {
        heaviestSet = set;
      }
    }
  }
  return heaviestSet;
}

RoutineLogDto _heaviestLog({required List<RoutineLogDto> logs}) {
  RoutineLogDto heaviestLog = logs[0];

  int heaviestVolume = 0;

  for (var log in logs) {
    final totalVolume = _totalVolumePerLog(log: log);
    if (totalVolume > heaviestVolume) {
      heaviestVolume = totalVolume;
      heaviestLog = log;
    }
  }

  return heaviestLog;
}

int _heaviestLogVolume({required List<RoutineLogDto> logs}) {
  int heaviestVolume = 0;

  for (var log in logs) {
    final totalVolume = _totalVolumePerLog(log: log);
    if (totalVolume > heaviestVolume) {
      heaviestVolume = totalVolume;
    }
  }

  return heaviestVolume;
}

int _heaviestWeight({required List<RoutineLogDto> logs}) {
  int heaviestWeight = 0;

  for (var log in logs) {
    final sets = _allSets(procedures: log.procedures);
    for (var set in sets) {
      final weight = set.weight;
      if (weight > heaviestWeight) {
        heaviestWeight = weight;
      }
    }
  }
  return heaviestWeight;
}

class ExerciseHistoryScreen extends StatelessWidget {
  final String exerciseId;

  const ExerciseHistoryScreen({super.key, required this.exerciseId});

  List<RoutineLogDto> _whereLogsForExercise({required List<RoutineLogDto> logs}) {
    return logs
        .where((log) => log.procedures.any((procedure) => procedure.exercise.id == exerciseId))
        .map((log) =>
            log.copyWith(procedures: log.procedures.where((procedure) => procedure.exercise.id == exerciseId).toList()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final exercise = Provider.of<ExerciseProvider>(context, listen: false).whereExercise(exerciseId: exerciseId);

    final routineLogs = Provider.of<RoutineLogProvider>(context, listen: false).logs;

    final routineLogsForExercise = _whereLogsForExercise(logs: routineLogs);

    final heaviestRoutineLog = _heaviestLog(logs: routineLogsForExercise);

    final heaviestRoutineLogVolume = _heaviestLogVolume(logs: routineLogsForExercise);

    final heaviestSet = _heaviestSet(logs: routineLogsForExercise);

    final heaviestWeight = _heaviestWeight(logs: routineLogsForExercise);

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
                heaviestWeight: heaviestWeight,
                heaviestSet: heaviestSet,
                heaviestRoutineLogVolume: heaviestRoutineLogVolume,
                heaviestLog: heaviestRoutineLog,
                routineLogDtos: routineLogsForExercise,
                exercise: exercise,
              ),
              HistoryWidget(logs: routineLogsForExercise)
            ],
          ),
        ));
  }
}

class SummaryWidget extends StatelessWidget {
  final int heaviestWeight;
  final SetDto heaviestSet;
  final RoutineLogDto heaviestLog;
  final int heaviestRoutineLogVolume;
  final List<RoutineLogDto> routineLogDtos;
  final Exercise exercise;

  const SummaryWidget(
      {super.key,
      required this.heaviestWeight,
      required this.heaviestSet,
      required this.heaviestLog,
      required this.routineLogDtos,
      required this.heaviestRoutineLogVolume,
      required this.exercise});

  @override
  Widget build(BuildContext context) {
    final oneRepMax = (heaviestSet.weight * (1 + 0.0333 * heaviestSet.rep));

    final heaviestWeightPerLog = routineLogDtos.map((log) => _heaviestWeightPerLog(log: log)).toList().reversed;

    final heaviestVolumePerLog = routineLogDtos.map((log) => _heaviestVolumePerLog(log: log)).toList().reversed;

    final repsPerLog = routineLogDtos.map((log) => _repsPerLog(log: log)).toList().reversed;

    final oneRepMaxPerLog = routineLogDtos.map((log) => _oneRepMaxPerLog(log: log)).toList().reversed;

    final dateTimes = routineLogDtos.map((log) => _dateTimePerLog(log: log).formattedDayAndMonth()).toList().reversed.toList();

    final weightPoints = repsPerLog
        .mapIndexed((index, value) => ChartPointDto(index.toDouble(), value.toDouble()))
        .toList();

    return SingleChildScrollView(
        child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const SizedBox(height: 10),
          // Text(
          //   "Primary Target: ${exercise.primary.join(", ")}",
          //   style: TextStyle(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500, fontSize: 12),
          // ),
          // const SizedBox(height: 5),
          // Text(
          //   "Secondary Target: ${exercise.secondary.isNotEmpty ? exercise.secondary.join(", ") : "None"}",
          //   style: TextStyle(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500, fontSize: 12),
          // ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(top: 20.0, right: 30, bottom: 20),
            child: LineChartWidget(chartPoints: weightPoints, dateTimes: dateTimes),
          ),
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  CTextButton(onPressed: () {}, label: "Heaviest Weight"),
                  const SizedBox(width: 5),
                  CTextButton(onPressed: () {}, label: "Heaviest Set Volume"),
                  const SizedBox(width: 5),
                  CTextButton(onPressed: () {}, label: "Session Volume"),
                  const SizedBox(width: 5),
                  CTextButton(onPressed: () {}, label: "1RM"),
                  const SizedBox(width: 5),
                  CTextButton(onPressed: () {}, label: "Total Reps"),
                ],
              )),
          const SizedBox(height: 10),
          MetricWidget(
              title: 'Heaviest weight', summary: "${heaviestWeight}kg", subtitle: 'Heaviest weight lifted for a set'),
          const SizedBox(height: 10),
          MetricWidget(
            title: 'Heaviest Set Volume',
            summary: "${heaviestSet.weight}kg x ${heaviestSet.rep}",
            subtitle: 'Heaviest volume lifted for a set',
          ),
          const SizedBox(height: 10),
          MetricWidget(
            title: 'Heaviest Session Volume',
            summary: "${heaviestRoutineLogVolume}kg",
            subtitle: 'Heaviest volume lifted for a session',
          ),
          const SizedBox(height: 10),
          MetricWidget(
            title: '1 Rep Max',
            summary: '${oneRepMax}kg',
            subtitle: 'Heaviest weight you can lift for one rep',
          ),
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
    required this.title,
    required this.subtitle,
    required this.summary,
  });

  final String title;
  final String subtitle;
  final String summary;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: tealBlueLight,
      title: Text(title, style: const TextStyle(fontSize: 14, color: Colors.white)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7))),
      trailing: Text(summary, style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
    );
  }
}
