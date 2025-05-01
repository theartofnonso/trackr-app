import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:sahha_flutter/sahha_flutter.dart';
import 'package:tracker_app/utils/navigation_utils.dart';
import 'package:tracker_app/widgets/empty_states/no_list_empty_state.dart';

import '../../utils/general_utils.dart';
import '../../utils/sahha_utils.dart';
import '../request_screens/sahha_sensors_request.dart';

class NotificationsScreen extends StatefulWidget {
  static const routeName = '/notifications_screen';

  final void Function(SahhaSensorStatus sensorStatus) onSahhaSensorStatusUpdate;

  const NotificationsScreen({super.key, required this.onSahhaSensorStatusUpdate});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  SahhaSensorStatus _sensorStatus = SahhaSensorStatus.pending;

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final hasPendingActions = _sensorStatus == SahhaSensorStatus.pending;

    final deviceOS = Platform.isIOS ? "Apple Health" : "Google Health";

    return Scaffold(
      appBar: AppBar(
        title: Text("TRKR Notifications".toUpperCase()),
        leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.squareXmark, size: 28), onPressed: Navigator.of(context).pop),
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: themeGradient(context: context),
        ),
        child: SafeArea(
          bottom: false,
          child: hasPendingActions
              ? Column(
                  children: [
                    if (hasPendingActions)
                      ListTile(
                        onTap: _enableSahhaSensors,
                        leading: FaIcon(
                          FontAwesomeIcons.solidBell,
                          size: 20,
                        ),
                        title: Text("Sync with $deviceOS"),
                        subtitle: Text("Connect to improve your training"),
                        trailing: FaIcon(
                          FontAwesomeIcons.chevronRight,
                          size: 12,
                          color: isDarkMode ? Colors.white70 : Colors.grey.shade400,
                        ),
                      ),
                  ],
                )
              : Center(
                  child: NoListEmptyState(
                      message:
                          "Hurray! You’re all caught up with your notifications. Check back later for updates or new tasks!")),
        ),
      ),
    );
  }

  void _getSahhaSensorStatus() {
    // Get status of `steps` and `sleep` sensors
    SahhaFlutter.getSensorStatus(sahhaSensors).then((value) {
      setState(() {
        _sensorStatus = value;
      });
    }).catchError((error, stackTrace) {
      debugPrint(error.toString());
    });
  }

  void _enableSahhaSensors() async {
    await navigateWithSlideTransition(
        context: context,
        child: SahhaSensorsRequestScreen(onRequest: () {
          SahhaFlutter.enableSensors(sahhaSensors).then((value) {
            if (mounted) {
              Navigator.of(context).pop();
            }

            setState(() {
              _sensorStatus = value;
            });

            widget.onSahhaSensorStatusUpdate(value);

            if (mounted) {
              context.pop();
            }
          }).catchError((error, stackTrace) {
            debugPrint(error.toString());
          });
        }));
  }

  @override
  void initState() {
    super.initState();
    _getSahhaSensorStatus();
  }
}
