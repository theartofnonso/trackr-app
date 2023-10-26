
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:tracker_app/models/Routine.dart';
import '../dtos/procedure_dto.dart';
import '../dtos/routine_dto.dart';

class RoutineProvider with ChangeNotifier {
  List<RoutineDto> _routineDtos = [];

  UnmodifiableListView<RoutineDto> get routines => UnmodifiableListView(_routineDtos);

  void listRoutines(BuildContext context) async {
    final routines = await Amplify.DataStore.query(Routine.classType, sortBy: [QuerySortBy(order: QuerySortOrder.descending, field: Routine.CREATEDAT.fieldName)]);
    if(routines.isNotEmpty) {
      _routineDtos = routines.map((routine) => routine.toRoutineDto(context)).toList();
      notifyListeners();
    }
  }

  void saveRoutine({required BuildContext context, required String name, required String notes, required List<ProcedureDto> procedures}) async {
    final proceduresJson = procedures.map((procedure) => procedure.toJson()).toList();
    final routineToSave = Routine(name: name, procedures: proceduresJson, notes: notes, createdAt: TemporalDateTime.now(), updatedAt: TemporalDateTime.now());
    await Amplify.DataStore.save<Routine>(routineToSave);
   if(context.mounted) {
     _routineDtos.add(routineToSave.toRoutineDto(context));
   }
    notifyListeners();
  }


  void updateRoutine({required RoutineDto dto}) async{
    final routine = dto.toRoutine();
    await Amplify.DataStore.save<Routine>(routine);
    final index = _indexWhereRoutine(id: dto.id);
    _routineDtos[index] = dto;
    notifyListeners();
  }

  void removeRoutine({required String id}) async {
    final index = _indexWhereRoutine(id: id);
    final dtoToBeRemoved = _routineDtos.removeAt(index);
    await Amplify.DataStore.delete<Routine>(dtoToBeRemoved.toRoutine());
    notifyListeners();
  }

  int _indexWhereRoutine({required String id}) {
    return _routineDtos.indexWhere((routine) => routine.id == id);
  }

  RoutineDto? whereRoutineDto({required String id}) {
    return _routineDtos.firstWhereOrNull((dto) => dto.id == id);
  }
}
