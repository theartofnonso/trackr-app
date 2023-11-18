import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/providers/exercise_provider.dart';
import 'package:tracker_app/providers/routine_log_provider.dart';
import 'package:tracker_app/screens/editor/exercise_editor_screen.dart';
import 'package:tracker_app/screens/exercise/history/history_screen.dart';
import 'package:tracker_app/screens/exercise/history/summary_screen.dart';
import 'package:tracker_app/screens/settings_screen.dart';
import 'package:tracker_app/widgets/buttons/text_button_widget.dart';

import '../../../dtos/procedure_dto.dart';
import '../../../dtos/set_dto.dart';
import '../../../models/Exercise.dart';
import '../../../models/RoutineLog.dart';
import '../../../shared_prefs.dart';
import '../../../utils/general_utils.dart';
import '../../../utils/snackbar_utils.dart';
import '../../../widgets/chart/line_chart_widget.dart';
import '../../../widgets/helper_widgets/dialog_helper.dart';
import 'notes_screen.dart';

const exerciseRouteName = "/exercise-history-screen";

ChartUnit weightUnit() {
  return SharedPrefs().weightUnit == WeightUnit.kg.name ? ChartUnit.kg : ChartUnit.lbs;
}

List<SetDto> _allSetsWithWeight({required List<String> procedureJsons}) {
  final procedures = procedureJsons.map((json) => ProcedureDto.fromJson(jsonDecode(json))).toList();
  return procedures
      .where((procedure) =>
          ExerciseType.fromString(procedure.exercise.type) == ExerciseType.weightAndReps ||
          ExerciseType.fromString(procedure.exercise.type) == ExerciseType.weightedBodyWeight)
      .expand((procedure) => procedure.sets)
      .toList();
}

List<SetDto> _allSetsWithReps({required List<String> procedureJsons}) {
  final procedures = procedureJsons.map((json) => ProcedureDto.fromJson(jsonDecode(json))).toList();
  return procedures
      .where((procedure) =>
          ExerciseType.fromString(procedure.exercise.type) == ExerciseType.weightAndReps ||
          ExerciseType.fromString(procedure.exercise.type) == ExerciseType.weightedBodyWeight ||
          ExerciseType.fromString(procedure.exercise.type) == ExerciseType.assistedBodyWeight ||
          ExerciseType.fromString(procedure.exercise.type) == ExerciseType.bodyWeightAndReps)
      .expand((procedure) => procedure.sets)
      .toList();
}

List<SetDto> _allSetsWithDuration({required List<String> procedureJsons}) {
  final procedures = procedureJsons.map((json) => ProcedureDto.fromJson(jsonDecode(json))).toList();
  return procedures
      .where((procedure) =>
          ExerciseType.fromString(procedure.exercise.type) == ExerciseType.duration ||
          ExerciseType.fromString(procedure.exercise.type) == ExerciseType.distanceAndDuration)
      .expand((procedure) => procedure.sets)
      .toList();
}

List<SetDto> _allSetsWithDistance({required List<String> procedureJsons}) {
  final procedures = procedureJsons.map((json) => ProcedureDto.fromJson(jsonDecode(json))).toList();
  return procedures
      .where((procedure) =>
          ExerciseType.fromString(procedure.exercise.type) == ExerciseType.weightAndDistance ||
          ExerciseType.fromString(procedure.exercise.type) == ExerciseType.distanceAndDuration)
      .expand((procedure) => procedure.sets)
      .toList();
}

/// Highest value per [RoutineLogDto]

SetDto _heaviestWeightInSetPerLog({required RoutineLog log}) {
  double heaviestWeight = 0;
  SetDto setWithHeaviestWeight = SetDto(0, 0, SetType.working, false);

  final sets = _allSetsWithWeight(procedureJsons: log.procedures);

  for (var set in sets) {
    final weight = set.value1.toDouble();
    if (weight > heaviestWeight) {
      heaviestWeight = weight.toDouble();
      setWithHeaviestWeight = set;
    }
  }
  return setWithHeaviestWeight;
}

