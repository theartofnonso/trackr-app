import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/widgets/buttons/opacity_button_widget.dart';
import 'package:tracker_app/widgets/dividers/label_divider.dart';
import 'package:tracker_app/widgets/icons/user_icon_widget.dart';
import 'package:tracker_app/widgets/list_tile.dart';

import '../../colors.dart';
import '../../controllers/routine_user_controller.dart';
import '../../dtos/appsync/routine_user_dto.dart';
import '../../utils/general_utils.dart';
import '../../widgets/empty_states/not_found.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({
    super.key,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> with WidgetsBindingObserver {
  RoutineUserDto? _user;

  double _weight = 0;

  bool _notificationEnabled = false;

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final user = _user;

    if (user == null) return const NotFound();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, size: 28),
          onPressed: context.pop,
        ),
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: themeGradient(context: context),
        ),
        child: SafeArea(
          minimum: const EdgeInsets.only(right: 10, left: 10, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 50),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(spacing: 36, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 6,
                        ),
                        Center(
                          child: UserIconWidget(size: 60, iconSize: 22),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Center(
                          child: Text(user.name.toUpperCase(),
                              style: Theme.of(context).textTheme.titleSmall, textAlign: TextAlign.center),
                        ),
                      ],
                    ),
                    if (Platform.isIOS)
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        LabelDivider(
                          label: "notifications".toUpperCase(),
                          labelColor: isDarkMode ? Colors.white : Colors.black,
                          dividerColor: sapphireLighter,
                          fontSize: 14,
                        ),
                        const SizedBox(height: 8),
                        Text(
                            "Allow us to remind you about long-running workouts if you’ve become distracted. We’ll also send reminders on your training days.",
                            textAlign: TextAlign.start,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w400, color: isDarkMode ? Colors.white70 : Colors.black)),
                        const SizedBox(height: 8),
                        ThemeListTile(
                          child: ListTile(
                            onTap: _turnOnNotification,
                            dense: true,
                            horizontalTitleGap: 0,
                            leading: Text(_notificationEnabled ? "Notification is on" : "Turn on notifications",
                                textAlign: TextAlign.start,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: isDarkMode ? Colors.white : Colors.black)),
                            trailing: FaIcon(
                              FontAwesomeIcons.solidBell,
                              size: 14,
                            ),
                          ),
                        )
                      ])
                  ]),
                ),
              ),
              SafeArea(
                minimum: EdgeInsets.all(10),
                child: SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: OpacityButtonWidget(
                      onPressed: _updateUser,
                      label: "Save Profile",
                      buttonColor: vibrantGreen,
                      padding: EdgeInsets.symmetric(vertical: 10),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateUser() async {
    final user = _user;
    if (user != null) {
      final userToUpdate = user.copyWith(weight: _weight);
      await Provider.of<RoutineUserController>(context, listen: false).updateUser(userDto: userToUpdate);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _turnOnNotification() async {
    if (!_notificationEnabled) {
      final isEnabled = await requestNotificationPermission();
      setState(() {
        _notificationEnabled = isEnabled;
      });
    }
  }

  void _checkNotificationPermission() async {
    final result = await checkIosNotificationPermission();
    setState(() {
      _notificationEnabled = result.isEnabled;
    });
  }

  @override
  void initState() {
    super.initState();
    _user = Provider.of<RoutineUserController>(context, listen: false).user;
    _weight = _user?.weight.toDouble() ?? 0.0;
    _checkNotificationPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    /// Uncomment this to enable notifications
    if (state == AppLifecycleState.resumed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkNotificationPermission();
      });
    }
  }
}
