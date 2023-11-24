import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/dtos/procedure_dto.dart';
import 'package:tracker_app/enums/exercise_type_enums.dart';
import '../../../screens/exercise/history/home_screen.dart';
import '../../../utils/general_utils.dart';
import '../../helper_widgets/routine_helper.dart';
import '../preview/set_headers/duration_distance_set_header.dart';
import '../preview/set_headers/duration_set_header.dart';
import '../preview/set_headers/reps_set_header.dart';
import '../preview/set_headers/weighted_set_header.dart';

class ProcedureWidget extends StatelessWidget {
  final ProcedureDto procedureDto;
  final ProcedureDto? otherSuperSetProcedureDto;
  final bool readOnly;

  const ProcedureWidget({
    super.key,
    required this.procedureDto,
    required this.otherSuperSetProcedureDto,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final otherProcedureDto = otherSuperSetProcedureDto;

    final exerciseString = procedureDto.exercise.type;
    final exerciseType = ExerciseType.fromString(exerciseString);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Theme(
          data: ThemeData(splashColor: tealBlueLight),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            onTap: () {
              if (!readOnly) {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => HomeScreen(exercise: procedureDto.exercise)));
              }
            },
            title: Text(procedureDto.exercise.name, style: Theme.of(context).textTheme.labelLarge),
            subtitle: otherProcedureDto != null
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Text("with ${procedureDto.exercise.name}",
                            style: GoogleFonts.lato(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w600)),
                      )
                    : null,
          ),
        ),
        procedureDto.notes.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(procedureDto.notes,
                    style: GoogleFonts.lato(color: Colors.white.withOpacity(0.8), fontSize: 15)),
              )
            : const SizedBox.shrink(),
        switch (exerciseType) {
          ExerciseType.weightAndReps => WeightedSetHeader(firstLabel: weightLabel().toUpperCase(), secondLabel: 'REPS',),
          ExerciseType.weightedBodyWeight => WeightedSetHeader(firstLabel: "+${weightLabel().toUpperCase()}", secondLabel: 'REPS',),
          ExerciseType.assistedBodyWeight => WeightedSetHeader(firstLabel: '-${weightLabel().toUpperCase()}', secondLabel: 'REPS',),
          ExerciseType.weightAndDistance => WeightedSetHeader(firstLabel: weightLabel().toUpperCase(), secondLabel: distanceTitle(type: ExerciseType.weightAndDistance)),
          ExerciseType.bodyWeightAndReps => const RepsSetHeader(),
          ExerciseType.duration => const DurationSetHeader(),
          ExerciseType.durationAndDistance => const DurationDistanceSetHeader(),
        },
        const SizedBox(height: 8),
        ...setsToWidgets(type: ExerciseType.fromString(procedureDto.exercise.type), sets: procedureDto.sets),
      ],
    );
  }
}
