import 'package:tracker_app/extensions/datetime_extension.dart';

class UntrainedMGFNotificationDto {
  final bool show;
  final DateTime dateTime;

  UntrainedMGFNotificationDto({required this.show, required this.dateTime});

  Map<String, dynamic> toJson() {
    return {
      'show': show,
      'dateTime': dateTime.toIso8601String(),
    };
  }

  factory UntrainedMGFNotificationDto.fromJson(Map<String, dynamic> json) {
    final show = json["show"] ?? true;
    final dateTimeString = json["dateTime"];
    final dateTime = dateTimeString != null ? DateTime.parse(dateTimeString).withHourOnly() : DateTime.now().withHourOnly();
    return UntrainedMGFNotificationDto(show: show, dateTime: dateTime);
  }

  @override
  String toString() {
    return 'UntrainedMuscleGroupFamilyNotificationDto{id: $show, dateTime: $dateTime}';
  }
}
