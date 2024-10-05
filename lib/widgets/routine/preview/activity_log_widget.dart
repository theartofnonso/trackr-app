import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/dtos/activity_log_dto.dart';
import 'package:tracker_app/enums/activity_type_enums.dart';
import 'package:tracker_app/extensions/duration_extension.dart';

class ActivityLogWidget extends StatelessWidget {
  final ActivityLogDto activity;
  final void Function()? onTap;

  const ActivityLogWidget({
    super.key,
    required this.activity,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    final activityType = ActivityType.fromString(activity.name);

    return Container(
      margin: null,
      decoration: BoxDecoration(
        color: sapphireDark80,
        borderRadius: BorderRadius.circular(5),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        leading: FaIcon(activityType.icon, color: Colors.white70),
        title: Text(activity.name.toUpperCase(),
            style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
        trailing: Text(activity.duration().hmsAnalog(),
            style: GoogleFonts.ubuntu(
                color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500, fontSize: 14)),
      ),
    );
  }
}
