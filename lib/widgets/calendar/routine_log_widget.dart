import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/utils/datetime_utils.dart';

import '../../../app_constants.dart';
import '../../../models/RoutineLog.dart';
import '../routine_log/routine_log_widget.dart';

class RoutineLogWidget extends StatelessWidget {
  final RoutineLog log;

  const RoutineLogWidget({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(splashColor: tealBlueLight),
      child: ListTile(
        tileColor: tealBlueLight,
          onTap: () => navigateToRoutineLogPreview(context: context, logId: log.id),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
          title: Text(log.name, style: Theme.of(context).textTheme.labelLarge),
          subtitle: Row(children: [
            const Icon(
              Icons.date_range_rounded,
              color: Colors.white,
              size: 12,
            ),
            const SizedBox(width: 1),
            Text(log.createdAt.getDateTimeInUtc().durationSinceOrDate(),
                style: GoogleFonts.lato(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500, fontSize: 12)),
            const SizedBox(width: 10),
            const Icon(
              Icons.timer,
              color: Colors.white,
              size: 12,
            ),
            const SizedBox(width: 1),
            Text(_logDuration(),
                style: GoogleFonts.lato(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500, fontSize: 12)),
          ])),
    );
  }

  String _logDuration() {
    String interval = "";
    final startTime = log.startTime.getDateTimeInUtc();
    final endTime = log.endTime.getDateTimeInUtc();
    final difference = endTime.difference(startTime);
    interval = difference.secondsOrMinutesOrHours();
    return interval;
  }
}
