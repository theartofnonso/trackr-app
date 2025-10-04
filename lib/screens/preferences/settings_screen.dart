import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/screens/request_screens/notifications_request.dart';
import 'package:tracker_app/screens/auth/auth_screen.dart';
import 'package:tracker_app/services/supabase_service.dart';
import 'package:tracker_app/services/sync_service.dart';
import 'package:tracker_app/shared_prefs.dart';

import '../../controllers/exercise_and_routine_controller.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/general_utils.dart';
import '../../utils/navigation_utils.dart';
import '../../utils/uri_utils.dart';
import '../../widgets/backgrounds/trkr_loading_screen.dart';
import '../../widgets/dividers/label_divider.dart';

enum WeightUnit {
  kg("kg"),
  lbs("lbs");

  const WeightUnit(this.display);

  final String display;

  static WeightUnit fromString(String string) {
    return WeightUnit.values.firstWhere((value) => value.name == string);
  }
}

enum HeightUnit {
  ftIn("ft"),
  cm("cm");

  const HeightUnit(this.display);

  final String display;

  static HeightUnit fromString(String string) {
    return HeightUnit.values.firstWhere((value) => value.name == string);
  }
}

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings-screen';

  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  bool _loading = false;
  bool _isAuthenticated = false;

  late WeightUnit _weightUnit;

  String _appVersion = "";

  bool _notificationEnabled = false;

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    if (_loading) return TRKRLoadingScreen(action: _hideLoadingScreen);

    // Get email from Supabase if authenticated, otherwise fallback to SharedPrefs
    final supabaseEmail = SupabaseService.instance.currentUserEmail;
    final userEmail = supabaseEmail ??
        (SharedPrefs().userEmail.isNotEmpty
            ? SharedPrefs().userEmail
            : "Not signed in");

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? darkBackground : Colors.white,
            ),
            child: SafeArea(
              minimum: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (Platform.isIOS)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Settings",
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                        height: 0.9,
                                      ),
                                ),
                                Text(
                                  "& Account",
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                        height: 0.9,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Manage your settings here",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        color: isDarkMode
                                            ? Colors.white70
                                            : Colors.black54,
                                        fontWeight: FontWeight.w400,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  LabelDivider(
                                    label: "Notifications",
                                    labelColor: isDarkMode
                                        ? darkOnSurface
                                        : Colors.black,
                                    dividerColor: isDarkMode
                                        ? darkDivider
                                        : Colors.grey.shade300,
                                    fontSize: 14,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                      "Allow us to remind you about long-running workouts if you’ve become distracted. We’ll also send reminders on your training days.",
                                      textAlign: TextAlign.start,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.w400,
                                              color: isDarkMode
                                                  ? darkOnSurfaceVariant
                                                  : Colors.black)),
                                ]),
                          ),
                          ListTile(
                            onTap: _turnOnNotification,
                            dense: true,
                            horizontalTitleGap: 0,
                            leading: Text(
                                _notificationEnabled
                                    ? "Notification is on"
                                    : "Turn on notifications",
                                textAlign: TextAlign.start,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: isDarkMode
                                            ? darkOnSurface
                                            : Colors.black)),
                            trailing: FaIcon(
                              FontAwesomeIcons.solidBell,
                              size: 14,
                            ),
                          ),
                        ],
                      ),
                    ListTile(
                      tileColor: Colors.transparent,
                      title: Text("Weight",
                          style: Theme.of(context).textTheme.titleMedium),
                      subtitle: Text("Choose kg or lbs"),
                      trailing: CupertinoSlidingSegmentedControl<WeightUnit>(
                        backgroundColor: isDarkMode
                            ? darkSurfaceVariant
                            : Colors.grey.shade400,
                        thumbColor:
                            isDarkMode ? darkSurfaceContainer : Colors.white,
                        groupValue: _weightUnit,
                        children: {
                          WeightUnit.kg: SizedBox(
                              width: 30,
                              child: Text(WeightUnit.kg.display,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.center)),
                          WeightUnit.lbs: SizedBox(
                              width: 30,
                              child: Text(WeightUnit.lbs.display,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.center)),
                        },
                        onValueChanged: (WeightUnit? value) {
                          if (value != null) {
                            setState(() {
                              _weightUnit = value;
                            });
                            toggleWeightUnit(unit: value);
                          }
                        },
                      ),
                    ),
                    ListTile(
                        onTap: _sendFeedback,
                        leading: FaIcon(FontAwesomeIcons.solidPaperPlane,
                            color: isDarkMode
                                ? darkOnSurfaceVariant
                                : Colors.black38),
                        title: Text("Feedback",
                            style: Theme.of(context).textTheme.titleMedium),
                        subtitle: Text("help us improve")),
                    ListTile(
                        onTap: _handleAuthAction,
                        leading: FaIcon(
                            _isAuthenticated
                                ? FontAwesomeIcons.arrowRightFromBracket
                                : FontAwesomeIcons.cloudArrowUp,
                            color: isDarkMode
                                ? darkOnSurfaceVariant
                                : Colors.black38),
                        title: Text(
                            _isAuthenticated ? "Logout" : "Sign in to sync",
                            style: Theme.of(context).textTheme.titleMedium),
                        subtitle: Text(_isAuthenticated
                            ? userEmail
                            : "Sync your workouts to the cloud")),
                    // Sync button (only shown when authenticated)
                    if (_isAuthenticated)
                      ListTile(
                          onTap: _syncData,
                          leading: FaIcon(FontAwesomeIcons.arrowsRotate,
                              color: isDarkMode
                                  ? darkOnSurfaceVariant
                                  : Colors.black38),
                          title: Text("Sync now",
                              style: Theme.of(context).textTheme.titleMedium),
                          subtitle: Text("Sync your workouts to the cloud")),
                    ListTile(
                        onTap: _delete,
                        leading: FaIcon(FontAwesomeIcons.xmark,
                            color: isDarkMode
                                ? darkOnSurfaceVariant
                                : Colors.black38),
                        title: Text("Delete Account",
                            style: Theme.of(context).textTheme.titleMedium),
                        subtitle: Text(userEmail)),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(_appVersion,
                          style: Theme.of(context).textTheme.bodySmall),
                    ),
                  ],
                ),
              ),
            ),
            // Overlay close button
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode
                    ? darkSurface.withValues(alpha: 0.9)
                    : Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.squareXmark,
                  size: 20,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLoadingScreen() {
    setState(() {
      _loading = true;
    });
  }

  void _hideLoadingScreen() {
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  void _sendFeedback() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'nonso@ware.health', // Replace with the recipient's email
      queryParameters: {
        'subject': 'Feedback for Trainer', // Set the email subject
      },
    );

    await openUrl(url: emailUri.toString(), context: context);
  }

  void _clearAppData() async {
    Posthog().reset();
    SharedPrefs().clear();
    await FlutterLocalNotificationsPlugin().cancelAll();
    if (mounted) {
      Provider.of<ExerciseAndRoutineController>(context, listen: false).clear();
    }
  }

  void _turnOnNotification() async {
    if (!_notificationEnabled) {
      await navigateWithSlideTransition(
          context: context,
          child: NotificationsRequestScreen(onRequest: () {
            requestNotificationPermission().then((status) {
              setState(() {
                _notificationEnabled = status;
              });
              if (mounted) {
                context.pop();
              }
            });
          }));
    }
  }

  void _checkNotificationPermission() async {
    final result = await checkIosNotificationPermission();
    setState(() {
      _notificationEnabled = result.isEnabled;
    });
  }

  void _checkAuthStatus() {
    setState(() {
      _isAuthenticated = SupabaseService.instance.isAuthenticated;
    });
  }

  void _handleAuthAction() async {
    if (_isAuthenticated) {
      _logout();
    } else {
      _showSignInPrompt();
    }
  }

  void _showSignInPrompt() {
    showBottomSheetWithMultiActions(
        context: context,
        title: "Sign in to sync?",
        description:
            "Sign in with your email to sync your workouts to the cloud and access them from any device.",
        leftAction: Navigator.of(context).pop,
        rightAction: () async {
          Navigator.of(context).pop();
          // Navigate to auth screen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AuthScreen(
                onAuthSuccess: () {
                  // Refresh auth status when user signs in
                  _checkAuthStatus();
                },
              ),
            ),
          );
        },
        leftActionLabel: 'Not now',
        rightActionLabel: 'Sign in',
        isRightActionDestructive: false);
  }

  void _syncData() async {
    _showLoadingScreen();
    try {
      await SyncService.instance.syncAll();
      _hideLoadingScreen();
      if (mounted) {
        showSnackbar(
          context: context,
          message: "Workouts synced successfully!",
        );
      }
    } catch (e) {
      _hideLoadingScreen();
      if (mounted) {
        showSnackbar(
          context: context,
          message: "Sync failed: ${e.toString()}",
        );
      }
    }
  }

  void _logout() async {
    showBottomSheetWithMultiActions(
        context: context,
        title: "Log out?",
        description: "Are you sure you want to log out?",
        leftAction: Navigator.of(context).pop,
        rightAction: () async {
          Navigator.of(context).pop();
          _showLoadingScreen();
          _clearAppData();
          if (mounted) {
            context.go('/'); // Replace '/welcome' with your initial route
          }
        },
        leftActionLabel: 'Cancel',
        rightActionLabel: 'Logout',
        isRightActionDestructive: true);
  }

  void _delete() async {
    // Check if user is authenticated
    if (!SupabaseService.instance.isAuthenticated) {
      showSnackbar(
        context: context,
        message: "No account to delete. You are not signed in.",
      );
      return;
    }

    final userEmail = SupabaseService.instance.currentUserEmail ?? "Unknown";

    showBottomSheetWithMultiActions(
        context: context,
        title: "Delete account?",
        description:
            "Are you sure you want to delete your account ($userEmail)? This action cannot be undone and will permanently remove all your data.",
        leftAction: Navigator.of(context).pop,
        rightAction: () async {
          Navigator.of(context).pop();
          _showLoadingScreen();

          try {
            // Delete the user account from Supabase
            await SupabaseService.instance.deleteUserAccount();

            _hideLoadingScreen();
            _clearAppData();

            if (mounted) {
              showSnackbar(
                context: context,
                message: "Account deleted successfully",
              );
              context.go('/');
            }
          } catch (e) {
            _hideLoadingScreen();
            if (mounted) {
              showSnackbar(
                context: context,
                message: "Failed to delete account: ${e.toString()}",
              );
            }
          }
        },
        leftActionLabel: 'Cancel',
        rightActionLabel: 'Delete',
        isRightActionDestructive: true);
  }

  void _getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final version = packageInfo.version;
    final buildNumber = packageInfo.buildNumber;
    setState(() {
      _appVersion = "APP VERSION: $version (BUILD $buildNumber)";
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _weightUnit = WeightUnit.fromString(SharedPrefs().weightUnit);
    _getAppVersion();
    _checkNotificationPermission();
    _checkAuthStatus();
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
