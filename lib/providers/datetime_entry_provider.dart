import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/models/ModelProvider.dart';

class DateTimeEntryProvider extends ChangeNotifier {
  List<DateTimeEntry> _dateTimeEntries = [];

  List<DateTimeEntry> get dateTimeEntries {
    return [..._dateTimeEntries];
  }

  void listDateTimeEntries() async {
    _dateTimeEntries = [
      DateTimeEntry(
          createdAt: TemporalDateTime.fromString(
              "${DateTime.now().subtract(const Duration(days: 1)).toIso8601String()}z")),
      DateTimeEntry(
          createdAt: TemporalDateTime.fromString(
              "${DateTime.now().subtract(const Duration(days: 2)).toIso8601String()}z")),
      DateTimeEntry(
          createdAt: TemporalDateTime.fromString(
              "${DateTime.now().subtract(const Duration(days: 1)).toIso8601String()}z")),
      DateTimeEntry(
          createdAt: TemporalDateTime.fromString(
              "${DateTime.now().subtract(const Duration(days: 5)).toIso8601String()}z")),
      DateTimeEntry(
          createdAt: TemporalDateTime.fromString(
              "${DateTime.now().subtract(const Duration(days: 8)).toIso8601String()}z"))
    ];
    //_dateTimeEntries = await Amplify.DataStore.query(DateTimeEntry.classType);
    notifyListeners();
  }

  Future<DateTimeEntry> addActivity() async {
    final entryToCreate = DateTimeEntry();
    await Amplify.DataStore.save(entryToCreate);
    _dateTimeEntries.add(entryToCreate);
    notifyListeners();
    return entryToCreate;
  }

  Future<DateTimeEntry> removeActivity({required DateTimeEntry entry}) async {
    await Amplify.DataStore.delete(entry);
    _dateTimeEntries.removeWhere((entry) => entry.id == entry.id);
    notifyListeners();
    return entry;
  }
}
