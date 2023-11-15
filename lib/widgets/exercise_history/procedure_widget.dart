import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/dtos/procedure_dto.dart';

import '../../enums/exercise_type_enums.dart';
import '../helper_widgets/routine_helper.dart';

class ProcedureWidget extends StatelessWidget {
  final ProcedureDto procedureDto;

  const ProcedureWidget({
    super.key,
    required this.procedureDto,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        procedureDto.notes.isNotEmpty
            ? Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(procedureDto.notes,
              style: GoogleFonts.lato(fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.8), fontSize: 15)),
        )
            : const SizedBox.shrink(),
        ...setsToWidgets(type: ExerciseType.fromString(procedureDto.exercise.type), sets: procedureDto.sets),
      ],
    );
  }
}