double heaviestWeightPerLog({required RoutineLog log}) {
  double heaviestWeight = 0;

  final sets = _allSetsWithWeight(procedureJsons: log.procedures);

  for (var set in sets) {
    final weight = set.value1.toDouble();
    if (weight > heaviestWeight) {
      heaviestWeight = weight.toDouble();
    }
  }

  final weight = isDefaultWeightUnit() ? heaviestWeight : toLbs(heaviestWeight);

  return weight;
}

int repsPerLog({required RoutineLog log}) {
  int totalReps = 0;

  final sets = _allSetsWithReps(procedureJsons: log.procedures);

  for (var set in sets) {
    totalReps += set.value2.toInt();
  }
  return totalReps;
}

double heaviestSetVolumePerLog({required RoutineLog log}) {
  double heaviestVolume = 0;

  final sets = _allSetsWithWeight(procedureJsons: log.procedures);

  for (var set in sets) {
    final volume = set.value1 * set.value2;
    if (volume > heaviestVolume) {
      heaviestVolume = volume.toDouble();
    }
  }

  final volume = isDefaultWeightUnit() ? heaviestVolume : toLbs(heaviestVolume);

  return volume;
}

double volumePerLog({required RoutineLog log}) {
  double totalVolume = 0;

  final sets = _allSetsWithWeight(procedureJsons: log.procedures);

  for (var set in sets) {
    final volume = set.value1 * set.value2;
    totalVolume += volume;
  }

  final volume = isDefaultWeightUnit() ? totalVolume : toLbs(totalVolume);

  return volume;
}

double oneRepMaxPerLog({required RoutineLog log}) {
  final heaviestWeightInSet = _heaviestWeightInSetPerLog(log: log);

  final max = (heaviestWeightInSet.value1 * (1 + 0.0333 * heaviestWeightInSet.value2));

  final maxWeight = isDefaultWeightUnit() ? max : toLbs(max);

  return maxWeight;
}

DateTime dateTimePerLog({required RoutineLog log}) {
  return log.createdAt.getDateTimeInUtc();
}

Duration durationPerLog({required RoutineLog log}) {
  final startTime = log.startTime.getDateTimeInUtc();
  final endTime = log.endTime.getDateTimeInUtc();
  final difference = endTime.difference(startTime);
  return difference;
}

double _totalVolumePerLog({required RoutineLog log}) {
  double totalVolume = 0;

  final sets = _allSetsWithWeight(procedureJsons: log.procedures);

  for (var set in sets) {
    final volume = set.value1 * set.value2;
    totalVolume += volume;
  }

  final volume = isDefaultWeightUnit() ? totalVolume : toLbs(totalVolume);

  return volume;
}

/// Highest value across all [RoutineLogDto]

(String, SetDto) _heaviestSet({required List<RoutineLog> logs}) {
  SetDto heaviestSet = SetDto(0, 0, SetType.working, false);
  String logId = "";
  for (var log in logs) {
    final sets = _allSetsWithWeight(procedureJsons: log.procedures);
    for (var set in sets) {
      final volume = set.value1 * set.value2;
      if (volume > (heaviestSet.value1 * heaviestSet.value2)) {
        heaviestSet = set;
        logId = log.id;
      }
    }
  }

  final weight = isDefaultWeightUnit() ? heaviestSet.value1 : toLbs(heaviestSet.value1.toDouble());

  return (logId, heaviestSet.copyWith(value1: weight));
}

(String, double) _heaviestLogVolume({required List<RoutineLog> logs}) {
  double heaviestVolume = 0;
  String logId = "";
  for (var log in logs) {
    final totalVolume = _totalVolumePerLog(log: log);
    if (totalVolume > heaviestVolume) {
      heaviestVolume = totalVolume;
      logId = log.id;
    }
  }

  return (logId, heaviestVolume);
}

