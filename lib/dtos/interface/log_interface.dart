
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
  LogType get type;

  Duration duration() {
    return endTime.difference(startTime);
  }

  Map<String, dynamic> toJson();

  Log copyWith();

}