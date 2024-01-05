import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/enums/routine_preview_type_enum.dart';
import '../../../providers/routine_log_provider.dart';
import '../../../screens/exercise/history/home_screen.dart';
import '../../../utils/exercise_logs_utils.dart';
import '../../../utils/general_utils.dart';
import '../../../utils/sets_utils.dart';
import '../../helper_widgets/routine_helper.dart';
import '../preview/set_headers/single_set_header.dart';
import '../preview/set_headers/double_set_header.dart';

enum PBType {
  weight("Weight"),
  volume("Volume"),
  oneRepMax("1RM"),
  duration("Duration");

  const PBType(this.name);

  final String name;
}

class PBViewModel {
  final SetDto set;
  final List<PBType> pbs;

  PBViewModel({required this.set, required this.pbs});
}

class ExerciseLogWidget extends StatelessWidget {
  final ExerciseLogDto exerciseLog;
  final ExerciseLogDto? superSet;
  final EdgeInsetsGeometry? padding;
  final RoutinePreviewType previewType;

  const ExerciseLogWidget({super.key, required this.exerciseLog, required this.superSet, this.padding, required this.previewType});

  @override
  Widget build(BuildContext context) {
    final otherSuperSet = superSet;

    final exerciseType = exerciseLog.exercise.type;

    final provider = Provider.of<RoutineLogProvider>(context, listen: false);

    final pastSets =
        provider.wherePastSetsForExerciseFromDate(exercise: exerciseLog.exercise, date: exerciseLog.createdAt);
    final pastExerciseLogs =
        provider.wherePastExerciseLogsFromDate(exercise: exerciseLog.exercise, date: exerciseLog.createdAt);

    PBViewModel? pbViewModel;

    if (pastSets.isNotEmpty && pastExerciseLogs.isNotEmpty && exerciseLog.sets.isNotEmpty) {
      if (exerciseType == ExerciseType.weightAndReps ||
          exerciseType == ExerciseType.weightedBodyWeight ||
          exerciseType == ExerciseType.assistedBodyWeight) {
        final pastBestSets = personalBestSets(sets: pastSets);
        final pastHeaviestSet = heaviestSet(sets: pastBestSets);
        final pastHeaviestSetVolume = pastExerciseLogs.map((log) => heaviestSetVolumePerLog(exerciseLog: log)).max;
        final pastHeaviest1RM = pastExerciseLogs.map((log) => oneRepMaxPerLog(exerciseLog: log)).max;

        final currentHeaviestSet = heaviestSetPerLog(exerciseLog: exerciseLog);
        final currentHeaviestSetVolume = currentHeaviestSet.value1 * currentHeaviestSet.value2;
        final currentHeaviest1RM = (currentHeaviestSet.value1 * (1 + 0.0333 * currentHeaviestSet.value2));

        List<PBType> pbs = [];

        if (currentHeaviestSet.value1 > pastHeaviestSet.value1) {
          pbs.add(PBType.weight);
        }

        if (currentHeaviestSetVolume > pastHeaviestSetVolume) {
          pbs.add(PBType.volume);
        }

        if (currentHeaviest1RM > pastHeaviest1RM) {
          pbs.add(PBType.oneRepMax);
        }

        if (pbs.isNotEmpty) {
          pbViewModel = PBViewModel(set: currentHeaviestSet, pbs: pbs);
        }
      }

      if (exerciseType == ExerciseType.duration) {
        final pastLongestDuration = pastExerciseLogs.map((log) => longestDurationPerLog(exerciseLog: log)).max;
        final currentLongestDurationSet = longestDurationSet(sets: exerciseLog.sets);
        final currentLongestDuration = Duration(milliseconds: currentLongestDurationSet.value1.toInt());

        if (currentLongestDuration > pastLongestDuration) {
          pbViewModel = PBViewModel(set: currentLongestDurationSet, pbs: [PBType.duration]);
        }
      }
    }

    return Container(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Theme(
            data: ThemeData(splashColor: tealBlueLight),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => HomeScreen(exercise: exerciseLog.exercise)));
              },
              title: Text(exerciseLog.exercise.name, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
              subtitle: otherSuperSet != null
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text("with ${otherSuperSet.exercise.name}",
                          style: GoogleFonts.montserrat(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                    )
                  : null,
            ),
          ),
          exerciseLog.notes.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(exerciseLog.notes,
                      style: GoogleFonts.montserrat(color: Colors.white.withOpacity(0.8), fontSize: 15)),
                )
              : const SizedBox.shrink(),
          switch (exerciseType) {
            ExerciseType.weightAndReps => DoubleSetHeader(firstLabel: weightLabel().toUpperCase(), secondLabel: 'REPS'),
            ExerciseType.weightedBodyWeight =>
              DoubleSetHeader(firstLabel: "+${weightLabel().toUpperCase()}", secondLabel: 'REPS'),
            ExerciseType.assistedBodyWeight =>
              DoubleSetHeader(firstLabel: '-${weightLabel().toUpperCase()}', secondLabel: 'REPS'),
            ExerciseType.bodyWeight => const SingleSetHeader(label: 'REPS'),
            ExerciseType.duration => const SingleSetHeader(label: 'TIME'),
          },
          const SizedBox(height: 8),
          ...setsToWidgets(type: exerciseType, sets: exerciseLog.sets, pbViewModel: previewType == RoutinePreviewType.log ? pbViewModel : null),
        ],
      ),
    );
  }
}
