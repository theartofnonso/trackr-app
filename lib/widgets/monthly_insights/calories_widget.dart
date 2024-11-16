import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/screens/insights/calories_trend_screen.dart';
import 'package:tracker_app/utils/routine_utils.dart';

import '../../colors.dart';
import '../../controllers/routine_user_controller.dart';
import '../../dtos/appsync/routine_log_dto.dart';

class CaloriesWidget extends StatelessWidget {
  final List<RoutineLogDto> thisMonthLogs;
  final List<RoutineLogDto> lastMonthLogs;

  const CaloriesWidget({super.key, required this.thisMonthLogs, required this.lastMonthLogs});

  @override
  Widget build(BuildContext context) {

    final routineUserController = Provider.of<RoutineUserController>(context, listen: false);

    final thisMonthCount = thisMonthLogs.map((log) => calculateCalories(duration: log.duration(), reps: routineUserController.weight(), activity: log.activityType)).sum;
    final lastMonthCount = lastMonthLogs.map((log) => calculateCalories(duration: log.duration(), reps: routineUserController.weight(), activity: log.activityType)).sum;

    final improved = thisMonthCount > lastMonthCount;

    return Container(
      decoration: BoxDecoration(
        color: sapphireDark80,
        borderRadius: BorderRadius.circular(5),
      ),
      child: ListTile(
        onTap: () {
          context.push(CaloriesTrendScreen.routeName);
        },
        tileColor: sapphireDark80,
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        leading: const FaIcon(FontAwesomeIcons.fire, color: Colors.white70),
        title: Text("Calories".toUpperCase(),
            style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
        subtitle: Text("Amount of energy expenditure",
            style: GoogleFonts.ubuntu(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w400)),
        trailing: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("$thisMonthCount",
                    style: GoogleFonts.ubuntu(
                        color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w900, fontSize: 20)),
                Text("$lastMonthCount",
                    style: GoogleFonts.ubuntu(color: Colors.white54, fontWeight: FontWeight.w900, fontSize: 12))
              ],
            ),
            const SizedBox(width: 4),
            FaIcon(
              improved ? FontAwesomeIcons.arrowUp : FontAwesomeIcons.arrowDown,
              color: improved ? vibrantGreen : Colors.deepOrange,
              size: 12,
            )
          ],
        ),
      ),
    );
  }
}
