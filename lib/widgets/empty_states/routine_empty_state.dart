import 'package:flutter/material.dart';
import 'package:tracker_app/widgets/empty_states/text_empty_state.dart';

class RoutineEmptyState extends StatelessWidget {

  final String message;

  const RoutineEmptyState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [Center(child: TextEmptyState(message: message))],
      ),
    );
  }
}
