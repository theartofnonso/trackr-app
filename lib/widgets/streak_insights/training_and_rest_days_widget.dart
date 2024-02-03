import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/app_constants.dart';

class TrainingAndRestDaysWidget extends StatelessWidget {
  final int trainingDays;
  final int restDays;

  const TrainingAndRestDaysWidget({super.key, required this.trainingDays, required this.restDays});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
        decoration: BoxDecoration(
          color: tealBlueLight,
          border: Border.all(color: tealBlueLighter, width: 1),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Table(
          border: TableBorder.symmetric(inside: const BorderSide(color: tealBlueLighter, width: 2)),
          columnWidths: const <int, TableColumnWidth>{
            0: FlexColumnWidth(),
            1: FlexColumnWidth(),
          },
          children: [
            TableRow(children: [
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Center(
                  child: SleepTimeColumn(
                      title: 'TRAINING DAYS',
                      subTitle: "$trainingDays",
                      titleColor: Colors.white,
                      subTitleColor: Colors.white70),
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Center(
                  child: SleepTimeColumn(
                      title: 'REST DAYS',
                      subTitle: "$restDays",
                      titleColor: Colors.deepOrangeAccent,
                      subTitleColor: Colors.deepOrangeAccent.withOpacity(0.8)),
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
