import 'package:tracker_app/dtos/logs.dart';

import '../dtos/routine_log_dto.dart';

extension MutableLogs on Logs {

  Logs saveLog({required RoutineLogDto logToBeAdded}) {
    final copy = List<RoutineLogDto>.from(routineLogs);
    copy.add(logToBeAdded);
    return Logs(copy);
  }

  Logs removeLog({required RoutineLogDto logToBeRemoved}) {
    final copy = List<RoutineLogDto>.from(routineLogs);
    copy.removeWhere((log) => log.id == logToBeRemoved.id);
    return Logs(copy);
  }

  Logs updateLog({required RoutineLogDto logToBeUpdated}) {
    final copy = List<RoutineLogDto>.from(routineLogs);
    final index = copy.indexWhere((log) => log.id == logToBeUpdated.id);
    copy[index] = logToBeUpdated;
    return Logs(copy);
  }

}
