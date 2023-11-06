import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/providers/routine_log_provider.dart';

import '../../app_constants.dart';
import '../../models/RoutineLog.dart';

class PendingRoutinesBanner extends StatelessWidget {
  final List<RoutineLog> logs;
  const PendingRoutinesBanner({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RoutineLogProvider>(context, listen: false);
    return MaterialBanner(
      padding: const EdgeInsets.only(left: 12, top: 12),
      margin: const EdgeInsets.symmetric(vertical: 12),
      dividerColor: Colors.transparent,
      content: Text('${logs.length} workouts are pending upload'),
      leading: const Icon(
        Icons.info_outline,
        color: Colors.white,
      ),
      backgroundColor: tealBlueLight,
      actions: <Widget>[
        TextButton(
          onPressed: () {
            provider.clearCachedPendingLogs();
          },
          child: Text('Discard workouts', style: GoogleFonts.lato(color: Colors.white)),
        ),
        TextButton(
          onPressed: () {
            provider.retrySavingRoutineLogs();
          },
          child: Text('Retry upload', style: GoogleFonts.lato(color: Colors.white)),
        ),
      ],
    );
  }
}
