import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/shared_prefs.dart';
import 'package:tracker_app/widgets/buttons/text_button_widget.dart';

import '../providers/settings_provider.dart';
import '../widgets/helper_widgets/dialog_helper.dart';
import 'exercise/exercise_library_screen.dart';

enum WeightUnit { kg, lbs }

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  WeightUnit _unit = WeightUnit.kg;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            ListTile(
              dense: true,
              title: const Text("Weight Unit Type",),
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
                selected: <WeightUnit>{_unit},
                onSelectionChanged: (Set<WeightUnit> unitType) {
                  setState(() {
                    _unit = unitType.first;
                  });
                  Provider.of<SettingsProvider>(context, listen: false).toggleUnit(unit: _unit);
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
            CTextButton(onPressed: _logout, label: "Logout")
          ],
        ),
      ),
    );
  }

  void _navigateToExerciseLibrary() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ExerciseLibraryScreen()));
  }

  void _logout() async {
    final alertDialogActions = <Widget>[
      TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text('Cancel', style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      CTextButton(
          onPressed: () async {
            Navigator.pop(context);
            await Amplify.Auth.signOut();
          },
          label: 'Logout'),
    ];
    showAlertDialog(context: context, message: "Log out?", actions: alertDialogActions);
  }

  WeightUnit _weightUnit(String unit) {
    return unit == WeightUnit.kg.name ? WeightUnit.kg : WeightUnit.lbs;
  }

  @override
  void initState() {
    super.initState();
    final previousValue = SharedPrefs().weightUnit;
    _unit = SharedPrefs().weightUnit.isNotEmpty ? _weightUnit(previousValue) : WeightUnit.kg;
  }
}
