import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/routine_log_dto.dart';

import '../../providers/routine_log_provider.dart';
import '../../screens/routine_editor_screen.dart';
import '../../shared_prefs.dart';

class MinimisedRoutineControllerWidget extends StatelessWidget {
  final RoutineLogDto logDto;

  const MinimisedRoutineControllerWidget({super.key, required this.logDto});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: 280,
      margin: const EdgeInsets.only(left: 12, bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5), // Adjust the radius as needed
      ),
      child: Row(
        children: [
          SizedBox(width: 150, child: Text(logDto.name, style: Theme.of(context).textTheme.labelMedium?.copyWith(overflow: TextOverflow.ellipsis, fontWeight: FontWeight.bold))),
          const Spacer(),
          GestureDetector(
              onTap: () {
                Provider.of<RoutineLogProvider>(context, listen: false).cachedLogDto = null;
                SharedPrefs().cachedRoutineLog = "";
              },
              child: Icon(CupertinoIcons.stop_fill, color: Colors.white.withOpacity(0.8))),
          const SizedBox(width: 20),
          GestureDetector(
              onTap: () => {
                    Navigator.of(context).push(CupertinoPageRoute(
                        builder: (context) => RoutineEditorScreen(
                            routineDto: logDto, mode: RoutineEditorMode.routine, type: RoutineEditingType.log)))
                  },
              child: const Icon(CupertinoIcons.play_arrow_solid, color: CupertinoColors.white))
        ],
      ),
    );
  }
}