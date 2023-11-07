import 'package:tracker_app/models/ModelProvider.dart';
import 'package:tracker_app/utils/datetime_utils.dart';

extension RoutineLogExtension on RoutineLog {

  String durationInString() {
    final startTime = this.startTime.getDateTimeInUtc();
    final endTime = this.endTime.getDateTimeInUtc();
    final difference = endTime.difference(startTime);
    return difference.secondsOrMinutesOrHours();
  }

}