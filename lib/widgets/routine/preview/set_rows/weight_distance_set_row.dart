import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/dtos/set_dto.dart';

import '../../../../app_constants.dart';
import '../../../../enums/exercise_type_enums.dart';
import '../../../../utils/general_utils.dart';

class WeightDistanceSetRow extends StatelessWidget {
  const WeightDistanceSetRow({super.key, required this.setDto});

  final SetDto setDto;

  @override
  Widget build(BuildContext context) {
    final weight = isDefaultWeightUnit() ? setDto.value1 : toLbs(setDto.value1.toDouble());
    final distance =
        isDefaultDistanceUnit() ? setDto.value2 : toKM(setDto.value2.toDouble(), type: ExerciseType.weightAndDistance);

    return Container(
      decoration: BoxDecoration(
        color: tealBlueLight, // Container color
        borderRadius: BorderRadius.circular(3.0), // Radius for rounded corners
      ),
      child: Table(
          border: TableBorder.all(color: tealBlueDark, borderRadius: BorderRadius.circular(3)),
          columnWidths: const <int, TableColumnWidth>{
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(1),
          },
          children: <TableRow>[
            TableRow(children: [
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Text(
                  "$weight",
                  style: GoogleFonts.lato(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Text(
                    "$distance",
                    style: GoogleFonts.lato(color: Colors.white),
                    textAlign: TextAlign.center,
                  ))
            ]),
          ]),
    );
  }
}
