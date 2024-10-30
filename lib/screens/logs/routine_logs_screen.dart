import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/widgets/empty_states/routine_log_empty_state.dart';

import '../../controllers/routine_log_controller.dart';
import '../../widgets/routine/preview/routine_log_widget.dart';

class RoutineLogsScreen extends StatelessWidget {
  static const routeName = '/routine_logs_screen';

  final DateTime dateTime;

  const RoutineLogsScreen({super.key, required this.dateTime});

  @override
  Widget build(BuildContext context) {
    final routineLogsForMonth =
        Provider.of<RoutineLogController>(context, listen: true).whereLogsIsSameMonth(dateTime: dateTime);

    final logs = routineLogsForMonth.sorted((a, b) => b.createdAt.compareTo(a.createdAt));

    final month = dateTime.formattedFullMonth();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: sapphireDark80,
        title: Text("$month Resistance Training".toUpperCase(),
            style: GoogleFonts.ubuntu(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
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
                            return RoutineLogWidget(
                                log: log,
                                color: Colors.transparent,
                                trailing: log.createdAt.durationSinceOrDate());
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
