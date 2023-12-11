import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/providers/routine_log_provider.dart';

import '../../../app_constants.dart';
import '../helper_widgets/dialog_helper.dart';

class PendingRoutinesBanner extends StatelessWidget {

  const PendingRoutinesBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final routineLogProvider = Provider.of<RoutineLogProvider>(context, listen: false);

    return MaterialBanner(
      padding: const EdgeInsets.only(left: 12, top: 12, bottom: 12),
      margin: const EdgeInsets.symmetric(vertical: 12),
      dividerColor: Colors.transparent,
      content: Text('${routineLogProvider.cachedPendingLogs.length} workout(s) pending upload', style: GoogleFonts.lato(fontSize: 15)),
      leading: const Icon(
        Icons.info_outline,
        color: Colors.white,
      ),
      backgroundColor: tealBlueLight,
      actions: <Widget>[
        TextButton(
          onPressed: () {
            showAlertDialogWithMultiActions(
                context: context,
                message: "Discard workout(s)?",
                leftAction: Navigator.of(context).pop,
                rightAction: () {
                  Navigator.of(context).pop();
                  routineLogProvider.clearCachedPendingLogs();
                },
                leftActionLabel: 'Cancel',
                rightActionLabel: 'Discard', isRightActionDestructive: true);
          },
          child: Text('Discard', style: GoogleFonts.lato(color: Colors.red)),
        ),
        TextButton(
          onPressed: routineLogProvider.retryPendingRoutineLogs,
          child: Text('Retry', style: GoogleFonts.lato(color: Colors.white)),
        ),
      ],
    );
  }
}
