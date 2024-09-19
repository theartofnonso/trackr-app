import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/dtos/routine_template_dto.dart';
import 'package:tracker_app/enums/week_days_enum.dart';
import 'package:tracker_app/extensions/week_days_extension.dart';
import 'package:tracker_app/utils/string_utils.dart';
import 'package:tracker_app/widgets/buttons/opacity_button_widget.dart';

import '../../../controllers/routine_template_controller.dart';
import '../../../enums/routine_schedule_type_enums.dart';

class RoutineDayPlanner extends StatefulWidget {
  static const routeName = "/routine-schedule-planner";

  final RoutineTemplateDto template;

  const RoutineDayPlanner({super.key, required this.template});

  @override
  State<RoutineDayPlanner> createState() => _RoutineDayPlannerState();
}

class _RoutineDayPlannerState extends State<RoutineDayPlanner> {
  final List<DayOfWeek> _selectedDays = [];

  void _toggleDay(DayOfWeek day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
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
                  style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white70),
                  children: [
                    TextSpan(
                      text: days,
                      style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                    )
                  ],
                ),
              )
            : Text('Select days to train ${widget.template.name}',
                style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white70)),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: DayOfWeek.values.map((day) {
            return ChoiceChip(
              label: Text(day.longName,
                  style: GoogleFonts.montserrat(
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
        const Spacer(),
        Center(
          child: OpacityButtonWidget(
              onPressed: _updateRoutineTemplateDays,
              label: "Save Days",
              padding: const EdgeInsets.all(10.0),
              buttonColor: Colors.transparent,),
        )
      ],
    );
  }


  @override
  void initState() {
    super.initState();
    _selectedDays.addAll(widget.template.scheduledDays);
  }

  void _updateRoutineTemplateDays() async {
    _selectedDays.sort((a, b) => a.index.compareTo(b.index));
    final template = widget.template.copyWith(scheduledDays: _selectedDays, scheduleType: RoutineScheduleType.days, scheduleIntervals: 0, scheduledDate: null);
    await Provider.of<RoutineTemplateController>(context, listen: false).updateTemplate(template: template);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
