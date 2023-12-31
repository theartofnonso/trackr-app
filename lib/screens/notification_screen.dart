import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/utils/general_utils.dart';

import '../widgets/helper_widgets/dialog_helper.dart';

class _NotificationDay {
  final int weekday;
  final String label;
  final String description;

  const _NotificationDay({required this.weekday, required this.label, required this.description});
}

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
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(children: [
            SwitchListTile(
              title: Text('Weekly Training reminder', style: GoogleFonts.lato(color: Colors.white, fontSize: 16)),
              subtitle: Text(_notificationStatusMessage, style: GoogleFonts.lato(color: Colors.white70, fontSize: 14)),
              value: _notificationEnabled,
              activeColor: Colors.green,
              inactiveThumbColor: Colors.white70,
              onChanged: (bool value) {
                if (value) {
                  _requestNotificationPermission();
                }
              },
            ),
            const SizedBox(height: 16),
            Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: tealBlueLight, // Background color
                    width: 2, // Border width
                  ),
                  borderRadius: BorderRadius.circular(16), // Border radius
                ),
                child: const _NotificationListView(notificationDays: [
                  _NotificationDay(
                      weekday: DateTime.monday, label: "Monday", description: "Remind me to train on Mondays"),
                  _NotificationDay(
                      weekday: DateTime.tuesday, label: "Tuesday", description: "Remind me to train on Tuesdays"),
                  _NotificationDay(
                      weekday: DateTime.wednesday, label: "Wednesday", description: "Remind me to train on Wednesdays"),
                  _NotificationDay(
                      weekday: DateTime.thursday, label: "Thursday", description: "Remind me to train on Thursdays"),
                  _NotificationDay(
                      weekday: DateTime.friday, label: "Friday", description: "Remind me to train on Fridays"),
                  _NotificationDay(
                      weekday: DateTime.saturday, label: "Saturday", description: "Remind me to train on Saturdays"),
                  _NotificationDay(
                      weekday: DateTime.sunday, label: "Sunday", description: "Remind me to train on Sundays"),
                ]))
          ]),
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

class _NotificationListTile extends StatefulWidget {
  final _NotificationDay notificationDay;

  const _NotificationListTile({required this.notificationDay});

  @override
  State<_NotificationListTile> createState() => _NotificationListTileState();
}

class _NotificationListTileState extends State<_NotificationListTile> {

  Duration _time = const Duration(hours: 3, minutes: 0);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        splashColor: Colors.transparent,
        brightness: Brightness.dark,
      ),
      child: SwitchListTile(
        activeColor: Colors.green,
        inactiveThumbColor: Colors.white70,
        title: Text(weekdayName(widget.notificationDay.weekday), style: GoogleFonts.lato(color: Colors.white, fontSize: 16)),
        subtitle: Text("Every ${weekdayName(widget.notificationDay.weekday)} at ${_time.digitalTimeHM()}", style: GoogleFonts.lato(color: Colors.white70, fontSize: 14)),
        value: false,
        onChanged: (bool value) {
          displayNotificationTimePicker(
              context: context,
              mode: CupertinoTimerPickerMode.hm,
              initialDuration: const Duration(hours: 3),
              onChangedDuration: (duration) {
                Navigator.of(context).pop();
                setState(() {
                  _time = duration;
                });
              }, turnOffReminder: () {  });
        },
      ),
    );
  }
}

class _NotificationListView extends StatelessWidget {
  final List<_NotificationDay> notificationDays;

  const _NotificationListView({required this.notificationDays});

  @override
  Widget build(BuildContext context) {
    final children = notificationDays.map((day) => _NotificationListTile(notificationDay: day)).toList();

    return Column(children: children);
  }
}
