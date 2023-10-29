import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/shared_prefs.dart';

import '../providers/weight_unit_provider.dart';

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
                  ButtonSegment<WeightUnit>(value: WeightUnit.kg, label: Text(WeightUnit.kg.name)),
                  ButtonSegment<WeightUnit>(value: WeightUnit.lbs, label: Text(WeightUnit.lbs.name)),
                ],
                selected: <WeightUnit>{_unit},
                onSelectionChanged: (Set<WeightUnit> unitType) {
                  setState(() {
                    SharedPrefs().weightUnit = unitType.first.name;
                    _unit = unitType.first;
                  });
                  Provider.of<WeightUnitProvider>(context, listen: false).toggleUnit();
                },
              ),
            ),
          ],
        ),
      ),
    );
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
