import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/utils/datetime_utils.dart';

import '../models/DateTimeEntry.dart';
import '../providers/datetime_entry_provider.dart';

class NotesEditor extends StatelessWidget {
  const NotesEditor({super.key});

  void _autoSaveText(
      {required DateTimeEntryProvider dateTimeEntryProvider,
      required DateTimeEntry dateTimeEntry,
      required BuildContext context,
      required String text}) {
    Future.delayed(const Duration(milliseconds: 500), () {
      dateTimeEntryProvider.updateDateTimeEntryWithNotes(
          entryToUpdate: dateTimeEntry, notes: text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DateTimeEntryProvider>(
        builder: (_, dateTimeEntryProvider, __) {
      final dateTimeEntry = dateTimeEntryProvider.selectedDateTimeEntry;
      return dateTimeEntry != null
          ? TextField(
              cursorColor: Colors.white,
              controller:
                  TextEditingController(text: dateTimeEntry.description),
              maxLines: 5,
              onChanged: (text) {
                _autoSaveText(
                    text: text,
                    context: context,
                    dateTimeEntryProvider: dateTimeEntryProvider,
                    dateTimeEntry: dateTimeEntry);
              },
              textCapitalization: TextCapitalization.sentences,
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.white),
              decoration: InputDecoration(
                enabledBorder:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                focusedBorder:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                filled: true,
                fillColor: const Color.fromRGBO(12, 14, 18, 1),
                // Set
                hintText:
                    "Tap to enter notes for ${dateTimeEntry.createdAt!.getDateTimeInUtc().formattedDayAndMonthAndYear()}",
                hintStyle: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70), // Set
              ),
            )
          : const SizedBox.shrink();
    });
  }
}
