import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/models/ModelProvider.dart';
import 'package:tracker_app/utils/datetime_utils.dart';

class DateTimeEntryProvider extends ChangeNotifier {
  DateTimeEntry? _selectedDateTimeEntry;
  DateTime _selectedDate = DateTime.now();

  List<DateTimeEntry> _dateTimeEntries = [];

  DateTimeEntry? get selectedDateTimeEntry {
    return _selectedDateTimeEntry?.copyWith();
  }

  DateTime get selectedDateTime {
    return _selectedDate.copyWith();
  }

  List<DateTimeEntry> get dateTimeEntries {
    return [..._dateTimeEntries];
  }

  DateTimeEntryProvider() {
    listDateTimeEntries();
  }

  void onSelectDateEntry({required DateTimeEntry? entry}) {
    _selectedDateTimeEntry = entry;
    notifyListeners();
  }

  void onSelectDate({required DateTime date}) {
    _selectedDate = date;
    notifyListeners();
  }

  void onRemoveDateEntry() {
    _selectedDateTimeEntry = null;
    notifyListeners();
  }

  void _selectToday() {
    _selectedDateTimeEntry = _dateTimeEntries.firstWhereOrNull((dateTimeEntry) {
      final date = dateTimeEntry.createdAt;
      if(date != null) {
        if(date.getDateTimeInUtc().isNow()) {
          return true;
        }
      }
      return false;
    });
  }

  void listDateTimeEntries() async {
    _dateTimeEntries = await Amplify.DataStore.query(DateTimeEntry.classType,
        sortBy: [DateTimeEntry.CREATEDAT.ascending()]);
    _selectToday();
    notifyListeners();
  }

  Future<DateTimeEntry> addDateTimeEntry({required DateTime dateTime}) async {
    final now = TemporalDateTime.fromString("${dateTime.toIso8601String()}z");
    final entryToCreate = DateTimeEntry(createdAt: now);
    await Amplify.DataStore.save(entryToCreate);
    _dateTimeEntries.add(entryToCreate);
    _selectedDateTimeEntry = entryToCreate;
    _selectedDate = dateTime;
    notifyListeners();
    return entryToCreate;
  }

  Future<void> updateDateTimeEntryWithNotes(
      {required DateTimeEntry entryToUpdate, required String notes}) async {
    final updatedEntry = entryToUpdate.copyWith(description: notes);
    await Amplify.DataStore.save(updatedEntry);
    _dateTimeEntries = _dateTimeEntries
        .map((dateTimeEntry) =>
            dateTimeEntry.id == updatedEntry.id ? updatedEntry : dateTimeEntry)
        .toList();
  }

  Future<DateTimeEntry> removeDateTimeEntry(
      {required DateTimeEntry entryToRemove}) async {
    await Amplify.DataStore.delete(entryToRemove);
    _dateTimeEntries.removeWhere((entry) => entry.id == entryToRemove.id);
    _selectedDateTimeEntry = null;
    _selectedDate = entryToRemove.createdAt!.getDateTimeInUtc();
    notifyListeners();
    return entryToRemove;
  }
}
