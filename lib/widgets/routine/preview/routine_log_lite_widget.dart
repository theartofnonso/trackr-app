import 'package:flutter/material.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/dtos/routine_log_dto.dart';
import 'package:tracker_app/utils/datetime_utils.dart';
import 'package:tracker_app/widgets/routine/preview/procedure_lite_widget.dart';

class RoutineLogLiteWidget extends StatelessWidget {
  final RoutineLogDto routineLogDto;

  const RoutineLogLiteWidget({
    super.key,
    required this.routineLogDto,
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
            title: Text(routineLogDto.name, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Row(children: [
            const Icon(
              Icons.date_range_rounded,
              color: Colors.white,
              size: 12,
            ),
            const SizedBox(width: 1),
            Text(routineLogDto.createdAt.formattedDayAndMonthAndYear(),
                style: TextStyle(color: Colors.white.withOpacity(0.95), fontWeight: FontWeight.w500, fontSize: 12)),
          ]),),
        ),
        ...routineLogDto.procedures.map((procedure) => ProcedureLiteWidget(procedureDto: procedure)).toList()
      ],
    );
  }
}
