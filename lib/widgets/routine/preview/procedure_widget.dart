import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/procedure_dto.dart';
import 'package:tracker_app/utils/datetime_utils.dart';
import 'package:tracker_app/widgets/routine/preview/set_widget.dart';

import '../../../dtos/set_dto.dart';

class ProcedureWidget extends StatelessWidget {
  final ProcedureDto procedureDto;
  final ProcedureDto? otherSuperSetProcedureDto;

  const ProcedureWidget({
    super.key,
    required this.procedureDto,
    required this.otherSuperSetProcedureDto,
  });

  List<Widget> _displaySets() {
    int workingSets = 0;

    return procedureDto.sets.mapIndexed(((index, setDto) {
      final widget = Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: SetWidget(
          index: index,
          workingIndex: setDto.type == SetType.working ? workingSets : -1,
          setDto: setDto,
        ),
      );

      if (setDto.type == SetType.working) {
        workingSets += 1;
      }

      return widget;
    })).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CupertinoListTile(
            title: Text(procedureDto.exercise.name, style: Theme.of(context).textTheme.labelLarge),
            subtitle: Row(children: [
              const Icon(
                CupertinoIcons.timer,
                color: CupertinoColors.white,
                size: 12,
              ),
              const SizedBox(width: 10),
              Text("${procedureDto.restInterval.secondsOrMinutesOrHours()} rest interval",
                  style: TextStyle(color: CupertinoColors.white.withOpacity(0.8), fontWeight: FontWeight.w500)),
            ]),
          trailing: otherSuperSetProcedureDto != null ? Text("with ${otherSuperSetProcedureDto?.exercise.name}",
              style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)) : const SizedBox.shrink(),
        ),
        procedureDto.notes.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(procedureDto.notes,
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: CupertinoColors.white.withOpacity(0.8), fontSize: 15)),
              )
            : const SizedBox.shrink(),
        ..._displaySets(),
      ],
    );
  }
}