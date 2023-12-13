import 'package:flutter/material.dart';

import '../../../widgets/empty_states/text_empty_state.dart';

class NotesScreen extends StatelessWidget {
  final String notes;

  const NotesScreen({super.key, required this.notes});

  @override
  Widget build(BuildContext context) {
    return notes.isNotEmpty
        ? Padding(padding: const EdgeInsets.only(top: 12, right: 10, bottom: 10, left: 10), child: Text(notes))
        : const Center(child: TextEmptyState(message: "You have no notes"));
  }
}