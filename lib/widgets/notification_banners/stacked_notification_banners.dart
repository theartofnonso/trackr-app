import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/controllers/notification_controller.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/shared_prefs.dart';
import 'package:tracker_app/widgets/notification_banners/untrained_muscle_group_family_banner.dart';

import '../../controllers/routine_log_controller.dart';
import '../../dtos/notification_dto.dart';
import '../../enums/muscle_group_enums.dart';
import '../../utils/string_utils.dart';

class StackedNotificationBanners extends StatefulWidget {
  const StackedNotificationBanners({super.key});

  @override
  State<StackedNotificationBanners> createState() => _StackedNotificationBannersState();
}

class _StackedNotificationBannersState extends State<StackedNotificationBanners> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    final notificationController = Provider.of<NotificationController>(context, listen: true);
    final untrainedMGFNotification =
        notificationController.cachedNotification(key: SharedPrefs().cachedUntrainedMGFNotification);

    final routineLogController = Provider.of<RoutineLogController>(context, listen: false);
    final untrainedMuscleGroupFamily = routineLogController.untrainedMuscleGroupFamily();
    final accruedMGFNames = joinWithAnd(items: untrainedMuscleGroupFamily.map((muscle) => muscle.name).toList());

    return Stack(alignment: Alignment.center, children: [
      if (_showUnTrainedMGFBanner(
          untrainedMGFNotification: untrainedMGFNotification, untrainedMuscleGroupFamily: untrainedMuscleGroupFamily))
        Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 4),
          child: UnTrainedMGFBanner(message: accruedMGFNames),
        ),
    ]);
  }

  bool _showUnTrainedMGFBanner(
      {required NotificationDto untrainedMGFNotification,
      required List<MuscleGroupFamily> untrainedMuscleGroupFamily}) {
    final isScheduledForToday = DateTime.now().withoutTime().isSameDayMonthYear(untrainedMGFNotification.dateTime);
    return isScheduledForToday && untrainedMuscleGroupFamily.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      setState(() {});
    }
  }
}
