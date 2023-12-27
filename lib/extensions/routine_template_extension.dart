import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:tracker_app/models/ModelProvider.dart';

extension RoutineExtension on RoutineTemplate {

  RoutineLog log() {
    return RoutineLog(
        user: user,
        name: name,
        exerciseLogs: exercises,
        notes: notes,
        template: this,
        startTime: TemporalDateTime.now(),
        endTime: TemporalDateTime.now(),
        createdAt: TemporalDateTime.now(),
        updatedAt: TemporalDateTime.now());
  }

}