import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/dtos/appsync/routine_template_dto.dart';
import 'package:tracker_app/enums/week_days_enum.dart';
import 'package:tracker_app/extensions/week_days_extension.dart';
import 'package:tracker_app/utils/string_utils.dart';
import 'package:tracker_app/widgets/buttons/opacity_button_widget.dart';

import '../../controllers/exercise_and_routine_controller.dart';
import '../../enums/routine_schedule_type_enums.dart';

class RoutineDayPlanner extends StatefulWidget {
  static const routeName = "/routine-schedule-planner";

  final RoutineTemplateDto template;

  const RoutineDayPlanner({super.key, required this.template});

  @override
  State<RoutineDayPlanner> createState() => _RoutineDayPlannerState();
}

class _RoutineDayPlannerState extends State<RoutineDayPlanner> {
  List<DayOfWeek> _selectedDays = [];

  void _toggleDay(DayOfWeek day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays = _selectedDays.where((selectedDay) => selectedDay != day).toList();
      } else {
        _selectedDays.add(day);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String days = joinWithAnd(items: _selectedDays.map((day) => day.shortName).toList());

    if (_selectedDays.length == 7) {
      days = 'everyday';
    } else {
      days = "on $days";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _selectedDays.isNotEmpty
            ? RichText(
                text: TextSpan(
                  text: 'Train ${widget.template.name} ',
                  style: Theme.of(context).textTheme.titleMedium,
                  children: [
                    TextSpan(
                      text: days,
                      style: Theme.of(context).textTheme.titleMedium,
                    )
                  ],
                ),
              )
            : Text('Select days to train ${widget.template.name}', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: DayOfWeek.values.map((day) {
            return ChoiceChip(
              label: Text(day.longName,
                  style: GoogleFonts.ubuntu(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _selectedDays.contains(day) ? sapphireDark : Colors.white)),
              backgroundColor: sapphireDark,
              selectedColor: vibrantGreen,
              visualDensity: VisualDensity.compact,
              checkmarkColor: sapphireDark,
              selected: _selectedDays.contains(day),
              side: const BorderSide(color: Colors.transparent),
              onSelected: (_) {
                _toggleDay(day);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        Center(
          child: OpacityButtonWidget(
              onPressed: _updateRoutineTemplateDays,
              label: "Schedule Days",
              padding: const EdgeInsets.all(10.0),
              buttonColor: vibrantGreen),
        )
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _selectedDays = widget.template.scheduledDays;
  }

  void _updateRoutineTemplateDays() async {
    _selectedDays.sort((a, b) => a.index.compareTo(b.index));
    final template = widget.template
        .copyWith(scheduledDays: _selectedDays, scheduleType: RoutineScheduleType.days, scheduledDate: null);
    await Provider.of<ExerciseAndRoutineController>(context, listen: false).updateTemplate(template: template);
    if (mounted) {
      Navigator.of(context).pop(template);
    }
  }
}
