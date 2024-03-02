import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';

import '../../colors.dart';
import '../../controllers/routine_log_controller.dart';
import '../../widgets/calender_heatmaps/calendar_heatmap.dart';

class StreakScreen extends StatelessWidget {
  static const routeName = '/streak_screen';

  const StreakScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final routineLogController = Provider.of<RoutineLogController>(context, listen: false);

    final monthsAndLogs = routineLogController.monthlyLogs.isNotEmpty
        ? routineLogController.monthlyLogs.values.map((logs) {
            final dates = logs.map((log) => log.createdAt.withoutTime()).toList();
            return CalendarHeatMap(dates: dates, spacing: 4);
          }).toList()
        : [
            CalendarHeatMap(dates: [DateTime.now()], spacing: 4)
          ];

    return Scaffold(
        appBar: AppBar(
          backgroundColor: sapphireDark80,
          leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                sapphireDark80,
                sapphireDark,
              ],
            ),
          ),
          child: SafeArea(
            minimum: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("Streak ${DateTime.now().year}",
                    style: GoogleFonts.montserrat(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                const SizedBox(height: 20),
                GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    crossAxisCount: 1,
                    childAspectRatio: 1.2,
                    mainAxisSpacing: 4.0,
                    crossAxisSpacing: 4.0,
                    children: monthsAndLogs)
              ]),
            ),
          ),
        ));
  }
}
