import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tracker_app/dtos/set_dtos/weight_and_reps_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import 'package:tracker_app/utils/string_utils.dart';

import '../../colors.dart';
import '../../dtos/appsync/routine_log_dto.dart';
import '../../screens/insights/volume_trend_screen.dart';
import '../../utils/navigation_utils.dart';
import '../list_tile.dart';

class VolumeWidget extends StatelessWidget {
  final List<RoutineLogDto> thisMonthLogs;
  final List<RoutineLogDto> lastMonthLogs;

  const VolumeWidget({super.key, required this.thisMonthLogs, required this.lastMonthLogs});

  @override
  Widget build(BuildContext context) {
    final thisMonthCount = thisMonthLogs
        .expand((log) => log.exerciseLogs)
        .expand((exerciseLog) => exerciseLog.sets)
        .map((set) {
          return switch (set.type) {
            ExerciseType.weights => (set as WeightAndRepsSetDto).volume(),
            ExerciseType.bodyWeight => 0,
            ExerciseType.duration => 0,
          };
        })
        .sum
        .toDouble();

    final lastMonthCount = lastMonthLogs
        .expand((log) => log.exerciseLogs)
        .expand((exerciseLog) => exerciseLog.sets)
        .map((set) {
          return switch (set.type) {
            ExerciseType.weights => (set as WeightAndRepsSetDto).volume(),
            ExerciseType.bodyWeight => 0,
            ExerciseType.duration => 0,
          };
        })
        .sum
        .toDouble();

    final improved = thisMonthCount > lastMonthCount;

    return ThemeListTile(
      child: ListTile(
        onTap: () => _showVolumeScreen(context: context),
        leading: const FaIcon(FontAwesomeIcons.weightHanging),
        title: Text("Volume".toUpperCase()),
        subtitle: Text("Intensity of training"),
        trailing: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(volumeInKOrM(thisMonthCount), style: Theme.of(context).textTheme.titleMedium),
                Text(volumeInKOrM(lastMonthCount), style: Theme.of(context).textTheme.titleSmall)
              ],
            ),
            const SizedBox(width: 4),
            FaIcon(
              improved ? FontAwesomeIcons.arrowUp : FontAwesomeIcons.arrowDown,
              color: improved ? vibrantGreen : Colors.deepOrange,
              size: 12,
            )
          ],
        ),
      ),
    );
  }

  void _showVolumeScreen({required BuildContext context}) {
    navigateWithSlideTransition(context: context, child: const VolumeTrendScreen());
  }
}
