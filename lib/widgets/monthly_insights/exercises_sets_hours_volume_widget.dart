import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/app_constants.dart';

class ExercisesSetsHoursVolumeWidget extends StatelessWidget {
  final int numberOfExercises;
  final int numberOfSets;
  final Duration totalHours;
  final String totalVolume;

  const ExercisesSetsHoursVolumeWidget({super.key, required this.numberOfExercises, required this.numberOfSets, required this.totalHours, required this.totalVolume});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 30),
        decoration: BoxDecoration(
          color: tealBlueDark,
          border: Border.all(color: tealBlueLighter, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Table(
          border: TableBorder.symmetric(inside: const BorderSide(color: tealBlueLighter, width: 2)),
          columnWidths: const <int, TableColumnWidth>{
            0: FlexColumnWidth(),
            1: FlexColumnWidth(),
            2: FlexColumnWidth(),
            3: FlexColumnWidth(),
          },
          children: [
            TableRow(children: [
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Center(
                  child: SleepTimeColumn(
                      title: 'EXERCISES',
                      subTitle: "$numberOfExercises",
                      titleColor: Colors.white,
                      subTitleColor: Colors.white70),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Center(
                  child: SleepTimeColumn(
                      title: 'SETS',
                      subTitle: "$numberOfSets",
                      titleColor: Colors.white,
                      subTitleColor: Colors.white70),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Center(
                  child: SleepTimeColumn(
                      title: 'HOURS',
                      subTitle: "${totalHours.inHours}",
                      titleColor: Colors.white,
                      subTitleColor: Colors.white70),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Center(
                  child: SleepTimeColumn(
                      title: 'VOLUME',
                      subTitle: "$totalVolume",
                      titleColor: Colors.white,
                      subTitleColor: Colors.white70),
                ),
              )
            ]),
          ],
        ));
  }
}

class SleepTimeColumn extends StatelessWidget {
  final String title;
  final String subTitle;
  final Color titleColor;
  final Color subTitleColor;

  const SleepTimeColumn({
    super.key,
    required this.title,
    required this.subTitle,
    required this.titleColor,
    required this.subTitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          subTitle,
          style: GoogleFonts.montserrat(
            color: titleColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            color: subTitleColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }
}
