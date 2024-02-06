import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../enums/muscle_group_enums.dart';

class MuscleGroupsFrequencyInsights extends StatelessWidget {
  final Map<MuscleGroupFamily, int> muscleGroupSplitFrequency;

  const MuscleGroupsFrequencyInsights({super.key, required this.muscleGroupSplitFrequency});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
              onPressed: Navigator.of(context).pop),
        ),
        body: SafeArea(
            minimum: const EdgeInsets.all(10.0),
            child: Column(children: [const SizedBox(height: 20)])));
  }
}
