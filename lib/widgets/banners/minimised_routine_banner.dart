import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/shared_prefs.dart';

import '../../app_constants.dart';
import '../../models/Routine.dart';
import '../../models/RoutineLog.dart';
import '../../screens/editors/routine_editor_screen.dart';
import '../../utils/general_utils.dart';
import '../../utils/navigation_utils.dart';

class MinimisedRoutineBanner extends StatefulWidget {
  final bool visible;
  const MinimisedRoutineBanner({super.key, required this.visible});

  @override
  State<MinimisedRoutineBanner> createState() => _MinimisedRoutineBannerState();
}

class _MinimisedRoutineBannerState extends State<MinimisedRoutineBanner> {

  bool _hideBanner = false;

  @override
  Widget build(BuildContext context) {
    RoutineLog? log = retrieveCachedRoutineLog();

    Widget banner = const SizedBox.shrink();

    if(widget.visible && !_hideBanner) {
      banner = Theme(
        data: ThemeData(splashColor: tealBlueLight),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: ListTile(
              tileColor: tealBlueLight,
              dense: true,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
              onTap: () {
                _navigateToRoutineEditor(context: context, routine: log?.routine);
              },
              leading: const Icon(
                Icons.info_outline,
                color: Colors.white,
              ),
              minLeadingWidth: 0,
              title: Text(
                '${log?.routine?.name ?? "Workout"} is in progress',
                style: GoogleFonts.lato(color: Colors.white),
              )),
        ),
      );
    }

    return banner;

  }

  void _navigateToRoutineEditor({required BuildContext context, Routine? routine}) async {
    final result = await navigateToRoutineEditor(context: context, routine: routine, mode: RoutineEditorMode.log);
    if (result != null) {
      final mode = result["mode"] ?? RoutineEditorMode.edit;
      final shouldClearCache = result["clearCache"] ?? false;
      if (mode == RoutineEditorMode.log) {
        if (shouldClearCache) {
          SharedPrefs().cachedRoutineLog = "";
          setState(() {
            _hideBanner = true;
          });
        }
      }
    }
  }

}
