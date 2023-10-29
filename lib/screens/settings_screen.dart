import 'package:flutter/material.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/shared_prefs.dart';

enum WeightUnitType { kg, lbs }

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  WeightUnitType _weightUnitType = WeightUnitType.kg;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: tealBlueDark,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Weight Unit Type",),
              subtitle: const Text("Choose kg or lbs", style: TextStyle(color: Colors.white70)),
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
                  ButtonSegment<WeightUnitType>(value: WeightUnitType.kg, label: Text(WeightUnitType.kg.name)),
                  ButtonSegment<WeightUnitType>(value: WeightUnitType.lbs, label: Text(WeightUnitType.lbs.name)),
                ],
                selected: <WeightUnitType>{_weightUnitType},
                onSelectionChanged: (Set<WeightUnitType> unitType) {
                  setState(() {
                    SharedPrefs().weightUnitType = unitType.first.name;
                    _weightUnitType = unitType.first;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  WeightUnitType _unitType(String unitType) {
    return unitType == WeightUnitType.kg.name ? WeightUnitType.kg : WeightUnitType.lbs;
  }

  @override
  void initState() {
    super.initState();
    final previousValue = SharedPrefs().weightUnitType;
    _weightUnitType = SharedPrefs().weightUnitType.isNotEmpty ? _unitType(previousValue) : WeightUnitType.kg;
  }
}
