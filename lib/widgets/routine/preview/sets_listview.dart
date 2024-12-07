import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/dtos/set_dtos/duration_set_dto.dart';
import 'package:tracker_app/dtos/set_dtos/reps_dto.dart';
import 'package:tracker_app/dtos/set_dtos/weight_and_reps_dto.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/widgets/routine/preview/set_rows/double_set_row.dart';
import 'package:tracker_app/widgets/routine/preview/set_rows/single_set_row.dart';

import '../../../dtos/pb_dto.dart';
import '../../../dtos/set_dtos/set_dto.dart';
import '../../../enums/exercise_type_enums.dart';

class SetsListview extends StatelessWidget {
  final ExerciseType type;
  final List<SetDto> sets;
  final List<PBDto> pbs;

  const SetsListview({super.key, required this.type, required this.sets, this.pbs = const []});

  @override
  Widget build(BuildContext context) {
    const margin = EdgeInsets.only(bottom: 6.0);

    final pbsBySet = groupBy(pbs, (pb) => pb.set);

    final widgets = sets.map(((setDto) {
      final pbsForSet = pbsBySet[setDto] ?? [];

      switch (type) {
        case ExerciseType.weights:
          final firstLabel = (setDto as WeightAndRepsSetDto).weight;
          final secondLabel = setDto.reps;
          return DoubleSetRow(first: "$firstLabel", second: "$secondLabel", margin: margin, pbs: pbsForSet);
        case ExerciseType.bodyWeight:
          final label = (setDto as RepsSetDto).reps;
          return SingleSetRow(label: "$label", margin: margin);
        case ExerciseType.duration:
          final label = (setDto as DurationSetDto).duration.hmsAnalog();
          return SingleSetRow(label: label, margin: margin, pbs: pbsForSet);
      }
    })).toList();

    return sets.isNotEmpty
        ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: widgets)
        : Center(
            child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5), // Circular border radius
              border: Border.all(
                color: Colors.deepOrange.withOpacity(0.2), // Border color
                width: 2, // Border width
              ),
            ),
            child: Text("No Sets have been logged for this exercise",
                textAlign: TextAlign.center,
                style: GoogleFonts.ubuntu(
                    fontSize: 12, height: 1.4, color: Colors.deepOrange, fontWeight: FontWeight.w600)),
          ));
  }
}
