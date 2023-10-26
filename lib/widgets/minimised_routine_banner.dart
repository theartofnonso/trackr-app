import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/routine_log_dto.dart';

import '../app_constants.dart';
import '../providers/routine_log_provider.dart';
import '../screens/routine_editor_screen.dart';

class MinimisedRoutineBanner extends StatelessWidget {
  final RoutineLogProvider provider;
  final RoutineLogDto logDto;
  const MinimisedRoutineBanner({super.key, required this.provider, required this.logDto});

  @override
  Widget build(BuildContext context) {
    return MaterialBanner(
      padding: const EdgeInsets.only(left: 12, top: 12),
      margin: const EdgeInsets.all(12),
      dividerColor: Colors.transparent,
      content: Text(
          '${logDto.name.isNotEmpty ? logDto.name : "Workout"} is running'),
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
          child: const Text('Cancel', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
            Navigator.of(context).push(CupertinoPageRoute(
                builder: (context) => RoutineEditorScreen(
                    routineDto: logDto,
                    mode: RoutineEditorMode.routine,
                    type: RoutineEditingType.log)));
          },
          child: const Text('Continue', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
