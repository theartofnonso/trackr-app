import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/extensions/duration_extension.dart';

import '../../dtos/routine_log_dto.dart';
import '../../strings.dart';

class LogDurationWidget extends StatelessWidget {
  final List<RoutineLogDto> logs;

  const LogDurationWidget({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {

    final logHours = logs.map((log) => log.duration().inMilliseconds);

    final minHours = Duration(milliseconds: logHours.isNotEmpty ? logHours.min : 0);
    final maxHours = Duration(milliseconds:  logHours.isNotEmpty ? logHours.max : 0);
    final avgHours = Duration(milliseconds:  logHours.isNotEmpty ? logHours.average.toInt() : 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("How many hours did you train?".toUpperCase(),
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
                  border: TableBorder.symmetric(inside: BorderSide(color: sapphireLighter.withOpacity(0.4), width: 2)),
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
                              subTitleColor: Colors.white),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Center(
                          child: SleepTimeColumn(
                              title: 'AVG TIME',
                              subTitle: avgHours.hmDigital(),
                              titleColor: avgHours.inMinutes < 30 ? Colors.orange: Colors.white70,
                              subTitleColor: avgHours.inMinutes < 30 ? Colors.orange.withOpacity(0.8) : Colors.white70),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Center(
                          child: SleepTimeColumn(
                              title: 'MOST TIME',
                              subTitle: maxHours.hmDigital(),
                              titleColor: Colors.white,
                              subTitleColor: Colors.white),
                        ),
                      )
                    ]),
                  ],
                ),
                const SizedBox(height: 26),
                Text(avgHours.inMinutes < 30 ? lowAverageWorkoutDuration : highAverageWorkoutDuration,
                    style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
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
            color: subTitleColor.withOpacity(0.6),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }
}
