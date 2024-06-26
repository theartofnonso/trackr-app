import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/widgets/empty_states/routine_log_empty_state.dart';

import '../../dtos/routine_log_dto.dart';
import '../../widgets/routine/preview/routine_log_widget.dart';

class RoutineLogsScreen extends StatelessWidget {

  static const routeName = '/routine_logs_screen';

  final List<RoutineLogDto>? logs;

  const RoutineLogsScreen({super.key, this.logs});

  @override
  Widget build(BuildContext context) {

    final routineLogs = logs ?? [];

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
              routineLogs.isNotEmpty
                  ? Expanded(
                      child: ListView.separated(
                          padding: const EdgeInsets.only(bottom: 150),
                          itemBuilder: (BuildContext context, int index) => RoutineLogWidget(log: routineLogs[index], trailing: routineLogs[index].createdAt.durationSinceOrDate()),
                          separatorBuilder: (BuildContext context, int index) =>
                              Divider(color: Colors.white70.withOpacity(0.1)),
                          itemCount: routineLogs.length),
                    )
                  : const RoutineLogEmptyState(),
            ],
          ),
        ),
      ),
    );
  }
}
