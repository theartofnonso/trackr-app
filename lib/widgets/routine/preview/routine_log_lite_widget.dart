import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/utils/datetime_utils.dart';
import 'package:tracker_app/widgets/routine/preview/procedure_lite_widget.dart';

import '../../../dtos/procedure_dto.dart';
import '../../../models/RoutineLog.dart';

class RoutineLogLiteWidget extends StatelessWidget {
  final RoutineLog routineLog;

  const RoutineLogLiteWidget({
    super.key,
    required this.routineLog,
  });

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
            title: Text(routineLog.name, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Row(children: [
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
        ...routineLog.procedures.map((procedure) => ProcedureLiteWidget(procedureDto: ProcedureDto.fromJson(jsonDecode(procedure)))).toList()
      ],
    );
  }
}
