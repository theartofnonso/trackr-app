import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';

import '../../colors.dart';
import '../../controllers/notification_controller.dart';
import '../../dtos/notification_dto.dart';
import '../../shared_prefs.dart';
import '../information_container.dart';

class UnTrainedMGFBanner extends StatelessWidget {
  final String message;

  const UnTrainedMGFBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return InformationContainer(
        leadingIcon: const FaIcon(FontAwesomeIcons.lightbulb, color: Colors.white, size: 16),
        trailingIcon: GestureDetector(
            onTap: () => _postponeNotificationBanner(context: context),
            child: const FaIcon(FontAwesomeIcons.solidSquareCheck, color: vibrantGreen, size: 22)),
        title: "This week's recommendation",
        richDescription: RichText(
            text: TextSpan(
                text: "You didn't train your",
                style: GoogleFonts.montserrat(
                    color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500, height: 1.5),
                children: [
              const TextSpan(text: " "),
              TextSpan(
                  text: message,
                  style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              const TextSpan(text: " "),
              TextSpan(
                  text: "last week.",
                  style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
              const TextSpan(text: " "),
              TextSpan(
                  text: "Try to include them in your training this week.",
                  style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
            ])),
        color: sapphireDark60);
  }

  void _postponeNotificationBanner({required BuildContext context}) {
    DateTime nextSchedule = DateTime.now().nextDay();
    Provider.of<NotificationController>(context, listen: false).cacheNotification(
        key: SharedPrefs().cachedUntrainedMGFNotification, dto: NotificationDto(dateTime: nextSchedule));
  }
}
