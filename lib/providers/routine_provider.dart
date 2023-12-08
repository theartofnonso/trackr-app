import 'dart:convert';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/models/Routine.dart';
import '../dtos/exercise_log_dto.dart';
import '../shared_prefs.dart';
import '../utils/general_utils.dart';

const emptyRoutineId = "empty_routine_id";

class RoutineProvider with ChangeNotifier {
  List<Routine> _routines = [];

  UnmodifiableListView<Routine> get routines => UnmodifiableListView(_routines);

  List<Routine> _cachedPendingRoutines = [];

  List<Routine> get cachedPendingRoutines => _cachedPendingRoutines;

  void clearCachedPendingRoutines() {
    _cachedPendingRoutines = [];
    SharedPrefs().cachedPendingRoutines = [];
    notifyListeners();
  }

  void listRoutines() async {
    final routineOwner = user();
    final request = ModelQueries.list(Routine.classType, where: Routine.USER.eq(routineOwner.id));
    final response = await Amplify.API.query(request: request).response;
    final routines = response.data?.items;
    if (routines != null) {
      _routines = routines.whereType<Routine>().toList();
      _routines.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();
    }
  }

  Map<String, dynamic> _fixJson(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    json.update("user", (value) {
      return {"serializedData": value};
    });
    return json;
  }

  void retrieveCachedPendingRoutines(BuildContext context) {
    final cachedRoutines = SharedPrefs().cachedPendingRoutines;
    if (cachedRoutines.isNotEmpty) {
      _cachedPendingRoutines = cachedRoutines.map((log) {
        final json = _fixJson(log);
        return Routine.fromJson(json);
      }).toList();
    }
  }

  Future<void> saveRoutine({required String name, required String notes, required List<ExerciseLogDto> procedures}) async {

    final proceduresJson = procedures.map((procedure) => procedure.toJson()).toList();
    final routineToCreate = Routine(
        name: name,
        procedures: proceduresJson,
        notes: notes,
        createdAt: TemporalDateTime.now(),
        updatedAt: TemporalDateTime.now(), user: user());
    final request = ModelMutations.create(routineToCreate);
    final response = await Amplify.API.mutate(request: request).response;
    final createdRoutine = response.data;
    if (createdRoutine != null) {
      _routines.insert(0, routineToCreate);
      _routines.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();
    }
  }

  Future<void> updateRoutine({required Routine routine}) async {

    try {
      final request = ModelMutations.update(routine);
      final response = await Amplify.API.mutate(request: request).response;
      final updatedRoutine = response.data;
      if (updatedRoutine != null) {
        final index = _indexWhereRoutine(id: routine.id);
        _routines[index] = routine;
        notifyListeners();
      }
    } catch (_) {
      _cachePendingRoutines(routine);
    }
  }

  void _cachePendingRoutines(Routine pendingRoutine) {
    _cachedPendingRoutines.add(pendingRoutine);
    final pendingRoutines = SharedPrefs().cachedPendingRoutines;
    final json = jsonEncode(pendingRoutine);
    pendingRoutines.add(json);
    SharedPrefs().cachedPendingRoutines = pendingRoutines;
    notifyListeners();
  }

  void retryPendingRoutines(BuildContext context) async {
    final cachedPendingRoutines = SharedPrefs().cachedPendingRoutines;
    for (int index = 0; index < _cachedPendingRoutines.length; index++) {
      final pendingRoutine = _cachedPendingRoutines[index];
      final request = ModelMutations.update(pendingRoutine);
      final response = await Amplify.API.mutate(request: request).response;
      final updatedRoutine = response.data;
      if (updatedRoutine != null) {
        /// Remove from caches i.e both [_cachedPendingRoutines] and [SharedPrefs().cachedPendingRoutines]
        _cachedPendingRoutines.removeAt(index);
        cachedPendingRoutines.removeAt(index);
        SharedPrefs().cachedPendingRoutines = cachedPendingRoutines;

        /// Update to routines
        final routineIndex = _indexWhereRoutine(id: updatedRoutine.id);
        _routines[routineIndex] = updatedRoutine;
        notifyListeners();
      }
    }
  }

  Future<void> removeRoutine({required String id}) async {
    final index = _indexWhereRoutine(id: id);
    final routineToBeRemoved = _routines[index];
    final request = ModelMutations.delete(routineToBeRemoved);
    final response = await Amplify.API.mutate(request: request).response;
    final deletedRoutine = response.data;
    if (deletedRoutine != null) {
      _routines.removeAt(index);
      notifyListeners();
    }
  }

  int _indexWhereRoutine({required String id}) {
    return _routines.indexWhere((routine) => routine.id == id);
  }

  Routine? routineWhere({required String id}) {
    return _routines.firstWhereOrNull((dto) => dto.id == id);
  }

  void reset() {
    _routines.clear();
    notifyListeners();
  }
}
