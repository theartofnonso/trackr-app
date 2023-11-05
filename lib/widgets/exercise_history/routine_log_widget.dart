import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/utils/datetime_utils.dart';
import 'package:tracker_app/widgets/exercise_history/procedure_widget.dart';

import '../../dtos/procedure_dto.dart';
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
            title: Text(routineLog.name, style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white)), subtitle: Row(children: [
            const Icon(
              Icons.date_range_rounded,
              color: Colors.white,
              size: 12,
            ),
            const SizedBox(width: 1),
            Text(routineLog.createdAt.getDateTimeInUtc().formattedDayAndMonthAndYear(),
                style: TextStyle(color: Colors.white.withOpacity(0.95), fontWeight: FontWeight.w500, fontSize: 12)),
          ]),),
        ),
        ...routineLog.procedures.map((procedure) => ProcedureWidget(procedureDto: ProcedureDto.fromJson(jsonDecode(procedure)))).toList()
      ],
    );
  }
}
