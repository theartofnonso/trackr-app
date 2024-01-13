import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/widgets/empty_states/routine_log_empty_state.dart';

import '../../utils/navigation_utils.dart';
import '../dtos/routine_log_dto.dart';
import '../utils/exercise_logs_utils.dart';
import '../widgets/chips/chip_1.dart';
import '../widgets/list_tiles/list_tile_solid.dart';

class RoutineLogsScreen extends StatelessWidget {
  final List<RoutineLogDto> logs;

  const RoutineLogsScreen({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
            onPressed: Navigator.of(context).pop),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            logs.isNotEmpty
                ? Expanded(
                    child: ListView.separated(
                        padding: const EdgeInsets.only(bottom: 150),
                        itemBuilder: (BuildContext context, int index) => _RoutineLogWidget(log: logs[index]),
                        separatorBuilder: (BuildContext context, int index) =>
                            Divider(color: Colors.white70.withOpacity(0.1)),
                        itemCount: logs.length),
                  )
                : const RoutineLogEmptyState(),
          ],
        ),
      ),
    );
  }
}

class _RoutineLogWidget extends StatelessWidget {
  final RoutineLogDto log;

  const _RoutineLogWidget({required this.log});

  @override
  Widget build(BuildContext context) {
    final pbs = log.exerciseLogs
        .map((exerciseLog) =>
            calculatePBs(context: context, exerciseType: exerciseLog.exercise.type, exerciseLog: exerciseLog))
        .expand((pbs) => pbs.values)
        .fold<int>(0, (count, pb) => count + pb.length);

    return SolidListTile(
        title: log.name,
        subtitle: "${log.exerciseLogs.length} ${log.exerciseLogs.length > 1 ? "exercises" : "exercise"}",
        trailing: log.createdAt.durationSinceOrDate(),
        trailingSubtitle: pbs >= 1 ? ChipOne(color: tealBlueLight, label: "$pbs") : null,
        onTap: () => navigateToRoutineLogPreview(context: context, log: log));
  }
}
