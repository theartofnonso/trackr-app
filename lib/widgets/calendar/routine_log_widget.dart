import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/utils/datetime_utils.dart';

import '../../../app_constants.dart';
import '../../../models/RoutineLog.dart';
import '../../../providers/routine_log_provider.dart';
import '../../screens/logs/routine_log_preview_screen.dart';
import '../../utils/snackbar_utils.dart';

class RoutineLogWidget extends StatelessWidget {
  final RoutineLog log;

  const RoutineLogWidget({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(splashColor: tealBlueLight),
      child: ListTile(
        tileColor: tealBlueLight,
          onTap: () => _navigateToRoutineLogPreview(context: context),
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

  void _navigateToRoutineLogPreview({required BuildContext context}) async {
    final routine = await Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => RoutineLogPreviewScreen(routineLogId: log.id)))
        as Map<String, String>?;
    if (routine != null) {
      final id = routine["id"] ?? "";
      if (id.isNotEmpty) {
        if (context.mounted) {
          try {
            Provider.of<RoutineLogProvider>(context, listen: false).removeLogFromCloud(id: id);
          } catch (_) {
            showSnackbar(context: context, icon: const Icon(Icons.info_outline), message: "Unable to save changes");
          }
        }
      }
    }
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
