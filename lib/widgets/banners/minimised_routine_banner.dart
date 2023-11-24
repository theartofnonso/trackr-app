import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app_constants.dart';
import '../../models/RoutineLog.dart';
import '../../screens/editors/routine_editor_screen.dart';

class MinimisedRoutineBanner extends StatelessWidget {
  final RoutineLog log;

  const MinimisedRoutineBanner({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(splashColor: tealBlueLight),
      child: ListTile(
          tileColor: tealBlueLight,
          dense: true,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    RoutineEditorScreen(routineLog: log, routine: log.routine, mode: RoutineEditorMode.log)));
          },
          leading: const Icon(
            Icons.info_outline,
            color: Colors.white,
          ),
          minLeadingWidth: 0,
          title: Text('${log.name.isNotEmpty ? log.name : "Workout"} is running', style: GoogleFonts.lato(color: Colors.white),)),
    );
  }
}