(String, double) _heaviestWeight({required List<RoutineLog> logs}) {
  double heaviestWeight = 0;
  String logId = "";
  for (var log in logs) {
    final weight = heaviestWeightPerLog(log: log);
    if (weight > heaviestWeight) {
      heaviestWeight = weight;
      logId = log.id;
    }
  }
  return (logId, heaviestWeight);
}

class ExerciseHistoryScreen extends StatelessWidget {
  final Exercise exercise;

  const ExerciseHistoryScreen({super.key, required this.exercise});

  List<RoutineLog> _logsWhereExercise({required List<RoutineLog> logs}) {
    return logs
        .where((log) => log.procedures
            .map((json) => ProcedureDto.fromJson(jsonDecode(json)))
            .any((procedure) => procedure.exercise.id == exercise.id))
        .map((log) => log.copyWith(
            procedures: log.procedures
                .where((procedure) => ProcedureDto.fromJson(jsonDecode(procedure)).exercise.id == exercise.id)
                .toList()))
        .toList();
  }

  /// [MenuItemButton]
  List<Widget> _menuActionButtons({required BuildContext context, required Exercise exercise}) {
    return [
      MenuItemButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => ExerciseEditorScreen(exercise: exercise)));
        },
        leadingIcon: const Icon(Icons.edit),
        child: const Text("Edit"),
      ),
      MenuItemButton(
        onPressed: () {
          final alertDialogActions = <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel', style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.red)),
            ),
            CTextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await Provider.of<ExerciseProvider>(context, listen: false).removeExercise(id: exercise.id);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  } catch (_) {
                    if (context.mounted) {
                      showSnackbar(
                          context: context,
                          icon: const Icon(Icons.info_outline),
                          message: "Oops, we are unable delete this exercise");
                    }
                  }
                },
                label: 'Delete'),
          ];
          showAlertDialog(context: context, message: "Delete exercise?", actions: alertDialogActions);
        },
        leadingIcon: const Icon(Icons.delete_sweep, color: Colors.red),
        child: Text("Delete", style: GoogleFonts.lato(color: Colors.red)),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    final foundExercise =
        Provider.of<ExerciseProvider>(context, listen: true).whereExerciseOrNull(exerciseId: exercise.id) ?? exercise;

    final routineLogs = Provider.of<RoutineLogProvider>(context, listen: true).logs;

    final routineLogsForExercise = _logsWhereExercise(logs: routineLogs);

    final heaviestRoutineLogVolume = _heaviestLogVolume(logs: routineLogsForExercise);

    final heaviestSet = _heaviestSet(logs: routineLogsForExercise);

    final heaviestWeight = _heaviestWeight(logs: routineLogsForExercise);

    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_outlined),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(foundExercise.name,
                style: GoogleFonts.lato(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
            bottom: const TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: [
                Tab(
                  text: "Summary",
                ),
                Tab(
                  text: "History",
                ),
                Tab(
                  text: "Notes",
                )
              ],
            ),
            actions: [
              MenuAnchor(
                style: MenuStyle(
                  backgroundColor: MaterialStateProperty.all(tealBlueLighter),
                ),
                builder: (BuildContext context, MenuController controller, Widget? child) {
                  return IconButton(
                    onPressed: () {
                      if (controller.isOpen) {
                        controller.close();
                      } else {
                        controller.open();
                      }
                    },
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    tooltip: 'Show menu',
                  );
                },
                menuChildren: _menuActionButtons(context: context, exercise: foundExercise),
              )
            ],
          ),
          body: TabBarView(
            children: [
              SummaryScreen(
                heaviestWeight: heaviestWeight,
                heaviestSet: heaviestSet,
                heaviestRoutineLogVolume: heaviestRoutineLogVolume,
                routineLogs: routineLogsForExercise,
                exercise: foundExercise,
              ),
              HistoryScreen(logs: routineLogsForExercise),
              NotesScreen(notes: foundExercise.notes)
            ],
          ),
        ));
  }
}
