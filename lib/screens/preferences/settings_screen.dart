import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/controllers/activity_log_controller.dart';
import 'package:tracker_app/graphQL/queries.dart';
import 'package:tracker_app/screens/preferences/notifications_screen.dart';
import 'package:tracker_app/screens/preferences/user_profile_screen.dart';
import 'package:tracker_app/shared_prefs.dart';
import 'package:tracker_app/urls.dart';
import 'package:tracker_app/widgets/list_tiles/list_tile_outline.dart';

import '../../controllers/exercise_and_routine_controller.dart';
import '../../controllers/routine_user_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/general_utils.dart';
import '../../utils/uri_utils.dart';
import '../../widgets/backgrounds/trkr_loading_screen.dart';
import '../../widgets/information_containers/information_container_with_background_image.dart';
import '../exercise/library/exercise_library_screen.dart';
import '../intro_screen.dart';

enum WeightUnit {
  kg,
  lbs;

  static WeightUnit fromString(String string) {
    return WeightUnit.values.firstWhere((value) => value.name == string);
  }
}

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings-screen';

  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with WidgetsBindingObserver {
  bool _loading = false;

  late WeightUnit _weightUnitType;

  bool _notificationEnabled = false;

  String _appVersion = "";

  @override
  Widget build(BuildContext context) {

    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    if (_loading) return TRKRLoadingScreen(action: _hideLoadingScreen);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        minimum: EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _openStoreListing,
                child: BackgroundInformationContainer(
                    image: 'images/boy_and_girl.jpg',
                    containerColor: sapphireDark,
                    content: "Loving TRKR? Share the love! Your feedback helps us grow and improve.",
                    textStyle: GoogleFonts.ubuntu(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.9),
                    )),
              ),
              ListTile(
                tileColor: Colors.transparent,
                title: Text("Weight"),
                subtitle: Text("Choose kg or lbs"),
                trailing: SegmentedButton(
                  showSelectedIcon: false,
                  style: ButtonStyle(
                    visualDensity: const VisualDensity(
                        horizontal: VisualDensity.minimumDensity, vertical: VisualDensity.minimumDensity),
                    shape: WidgetStatePropertyAll<OutlinedBorder>(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    )),
                    backgroundColor: WidgetStateProperty.resolveWith<Color>(
                          (Set<WidgetState> states) {
                        if (states.contains(WidgetState.selected)) {

                          return isDarkMode ? Colors.white : Colors.black;
                        }
                        return isDarkMode ? Colors.black : Colors.white;
                      },
                    ),
                    foregroundColor: WidgetStateProperty.resolveWith<Color>(
                          (Set<WidgetState> states) {
                        if (states.contains(WidgetState.selected)) {
                          return isDarkMode ? Colors.black : Colors.white;
                        }
                        return isDarkMode ? Colors.black : Colors.white;
                      },
                    ),
                  ),
                  segments: [
                    ButtonSegment<WeightUnit>(value: WeightUnit.kg, label: Text(WeightUnit.kg.name)),
                    ButtonSegment<WeightUnit>(value: WeightUnit.lbs, label: Text(WeightUnit.lbs.name)),
                  ],
                  selected: <WeightUnit>{_weightUnitType},
                  onSelectionChanged: (Set<WeightUnit> unitType) {
                    setState(() {
                      _weightUnitType = unitType.first;
                    });
                    toggleWeightUnit(unit: _weightUnitType);
                  },
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                tileColor: Colors.transparent,
                activeColor: vibrantGreen,
                title: Text('Show calendar'),
                value: SharedPrefs().showCalendar,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                onChanged: (bool value) {
                  setState(() {
                    SharedPrefs().showCalendar = value;
                    Provider.of<SettingsController>(context, listen: false).notify();
                  });
                },
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                tileColor: Colors.transparent,
                activeColor: vibrantGreen,
                title: Text('Show calendar dates',),
                value: SharedPrefs().showCalendarDates,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                onChanged: (bool value) {
                  setState(() {
                    SharedPrefs().showCalendarDates = value;
                    Provider.of<SettingsController>(context, listen: false).notify();
                  });
                },
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  OutlineListTile(onTap: _navigateToUserProfile, title: "Profile", trailing: "manage profile"),
                ],
              ),
              const SizedBox(height: 8),
              OutlineListTile(onTap: _navigateToExerciseLibrary, title: "Exercises", trailing: "manage exercises"),
              if (Platform.isIOS)
                Column(children: [
                  const SizedBox(height: 8),
                  OutlineListTile(
                      onTap: _navigateToNotificationSettings,
                      title: "Notifications",
                      trailing: _notificationEnabled ? "Enabled" : "Disabled"),
                ]),
              const SizedBox(height: 8),
              OutlineListTile(onTap: _sendFeedback, title: "Feedback", trailing: "Help us improve"),
              const SizedBox(height: 8),
              OutlineListTile(onTap: _visitTRKR, title: "Visit TRKR"),
              const SizedBox(height: 8),
              OutlineListTile(onTap: _navigateTutorialScreen, title: "Tutorial", trailing: "Learn about TRKR"),
              const SizedBox(height: 8),
              OutlineListTile(onTap: _logout, title: "Logout", trailing: SharedPrefs().userEmail),
              const SizedBox(height: 8),
              OutlineListTile(onTap: _delete, title: "Delete Account", trailing: SharedPrefs().userEmail),
              const SizedBox(height: 10),
              Center(
                child: Text(_appVersion,
                    style: GoogleFonts.ubuntu(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToUserProfile() {
    final routineUserController = Provider.of<RoutineUserController>(context, listen: false);
    final user = routineUserController.user;
    if (user != null) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const UserProfileScreen()));
    } else {
      showCreateProfileBottomSheet(context: context);
    }
  }

  void _showLoadingScreen() {
    setState(() {
      _loading = true;
    });
  }

  void _hideLoadingScreen() {
    setState(() {
      _loading = false;
    });
  }

  void _openStoreListing() {
    final InAppReview inAppReview = InAppReview.instance;

    inAppReview.openStoreListing(appStoreId: appStoreId);
  }

  void _sendFeedback() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'hello@trkr.fit', // Replace with the recipient's email
      queryParameters: {
        'subject': 'Feedback for TRKR', // Set the email subject
      },
    );

    await openUrl(url: emailUri.toString(), context: context);
  }

  void _navigateToExerciseLibrary() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ExerciseLibraryScreen(readOnly: true)));
  }

  void _navigateToNotificationSettings() async {
    if (!_notificationEnabled) {
      final isEnabled = await requestNotificationPermission();
      setState(() {
        _notificationEnabled = isEnabled;
      });
      if (!isEnabled) {
        if (mounted) {
          showBottomSheetWithMultiActions(
              context: context,
              title: "Enable notifications?",
              description: "You need to enable notifications to receive reminders.",
              leftAction: Navigator.of(context).pop,
              rightAction: () {},
              leftActionLabel: "Cancel",
              rightActionLabel: "Settings");
        }
      }
    } else {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const NotificationsScreen()));
    }
  }

  void _clearAppData() async {
    Posthog().reset();
    await Amplify.DataStore.clear();
    SharedPrefs().clear();
    await FlutterLocalNotificationsPlugin().cancelAll();
    if (mounted) {
      Provider.of<ExerciseAndRoutineController>(context, listen: false).clear();
      Provider.of<ActivityLogController>(context, listen: false).clear();
      Provider.of<RoutineUserController>(context, listen: false).clear();
    }
  }

  void _visitTRKR() {
    displayBottomSheet(
        context: context,
        child: SafeArea(
          child: Column(children: [
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const FaIcon(FontAwesomeIcons.globe, size: 18),
              horizontalTitleGap: 6,
              title: Text("On the web",
                  style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16)),
              onTap: () {
                Navigator.of(context).pop();
                openUrl(url: trackrWebUrl, context: context);
              },
            ),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const FaIcon(FontAwesomeIcons.instagram, size: 18),
              horizontalTitleGap: 6,
              title: Text("On Instagram",
                  style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16)),
              onTap: () {
                Navigator.of(context).pop();
                openUrl(url: instagramUrl, context: context);
              },
            )
          ]),
        ));
  }

  void _navigateTutorialScreen() {
    context.push(IntroScreen.routeName);
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
          await Amplify.Auth.signOut();
        },
        leftActionLabel: 'Cancel',
        rightActionLabel: 'Logout',
        isRightActionDestructive: true);
  }

  Future<void> _deleteRoutineUser() async {
    final controller = Provider.of<RoutineUserController>(context, listen: false);
    final user = controller.user;
    if (user != null) {
      await controller.removeUser(userDto: user);
    }
  }

  void _delete() async {
    showBottomSheetWithMultiActions(
        context: context,
        title: "Delete account?",
        description: "Are you sure you want to delete your account? This action cannot be undone.",
        leftAction: Navigator.of(context).pop,
        rightAction: () async {
          Navigator.of(context).pop();
          _showLoadingScreen();
          final deletedExercises =
              await batchDeleteUserData(document: deleteUserExerciseData, documentKey: "deleteUserExerciseData");
          final deletedRoutineTemplates = await batchDeleteUserData(
              document: deleteUserRoutineTemplateData, documentKey: "deleteUserRoutineTemplateData");
          final deletedRoutineLogs =
              await batchDeleteUserData(document: deleteUserRoutineLogData, documentKey: "deleteUserRoutineLogData");
          if (deletedExercises && deletedRoutineTemplates && deletedRoutineLogs) {
            await _deleteRoutineUser();
            _hideLoadingScreen();
            _clearAppData();
            await Amplify.Auth.deleteUser();
          } else {
            _hideLoadingScreen();
            if (mounted) {
              showSnackbar(
                  context: context,
                  icon: const Icon(Icons.info_outline_rounded),
                  message: "Something went wrong. Please try again.");
            }
          }
        },
        leftActionLabel: 'Cancel',
        rightActionLabel: 'Delete',
        isRightActionDestructive: true);
  }

  void _checkNotificationPermission() async {
    final result = await checkIosNotificationPermission();
    setState(() {
      _notificationEnabled = result.isEnabled;
    });
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
    _weightUnitType = WeightUnit.fromString(SharedPrefs().weightUnit);
    _checkNotificationPermission();
    _getAppVersion();
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
