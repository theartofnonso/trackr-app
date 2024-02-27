import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/controllers/notification_controller.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/shared_prefs.dart';
import 'package:tracker_app/widgets/notification_banners/weekly_training_MGF_banner.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StackedNotificationBanners extends StatefulWidget {
  const StackedNotificationBanners({super.key});

  @override
  State<StackedNotificationBanners> createState() => _StackedNotificationBannersState();
}

class _StackedNotificationBannersState extends State<StackedNotificationBanners> with WidgetsBindingObserver {
  bool _showBanner = false;

  @override
  Widget build(BuildContext context) {
    final notificationController = Provider.of<NotificationController>(context, listen: true);

    final untrainedMGFNotification =
        notificationController.cachedNotification(key: SharedPrefs().cachedUntrainedMGFNotification);

    if (untrainedMGFNotification == null) {
      return const SizedBox.shrink();
    }

    return Stack(alignment: Alignment.center, children: [
      if (_showBanner)
        Animate(
          effects: const [FadeEffect(), ScaleEffect()],
          child: const Padding(
            padding: EdgeInsets.only(top: 16.0, bottom: 4),
            child: WeeklyTrainingMGFBanner(),
          ),
        ),
    ]);
  }

  void _checkForNotificationBanner() {
    final notificationController = Provider.of<NotificationController>(context, listen: false);
    final untrainedMGFNotification =
        notificationController.cachedNotification(key: SharedPrefs().cachedUntrainedMGFNotification);
    setState(() {
      _showBanner =
          DateTime.now().withoutTime().isSameDayMonthYear(untrainedMGFNotification?.dateTime ?? DateTime.now());
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkForNotificationBanner();
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
      _checkForNotificationBanner();
    }
  }
}
