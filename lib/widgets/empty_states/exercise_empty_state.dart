import 'package:flutter/material.dart';
import 'package:tracker_app/widgets/empty_states/text_empty_state.dart';

class ExerciseEmptyState extends StatelessWidget {
  const ExerciseEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(child: TextEmptyState(message: "Tap the + button to add exercises"))
        ],
      ),
    );
  }
}
