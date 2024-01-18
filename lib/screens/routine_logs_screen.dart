import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/utils/string_utils.dart';
import 'package:tracker_app/widgets/empty_states/routine_log_empty_state.dart';

import '../../utils/navigation_utils.dart';
import '../dtos/routine_log_dto.dart';
import '../utils/exercise_logs_utils.dart';
import '../widgets/pbs/pb_icon.dart';
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
        .expand((pbs) => pbs);

    return SolidListTile(
        title: log.name,
        subtitle: "${log.exerciseLogs.length} ${pluralize(word: "exercise", count: log.exerciseLogs.length)}",
        trailing: log.createdAt.durationSinceOrDate(),
        trailingSubtitle: pbs.isNotEmpty ? PBIcon(color: tealBlueLight, label: "${pbs.length}") : null,
        onTap: () => navigateToRoutineLogPreview(context: context, log: log));
  }
}
