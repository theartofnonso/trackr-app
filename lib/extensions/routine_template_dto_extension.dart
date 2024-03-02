import '../dtos/routine_template_dto.dart';
import '../enums/week_days_enum.dart';

extension RoutineTemplateDtoExtension on RoutineTemplateDto {

  bool isScheduledToday() {
    // Get the current day of the week as a `DayOfWeek` enum
    DayOfWeek today = DayOfWeek.fromDateTime(DateTime.now());

    // Check if the list of days contains the current day
    return days.contains(today);
  }
}
