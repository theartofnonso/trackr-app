import 'package:tracker_app/extensions/datetime_extension.dart';

class NotificationDto {
  final DateTime dateTime;

  NotificationDto({required this.dateTime});

  Map<String, dynamic> toJson() {
    return {
      'dateTime': dateTime.toIso8601String(),
    };
  }

  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    final dateTimeString = json["dateTime"];
    final historicDateTime = DateTime.now().withHourOnly();
    final dateTime = dateTimeString != null ? DateTime.parse(dateTimeString).withHourOnly() : historicDateTime;
    return NotificationDto(dateTime: dateTime);
  }

  @override
  String toString() {
    return 'NotificationDto{dateTime: $dateTime}';
  }
}
