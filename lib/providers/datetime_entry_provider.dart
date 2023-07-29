import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/models/ModelProvider.dart';

class DateTimeEntryProvider extends ChangeNotifier {
  List<DateTimeEntry> _dateTimeEntries = [];

  List<DateTimeEntry> get dateTimeEntries {
    return [..._dateTimeEntries];
  }

  DateTimeEntryProvider() {
    listDateTimeEntries();
  }

  void listDateTimeEntries() async {
    _dateTimeEntries = await Amplify.DataStore.query(DateTimeEntry.classType);
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

  Future<DateTimeEntry> removeDateTimeEntry({required DateTimeEntry entry}) async {
    await Amplify.DataStore.delete(entry);
    _dateTimeEntries.removeWhere((entry) => entry.id == entry.id);
    notifyListeners();
    return entry;
  }
}
