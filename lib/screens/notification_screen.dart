import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tracker_app/utils/general_utils.dart';

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
            )
        ),
        body: Column(children: [
          SwitchListTile(
            title: Text('Weekly Training reminder', style: GoogleFonts.lato(color: Colors.white, fontSize: 16)),
            subtitle: Text(_notificationStatusMessage,
                style: GoogleFonts.lato(color: Colors.white70, fontSize: 14)),
            value: _notificationEnabled,
            onChanged: (bool value) {
              if (value) {
                _requestNotificationPermission();
              }
            },
          )
        ]));
  }

  void _checkNotificationPermission() async {
    final status = await Permission.notification.status;
    print(status);
    if (!status.isGranted) {
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
    final bool = await requestNotificationPermission();
    if (bool != null) {
      if (bool) {
        setState(() {
          _notificationEnabled = true;
          _notificationStatusMessage = "Trackr will remind you to train weekly";
        });
      }
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
