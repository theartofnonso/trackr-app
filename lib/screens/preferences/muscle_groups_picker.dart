import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/utils/string_utils.dart';
import 'package:tracker_app/widgets/buttons/opacity_button_widget.dart';

import '../../controllers/routine_user_controller.dart';

class MuscleGroupsPicker extends StatefulWidget {

  const MuscleGroupsPicker({super.key});

  @override
  State<MuscleGroupsPicker> createState() => _MuscleGroupsPickerState();
}

class _MuscleGroupsPickerState extends State<MuscleGroupsPicker> {
  List<MuscleGroup> _muscleGroups = [];

  void _toggleMuscleGroup(MuscleGroup muscleGroup) {
    setState(() {
      if (_muscleGroups.contains(muscleGroup)) {
        _muscleGroups = _muscleGroups.where((selectedDay) => selectedDay != muscleGroup).toList();
      } else {
        _muscleGroups.add(muscleGroup);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String muscleGroupNames = joinWithAnd(items: _muscleGroups.map((muscleGroup) => muscleGroup.name).toList());

    if (_muscleGroups.length == 7) {
      muscleGroupNames = 'all muscle groups';
    } else {
      muscleGroupNames = muscleGroupNames;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: MuscleGroup.values.map((muscleGroup) {
            return ChoiceChip(
              label: Text(muscleGroup.name,
                  style: GoogleFonts.ubuntu(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _muscleGroups.contains(muscleGroup) ? sapphireDark : Colors.white)),
              backgroundColor: sapphireDark,
              selectedColor: vibrantGreen,
              visualDensity: VisualDensity.compact,
              checkmarkColor: sapphireDark,
              selected: _muscleGroups.contains(muscleGroup),
              side: const BorderSide(color: Colors.transparent),
              onSelected: (_) {
                _toggleMuscleGroup(muscleGroup);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        Center(
          child: OpacityButtonWidget(
              onPressed: _updateMuscleGroups,
              label: "Save selection",
              padding: const EdgeInsets.all(10.0),
              buttonColor: vibrantGreen),
        )
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    final user = Provider.of<RoutineUserController>(context, listen: false).user;
    _muscleGroups = user?.muscleGroups ?? MuscleGroup.values;
  }

  @override
  void dispose() {
    _muscleGroups = [];
    super.dispose();
  }

  void _updateMuscleGroups() async {
    if (_muscleGroups.isNotEmpty) {
        if(mounted) {
          Navigator.of(context).pop(_muscleGroups);
        }
    }
  }
}
