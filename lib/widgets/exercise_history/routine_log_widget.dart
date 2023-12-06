import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/widgets/exercise_history/procedure_widget.dart';

import '../../dtos/exercise_log_dto.dart';
import '../../models/RoutineLog.dart';

class RoutineLogWidget extends StatelessWidget {
  final RoutineLog routineLog;

  const RoutineLogWidget({super.key, required this.routineLog,});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Theme(
          data: ThemeData(
            splashColor: tealBlueLight
          ),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(routineLog.name, style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white)), subtitle: Row(children: [
            const Icon(
              Icons.date_range_rounded,
              color: Colors.white,
              size: 12,
            ),
            const SizedBox(width: 1),
            Text(routineLog.createdAt.getDateTimeInUtc().formattedDayAndMonthAndYear(),
                style: GoogleFonts.lato(color: Colors.white.withOpacity(0.95), fontWeight: FontWeight.w500, fontSize: 12)),
          ]),),
        ),
        ...routineLog.procedures.map((procedure) => ProcedureWidget(procedureDto: ExerciseLogDto.fromJson(jsonDecode(procedure)))).toList()
      ],
    );
  }
}
