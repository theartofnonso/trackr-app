import 'package:intl/intl.dart';

/// Get datetime format
String formattedDay({required DateTime dateTime}) {
  return DateFormat("dd", "en").format(dateTime);
}

/// Get datetime format
String formattedMonth({required DateTime dateTime}) {
  return DateFormat("MMM", "en").format(dateTime);
}

/// Get datetime format
String formattedDate({required DateTime dateTime}) {
  return DateFormat("EE dd, MMM", "en").format(dateTime);
}

/// Get datetime format
String formattedTime({required DateTime dateTime}) {
  return DateFormat("Hm", "en").format(dateTime);
}

extension DurationExtension on Duration{

  String friendlyTime() {
    return "$inHours hrs  $inMinutes mins  ${inSeconds > 59 ? (inSeconds % 60) : inSeconds} secs";
  }

}