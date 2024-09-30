import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/extensions/datetime_range_extension.dart';
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
    final totalTrainingDays = groupBy(logs, (log) => log.createdAt.day).length;
    final totalRestDays = daysInMonth - totalTrainingDays;

    final averageRestDays =
        totalTrainingDays > 0 ? _averageDaysBetween(logs: logs, datesInMonth: dateTimeRange.dates) : totalRestDays;

    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        decoration: BoxDecoration(
          color: sapphireDark80,
          border: Border.all(color: sapphireDark80.withOpacity(0.8), width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Training vs Rest Days".toUpperCase(),
                style: GoogleFonts.ubuntu(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            Table(
              border: TableBorder.symmetric(inside: BorderSide(color: sapphireLighter.withOpacity(0.4), width: 2)),
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
                          subTitle: "$totalTrainingDays",
                          titleColor: logStreakColor(value: totalTrainingDays / 12),
                          subTitleColor: logStreakColor(value: totalTrainingDays / 12)),
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
                          subTitle: "$totalRestDays",
                          titleColor: Colors.white,
                          subTitleColor: Colors.white),
                    ),
                  )
                ]),
              ],
            ),
            const SizedBox(height: 26),
            Text(totalTrainingDays < 12 ? lowStreak : highStreak,
                style: GoogleFonts.ubuntu(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center),
          ],
        ));
  }

  int _averageDaysBetween({required List<RoutineLogDto> logs, required List<DateTime> datesInMonth}) {
    if (logs.isEmpty) return 0;

    List<int> intervals = [];

    final firstLogDate = logs.first.createdAt;
    final intervalsBeforeFirstLog = firstLogDate.day - 1;
    intervals.add(intervalsBeforeFirstLog);

    for (int i = 0; i < logs.length; i++) {
      final currentLog = logs[i].createdAt.withoutTime();
      if (i == logs.length - 1) break; // Break if we are at the last log (no more intervals to calculate)
      final nextLog = logs[i + 1].createdAt.withoutTime();
      final daysBetween = nextLog.difference(currentLog).inDays - 1;
      if (daysBetween > 0) {
        intervals.add(daysBetween);
      }
    }
    // Calculate the average by dividing the total difference by the number of intervals
    final totalIntervals = intervals.isNotEmpty ? intervals.sum : 0;
    final intervalsLength = intervals.isNotEmpty ? intervals.length : 1;
    return (totalIntervals / intervalsLength).round();
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
          style: GoogleFonts.ubuntu(
            color: titleColor,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.ubuntu(
            color: subTitleColor.withOpacity(0.6),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }
}
