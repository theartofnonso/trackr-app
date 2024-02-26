import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';

import '../../colors.dart';
import '../../controllers/notification_controller.dart';
import '../../controllers/routine_log_controller.dart';
import '../../dtos/notification_dto.dart';
import '../../shared_prefs.dart';
import '../../utils/string_utils.dart';
import '../information_container.dart';

class WeeklyTrainingMGFBanner extends StatelessWidget {
  const WeeklyTrainingMGFBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<RoutineLogController>(context, listen: false);

    final accruedMGF = controller.accruedMGF;

    final pendingMGF = controller.pendingMGF;

    String title = "";

    Widget richText = const SizedBox.shrink();
    if (accruedMGF.isNotEmpty) {
      title = "This week's recommendation";
      richText = const _AccruedMGFRichText();
    } else if (pendingMGF.isNotEmpty) {
      title = "This week's focus";
      richText = const _PendingMGFRichText();
    } else if (accruedMGF.isEmpty && pendingMGF.isEmpty) {
      title = "Congratulations";
      richText = const _NoMGFRichText();
    }

    return InformationContainer(
        leadingIcon: const FaIcon(FontAwesomeIcons.lightbulb, color: Colors.white, size: 16),
        trailingIcon: GestureDetector(
            onTap: () => _postponeNotificationBanner(context: context),
            child: const FaIcon(FontAwesomeIcons.solidSquareCheck, color: vibrantGreen, size: 22)),
        title: title,
        richDescription: richText,
        color: sapphireDark60);
  }

  void _postponeNotificationBanner({required BuildContext context}) {
    final controller = Provider.of<RoutineLogController>(context, listen: false);

    final accruedMGF = controller.accruedMGF;

    final pendingMGF = controller.pendingMGF;

    DateTime nextSchedule = DateTime.now().nextHour();

    if (accruedMGF.isEmpty && pendingMGF.isEmpty) {
      nextSchedule = DateTime.now().withHourOnly().nextWeek();
    }

    Provider.of<NotificationController>(context, listen: false).cacheNotification(
        key: SharedPrefs().cachedUntrainedMGFNotification, dto: NotificationDto(dateTime: nextSchedule));
  }
}

class _AccruedMGFRichText extends StatelessWidget {
  const _AccruedMGFRichText();

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<RoutineLogController>(context, listen: false);

    final accruedMGF = controller.accruedMGF;

    final accruedMGFNames = joinWithAnd(items: accruedMGF.map((muscle) => muscle.name).toList());

    return RichText(
        text: TextSpan(
            text: "You didn't train your",
            style:
                GoogleFonts.montserrat(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500, height: 1.5),
            children: [
          const TextSpan(text: " "),
          TextSpan(
              text: accruedMGFNames,
              style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          const TextSpan(text: " "),
          TextSpan(
              text: "last week.",
              style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
          const TextSpan(text: " "),
          TextSpan(
              text: "Try to include them in your training this week.",
              style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
        ]));
  }
}

class _PendingMGFRichText extends StatelessWidget {
  const _PendingMGFRichText();

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<RoutineLogController>(context, listen: false);

    final pendingMGF = controller.pendingMGF;

    final pendingMGFNames = joinWithAnd(items: pendingMGF.map((muscle) => muscle.name).toList());

    return RichText(
        text: TextSpan(
            text: "Set your focus on training your",
            style:
                GoogleFonts.montserrat(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500, height: 1.5),
            children: [
          const TextSpan(text: " "),
          TextSpan(
              text: pendingMGFNames,
              style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          const TextSpan(text: " "),
          TextSpan(
              text: "this week.",
              style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
        ]));
  }
}

class _NoMGFRichText extends StatelessWidget {
  const _NoMGFRichText();

  @override
  Widget build(BuildContext context) {
    return Text(
        "You have all muscle groups included in your training for the week. Ensure to hit optimal sets and reps as well.",
        style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500, height: 1.5));
  }
}
