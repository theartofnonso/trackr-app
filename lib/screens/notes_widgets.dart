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
    return Consumer<DateTimeEntryProvider>(
      builder: (_, dateTimeEntryProvider, __) {
        final dateEntry = dateTimeEntryProvider.dateTimeEntry;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const Row(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   children: [
              //     InkWell(
              //       splashColor: Colors.transparent,
              //       child: Icon(
              //         Icons.edit_note_rounded,
              //         color: Colors.black,
              //       ),
              //     ),
              //   ],
              // ),

              NotesEditor(
                dateTimeEntry: dateEntry,
              )
            ],
          ),
        );
      },
    );
  }
}

class NotesEditor extends StatefulWidget {
  final DateTimeEntry? dateTimeEntry;

  const NotesEditor({super.key, this.dateTimeEntry});

  @override
  State<NotesEditor> createState() => _NotesEditorState();
}

class _NotesEditorState extends State<NotesEditor> {

  late TextEditingController _notesController;
  String tempNotes;

  @override
  void initState() {
    super.initState();
    _notesController =
        TextEditingController(text: widget.dateTimeEntry?.description ?? "");
  }

  @override
  Widget build(BuildContext context) {
    final dateEntry = widget.dateTimeEntry;
    if (dateEntry != null) {
      final notes = dateEntry.description ?? "";
      if (notes.isNotEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Notes for ${DateTime.now().formattedDate()}",
              style: GoogleFonts.poppins(
                decoration: TextDecoration.underline,
                  fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              notes,
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black),
            ),
          ],
        );
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              cursorColor: Colors.black,
              controller: _notesController,
              onChanged: (text) {

              },
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              style: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black),
              decoration: InputDecoration(
                hintText: "Tap to add notes",
                hintStyle: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey), // Set
              ),
            ),
            _notesController.text.isNotEmpty ? InkWell(
              onTap: () {  },
              splashColor: Colors.grey,
              child: Text("Save", style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Colors.black)),
            ) : const SizedBox.shrink(),
          ],
        );
      }
    }

    return const SizedBox.shrink();
  }
}
