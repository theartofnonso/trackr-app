import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/colors.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker_app/enums/muscle_group_enums.dart';

import '../../dtos/appsync/exercise_dto.dart';

class TrkrCoachExerciseRecommendationScreen extends StatefulWidget {
  static const routeName = '/trkr_coach_exercise_recommendation_screen';

  final List<ExerciseDto> originalExerciseTemplates;
  final List<Map<String, dynamic>> muscleGroupAndExercises;

  const TrkrCoachExerciseRecommendationScreen(
      {super.key, required this.originalExerciseTemplates, required this.muscleGroupAndExercises});

  @override
  State<TrkrCoachExerciseRecommendationScreen> createState() => _TrkrCoachExerciseRecommendationScreenState();
}

class _TrkrCoachExerciseRecommendationScreenState extends State<TrkrCoachExerciseRecommendationScreen> {
  final List<String> _selectedExercises = [];

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
          originalExercises: widget.originalExerciseTemplates,
          isSelected: _selectedExercises.contains((exercises[1] as ExerciseDto).id),
          onSelect: (String selectedExerciseId) {
            if (_selectedExercises.contains(selectedExerciseId)) {
              setState(() {
                _selectedExercises.remove(selectedExerciseId);
              });
            } else {
              setState(() {
                _selectedExercises.add(selectedExerciseId);
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
            _AppBar(positiveAction: _navigateBack, canPerformPositiveAction: _selectedExercises.isNotEmpty),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text("Recommendations are based on the principle that a standard workout session should train each muscle group with at least two exercises. Below are your exercises with a recommended option to pair with.", style: GoogleFonts.ubuntu(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w400)),
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
    context.pop(_selectedExercises);
  }
}

class _RecommendationListItem extends StatelessWidget {
  final List<ExerciseDto> originalExercises;
  final MuscleGroup muscleGroup;
  final ExerciseDto first;
  final ExerciseDto second;
  final String rationale;
  final bool isSelected;
  final Function(String selectedExerciseId) onSelect;

  const _RecommendationListItem({
    required this.muscleGroup,
    required this.first,
    required this.second,
    required this.rationale,
    required this.originalExercises,
    this.isSelected = false,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isFirstSuggested = originalExercises.firstWhereOrNull((exercise) => exercise.id == first.id) == null;
    final isSecondSuggested = originalExercises.firstWhereOrNull((exercise) => exercise.id == second.id) == null;

    final suggestedChip = Padding(
      padding: const EdgeInsets.only(top: 12.0),
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
      onTap: () => onSelect(second.id),
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
                Text("Training ${muscleGroup.name}",
                    style: GoogleFonts.ubuntu(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
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
            Row(
              children: [
                Image.asset(
                  'icons/dumbbells.png',
                  fit: BoxFit.contain,
                  height: 24, // Adjust the height as needed
                ),
                const SizedBox(
                  width: 6,
                ),
                Text(first.name,
                    style: GoogleFonts.ubuntu(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
            isFirstSuggested ? suggestedChip : const SizedBox.shrink(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(
                height: 1,
                color: Colors.white10.withOpacity(0.1),
                endIndent: 24,
                indent: 8,
              ),
            ),
            Row(
              children: [
                Image.asset(
                  'icons/dumbbells.png',
                  fit: BoxFit.contain,
                  height: 24, // Adjust the height as needed
                ),
                const SizedBox(
                  width: 6,
                ),
                Text(second.name,
                    style: GoogleFonts.ubuntu(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
            isSecondSuggested ? suggestedChip : const SizedBox.shrink(),
            const SizedBox(
              height: 16,
            ),
            Text(rationale, style: GoogleFonts.ubuntu(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w400))
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
