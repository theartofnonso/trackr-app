import 'package:tracker_app/enums/routine_schedule_type_enums.dart';

import '../../dtos/appsync/routine_template_dto.dart';
import '../../enums/week_days_enum.dart';

extension RoutineTemplateDtoExtension on RoutineTemplateDto {

  bool isScheduledToday() {

    if(scheduleType == RoutineScheduleType.days) {

      // Get the current day of the week as a `DayOfWeek` enum
      DayOfWeek today = DayOfWeek.fromDateTime(DateTime.now());

      // Check if the list of days contains the current day
      return scheduledDays.contains(today);
    }

    return false;
  }
}
