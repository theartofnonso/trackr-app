import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/procedure_dto.dart';
import 'package:tracker_app/utils/datetime_utils.dart';

import '../helper_widgets/routine_helper.dart';

class ProcedureWidget extends StatelessWidget {
  final ProcedureDto procedureDto;

  const ProcedureWidget({
    super.key,
    required this.procedureDto,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Icon(
            Icons.timer,
            color: Colors.white,
            size: 12,
          ),
          const SizedBox(width: 10),
          Text("${procedureDto.restInterval.secondsOrMinutesOrHours()} rest interval",
              style: TextStyle(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500)),
        ]),
        const SizedBox(height: 4),
        procedureDto.notes.isNotEmpty
            ? Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(procedureDto.notes,
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.8), fontSize: 15)),
        )
            : const SizedBox.shrink(),
        ...setsToWidgets(sets: procedureDto.sets),
      ],
    );
  }
}
