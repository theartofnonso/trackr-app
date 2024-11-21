import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/colors.dart';

import '../../../../dtos/abstract_class/exercise_dto.dart';
import '../../../buttons/opacity_button_widget.dart';
import '../../../empty_states/list_tile_empty_state.dart';

class SubstituteExercisePicker extends StatefulWidget {
  final String title;
  final List<ExerciseDTO> exercises;
  final void Function(ExerciseDTO exericse) onSelect;
  final void Function(ExerciseDTO exericse) onRemove;
  final void Function() onSelectExercisesInLibrary;

  const SubstituteExercisePicker(
      {super.key,
      required this.title,
      required this.exercises,
      required this.onSelect,
      required this.onRemove,
      required this.onSelectExercisesInLibrary});

  @override
  State<SubstituteExercisePicker> createState() => _SubstituteExercisePickerState();
}

class _SubstituteExercisePickerState extends State<SubstituteExercisePicker> {
  List<ExerciseDTO> _exercises = [];

  void _onRemoveExercises({required ExerciseDTO exercise}) {
    setState(() {
      _exercises.removeWhere((exerciseToBeRemoved) => exerciseToBeRemoved.name == exercise.name);
    });
    widget.onRemove(exercise);
  }

  @override
  Widget build(BuildContext context) {
    final listTiles = widget.exercises
        .map((exercise) => ListTile(
              onTap: () {
                widget.onSelect(exercise);
              },
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(exercise.name,
                  style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15)),
              trailing: GestureDetector(
                  onTap: () => _onRemoveExercises(exercise: exercise),
                  child: FaIcon(FontAwesomeIcons.squareXmark, color: Colors.redAccent, size: 22)),
            ))
        .toList();

    return widget.exercises.isNotEmpty || _exercises.isNotEmpty
        ? SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 10),
                  child: Text(widget.title,
                      textAlign: TextAlign.start,
                      style: GoogleFonts.ubuntu(color: Colors.white70, fontWeight: FontWeight.w500, fontSize: 15)),
                ),
                ...listTiles,
                const SizedBox(height: 12),
                Center(
                  child: OpacityButtonWidget(
                      onPressed: widget.onSelectExercisesInLibrary,
                      label: "Add substitute exercises",
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      buttonColor: vibrantGreen),
                )
              ],
            ),
          )
        : _EmptyState(onPressed: widget.onSelectExercisesInLibrary);
  }

  @override
  void initState() {
    super.initState();
    _exercises = widget.exercises;
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onPressed;

  const _EmptyState({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.only(left: 18.0),
          child: ListTileEmptyState(),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.only(left: 18.0),
          child: ListTileEmptyState(),
        ),
        const SizedBox(height: 24),
        Center(
          child: OpacityButtonWidget(
              onPressed: onPressed,
              label: "Add substitute exercises",
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              buttonColor: vibrantGreen),
        )
      ],
    );
  }
}
