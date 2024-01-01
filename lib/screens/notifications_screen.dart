import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/enums/daily_notifications_enums.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/widgets/buttons/text_button_widget.dart';

import '../utils/timezone_utils.dart';
import '../widgets/helper_widgets/dialog_helper.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

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
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text("Notifications", style: GoogleFonts.montserrat(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                const SizedBox(height: 16),
                const _NotificationListView()
              ]),
            ),
          ),
        ));
  }
}

class _NotificationListTile extends StatelessWidget {
  final DailyReminder dailyReminder;
  final PendingNotificationRequest? schedule;
  final void Function() onScheduleChanged;

  const _NotificationListTile({required this.dailyReminder, required this.schedule, required this.onScheduleChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: tealBlueLight, // Background color
          width: 1, // Border width
        ),
        borderRadius: BorderRadius.circular(5), // Border radius
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(dailyReminder.day, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 16)),
          if (schedule != null)
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 8),
              CTextButton(
                  onPressed: () => _displayTimePicker(context: context),
                  label:
                      "${dailyReminder.day == DailyReminder.everyday.day ? "Everyday" : "Every ${dailyReminder.day}"} at ${_timeForSchedule().digitalTimeHM()}",
                  textStyle: GoogleFonts.montserrat(color: Colors.white70, fontSize: 14))
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
              FlutterLocalNotificationsPlugin().cancel(dailyReminder.weekday);
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
    final tzDateTime = dailyReminder.weekday == DailyReminder.everyday.weekday
        ? nextInstanceOfHour(hours: duration.inHours)
        : nextInstanceOfHourAndWeekDay(hours: duration.inHours, weekday: dailyReminder.weekday);

    final matchDateTimeComponents = dailyReminder.weekday == DailyReminder.everyday.weekday
        ? DateTimeComponents.time
        : DateTimeComponents.dayOfWeekAndTime;

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    if (dailyReminder.weekday == DailyReminder.everyday.weekday) {
      await flutterLocalNotificationsPlugin.cancelAll();
    } else {
      await flutterLocalNotificationsPlugin.cancel(dailyReminder.weekday);
    }

    FlutterLocalNotificationsPlugin().zonedSchedule(
        dailyReminder.weekday, dailyReminder.title, dailyReminder.subtitle, tzDateTime, const NotificationDetails(),
        payload: duration.inMilliseconds.toString(),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: matchDateTimeComponents);
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
    List<int> weekDays = List.generate(7, (index) => index);
    final children = weekDays.map((day) {
      final dailyReminder = DailyReminder.values[day];
      return _NotificationListTile(
          dailyReminder: dailyReminder,
          schedule: _schedules.firstWhereOrNull((schedule) => schedule.id == dailyReminder.weekday),
          onScheduleChanged: _loadSchedules);
    }).toList();

    final dailyNotificationEnabled =
        _schedules.firstWhereOrNull((schedule) => schedule.id == DailyReminder.everyday.weekday);

    final dailyNotification = _NotificationListTile(
        dailyReminder: DailyReminder.everyday, schedule: dailyNotificationEnabled, onScheduleChanged: _loadSchedules);

    if (dailyNotificationEnabled != null) {
      return dailyNotification;
    }

    return Column(children: [dailyNotification, const SizedBox(height: 16), ...children]);
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
