import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/models/Routine.dart';
import '../dtos/procedure_dto.dart';
import '../models/RoutineLog.dart';
import '../utils/general_utils.dart';

const emptyRoutineId = "empty_routine_id";

class RoutineProvider with ChangeNotifier {
  List<Routine> _routines = [];

  UnmodifiableListView<Routine> get routines => UnmodifiableListView(_routines);

  void listRoutines(BuildContext context) async {

    final request = ModelQueries.list(Routine.classType);
    final response = await Amplify.API.query(request: request).response;

    final routines = response.data?.items;
    if (routines != null) {
      _routines = routines.whereType<Routine>().whereNot((routine) => routine.name.isEmpty).toList();
      _routines.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();
    }
  }

  void saveRoutine({required String name, required String notes, required List<ProcedureDto> procedures}) async {

    final routineOwner = await user();

    final proceduresJson = procedures.map((procedure) => procedure.toJson()).toList();
    final routineToCreate = Routine(
        name: name,
        procedures: proceduresJson,
        notes: notes,
        createdAt: TemporalDateTime.now(),
        updatedAt: TemporalDateTime.now(), user: routineOwner);
    final request = ModelMutations.create(routineToCreate);
    final response = await Amplify.API.mutate(request: request).response;
    final createdRoutine = response.data;
    if (createdRoutine != null) {
      _routines.insert(0, routineToCreate);
      _routines.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();
    }
  }

  void updateRoutine({required Routine routine}) async {
    final request = ModelMutations.update(routine);
    final response = await Amplify.API.mutate(request: request).response;
    final updatedRoutine = response.data;
    if (updatedRoutine != null) {
      final index = _indexWhereRoutine(id: routine.id);
      _routines[index] = routine;
      notifyListeners();
    }
  }

  void removeRoutine({required String id}) async {
    final index = _indexWhereRoutine(id: id);
    final routineToBeRemoved = _routines.removeAt(index);
    final request = ModelMutations.delete(routineToBeRemoved);
    final response = await Amplify.API.mutate(request: request).response;
    final deletedRoutine = response.data;
    if (deletedRoutine != null) {
      notifyListeners();
    }
  }

  int _indexWhereRoutine({required String id}) {
    return _routines.indexWhere((routine) => routine.id == id);
  }

  Routine? routineWhere({required String id}) {
    return _routines.firstWhereOrNull((dto) => dto.id == id);
  }

  Future<List<RoutineLog>> routinesLogsWhere({required String id}) async {
    final logs = await Amplify.DataStore.query(
      RoutineLog.classType,
      where: RoutineLog.ROUTINE.eq(id),
    );
    return logs;
  }
}
