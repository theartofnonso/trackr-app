import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/screens/exercise/muscle_groups_screen.dart';

class MuscleGroupWidget extends StatelessWidget {
  final MuscleGroupDto muscleGroupDto;
  final void Function() onTap;

  const MuscleGroupWidget({super.key, required this.muscleGroupDto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        splashColor: Colors.transparent,
      ),
      child: ListTile(
        onTap: onTap,
        dense: true,
        title: Text(muscleGroupDto.muscleGroup.name,
            style: GoogleFonts.ubuntu(
                color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
        trailing: muscleGroupDto.selected
            ? const Icon(Icons.check_box_rounded, color: vibrantGreen)
            : const Icon(Icons.check_box_rounded, color: sapphireDark),
      ),
    );
  }
}
