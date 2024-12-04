import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/dtos/appsync/activity_log_dto.dart';
import 'package:tracker_app/enums/activity_type_enums.dart';

class ActivityLogWidget extends StatelessWidget {
  final ActivityLogDto activity;
  final String trailing;
  final Color color;
  final void Function()? onTap;

  const ActivityLogWidget({
    super.key,
    required this.activity,
    required this.trailing,
    this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final activityType = ActivityType.fromJson(activity.name);

    final image = activityType.image;

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
      child: ListTile(
        onTap: onTap,
        tileColor: color,
        contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        leading: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: sapphireDark60, // Background color
            borderRadius: BorderRadius.circular(5), // Rounded corners
          ),
          child: image != null
                ? Image.asset(
                    'icons/$image.png',
                    fit: BoxFit.contain,
                    height: 24,
                    color: Colors.greenAccent, // Adjust the height as needed
                  )
                : FaIcon(activityType.icon, color: Colors.greenAccent, size: 20,),
        ),
        title: Text(activity.name.toUpperCase(),
            style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
        trailing: Text(trailing,
            style: GoogleFonts.ubuntu(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500, fontSize: 14)),
      ),
    );
  }
}
