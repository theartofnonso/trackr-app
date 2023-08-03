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
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: NotesTitle(isVisible: dateTimeEntry.description != null, message: "Notes for ${dateTimeEntry.createdAt!.getDateTimeInUtc().formattedDayAndMonthAndYear()}",),
                ),
                TextField(
                  textInputAction: TextInputAction.done,
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
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5)),
                    hintText:
                        "Tap to enter notes for ${dateTimeEntry.createdAt!.getDateTimeInUtc().formattedDayAndMonthAndYear()}",
                    hintStyle: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.white70), // Set
                  ),
                ),
              ],
            )
          : const SizedBox.shrink();
    });
  }
}

class NotesTitle extends StatelessWidget {
  final bool isVisible;
  final String message;
  const NotesTitle({
    super.key, required this.isVisible, required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return isVisible ? Text(
      message,
      style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey),
    ) : const SizedBox.shrink();
  }
}
