import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/providers/routine_log_provider.dart';

import '../../app_constants.dart';
import '../../models/RoutineLog.dart';
import '../../screens/routine_editor_screen.dart';
import '../buttons/text_button_widget.dart';
import '../helper_widgets/dialog_helper.dart';

class MinimisedRoutineBanner extends StatelessWidget {
  final RoutineLog log;
  const MinimisedRoutineBanner({super.key, required this.log});

  @override
  Widget build(BuildContext context) {

    final alertDialogActions = <Widget>[
      TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text('Cancel', style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      CTextButton(
          onPressed: () {
            Navigator.pop(context);
            Provider.of<RoutineLogProvider>(context, listen: false).clearCachedLog();
          },
          label: 'Discard'),
    ];

    return MaterialBanner(
      padding: const EdgeInsets.only(left: 12, top: 12),
      margin: const EdgeInsets.symmetric(vertical: 12),
      dividerColor: Colors.transparent,
      content: Text(
          '${log.name.isNotEmpty ? log.name : "Workout"} is running'),
      leading: const Icon(
        Icons.info_outline,
        color: Colors.white,
      ),
      backgroundColor: tealBlueLight,
      actions: <Widget>[
        TextButton(
          onPressed: () {
            showAlertDialog(context: context, message: "Discard workout?", actions: alertDialogActions);
          },
          child: Text('Discard', style: GoogleFonts.lato(color: Colors.white)),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => RoutineEditorScreen(
                    routineLog: log,
                    routine: log.routine,
                    mode: RoutineEditorType.log)));
          },
          child: Text('Continue', style: GoogleFonts.lato(color: Colors.white)),
        ),
      ],
    );
  }
}
