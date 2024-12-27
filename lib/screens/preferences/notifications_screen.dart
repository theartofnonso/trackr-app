import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/enums/daily_notifications_enums.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/widgets/buttons/opacity_button_widget.dart';

import '../../utils/dialog_utils.dart';
import '../../utils/general_utils.dart';
import '../../utils/timezone_utils.dart';

Duration _timeForSchedule({required PendingNotificationRequest? schedule}) {
  final payload = _decodeNotificationPayload(schedule: schedule);
  return payload.isNotEmpty ? payload["duration"] : const Duration(hours: 3);
}

Future<void> _scheduleNotification(
    {required DailyReminder reminder, required DailyReminderType type, required Duration duration}) async {
  final tzDateTime = nextInstanceOfHourAndWeekDay(hours: duration.inHours, weekday: reminder.weekday);

  const matchDateTimeComponents = DateTimeComponents.dayOfWeekAndTime;

  final payload = {"type": type.name, "duration": duration.inMilliseconds.toString()};

  await FlutterLocalNotificationsPlugin().zonedSchedule(
      reminder.weekday, reminder.title, reminder.subtitle, tzDateTime, const NotificationDetails(),
      payload: jsonEncode(payload),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: matchDateTimeComponents,
      androidScheduleMode: AndroidScheduleMode.exact);
}

Map<String, dynamic> _decodeNotificationPayload({required PendingNotificationRequest? schedule}) {
  final payloadString = schedule?.payload;
  if (payloadString != null) {
    final payload = jsonDecode(payloadString);
    final reminderTypeString = payload["type"];
    final type = DailyReminderType.fromString(reminderTypeString);
    final durationString = payload["duration"];
    final duration = Duration(milliseconds: int.parse(durationString));
    return {"type": type, "duration": duration};
  }
  return {};
}

void _displayTimePicker(
    {required BuildContext context,
    required PendingNotificationRequest? schedule,
    required void Function(Duration) onDurationChanged}) {
  showHourTimerPicker(
      context: context,
      initialDuration: _timeForSchedule(schedule: schedule),
      onChangedDuration: (duration) {
        context.pop();
        onDurationChanged(duration);
      });
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, size: 28),
            onPressed: context.pop,
          ),
          title: Text(
            "Notifications".toUpperCase(),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: themeGradient(context: context),
          ),
          child: SafeArea(
            bottom: false,
            minimum: const EdgeInsets.all(10.0),
            child: const _NotificationListView(),
          ),
        ));
  }
}

class _NotificationSwitch extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool enabled;
  final void Function() onPressed;
  final void Function(bool)? onChanged;

  const _NotificationSwitch(
      {required this.title,
      required this.subtitle,
      required this.enabled,
      required this.onPressed,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? sapphireDark80 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(title, style: Theme.of(context).textTheme.bodyLarge),
              ),
              if (enabled)
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  OpacityButtonWidget(
                    onPressed: onPressed,
                    label: subtitle,
                    buttonColor: vibrantGreen,
                  )
                ]),
            ]),
            Switch(
              activeColor: vibrantGreen,
              value: enabled,
              onChanged: onChanged,
            )
          ]),
    );
  }
}

class _WeekDayNotificationListTile extends StatelessWidget {
  final DailyReminder dailyReminder;
  final PendingNotificationRequest? schedule;
  final void Function() onScheduleChanged;

  const _WeekDayNotificationListTile(
      {required this.dailyReminder, required this.schedule, required this.onScheduleChanged});

  @override
  Widget build(BuildContext context) {
    final payload = _decodeNotificationPayload(schedule: schedule);

    return _NotificationSwitch(
        title: dailyReminder.day,
        subtitle: _timeForSchedule(schedule: schedule).hmDigital(),
        enabled: schedule != null && payload["type"] == DailyReminderType.weekday,
        onPressed: () =>
            _displayTimePicker(context: context, schedule: schedule, onDurationChanged: _scheduleWeekDayNotification),
        onChanged: (bool value) {
          if (value) {
            _scheduleWeekDayNotification(const Duration(hours: 3));
          } else {
            _cancelWeekDayNotification();
          }
        });
  }

  void _cancelWeekDayNotification() async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.cancel(dailyReminder.weekday);
    onScheduleChanged();
  }

  void _scheduleWeekDayNotification(Duration duration) async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin.cancel(dailyReminder.weekday);

    await _scheduleNotification(reminder: dailyReminder, type: DailyReminderType.weekday, duration: duration);

    onScheduleChanged();
  }
}

class _DailyNotificationListTile extends StatelessWidget {
  final bool enabled;
  final PendingNotificationRequest? schedule;
  final void Function() onScheduleChanged;

  const _DailyNotificationListTile({required this.enabled, required this.schedule, required this.onScheduleChanged});

  @override
  Widget build(BuildContext context) {
    return _NotificationSwitch(
        title: "Everyday",
        subtitle: _timeForSchedule(schedule: schedule).hmDigital(),
        enabled: enabled,
        onPressed: () =>
            _displayTimePicker(context: context, schedule: schedule, onDurationChanged: _scheduleDailyNotification),
        onChanged: (bool value) {
          if (value) {
            _scheduleDailyNotification(const Duration(hours: 3));
          } else {
            _cancelDailyNotification();
          }
        });
  }

  void _cancelDailyNotification() async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.cancelAll();
    onScheduleChanged();
  }

  void _scheduleDailyNotification(Duration duration) async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin.cancelAll();

    const weekDays = DailyReminder.values;

    for (var day in weekDays) {
      await _scheduleNotification(reminder: day, type: DailyReminderType.daily, duration: duration);
    }
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
    const reminders = DailyReminder.values;
    final children = reminders.map((reminder) {
      final schedule = _schedules.firstWhereOrNull((schedule) => schedule.id == reminder.weekday);
      return _WeekDayNotificationListTile(
          dailyReminder: reminder, schedule: schedule, onScheduleChanged: _loadSchedules);
    }).toList();

    final isDailyNotificationEnabled = _schedules.isNotEmpty &&
        _schedules.every((schedule) {
          final payload = _decodeNotificationPayload(schedule: schedule);
          return payload["type"] == DailyReminderType.daily;
        });

    final dailyNotification = _DailyNotificationListTile(
        enabled: isDailyNotificationEnabled, schedule: _schedules.firstOrNull, onScheduleChanged: _loadSchedules);

    final listItems = [dailyNotification, ...children];

    return ListView.separated(
        itemBuilder: (context, index) {
          return listItems[index];
        },
        separatorBuilder: (context, index) {
          return const SizedBox(
            height: 10,
          );
        },
        itemCount: listItems.length);
  }

  void _loadSchedules() async {
    final schedules = await FlutterLocalNotificationsPlugin().pendingNotificationRequests();
    setState(() {
      _schedules = schedules;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _loadSchedules();
    });
  }
}
