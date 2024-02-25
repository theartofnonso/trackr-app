import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/dtos/untrained_muscle_group_families_notification_dto.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/widgets/notification_banners/weekly_untrained_muscle_group_families_banner.dart';

import '../../controllers/routine_log_controller.dart';

class StackedNotificationBanners extends StatelessWidget {
  const StackedNotificationBanners({super.key});

  @override
  Widget build(BuildContext context) {
    final routineLogController = Provider.of<RoutineLogController>(context, listen: true);

    final untrainedMGFNotification = routineLogController.cachedUntrainedMGFNotification();

    final untrainedMuscleGroups = routineLogController.untrainedMuscleGroupFamilies;

    return Stack(alignment: Alignment.center, children: [
      if ((untrainedMGFNotification.dateTime.difference(DateTime.now()).inDays > 1 || untrainedMGFNotification.show) &&
          untrainedMuscleGroups.isNotEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: WeeklyUntrainedMuscleGroupFamiliesBanner(onDismiss: () => _hideNotificationBanner(context: context)),
        ),
    ]);
  }

  void _hideNotificationBanner({required BuildContext context}) {
    Provider.of<RoutineLogController>(context, listen: false).cacheUntrainedMGFNotification(
        dto: UntrainedMGFNotificationDto(show: false, dateTime: DateTime.now().withHourOnly()));
  }
}
