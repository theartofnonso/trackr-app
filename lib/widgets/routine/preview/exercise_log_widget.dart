import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/dtos/exercise_log_dto.dart';
import 'package:tracker_app/dtos/set_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import '../../../providers/routine_log_provider.dart';
import '../../../screens/exercise/history/home_screen.dart';
import '../../../utils/exercise_logs_utils.dart';
import '../../../utils/general_utils.dart';
import '../../../utils/sets_utils.dart';
import '../../helper_widgets/routine_helper.dart';
import '../preview/set_headers/single_set_header.dart';
import '../preview/set_headers/double_set_header.dart';

enum PBType {

  weight("Weight"), volume("Volume"), oneRepMax("1RM"), duration("Duration"), distance("Distance");

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

  const ExerciseLogWidget({super.key, required this.exerciseLog, required this.superSet, this.padding});

  @override
  Widget build(BuildContext context) {
    final otherSuperSet = superSet;

    final exerciseType = exerciseLog.exercise.type;

    PBViewModel? pbViewModel;

    if(exerciseType == ExerciseType.weightAndReps || exerciseType == ExerciseType.weightedBodyWeight || exerciseType == ExerciseType.assistedBodyWeight) {

      final provider = Provider.of<RoutineLogProvider>(context, listen: false);

      final pastSets = provider.wherePastSetsForExerciseFromDate(exercise: exerciseLog.exercise, date: exerciseLog.createdAt);
      final pastExerciseLogs = provider.wherePastExerciseLogsFromDate(exercise: exerciseLog.exercise, date: exerciseLog.createdAt);

      if(pastSets.isNotEmpty) {
        final pastBestSets = personalBestSets(sets: pastSets);
        final highestPastSet = maxVolume(sets: pastBestSets);
        final highestPastSetVolume = highestPastSet.value1 * highestPastSet.value2;
        final highestPast1RM = pastExerciseLogs.map((log) => oneRepMaxPerLog(exerciseLog: log)).toList().max;

        final currentBestSet = personalBestSets(sets: exerciseLog.sets);
        final highestCurrentSet = maxVolume(sets: currentBestSet);
        final highestCurrentSetVolume = highestCurrentSet.value1 * highestCurrentSet.value2;
        final heaviestSet = heaviestSetPerLog(exerciseLog: exerciseLog);
        final highestCurrent1RM = (heaviestSet.value1 * (1 + 0.0333 * heaviestSet.value2));

        List<PBType> pbs = [];

        if (highestCurrentSet.value1 > highestPastSet.value1) {
          pbs.add(PBType.weight);
        }

        if (highestCurrentSetVolume > highestPastSetVolume) {
          pbs.add(PBType.volume);
        }

        if (highestCurrent1RM > highestPast1RM) {
          pbs.add(PBType.oneRepMax);
        }

        if (pbs.isNotEmpty) {
          pbViewModel = PBViewModel(set: highestCurrentSet, pbs: pbs);
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
              title: Text(exerciseLog.exercise.name, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14)),
              subtitle: otherSuperSet != null
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text("with ${otherSuperSet.exercise.name}",
                          style: GoogleFonts.montserrat(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w600)),
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
            ExerciseType.bodyWeightAndReps => const SingleSetHeader(label: 'REPS'),
            ExerciseType.duration => const SingleSetHeader(label: 'TIME'),
          },
          const SizedBox(height: 8),
          ...setsToWidgets(type: exerciseType, sets: exerciseLog.sets, pbViewModel: pbViewModel),
        ],
      ),
    );
  }
}
