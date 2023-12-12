import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/providers/exercise_provider.dart';
import 'package:tracker_app/providers/routine_log_provider.dart';
import 'package:tracker_app/screens/editors/exercise_editor_screen.dart';
import 'package:tracker_app/screens/exercise/history/history_screen.dart';
import 'package:tracker_app/screens/exercise/history/exercise_chart_screen.dart';
import 'package:tracker_app/screens/settings_screen.dart';

import '../../../dtos/exercise_log_dto.dart';
import '../../../dtos/set_dto.dart';
import '../../../models/Exercise.dart';
import '../../../shared_prefs.dart';
import '../../../utils/general_utils.dart';
import '../../../utils/snackbar_utils.dart';
import '../../../widgets/chart/line_chart_widget.dart';
import '../../../widgets/helper_widgets/dialog_helper.dart';
import 'notes_screen.dart';

const exerciseRouteName = "/exercise-history-screen";

ChartUnitLabel weightUnit() {
  return SharedPrefs().weightUnit == WeightUnit.kg.name ? ChartUnitLabel.kg : ChartUnitLabel.lbs;
}

/// Highest value per [RoutineLogDto]

SetDto _heaviestSetPerLog({required ExerciseLogDto exerciseLog}) {
  double heaviestWeight = 0;
  SetDto setWithHeaviestWeight = SetDto(0, 0, 0, SetType.working, false);

  for (SetDto set in exerciseLog.sets) {
    final weight = set.value1.toDouble();
    if (weight > heaviestWeight) {
      heaviestWeight = weight.toDouble();
      setWithHeaviestWeight = set;
    }
  }
  return setWithHeaviestWeight;
}

double heaviestWeightPerLog({required ExerciseLogDto exerciseLog}) {
  double heaviestWeight = 0;

  for (SetDto set in exerciseLog.sets) {
    final weight = set.value1.toDouble();
    if (weight > heaviestWeight) {
      heaviestWeight = weight.toDouble();
    }
  }

  final weight = isDefaultWeightUnit() ? heaviestWeight : toLbs(heaviestWeight);

  return weight;
}

Duration longestDurationPerLog({required ExerciseLogDto exerciseLog}) {
  Duration longestDuration = Duration.zero;

  for (var set in exerciseLog.sets) {
    final duration = Duration(milliseconds: set.value1.toInt());
    if (duration > longestDuration) {
      longestDuration = duration;
    }
  }
  return longestDuration;
}

Duration totalDurationPerLog({required ExerciseLogDto exerciseLog}) {
  Duration totalDuration = Duration.zero;

  for (var set in exerciseLog.sets) {
    final duration = Duration(milliseconds: set.value1.toInt());
    totalDuration += duration;
  }
  return totalDuration;
}

double longestDistancePerLog({required ExerciseLogDto exerciseLog}) {
  double longestDistance = 0;

  for (var set in exerciseLog.sets) {
    final distance = set.value2.toDouble();
    if (distance > longestDistance) {
      longestDistance = distance;
    }
  }
  return longestDistance;
}

double totalDistancePerLog({required ExerciseLogDto exerciseLog}) {
  double totalDistance = 0;

  for (var set in exerciseLog.sets) {
    final distance = set.value2.toDouble();
    totalDistance += distance;
  }
  return totalDistance;
}

int totalRepsForLog({required ExerciseLogDto exerciseLog}) {
  int totalReps = 0;

  final sets = exerciseLog.sets;

  for (var set in sets) {
    totalReps += set.value2.toInt();
  }
  return totalReps;
}

int highestRepsForLog({required ExerciseLogDto exerciseLog}) {
  int highestReps = 0;

  final sets = exerciseLog.sets;

  for (var set in sets) {
    final reps = set.value2;
    if (reps > highestReps) {
      highestReps = reps.toInt();
    }
  }

  return highestReps;
}

double heaviestSetVolumePerLog({required ExerciseLogDto exerciseLog}) {
  double heaviestVolume = 0;

  for (var set in exerciseLog.sets) {
    final volume = set.value1 * set.value2;
    if (volume > heaviestVolume) {
      heaviestVolume = volume.toDouble();
    }
  }

  final volume = isDefaultWeightUnit() ? heaviestVolume : toLbs(heaviestVolume);

  return volume;
}

