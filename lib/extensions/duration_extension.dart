
extension DurationExtension on Duration {

  String hmsAnalog() {

    final days = inDays;
    final hours = inHours.remainder(24);
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60);

    if (days > 0) {
      return "${days}d ${hours}h ${minutes}m ${seconds}s";
    } else if (inHours > 0) {
      return "${hours}h ${minutes}m ${seconds}s";
    } else if (inMinutes > 0) {
      return "${minutes}m ${seconds}s";
    } else {
      return "${seconds}s";
    }
  }

  String hmsDigital() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(inHours);
    String minutes = twoDigits(inMinutes.remainder(60));
    String seconds = twoDigits(inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  String hmDigital() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(inHours);
    String minutes = twoDigits(inMinutes.remainder(60));
    return "$hours:$minutes";
  }

  String msDigital() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(inMinutes.remainder(60));
    String seconds = twoDigits(inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

}