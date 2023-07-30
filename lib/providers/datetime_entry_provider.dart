import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/models/ModelProvider.dart';

class DateTimeEntryProvider extends ChangeNotifier {

  DateTimeEntry? _dateTimeEntry;

  List<DateTimeEntry> _dateTimeEntries = [];

  DateTimeEntry? get dateTimeEntry {
    return _dateTimeEntry?.copyWith();
  }

  List<DateTimeEntry> get dateTimeEntries {
    return [..._dateTimeEntries];
  }

  DateTimeEntryProvider() {
    listDateTimeEntries();
  }

  void onSelectDateEntry({required DateTimeEntry entry}) {
    _dateTimeEntry = entry;
  }

  void listDateTimeEntries() async {
    _dateTimeEntries = await Amplify.DataStore.query(DateTimeEntry.classType);
    _dateTimeEntries.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
    if(_dateTimeEntries.isNotEmpty) {
      _dateTimeEntry = _dateTimeEntries.first;
    }
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

  Future<DateTimeEntry> removeDateTimeEntry({required DateTimeEntry entryToRemove}) async {
    await Amplify.DataStore.delete(entryToRemove);
    _dateTimeEntries.removeWhere((entry) => entry.id == entryToRemove.id);
    notifyListeners();
    return entryToRemove;
  }
}
