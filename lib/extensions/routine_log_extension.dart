import 'package:tracker_app/models/ModelProvider.dart';

extension RoutineLogExtension on RoutineLog {

  Duration duration() {
    final startTime = this.startTime.getDateTimeInUtc();
    final endTime = this.endTime.getDateTimeInUtc();
    return endTime.difference(startTime);
  }

}