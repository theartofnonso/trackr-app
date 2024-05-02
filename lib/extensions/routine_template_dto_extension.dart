import 'package:tracker_app/enums/routine_schedule_type_enums.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';

import '../dtos/routine_template_dto.dart';
import '../enums/week_days_enum.dart';

extension RoutineTemplateDtoExtension on RoutineTemplateDto {

  bool isScheduledToday() {

    if(scheduleType == RoutineScheduleType.days) {

      // Get the current day of the week as a `DayOfWeek` enum
      DayOfWeek today = DayOfWeek.fromDateTime(DateTime.now());

      // Check if the list of days contains the current day
      return scheduledDays.contains(today);
    }

    if(scheduleType == RoutineScheduleType.intervals) {

      return scheduledDate?.isSameDayMonthAndYear(DateTime.now()) ?? false;
    }

    return false;
  }
}
