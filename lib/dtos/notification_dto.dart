import 'package:tracker_app/extensions/datetime_extension.dart';

class NotificationDto {
  final bool show;
  final DateTime dateTime;

  NotificationDto({required this.show, required this.dateTime});

  Map<String, dynamic> toJson() {
    return {
      'show': show,
      'dateTime': dateTime.toIso8601String(),
    };
  }

  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    final show = json["show"] ?? true;
    final dateTimeString = json["dateTime"];
    final dateTime = dateTimeString != null ? DateTime.parse(dateTimeString).withHourOnly() : DateTime.now().withHourOnly();
    return NotificationDto(show: show, dateTime: dateTime);
  }

  @override
  String toString() {
    return 'NotificationDto{id: $show, dateTime: $dateTime}';
  }
}
