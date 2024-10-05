import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/dtos/routine_log_dto.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/widgets/empty_states/routine_log_empty_state.dart';
import 'package:tracker_app/widgets/routine/preview/activity_log_widget.dart';

import '../../dtos/activity_log_dto.dart';
import '../../dtos/interface/log_interface.dart';
import '../../widgets/routine/preview/routine_log_widget.dart';

class LogsScreen extends StatelessWidget {
  static const routeName = '/logs_screen';

  final List<Log> logs;

  const LogsScreen({
    super.key,
    this.logs = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: sapphireDark80,
        leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
            onPressed: Navigator.of(context).pop),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              sapphireDark80,
              sapphireDark,
            ],
          ),
        ),
        child: SafeArea(
          minimum: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              logs.isNotEmpty
                  ? Expanded(
                      child: ListView.separated(
                          padding: const EdgeInsets.only(bottom: 150),
                          itemBuilder: (BuildContext context, int index) {
                            final log = logs[index];
                            if (log.type == LogType.routine) {
                              final routineLog = log as RoutineLogDto;
                              return RoutineLogWidget(
                                  log: routineLog,
                                  color: Colors.transparent,
                                  trailing: routineLog.createdAt.durationSinceOrDate());
                            } else {
                              final activityLog = log as ActivityLogDto;
                              return ActivityLogWidget(activity: activityLog, color: Colors.transparent,);
                            }
                          },
                          separatorBuilder: (BuildContext context, int index) =>
                              Divider(color: Colors.white70.withOpacity(0.1)),
                          itemCount: logs.length),
                    )
                  : const RoutineLogEmptyState(),
            ],
          ),
        ),
      ),
    );
  }
}
