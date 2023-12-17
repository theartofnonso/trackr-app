import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';

import '../../../app_constants.dart';
import '../../../models/RoutineLog.dart';
import '../../utils/navigation_utils.dart';

class RoutineLogsScreen extends StatelessWidget {
  final List<RoutineLog> logs;

  const RoutineLogsScreen({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_outlined), onPressed: Navigator.of(context).pop),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 150),
                    itemBuilder: (BuildContext context, int index) => _RoutineLogWidget(log: logs[index]),
                    separatorBuilder: (BuildContext context, int index) =>
                        Divider(color: Colors.white70.withOpacity(0.1)),
                    itemCount: logs.length),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _RoutineLogWidget extends StatelessWidget {
  final RoutineLog log;

  const _RoutineLogWidget({required this.log});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(splashColor: tealBlueLight),
      child: ListTile(
        onTap: () => navigateToRoutineLogPreview(context: context, logId: log.id),
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        title: Text(log.name, style: GoogleFonts.lato(color: Colors.white, fontSize: 14)),
        subtitle: Text("${log.procedures.length} exercise(s)",
            style: GoogleFonts.lato(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500, fontSize: 14)),
        trailing: Text(log.createdAt.getDateTimeInUtc().durationSinceOrDate(),
            style: GoogleFonts.lato(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500, fontSize: 14)),
      ),
    );
  }
}
