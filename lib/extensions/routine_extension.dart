import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:tracker_app/models/ModelProvider.dart';

extension RoutineExtension on Routine {

  RoutineLog log() {
    return RoutineLog(
        user: user,
        name: name,
        procedures: procedures,
        notes: notes,
        routine: this,
        startTime: TemporalDateTime.now(),
        endTime: TemporalDateTime.now(),
        createdAt: TemporalDateTime.now(),
        updatedAt: TemporalDateTime.now());
  }

}