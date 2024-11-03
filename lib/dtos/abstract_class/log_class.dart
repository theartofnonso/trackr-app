
import 'package:tracker_app/enums/activity_type_enums.dart';

enum LogType {
  routine, activity
}

abstract class Log {
  String get id;
  String get name;
  String get notes;
  DateTime get startTime;
  DateTime get endTime;
  DateTime get createdAt;
  DateTime get updatedAt;
  LogType get logType;
  ActivityType get activityType;

  Duration duration() {
    return endTime.difference(startTime);
  }

  Log copyWith();

}