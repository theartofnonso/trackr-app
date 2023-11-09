import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../dtos/procedure_dto.dart';
import '../../dtos/set_dto.dart';
import '../empty_states/list_tile_empty_state.dart';
import '../routine/preview/set_widget.dart';

ProcedureDto? whereOtherSuperSetProcedure(
    {required ProcedureDto firstProcedure, required List<ProcedureDto> procedures}) {
  return procedures.firstWhereOrNull((procedure) =>
      procedure.superSetId.isNotEmpty &&
      procedure.superSetId == firstProcedure.superSetId &&
      procedure.exercise.id != firstProcedure.exercise.id);
}

List<Widget> setsToWidgets({required List<SetDto> sets}) {
  int workingSets = 0;

  final widgets = sets.mapIndexed(((index, setDto) {
    final widget = Padding(
      padding: const EdgeInsets.only(top: 6.0),
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

  return widgets.isNotEmpty ? widgets : [const ListStyleEmptyState()];
}
