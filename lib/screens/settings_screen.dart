import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/shared_prefs.dart';
import 'package:tracker_app/widgets/buttons/text_button_widget.dart';

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
  late WeightUnit _weightUnitType;
  late DistanceUnit _distanceUnitType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              ListTile(
                dense: true,
                title: const Text(
                  "Weight",
                ),
                subtitle: Text("Choose kg or lbs", style: GoogleFonts.lato(color: Colors.white70)),
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
              ListTile(
                dense: true,
                title: const Text(
                  "Distance",
                ),
                subtitle: Text("Choose kilometres or miles", style: GoogleFonts.lato(color: Colors.white70)),
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
              Theme(
                data: ThemeData(splashColor: tealBlueLight),
                child: ListTile(
                    onTap: _navigateToExerciseLibrary,
                    dense: true,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                    title: Text("Exercises", style: Theme.of(context).textTheme.labelLarge),
                    subtitle: Text("Add your favourites exercises",
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white70))),
              ),
              const Spacer(),
              CTextButton(onPressed: _logout, label: "Logout - ${user().email}", padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),)
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToExerciseLibrary() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const ExerciseLibraryScreen(
              multiSelect: false,
              readOnly: true,
            )));
  }

  void _logout() async {
    showAlertDialog(context: context,
        message: "Log out?",
        leftAction: Navigator.of(context).pop,
        rightAction: () async {
          Navigator.of(context).pop();
          SharedPrefs().clear();
          AppProviders.resetProviders(context);
          await Amplify.Auth.signOut();
        },
        leftActionLabel: 'Cancel',
        rightActionLabel: 'Logout', isRightActionDestructive: true);
  }

  @override
  void initState() {
    super.initState();
    _weightUnitType = WeightUnit.fromString(SharedPrefs().weightUnit);
    _distanceUnitType = DistanceUnit.fromString(SharedPrefs().distanceUnit);
  }
}
