

enum DurationType {
  seconds("Seconds", "Secs"),
  minutes("Minutes", "Mins"),
  hours("Hours", "Hrs");

  const DurationType(this.longName, this.shortName);

  final String longName;
  final String shortName;
}

extension DurationExtension on Duration {
  String _absoluteDuration(duration) {
    final durationInNum = duration > 59 ? (duration % 60) : duration;
    return durationInNum.toString().padLeft(2, "0");
  }

  String secondsOrMinutesOrHours() {
    String display;
    final remainingSeconds = inSeconds.remainder(60);
    final remainingMinutes = inMinutes.remainder(60);
    final remainingHours = inHours.remainder(24);
    if (inHours > 24) {
      if(remainingHours > 0 && remainingMinutes > 0 && remainingSeconds > 0) {
        display = "${inDays}d ${remainingHours}h ${remainingMinutes}m ${remainingSeconds}s";
      } else if(remainingHours > 0 && remainingMinutes > 0 && remainingSeconds <= 0) {
        display = "${inDays}d ${inHours}h ${remainingMinutes}m";
      } else if(remainingHours > 0 && remainingMinutes <= 0 && remainingSeconds <= 0) {
        display = "${inDays}d ${inHours}h";
      }  else {
        display = "${inHours}h";
      }
    } else if (inMinutes > 59) {
      if(remainingMinutes > 0 && remainingSeconds > 0) {
        display = "${inHours}h ${remainingMinutes}m ${remainingSeconds}s";
      } else if(remainingMinutes > 0 && remainingSeconds <= 0) {
        display = "${inHours}h ${remainingMinutes}m";
      }  else {
        display = "${inHours}h";
      }
    } else if (inSeconds > 59) {
      display = remainingSeconds > 0 ? "${inMinutes}m ${remainingSeconds}s" : "${inMinutes}m";
    } else {
      display = "${inSeconds}s";
    }
    return display;
  }

  String digitalTimeHMS() {
    return "${inHours.toString().padLeft(2, "0")}:${_absoluteDuration(inMinutes)}:${_absoluteDuration(inSeconds)}";
  }

  String digitalTimeHM() {
    return "${inHours.toString().padLeft(2, "0")}:${_absoluteDuration(inMinutes)}";
  }

  String digitalTimeMS() {
    return "${_absoluteDuration(inMinutes)}:${_absoluteDuration(inSeconds)}";
  }

}