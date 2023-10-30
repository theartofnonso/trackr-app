import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/providers/routine_log_provider.dart';

import '../../app_constants.dart';
import '../../models/RoutineLog.dart';
import '../../screens/routine_editor_screen.dart';

class MinimisedRoutineBanner extends StatelessWidget {
  final RoutineLog log;
  const MinimisedRoutineBanner({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
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
      backgroundColor: tealBlueLight.withOpacity(0.4),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Provider.of<RoutineLogProvider>(context, listen: false).clearCachedLog();
          },
          child: const Text('Cancel', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => RoutineEditorScreen(
                    routineLog: log,
                    routine: log.routine,
                    mode: RoutineEditorMode.routine,
                    type: RoutineEditingType.log)));
          },
          child: const Text('Continue', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
