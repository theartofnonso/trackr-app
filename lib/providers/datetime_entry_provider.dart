import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/models/ModelProvider.dart';

class DateTimeEntryProvider extends ChangeNotifier {
  DateTimeEntry? _selectedDateTimeEntry;

  List<DateTimeEntry> _dateTimeEntries = [];

  DateTimeEntry? get selectedDateTimeEntry {
    return _selectedDateTimeEntry?.copyWith();
  }

  List<DateTimeEntry> get dateTimeEntries {
    return [..._dateTimeEntries];
  }

  DateTimeEntryProvider() {
    listDateTimeEntries();
  }

  void onSelectDateEntry({required DateTimeEntry entry}) {
    _selectedDateTimeEntry = entry;
    notifyListeners();
  }

  void listDateTimeEntries() async {
    _dateTimeEntries = await Amplify.DataStore.query(DateTimeEntry.classType, sortBy: [DateTimeEntry.CREATEDAT.ascending()]);
    notifyListeners();
  }

  Future<DateTimeEntry> addDateTimeEntry({required DateTime dateTime}) async {
    final now = TemporalDateTime.fromString("${dateTime.toIso8601String()}z");
    final entryToCreate = DateTimeEntry(createdAt: now);
    await Amplify.DataStore.save(entryToCreate);
    _dateTimeEntries.add(entryToCreate);
    notifyListeners();
    return entryToCreate;
  }

  Future<void> updateDateTimeEntryWithNotes({required DateTimeEntry entry, required String notes}) async {
    final entryToUpdate = _dateTimeEntries.firstWhereOrNull((dateTimeEntry) => dateTimeEntry.id == entry.id);
    if (entryToUpdate != null) {
      final updatedEntry = entryToUpdate.copyWith(description: notes);
      await Amplify.DataStore.save(updatedEntry);
      _dateTimeEntries = _dateTimeEntries
          .map((dateTimeEntry) => dateTimeEntry.id == updatedEntry.id
              ? updatedEntry
              : dateTimeEntry)
          .toList();
    }
  }

  Future<DateTimeEntry> removeDateTimeEntry(
      {required DateTimeEntry entryToRemove}) async {
    await Amplify.DataStore.delete(entryToRemove);
    _dateTimeEntries.removeWhere((entry) => entry.id == entryToRemove.id);
    notifyListeners();
    return entryToRemove;
  }
}
