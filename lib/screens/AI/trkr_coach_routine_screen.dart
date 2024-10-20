
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import '../../dtos/exercise_dto.dart';

class TRKRCoachRoutineScreen extends StatelessWidget {
  static const routeName = '/trkr_coach_routine_screen';

  final List<Map<String, dynamic>> muscleGroupAndExercises;

  const TRKRCoachRoutineScreen({super.key, required this.muscleGroupAndExercises});

  @override
  Widget build(BuildContext context) {

    final children = muscleGroupAndExercises.map((muscleGroupAndExercises) {
      final muscleGroup = muscleGroupAndExercises["muscle_group"];
      final exercises = muscleGroupAndExercises["exercises"];
      final rationale = muscleGroupAndExercises["rationale"];
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: _RecommendationListItem(muscleGroup: muscleGroup, first: exercises[0], second: exercises[1], rationale: rationale),
      );
    });

    return Scaffold(
        body: Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        gradient: SweepGradient(
          colors: [Colors.green.shade900, Colors.blue.shade900],
          stops: const [0, 1],
          center: Alignment.topRight,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AppBar(positiveAction: Navigator.of(context).pop, canPerformPositiveAction: true),
              Column(children: [...children])
            ],
          ),
        ),
      ),
    ));
  }

}

class _RecommendationListItem extends StatelessWidget {

  final MuscleGroup muscleGroup;
  final ExerciseDto first;
  final ExerciseDto second;
  final String rationale;

  const _RecommendationListItem({
    required this.muscleGroup, required this.first, required this.second, required this.rationale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white10.withOpacity(0.1),
        border: Border.all(color: Colors.white38, width: 0.5,),
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(muscleGroup.name.toUpperCase(),
              style:
              GoogleFonts.ubuntu(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16,),
          Row(
            children: [
              Image.asset(
                'icons/dumbbells.png',
                fit: BoxFit.contain,
                height: 24, // Adjust the height as needed
              ),
              const SizedBox(width: 6,),
              Text(first.name,
                  style:
                  GoogleFonts.ubuntu(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600))
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(height: 1, color: Colors.white10.withOpacity(0.1), endIndent: 20, indent: 8,),
          ),
          Row(
            children: [
              Image.asset(
                'icons/dumbbells.png',
                fit: BoxFit.contain,
                height: 24, // Adjust the height as needed
              ),
              const SizedBox(width: 6,),
              Text(second.name,
                  style:
                  GoogleFonts.ubuntu(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600))
            ],
          ),
          const SizedBox(height: 16,),
          Text(rationale,
              style:
              GoogleFonts.ubuntu(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w400))
        ],
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  final VoidCallback positiveAction;
  final bool canPerformPositiveAction;

  const _AppBar({required this.positiveAction, this.canPerformPositiveAction = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.xmark, color: Colors.white, size: 28),
          onPressed: Navigator.of(context).pop,
        ),
        Expanded(
          child: Text("TRKR Coach".toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
        ),
        canPerformPositiveAction
            ? IconButton(
                icon: const FaIcon(FontAwesomeIcons.check, color: Colors.white, size: 28),
                onPressed: positiveAction,
              )
            : const IconButton(
                icon: SizedBox.shrink(),
                onPressed: null,
              )
      ],
    );
  }
}
