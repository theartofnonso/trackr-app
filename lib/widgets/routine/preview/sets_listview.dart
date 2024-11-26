import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/widgets/routine/preview/set_rows/double_set_row.dart';
import 'package:tracker_app/widgets/routine/preview/set_rows/set_row.dart';
import 'package:tracker_app/widgets/routine/preview/set_rows/single_set_row.dart';

import '../../../dtos/pb_dto.dart';
import '../../../dtos/set_dto.dart';
import '../../../enums/exercise_type_enums.dart';
import '../../../utils/exercise_logs_utils.dart';
import '../../empty_states/double_set_row_empty_state.dart';
import '../../empty_states/single_set_row_empty_state.dart';

class SetsListview extends StatelessWidget {

  const SetsListview({super.key});
  
  List<Widget> setsToWidgets(
      {required ExerciseType type,
        required List<SetDto> sets,
        List<PBDto> pbs = const []}) {
    final durationTemplate = SetRow(
        margin: const EdgeInsets.only(bottom: 6),
        pbs: const [],
        child: Table(columnWidths: const <int, TableColumnWidth>{
          0: FlexColumnWidth(),
        }, children: const <TableRow>[
          TableRow(children: [
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Center(
                child: FaIcon(
                  FontAwesomeIcons.solidClock,
                  color: Colors.white70,
                  size: 16,
                ),
              ),
            ),
          ]),
        ]));

    Widget emptyState;

    if (withWeightsOnly(type: type)) {
      emptyState = const DoubleSetRowEmptyState();
    } else {
      if (withDurationOnly(type: type)) {
        emptyState = durationTemplate;
      } else {
        emptyState = const SingleSetRowEmptyState();
      }
    }

    const margin = EdgeInsets.only(bottom: 6.0);

    final pbsBySet = groupBy(pbs, (pb) => pb.set);

    final widgets = sets.map(((setDto) {
      final pbsForSet = pbsBySet[setDto] ?? [];

      switch (type) {
        case ExerciseType.weights:
          final firstLabel = setDto.weight();
          final secondLabel = setDto.reps();
          return DoubleSetRow(
              first: "$firstLabel",
              second: "$secondLabel",
              margin: margin,
              pbs: pbsForSet);
        case ExerciseType.bodyWeight:
          final label = setDto.reps();
          return SingleSetRow(label: "$label", margin: margin);
        case ExerciseType.duration:
        // if (routinePreviewType == RoutinePreviewType.template) {
        //   return durationTemplate;
        // }
          final label = Duration(milliseconds: setDto.duration()).hmsAnalog();
          return SingleSetRow(label: label, margin: margin, pbs: pbsForSet);
        case ExerciseType.all:
          throw Exception("Unable to create Set widget for type ExerciseType.all");
      }
    })).toList();

    return widgets.isNotEmpty ? widgets : [emptyState];
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
