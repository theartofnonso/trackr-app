import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/controllers/notification_controller.dart';
import 'package:tracker_app/dtos/notification_dto.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/shared_prefs.dart';
import 'package:tracker_app/widgets/notification_banners/weekly_training_MGF_banner.dart';

class StackedNotificationBanners extends StatelessWidget {
  const StackedNotificationBanners({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationController = Provider.of<NotificationController>(context, listen: true);

    final untrainedMGFNotification = notificationController.cachedNotification(key: SharedPrefs().cachedUntrainedMGFNotification);

    if(untrainedMGFNotification == null) {
      return const SizedBox.shrink();
    }

    return Stack(alignment: Alignment.center, children: [
      if ((untrainedMGFNotification.dateTime.difference(DateTime.now()).inDays > 1 || untrainedMGFNotification.show))
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: WeeklyTrainingMGFBanner(onDismiss: () => _hideNotificationBanner(context: context)),
        ),
    ]);
  }

  void _hideNotificationBanner({required BuildContext context}) {
    Provider.of<NotificationController>(context, listen: false).cacheNotification(key: SharedPrefs().cachedUntrainedMGFNotification,
        dto: NotificationDto(show: false, dateTime: DateTime.now().withHourOnly()));
  }
}
