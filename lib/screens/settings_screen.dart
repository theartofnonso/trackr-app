import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/graphQL/queries.dart';
import 'package:tracker_app/screens/notifications_screen.dart';
import 'package:tracker_app/shared_prefs.dart';
import 'package:tracker_app/widgets/list_tiles/list_tile_outline.dart';

import '../providers/app_provider.dart';
import '../utils/general_utils.dart';
import '../widgets/helper_widgets/dialog_helper.dart';
import 'exercise/exercise_library_screen.dart';

enum WeightUnit {
  kg,
  lbs;

  static WeightUnit fromString(String string) {
    return WeightUnit.values.firstWhere((value) => value.name == string);
  }
}

enum DistanceUnit {
  mi,
  km;

  static DistanceUnit fromString(String string) {
    return DistanceUnit.values.firstWhere((value) => value.name == string);
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _loading = false;
  String _loadingMessage = "";

  late WeightUnit _weightUnitType;
  late DistanceUnit _distanceUnitType;

  bool _notificationEnabled = false;

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
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text("Weight",
                      style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                  subtitle:
                      Text("Choose kg or lbs", style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 14)),
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
                const SizedBox(height: 2),
                ListTile(
                  title: Text("Distance",
                      style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                  subtitle: Text("Choose kilometres or miles",
                      style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 14)),
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
                      ButtonSegment<DistanceUnit>(value: DistanceUnit.mi, label: Text(DistanceUnit.mi.name)),
                      ButtonSegment<DistanceUnit>(value: DistanceUnit.km, label: Text(DistanceUnit.km.name)),
                    ],
                    selected: <DistanceUnit>{_distanceUnitType},
                    onSelectionChanged: (Set<DistanceUnit> unitType) {
                      setState(() {
                        _distanceUnitType = unitType.first;
                      });
                      toggleDistanceUnit(unit: _distanceUnitType);
                    },
                  ),
                ),
                const SizedBox(height: 8),
                OutlineListTile(
                    onTap: _navigateToExerciseLibrary, title: "Exercises", trailing: "Add favourites exercises"),
                const SizedBox(height: 8),
                OutlineListTile(
                    onTap: _navigateToNotificationSettings,
                    title: "Notifications",
                    trailing: _notificationEnabled ? "Enabled" : "Disabled"),
                const SizedBox(height: 8),
                const SizedBox(height: 16),
                OutlineListTile(onTap: _logout, title: "Logout", trailing: SharedPrefs().userEmail),
                const SizedBox(height: 8),
                OutlineListTile(onTap: _delete, title: "Delete Account"),
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
    } else {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const NotificationsScreen()));
    }
  }

  void _clearAppData() async {
    await Amplify.DataStore.clear();
    SharedPrefs().clear();
    if (context.mounted) {
      AppProviders.resetProviders(context);
    }
  }

  void _logout() async {
    showAlertDialogWithMultiActions(
        context: context,
        message: "Log out?",
        leftAction: Navigator.of(context).pop,
        rightAction: () async {
          _toggleLoadingState(message: "Signing out...");
          Navigator.of(context).pop();
          _clearAppData();
          await Amplify.Auth.signOut();
        },
        leftActionLabel: 'Cancel',
        rightActionLabel: 'Sign out',
        isRightActionDestructive: true);
  }

  void _delete() async {
    showAlertDialogWithMultiActions(
        context: context,
        message: "Request Deletion?",
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

  @override
  void initState() {
    super.initState();
    _weightUnitType = WeightUnit.fromString(SharedPrefs().weightUnit);
    _distanceUnitType = DistanceUnit.fromString(SharedPrefs().distanceUnit);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkNotificationPermission();
    });
  }
}
