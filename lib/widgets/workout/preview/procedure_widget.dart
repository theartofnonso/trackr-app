import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/dtos/procedure_dto.dart';
import 'package:tracker_app/widgets/workout/preview/set_widget.dart';

import '../../../app_constants.dart';
import '../../../dtos/set_dto.dart';
class ProcedureWidget extends StatelessWidget {

  final ProcedureDto procedureDto;
  final ProcedureDto? otherSuperSetProcedureDto;

  const ProcedureWidget({
    super.key,
    required this.procedureDto,
    required this.otherSuperSetProcedureDto,
  });

  List<Widget>? _displaySets() {
    int workingSets = 0;

    return procedureDto.sets.mapIndexed(((index, setDto) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tealBlueLight, // Set the background color
        borderRadius: BorderRadius.circular(20), // Set the border radius to make it rounded
      ),
      child: Column(
        children: [
          CupertinoListTile(
            backgroundColorActivated: Colors.transparent,
            padding: EdgeInsets.zero,
            title: Text(procedureDto.exercise.name,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: procedureDto.isSuperSet
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text("Super set: ${otherSuperSetProcedureDto?.exercise.name}",
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                  )
                : const SizedBox.shrink(),
          ),
          procedureDto.notes.isNotEmpty
              ? Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(procedureDto.notes,
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: CupertinoColors.white.withOpacity(0.8), fontSize: 15)),
          )
              : const SizedBox.shrink(),
          Column(
            children: [...?_displaySets()],
          )
        ],
      ),
    );
  }
}
