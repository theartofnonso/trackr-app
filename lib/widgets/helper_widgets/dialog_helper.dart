import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_constants.dart';
import '../../providers/routine_log_provider.dart';
import '../../screens/routine_editor_screen.dart';

void showModalPopup({required BuildContext context, required Widget child}) {
  showCupertinoModalPopup<void>(
    context: context,
    builder: (BuildContext context) => Container(
      height: 216,
      padding: const EdgeInsets.only(top: 6.0),
      // The bottom margin is provided to align the popup above the system
      // navigation bar.
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      // Provide a background color for the popup.
      color: tealBlueLight,
      // Use a SafeArea widget to avoid system overlaps.
      child: SafeArea(
        top: false,
        child: child,
      ),
    ),
  );
}

void showMinimisedRoutineBanner(BuildContext context) {
  final provider = Provider.of<RoutineLogProvider>(context, listen: false);
  final cachedRoutineLog = provider.cachedLogDto;

  if (cachedRoutineLog != null) {
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        padding: const EdgeInsets.only(left: 12, top: 12),
        margin: const EdgeInsets.all(12),
        content: Text('${cachedRoutineLog.name.isNotEmpty ? cachedRoutineLog.name : "Workout"} is running'),
        leading: const Icon(
          Icons.info_outline,
          color: Colors.white,
        ),
        backgroundColor: tealBlueLight.withOpacity(0.4),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              provider.clearCachedLog();
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            },
            child: const Text('End', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () async {
              ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
              await Navigator.of(context).push(CupertinoPageRoute(builder: (context) => RoutineEditorScreen(routineDto: cachedRoutineLog, mode: RoutineEditorMode.routine, type: RoutineEditingType.log)));
              if(context.mounted) {
                showMinimisedRoutineBanner(context);
              }
            },
            child: const Text('Continue', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
