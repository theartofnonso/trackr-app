import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/dtos/exercise_variant_dto.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';
import 'package:tracker_app/widgets/dividers/label_container.dart';

import '../../dtos/exercises/exercise_dto.dart';

class TRKRCoachExerciseRecommendationScreen extends StatefulWidget {
  static const routeName = '/trkr_coach_exercise_recommendation_screen';

  final List<ExerciseVariantDTO> originalExerciseVariants;
  final List<Map<String, dynamic>> muscleGroupAndExercises;

  const TRKRCoachExerciseRecommendationScreen(
      {super.key, required this.originalExerciseVariants, required this.muscleGroupAndExercises});

  @override
  State<TRKRCoachExerciseRecommendationScreen> createState() => _TRKRCoachExerciseRecommendationScreenState();
}

class _TRKRCoachExerciseRecommendationScreenState extends State<TRKRCoachExerciseRecommendationScreen> {
  final List<String> _selectedExerciseNames = [];

  @override
  Widget build(BuildContext context) {
    final children = widget.muscleGroupAndExercises.map((muscleGroupAndExercises) {
      final muscleGroup = muscleGroupAndExercises["muscle_group"];
      final exercises = muscleGroupAndExercises["exercises"];
      final rationale = muscleGroupAndExercises["rationale"];

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: _RecommendationListItem(
          muscleGroup: muscleGroup,
          first: exercises[0],
          second: exercises[1],
          rationale: rationale,
          originalExerciseVariants: widget.originalExerciseVariants,
          isSelected: _selectedExerciseNames.contains((exercises[1] as ExerciseDTO).name),
          onSelect: (String selectedExerciseName) {
            if (_selectedExerciseNames.contains(selectedExerciseName)) {
              setState(() {
                _selectedExerciseNames.remove(selectedExerciseName);
              });
            } else {
              setState(() {
                _selectedExerciseNames.add(selectedExerciseName);
              });
            }
          },
        ),
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
        child: Column(
          children: [
            _AppBar(positiveAction: _navigateBack, canPerformPositiveAction: _selectedExerciseNames.isNotEmpty),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                  "Recommendations are based on the principle that a standard workout session should train each muscle group with at least two exercises. Below are your exercises with a recommended option to pair with.",
                  style: GoogleFonts.ubuntu(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w400)),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [...children],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  void _navigateBack() {
    context.pop(_selectedExerciseNames);
  }
}

class _RecommendationListItem extends StatelessWidget {
  final List<ExerciseVariantDTO> originalExerciseVariants;
  final MuscleGroup muscleGroup;
  final ExerciseVariantDTO first;
  final ExerciseVariantDTO second;
  final String rationale;
  final bool isSelected;
  final Function(String selectedExerciseId) onSelect;

  const _RecommendationListItem({
    required this.muscleGroup,
    required this.first,
    required this.second,
    required this.rationale,
    required this.originalExerciseVariants,
    this.isSelected = false,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final originalChip = Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Container(
          padding: const EdgeInsets.all(6.0),
          decoration: BoxDecoration(
            color: Colors.white10.withOpacity(0.1),
            borderRadius: BorderRadius.circular(3.0),
          ),
          child: Text("Yours".toUpperCase(),
              style: GoogleFonts.ubuntu(color: vibrantGreen, fontSize: 9, fontWeight: FontWeight.w700))),
    );

    final suggestedChip = Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Container(
          padding: const EdgeInsets.all(6.0),
          decoration: BoxDecoration(
            color: Colors.white10.withOpacity(0.1),
            borderRadius: BorderRadius.circular(3.0),
          ),
          child: Text("Recommended".toUpperCase(),
              style: GoogleFonts.ubuntu(color: vibrantGreen, fontSize: 9, fontWeight: FontWeight.w700))),
    );

    return GestureDetector(
      onTap: () => onSelect(second.name),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white10.withOpacity(0.1),
          border: Border.all(
            color: Colors.white38,
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text("Training ${muscleGroup.name}".toUpperCase(),
                    style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(
                  height: 16,
                ),
                const Spacer(),
                FaIcon(
                  isSelected ? FontAwesomeIcons.solidSquareCheck : FontAwesomeIcons.solidSquareCheck,
                  color: isSelected ? vibrantGreen : Colors.white70.withOpacity(0.3),
                  size: 30,
                ),
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            Text(first.name,
                style: GoogleFonts.ubuntu(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w400)),
            originalChip,
            const SizedBox(
              height: 18,
            ),
            Text(second.name,
                style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400)),
            suggestedChip,
            const SizedBox(
              height: 18,
            ),
            LabelContainer(
              label: "Explanation".toUpperCase(),
              description: rationale,
              labelStyle: GoogleFonts.ubuntu(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
              descriptionStyle: GoogleFonts.ubuntu(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w400),
              dividerColor: Colors.white30,
            ),
          ],
        ),
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
          icon: const FaIcon(FontAwesomeIcons.squareXmark, color: Colors.white, size: 28),
          onPressed: Navigator.of(context).pop,
        ),
        Expanded(
          child: Text("TRKR Coach".toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
        ),
        canPerformPositiveAction
            ? IconButton(
                icon: const FaIcon(FontAwesomeIcons.solidSquareCheck, color: Colors.white, size: 28),
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
