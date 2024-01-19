import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/graphQL/queries.dart';
import 'package:tracker_app/screens/notifications_screen.dart';
import 'package:tracker_app/shared_prefs.dart';
import 'package:tracker_app/widgets/list_tiles/list_tile_outline.dart';

import '../controllers/exercise_controller.dart';
import '../controllers/routine_log_controller.dart';
import '../controllers/routine_template_controller.dart';
import '../utils/general_utils.dart';
import '../utils/dialog_utils.dart';
import 'exercise/exercise_library_screen.dart';

enum WeightUnit {
  kg,
  lbs;

  static WeightUnit fromString(String string) {
    return WeightUnit.values.firstWhere((value) => value.name == string);
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with WidgetsBindingObserver {
  bool _loading = false;
  String _loadingMessage = "";

  late WeightUnit _weightUnitType;

  bool _notificationEnabled = false;

  String _appVersion = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(children: [
        SafeArea(
          minimum: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Settings",
                    style: GoogleFonts.montserrat(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                const SizedBox(height: 16),
                ListTile(
                  title: Text("Weight",
                      style: GoogleFonts.montserrat(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                  subtitle: Text("Choose kg or lbs", style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 14)),
                  trailing: SegmentedButton(
                    showSelectedIcon: false,
                    style: ButtonStyle(
                      visualDensity: const VisualDensity(
                          horizontal: VisualDensity.minimumDensity, vertical: VisualDensity.minimumDensity),
                      shape: MaterialStatePropertyAll<OutlinedBorder>(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      )),
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.selected)) {
                            return Colors.white;
                          }
                          return Colors.transparent;
                        },
                      ),
                      foregroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.selected)) {
                            return Colors.black;
                          }
                          return Colors.white;
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
                Theme(
                  data: Theme.of(context).copyWith(
                    splashColor: Colors.transparent // Disable the splash effect
                  ),
                  child: SwitchListTile(
                    activeColor: Colors.green,
                    title: Text('Show calendar dates',
                        style: GoogleFonts.montserrat(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                    value: SharedPrefs().showCalendarDates,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                    onChanged: (bool value) {
                      setState(() {
                        SharedPrefs().showCalendarDates = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 8),
                OutlineListTile(
                    onTap: _navigateToExerciseLibrary, title: "Exercises", trailing: "manage exercises"),
                const SizedBox(height: 8),
                /// Uncomment this to enable notifications
                OutlineListTile(
                    onTap: _navigateToNotificationSettings,
                    title: "Notifications",
                    trailing: _notificationEnabled ? "Enabled" : "Disabled"),
                const SizedBox(height: 8),
                const SizedBox(height: 16),
                OutlineListTile(onTap: _logout, title: "Logout", trailing: SharedPrefs().userEmail),
                const SizedBox(height: 8),
                OutlineListTile(onTap: _delete, title: "Delete Account"),
                const SizedBox(height: 50),
                Center(
                  child: Text(_appVersion,
                      style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
        if (_loading)
          Align(
              alignment: Alignment.center,
              child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: tealBlueDark.withOpacity(0.7),
                  child: Center(child: Text(_loadingMessage, style: GoogleFonts.montserrat(fontSize: 14)))))
      ]),
    );
  }

  void _navigateToExerciseLibrary() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const ExerciseLibraryScreen(
              multiSelect: false,
              readOnly: true,
            )));
  }

  void _navigateToNotificationSettings() async {
    if (!_notificationEnabled) {
      final isEnabled = await requestIosNotificationPermission();
      setState(() {
        _notificationEnabled = isEnabled;
      });
      if (!isEnabled) {
        if (mounted) {
          showAlertDialogWithMultiActions(
              context: context,
              message: "Enable notifications?",
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
    await Amplify.DataStore.clear();
    SharedPrefs().clear();
    FlutterLocalNotificationsPlugin().cancelAll();
    if (context.mounted) {
      Provider.of<RoutineTemplateController>(context, listen: false).clear();
      Provider.of<RoutineLogController>(context, listen: false).clear();
      Provider.of<ExerciseController>(context, listen: false).clear();
    }
  }

  void _logout() async {
    showAlertDialogWithMultiActions(
        context: context,
        message: "Log out?",
        leftAction: Navigator.of(context).pop,
        rightAction: () async {
          _toggleLoadingState(message: "Logging out...");
          Navigator.of(context).pop();
          _clearAppData();
          await Amplify.Auth.signOut();
        },
        leftActionLabel: 'Cancel',
        rightActionLabel: 'Logout',
        isRightActionDestructive: true);
  }

  void _delete() async {
    showAlertDialogWithMultiActions(
        context: context,
        message: "Delete account?",
        leftAction: Navigator.of(context).pop,
        rightAction: () async {
          Navigator.of(context).pop();
          _toggleLoadingState(message: "Deleting account...");
          final deletedExercises =
              await batchDeleteUserData(document: deleteUserExerciseData, documentKey: "deleteUserExerciseData");
          final deletedRoutineTemplates = await batchDeleteUserData(
              document: deleteUserRoutineTemplateData, documentKey: "deleteUserRoutineTemplateData");
          final deletedRoutineLogs =
              await batchDeleteUserData(document: deleteUserRoutineLogData, documentKey: "deleteUserRoutineLogData");
          if (deletedExercises && deletedRoutineTemplates && deletedRoutineLogs) {
            _toggleLoadingState();
            _clearAppData();
            await Amplify.Auth.deleteUser();
          } else {
            _toggleLoadingState();
            if (context.mounted) {
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

  void _toggleLoadingState({String message = ""}) {
    setState(() {
      _loading = !_loading;
      _loadingMessage = message;
    });
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
