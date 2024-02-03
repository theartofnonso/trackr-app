import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/extensions/duration_extension.dart';

class LogDurationWidget extends StatelessWidget {
  final Iterable<int> logHours;

  const LogDurationWidget({super.key, required this.logHours});

  @override
  Widget build(BuildContext context) {
    final minHours = Duration(milliseconds: logHours.min);
    final maxHours = Duration(milliseconds: logHours.max);
    final avgHours = Duration(milliseconds: logHours.average.toInt());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("How many hours did you train?".toUpperCase(),
            style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            decoration: BoxDecoration(
              color: sapphireLight,
              border: Border.all(color: sapphireLighter, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Table(
              border: TableBorder.symmetric(inside: const BorderSide(color: sapphireLighter, width: 2)),
              columnWidths: const <int, TableColumnWidth>{
                0: FlexColumnWidth(),
                1: FlexColumnWidth(),
                2: FlexColumnWidth(),
              },
              children: [
                TableRow(children: [
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Center(
                      child: SleepTimeColumn(
                          title: 'LEAST TIME',
                          subTitle: minHours.hmDigital(),
                          titleColor: Colors.white,
                          subTitleColor: Colors.white70),
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Center(
                      child: SleepTimeColumn(
                          title: 'AVG TIME',
                          subTitle: avgHours.hmDigital(),
                          titleColor: sapphireBlue,
                          subTitleColor: sapphireBlue.withOpacity(0.8)),
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Center(
                      child: SleepTimeColumn(
                          title: 'MOST TIME',
                          subTitle: maxHours.hmDigital(),
                          titleColor: Colors.white,
                          subTitleColor: Colors.white70),
                    ),
                  )
                ]),
              ],
            )),
      ],
    );
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
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            color: subTitleColor,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }
}
