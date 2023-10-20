import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/routine_log_dto.dart';

import '../../app_constants.dart';
import '../../providers/routine_log_provider.dart';
import '../../screens/routine_editor_screen.dart';

class MinimisedRoutineControllerWidget extends StatelessWidget {
  final RoutineLogDto logDto;

  const MinimisedRoutineControllerWidget({super.key, required this.logDto});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: tealBlueLighter,
        borderRadius: BorderRadius.circular(2), // Adjust the radius as needed
      ),
      child: Row(
        children: [
          Text(logDto.name, style: Theme.of(context).textTheme.labelMedium),
          const Spacer(),
          GestureDetector(
              onTap: () {
                Provider.of<RoutineLogProvider>(context, listen: false).cacheLogDto = null;
              },
              child: Icon(CupertinoIcons.stop_fill, color: Colors.white.withOpacity(0.8))),
          const SizedBox(width: 30),
          GestureDetector(
              onTap: () => {
                Navigator.of(context).push(CupertinoPageRoute(builder: (context) => RoutineEditorScreen(routineDto: logDto, mode: RoutineEditorMode.routine)))
              },
              child: const Icon(CupertinoIcons.play_arrow_solid, color: CupertinoColors.white))
        ],
      ),
    );
  }
}
