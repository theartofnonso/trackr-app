import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/strings.dart';
import 'package:tracker_app/utils/general_utils.dart';

import '../../dtos/routine_log_dto.dart';

class TrainingAndRestDaysWidget extends StatelessWidget {
  final DateTimeRange dateTimeRange;
  final List<RoutineLogDto> logs;
  final int daysInMonth;

  const TrainingAndRestDaysWidget(
      {super.key, required this.dateTimeRange, required this.logs, required this.daysInMonth});

  @override
  Widget build(BuildContext context) {
    final numberOfTrainingDays = logs.length;
    final numberOfRestDays = daysInMonth - numberOfTrainingDays;

    final averageRestDays = averageDaysBetween(logs.map((log) => log.createdAt).toList());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Training vs Rest Days".toUpperCase(),
            style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            decoration: BoxDecoration(
              color: sapphireDark80,
              border: Border.all(color: sapphireDark80.withOpacity(0.8), width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Table(
                  border: TableBorder.symmetric(inside: const BorderSide(color: sapphireLighter, width: 2)),
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
                              title: 'TRAINING',
                              subTitle: "$numberOfTrainingDays",
                              titleColor: consistencyHealthColor(value: numberOfTrainingDays / 12),
                              subTitleColor: consistencyHealthColor(value: numberOfTrainingDays / 12)),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Center(
                          child: SleepTimeColumn(
                              title: 'AVG REST',
                              subTitle: "$averageRestDays",
                              titleColor: Colors.white70,
                              subTitleColor: Colors.white70),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Center(
                          child: SleepTimeColumn(
                              title: 'TOTAL REST',
                              subTitle: "$numberOfRestDays",
                              titleColor: Colors.white,
                              subTitleColor: Colors.white),
                        ),
                      )
                    ]),
                  ],
                ),
                const SizedBox(height: 26),
                Text(numberOfTrainingDays < 12 ? lowStreak : highStreak,
                    style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center),
              ],
            )),
      ],
    );
  }

  int averageDaysBetween(List<DateTime> dates) {
    if (dates.length <= 1) {
      return 0; // If there's only one date or none, the average is 0.
    }

    // Sort the dates in ascending order
    dates.sort((a, b) => a.compareTo(b));

    int totalDays = 0;

    // Iterate through the list of dates and calculate the total difference
    for (int i = 1; i < dates.length; i++) {
      totalDays += dates[i].difference(dates[i - 1]).inDays;
    }

    // Calculate the average by dividing the total difference by the number of intervals
    return (totalDays / (dates.length - 1)).round();
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
            color: subTitleColor.withOpacity(0.6),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }
}
