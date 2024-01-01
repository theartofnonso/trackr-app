import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/utils/general_utils.dart';
import 'package:tracker_app/widgets/buttons/text_button_widget.dart';

import '../utils/timezone_utils.dart';
import '../widgets/helper_widgets/dialog_helper.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _notificationEnabled = false;
  String _notificationStatusMessage = "Trackr won't remind you to train weekly";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        )),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              child: Column(children: [
                SwitchListTile(
                  title: Text('Weekly Training reminder', style: GoogleFonts.lato(color: Colors.white, fontSize: 16)),
                  subtitle:
                      Text(_notificationStatusMessage, style: GoogleFonts.lato(color: Colors.white70, fontSize: 14)),
                  value: _notificationEnabled,
                  activeColor: Colors.green,
                  inactiveThumbColor: Colors.white70,
                  onChanged: (bool value) {
                    if (value) {
                      _requestNotificationPermission();
                    } else {
                      // Handle disabling notifications
                    }
                  },
                ),
                const SizedBox(height: 16),
                const _NotificationListView()
              ]),
            ),
          ),
        ));
  }

  void _checkNotificationPermission() async {
    final result = await checkIosNotificationPermission();
    if (!result.isEnabled) {
      setState(() {
        _notificationEnabled = false;
        _notificationStatusMessage = "Trackr won't remind you to train weekly";
      });
    } else {
      setState(() {
        _notificationEnabled = true;
        _notificationStatusMessage = "Trackr will remind you to train weekly";
      });
    }
  }

  void _requestNotificationPermission() async {
    final isEnabled = await requestIosNotificationPermission();
    if (isEnabled) {
      setState(() {
        _notificationEnabled = true;
        _notificationStatusMessage = "Trackr will remind you to train weekly";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkNotificationPermission();
    });
  }
}

class _NotificationListTile extends StatelessWidget {
  final int weekDay;
  final PendingNotificationRequest? schedule;
  final void Function() onScheduleChanged;

  const _NotificationListTile({required this.weekDay, required this.schedule, required this.onScheduleChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: tealBlueLight, // Background color
          width: 1, // Border width
        ),
        borderRadius: BorderRadius.circular(16), // Border radius
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(weekdayName(weekDay), style: GoogleFonts.lato(color: Colors.white, fontSize: 16)),
          if (schedule != null)
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 8),
              CTextButton(
                  onPressed: () => _displayTimePicker(context: context),
                  label: "Every ${weekdayName(weekDay)} at ${_timeForSchedule().digitalTimeHM()}",
                  textStyle: GoogleFonts.lato(color: Colors.white70, fontSize: 14))
            ]),
        ]),
        Switch(
          activeColor: Colors.green,
          inactiveThumbColor: Colors.white70,
          value: schedule != null,
          onChanged: (bool value) {
            if (value) {
              _scheduleWeekDayNotification(duration: const Duration(hours: 3));
            } else {
              FlutterLocalNotificationsPlugin().cancel(weekDay);
              onScheduleChanged();
            }
          },
        )
      ]),
    );
  }

  Duration _timeForSchedule() {
    final json = schedule?.payload ?? "";
    return json.isNotEmpty ? Duration(milliseconds: int.parse(json)) : const Duration(hours: 3);
  }

  void _displayTimePicker({required BuildContext context}) {
    displayNotificationTimePicker(
        context: context,
        mode: CupertinoTimerPickerMode.hm,
        initialDuration: _timeForSchedule(),
        onChangedDuration: (duration) {
          Navigator.of(context).pop();
          _scheduleWeekDayNotification(duration: duration);
        });
  }

  void _scheduleWeekDayNotification({required Duration duration}) async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.cancel(weekDay);
    FlutterLocalNotificationsPlugin().zonedSchedule(
        weekDay,
        "It's a great day to train!",
        "Let's get you on track",
        nextInstanceOfWeekDayAndHour(hour: duration.inHours, minutes: duration.inMinutes, weekday: weekDay),
        const NotificationDetails(),
        payload: duration.inMilliseconds.toString(),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime);
    onScheduleChanged();
  }

}

class _NotificationListView extends StatefulWidget {
  const _NotificationListView();

  @override
  State<_NotificationListView> createState() => _NotificationListViewState();
}

class _NotificationListViewState extends State<_NotificationListView> {
  List<PendingNotificationRequest> _schedules = [];

  @override
  Widget build(BuildContext context) {
    List<int> weekDays = List.generate(7, (index) => index + 1);
    final children = weekDays
        .map((day) => _NotificationListTile(
            weekDay: day,
            schedule: _schedules.firstWhereOrNull((schedule) => schedule.id == day),
            onScheduleChanged: _loadSchedules))
        .toList();

    return Column(children: children);
  }

  void _loadSchedules() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final schedules = await FlutterLocalNotificationsPlugin().pendingNotificationRequests();
      setState(() {
        _schedules = schedules;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }
}
