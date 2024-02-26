import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/controllers/notification_controller.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/shared_prefs.dart';
import 'package:tracker_app/widgets/notification_banners/weekly_training_MGF_banner.dart';

import '../../controllers/routine_log_controller.dart';

class StackedNotificationBanners extends StatelessWidget {
  const StackedNotificationBanners({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationController = Provider.of<NotificationController>(context, listen: true);
    final routineLogController = Provider.of<RoutineLogController>(context, listen: true);

    final untrainedMGFNotification =
        notificationController.cachedNotification(key: SharedPrefs().cachedUntrainedMGFNotification);

    if (untrainedMGFNotification == null || !routineLogController.hasLogs) {
      return const SizedBox.shrink();
    }

    return Stack(alignment: Alignment.center, children: [
      if ((DateTime.now().withHourOnly().isAtSameMomentAs(untrainedMGFNotification.dateTime)))
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: WeeklyTrainingMGFBanner(),
        ),
    ]);
  }
}
