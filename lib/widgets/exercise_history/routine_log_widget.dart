import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/providers/routine_log_provider.dart';
import 'package:tracker_app/widgets/exercise_history/procedure_widget.dart';

import '../../dtos/exercise_log_dto.dart';

class RoutineLogWidget extends StatelessWidget {
  final ExerciseLogDto exerciseLog;

  const RoutineLogWidget({
    super.key,
    required this.exerciseLog,
  });

  @override
  Widget build(BuildContext context) {
    final routineLogProvider = Provider.of<RoutineLogProvider>(context, listen: false);
    final routineLog = routineLogProvider.whereRoutineLog(id: exerciseLog.routineLogId)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Theme(
          data: ThemeData(splashColor: tealBlueLight),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(routineLog.name, style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white)),
            subtitle: Row(children: [
              const Icon(
                Icons.date_range_rounded,
                color: Colors.white,
                size: 12,
              ),
              const SizedBox(width: 1),
              Text(exerciseLog.createdAt.getDateTimeInUtc().formattedDayAndMonthAndYear(),
                  style: GoogleFonts.lato(
                      color: Colors.white.withOpacity(0.95), fontWeight: FontWeight.w500, fontSize: 12)),
            ]),
          ),
        ),
        ProcedureWidget(exerciseLog: exerciseLog)
      ],
    );
  }
}
