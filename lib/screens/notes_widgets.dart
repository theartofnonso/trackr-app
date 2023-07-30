import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/utils/datetime_utils.dart';

import '../models/DateTimeEntry.dart';
import '../providers/datetime_entry_provider.dart';

class Notes extends StatefulWidget {
  const Notes({super.key});

  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  @override
  Widget build(BuildContext context) {
    return const NotesEditor();
  }
}

class NotesEditor extends StatelessWidget {

  const NotesEditor({super.key});

  void _autoSaveText({required BuildContext context, required DateTimeEntryProvider dateTimeEntryProvider, required DateTimeEntry dateTimeEntry, required String text}) {
    Future.delayed(const Duration(milliseconds: 500), () {
      dateTimeEntryProvider.updateDateTimeEntryWithNotes(entry: dateTimeEntry, notes: text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateTimeEntryProvider = Provider.of<DateTimeEntryProvider>(context, listen: true);
    final dateTimeEntry = dateTimeEntryProvider.dateTimeEntry;
    if(dateTimeEntry != null) {
      return TextField(
        cursorColor: Colors.white,
        controller: TextEditingController(text: dateTimeEntry.description),
        maxLines: 2,
        onChanged: (text) {
          _autoSaveText(text: text, context: context, dateTimeEntryProvider: dateTimeEntryProvider, dateTimeEntry: dateTimeEntry);
        },
        textCapitalization: TextCapitalization.sentences,
        style: GoogleFonts.poppins(
            fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText:
          "Tap to enter notes for ${dateTimeEntry.createdAt!.getDateTimeInUtc().formattedDayAndMonthAndYear()}",
          hintStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white70), // Set
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
