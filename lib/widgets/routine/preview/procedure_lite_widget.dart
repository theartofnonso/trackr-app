import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/procedure_dto.dart';
import 'package:tracker_app/utils/datetime_utils.dart';
import 'package:tracker_app/widgets/empty_states/list_tile_empty_state.dart';
import 'package:tracker_app/widgets/routine/preview/set_widget.dart';

import '../../../dtos/set_dto.dart';

class ProcedureLiteWidget extends StatelessWidget {
  final ProcedureDto procedureDto;

  const ProcedureLiteWidget({
    super.key,
    required this.procedureDto,
  });

  List<Widget> _displaySets() {
    int workingSets = 0;

    final sets = procedureDto.sets.mapIndexed(((index, setDto) {
      final widget = SetWidget(
        index: index,
        workingIndex: setDto.type == SetType.working ? workingSets : -1,
        setDto: setDto,
      );

      if (setDto.type == SetType.working) {
        workingSets += 1;
      }

      return widget;
    })).toList();

    return sets.isNotEmpty
        ? sets
        : [
            const Padding(
              padding: EdgeInsets.only(left: 18.0, top: 10),
              child: ListStyleEmptyState(),
            )
          ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          //contentPadding: EdgeInsets.zero,
          title: Text(procedureDto.exercise.name, style: Theme.of(context).textTheme.labelLarge),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(
                  CupertinoIcons.timer,
                  color: Colors.white,
                  size: 12,
                ),
                const SizedBox(width: 10),
                Text("${procedureDto.restInterval.secondsOrMinutesOrHours()} rest interval",
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500)),
              ]),
            ],
          ),
        ),
        procedureDto.notes.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(procedureDto.notes,
                    style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.8), fontSize: 15)),
              )
            : const SizedBox.shrink(),
        ..._displaySets(),
      ],
    );
  }
}