double lightestSetVolumePerLog({required ExerciseLogDto exerciseLog}) {
  double lightestVolume = 0;

  for (var set in exerciseLog.sets) {
    final volume = set.value1 * set.value2;
    if (lightestVolume < volume) {
      lightestVolume = volume.toDouble();
    }
  }

  final volume = isDefaultWeightUnit() ? lightestVolume : toLbs(lightestVolume);

  return volume;
}

double oneRepMaxPerLog({required ExerciseLogDto exerciseLog}) {
  final heaviestWeightInSet = _heaviestSetPerLog(exerciseLog: exerciseLog);

  final max = (heaviestWeightInSet.value1 * (1 + 0.0333 * heaviestWeightInSet.value2));

  final maxWeight = isDefaultWeightUnit() ? max : toLbs(max);

  return maxWeight;
}

DateTime dateTimePerLog({required ExerciseLogDto log}) {
  return log.createdAt.getDateTimeInUtc();
}

/// Highest value across all [RoutineLogDto]

List<ExerciseLogDto> _pastLogsForExercise({required BuildContext context, required Exercise exercise}) {
  final pastLogs = Provider.of<RoutineLogProvider>(context, listen: false).exerciseLogs[exercise.id] ?? [];
  return pastLogs.reversed.toList();
}

(String, SetDto) _heaviestSet({required BuildContext context, required Exercise exercise}) {
  final pastLogs = _pastLogsForExercise(context: context, exercise: exercise);
  SetDto heaviestSet = pastLogs.first.sets.first;
  String logId = pastLogs.first.routineLogId;
  for (var log in pastLogs) {
    for (var set in log.sets) {
      final volume = set.value1 * set.value2;
      if (volume > (heaviestSet.value1 * heaviestSet.value2)) {
        heaviestSet = set;
        logId = log.routineLogId;
      }
    }
  }

  final weight = isDefaultWeightUnit() ? heaviestSet.value1 : toLbs(heaviestSet.value1.toDouble());

  return (logId, heaviestSet.copyWith(value1: weight));
}

(String, SetDto) _lightestSet({required BuildContext context, required Exercise exercise}) {
  final pastLogs = _pastLogsForExercise(context: context, exercise: exercise);
  SetDto lightestSet = pastLogs.first.sets.first;
  String logId = pastLogs.first.routineLogId;
  for (var log in pastLogs) {
    for (var set in log.sets) {
      final volume = set.value1 * set.value2;
      if ((lightestSet.value1 * lightestSet.value2) > volume) {
        lightestSet = set;
        logId = log.routineLogId;
      }
    }
  }

  final weight = isDefaultWeightUnit() ? lightestSet.value1 : toLbs(lightestSet.value1.toDouble());

  return (logId, lightestSet.copyWith(value1: weight));
}

(String, double) _heaviestWeight({required BuildContext context, required Exercise exercise}) {
  final pastLogs = _pastLogsForExercise(context: context, exercise: exercise);
  double heaviestWeight = pastLogs.first.sets.first.value1.toDouble();
  String logId = pastLogs.first.routineLogId;
  for (var log in pastLogs) {
    for (var set in log.sets) {
      final weight = set.value1.toDouble();
      if (weight > heaviestWeight) {
        heaviestWeight = weight;
        logId = log.routineLogId;
      }
    }
  }
  return (logId, heaviestWeight);
}

(String, double) _lightestWeight({required BuildContext context, required Exercise exercise}) {
  final pastLogs = _pastLogsForExercise(context: context, exercise: exercise);
  double lightestWeight = pastLogs.first.sets.first.value1.toDouble();
  String logId = pastLogs.first.routineLogId;
  for (var log in pastLogs) {
    for (var set in log.sets) {
      final weight = set.value1.toDouble();
      if (lightestWeight > weight) {
        lightestWeight = weight;
        logId = log.routineLogId;
      }
    }
  }
  return (logId, lightestWeight);
}

(String, int) _highestReps({required BuildContext context, required Exercise exercise}) {
  final pastLogs = _pastLogsForExercise(context: context, exercise: exercise);
  int highestReps = pastLogs.first.sets.first.value2.toInt();
  String logId = pastLogs.first.routineLogId;
  for (var log in pastLogs) {
    final reps = highestRepsForLog(exerciseLog: log);
    if (reps > highestReps) {
      highestReps = reps;
      logId = log.routineLogId;
    }
  }
  return (logId, highestReps);
}

