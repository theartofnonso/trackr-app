import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        width: 55,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.greenAccent.withValues(alpha:0.1), // Background color
          borderRadius: BorderRadius.circular(5), // Rounded corners
        ),
        child: image != null
            ? Image.asset(
                'icons/$image.png',
                fit: BoxFit.contain,
                height: 30,
                color: Colors.greenAccent, // Adjust the height as needed
              )
            : Center(
              child: FaIcon(
                  activityType.icon,
                  color: Colors.greenAccent,
                  size: 20,
                ),
            ),
      ),
      title: Text(activity.nameOrSummary.toUpperCase()),
      trailing: Text(trailing),
    );
  }
}
