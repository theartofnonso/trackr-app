import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:tracker_app/models/Routine.dart';
import '../dtos/procedure_dto.dart';
import '../models/RoutineLog.dart';

const emptyRoutineId = "empty_routine_id";

class RoutineProvider with ChangeNotifier {
  List<Routine> _routines = [];

  UnmodifiableListView<Routine> get routines => UnmodifiableListView(_routines);

  void listRoutines(BuildContext context) async {
    final routines = await Amplify.DataStore.query(Routine.classType,
        sortBy: [QuerySortBy(order: QuerySortOrder.descending, field: Routine.CREATEDAT.fieldName)]);
    if (routines.isNotEmpty) {
      _routines = routines.map((routine) => routine).where((routine) => routine.name.isNotEmpty).toList();
      notifyListeners();
    }
  }

  Future<Routine> createEmptyRoutine() async {
    final routineToSave = Routine(
        name: "", procedures: [], notes: "", createdAt: TemporalDateTime.now(), updatedAt: TemporalDateTime.now());
    await Amplify.DataStore.save<Routine>(routineToSave);
    return routineToSave;
  }

  void saveRoutine({required String name, required String notes, required List<ProcedureDto> procedures}) async {
    final proceduresJson = procedures.map((procedure) => procedure.toJson()).toList();
    final routineToSave = Routine(
        name: name,
        procedures: proceduresJson,
        notes: notes,
        createdAt: TemporalDateTime.now(),
        updatedAt: TemporalDateTime.now());
    await Amplify.DataStore.save<Routine>(routineToSave);
    _routines.insert(0, routineToSave);
    notifyListeners();
  }

  void updateRoutine({required Routine routine}) async {
    await Amplify.DataStore.save<Routine>(routine);
    final index = _indexWhereRoutine(id: routine.id);
    _routines[index] = routine;
    notifyListeners();
  }

  void removeRoutine({required String id}) async {
    final index = _indexWhereRoutine(id: id);
    final dtoToBeRemoved = _routines.removeAt(index);
    await Amplify.DataStore.delete<Routine>(dtoToBeRemoved);
    notifyListeners();
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