(String, int) _totalReps({required BuildContext context, required Exercise exercise}) {
  final pastLogs = _pastLogsForExercise(context: context, exercise: exercise);
  int mostReps = pastLogs.first.sets.first.value2.toInt();
  String logId = pastLogs.first.routineLogId;
  for (var log in pastLogs) {
    final reps = totalRepsForLog(exerciseLog: log);
    if (reps > mostReps) {
      mostReps = reps;
      logId = log.routineLogId;
    }
  }
  return (logId, mostReps);
}

(String, Duration) _longestDuration({required BuildContext context, required Exercise exercise}) {
  final pastLogs = _pastLogsForExercise(context: context, exercise: exercise);
  Duration longestDuration = Duration(milliseconds: pastLogs.first.sets.first.value1.toInt());
  String logId = pastLogs.first.routineLogId;
  for (var log in pastLogs) {
    final duration = longestDurationPerLog(exerciseLog: log);
    if (duration > longestDuration) {
      longestDuration = duration;
      logId = log.routineLogId;
    }
  }
  return (logId, longestDuration);
}

(String, double) _longestDistance({required BuildContext context, required Exercise exercise}) {
  final pastLogs = _pastLogsForExercise(context: context, exercise: exercise);
  double longestDistance = pastLogs.first.sets.first.value2.toDouble();
  String logId = pastLogs.first.routineLogId;
  for (var log in pastLogs) {
    final distance = longestDistancePerLog(exerciseLog: log);
    if (distance > longestDistance) {
      longestDistance = distance;
      logId = log.routineLogId;
    }
  }
  return (logId, longestDistance);
}

class HomeScreen extends StatelessWidget {
  final Exercise exercise;

  const HomeScreen({super.key, required this.exercise});

  /// [MenuItemButton]
  List<Widget> _menuActionButtons({required BuildContext context, required Exercise exercise}) {
    return [
      MenuItemButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => ExerciseEditorScreen(exercise: exercise)));
        },
        child: const Text("Edit"),
      ),
      MenuItemButton(
        onPressed: () {
          showAlertDialogWithMultiActions(
              context: context,
              message: "Delete exercise?",
              leftAction: Navigator.of(context).pop,
              rightAction: () => _deleteExercise(context),
              leftActionLabel: 'Cancel',
              rightActionLabel: 'Delete',
              isRightActionDestructive: true);
        },
        child: Text("Delete", style: GoogleFonts.lato(color: Colors.red)),
      )
    ];
  }

  void _deleteExercise(BuildContext context) async {
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
  }

  @override
  Widget build(BuildContext context) {
    final foundExercise =
        Provider.of<ExerciseProvider>(context, listen: true).whereExerciseOrNull(exerciseId: exercise.id) ?? exercise;

    final heaviestSet = _heaviestSet(context: context, exercise: foundExercise);

    final lightestSet = _lightestSet(context: context, exercise: foundExercise);

    final heaviestWeight = _heaviestWeight(context: context, exercise: foundExercise);

    final lightestWeight = _lightestWeight(context: context, exercise: foundExercise);

    final longestDuration = _longestDuration(context: context, exercise: foundExercise);

    final longestDistance = _longestDistance(context: context, exercise: foundExercise);

    final mostRepsSet = _highestReps(context: context, exercise: foundExercise);

    final mostRepsSession = _totalReps(context: context, exercise: foundExercise);

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
          body: SafeArea(
            child: TabBarView(
              children: [
                ExerciseChartScreen(
                  heaviestWeight: heaviestWeight,
                  lightestWeight: lightestWeight,
                  heaviestSet: heaviestSet,
                  lightestSet: lightestSet,
                  longestDuration: longestDuration,
                  longestDistance: longestDistance,
                  mostRepsSet: mostRepsSet,
                  mostRepsSession: mostRepsSession,
                  exercise: foundExercise,
                ),
                HistoryScreen(exercise: foundExercise),
                NotesScreen(notes: foundExercise.notes ?? "")
              ],
            ),
          ),
        ));
  }
}
