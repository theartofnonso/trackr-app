import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/utils/datetime_utils.dart';

import '../../../app_constants.dart';
import '../../../dtos/procedure_dto.dart';
import '../../../models/RoutineLog.dart';
import '../../../providers/exercises_provider.dart';
import '../../../providers/routine_log_provider.dart';
import '../../../screens/routine_editor_screen.dart';
import '../../../screens/routine_log_preview_screen.dart';

class RoutineLogWidget extends StatelessWidget {
  final RoutineLog log;

  const RoutineLogWidget({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(splashColor: tealBlueLight),
      child: ListTile(
        tileColor: tealBlueLight,
          onTap: () => _navigateToRoutineLogPreview(context: context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
          title: Text(log.name, style: Theme.of(context).textTheme.labelLarge),
          subtitle: Row(children: [
            const Icon(
              Icons.date_range_rounded,
              color: Colors.white,
              size: 12,
            ),
            const SizedBox(width: 1),
            Text(log.createdAt.getDateTimeInUtc().durationSinceOrDate(),
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500, fontSize: 12)),
            const SizedBox(width: 10),
            const Icon(
              Icons.timer,
              color: Colors.white,
              size: 12,
            ),
            const SizedBox(width: 1),
            Text(_logDuration(),
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500, fontSize: 12)),
          ]),
          trailing: MenuAnchor(
            style: MenuStyle(
              backgroundColor: MaterialStateProperty.all(tealBlueLighter),
            ),
            builder: (BuildContext context, MenuController controller, Widget? child) {
              return IconButton(
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                icon: const Icon(
                  Icons.more_horiz_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                tooltip: 'Show menu',
              );
            },
            menuChildren: _menuActionButtons(context: context),
          )),
    );
  }

  /// [MenuItemButton]
  List<Widget> _menuActionButtons({required BuildContext context}) {
    return [
      MenuItemButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => RoutineEditorScreen(routineLog: log, type: RoutineEditingType.log)));
        },
        leadingIcon: const Icon(Icons.edit),
        child: const Text("Edit"),
      ),
      MenuItemButton(
        onPressed: () {
          Provider.of<RoutineLogProvider>(context, listen: false).removeLog(id: log.id);
        },
        leadingIcon: const Icon(Icons.delete_sweep, color: Colors.red),
        child: const Text("Delete", style: TextStyle(color: Colors.red)),
      )
    ];
  }

  void _navigateToRoutineLogPreview({required BuildContext context}) async {
    final routine = await Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => RoutineLogPreviewScreen(routineLogId: log.id)))
        as Map<String, String>?;
    if (routine != null) {
      final id = routine["id"] ?? "";
      if (id.isNotEmpty) {
        if (context.mounted) {
          Provider.of<RoutineLogProvider>(context, listen: false).removeLog(id: id);
        }
      }
    }
  }

  String _logDuration() {
    String interval = "";
    final startTime = log.startTime.getDateTimeInUtc();
    final endTime = log.endTime.getDateTimeInUtc();
    final difference = endTime.difference(startTime);
    interval = difference.secondsOrMinutesOrHours();
    return interval;
  }
}
