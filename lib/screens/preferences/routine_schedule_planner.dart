import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/dtos/routine_template_dto.dart';
import 'package:tracker_app/utils/string_utils.dart';

class RoutineSchedulePlanner extends StatefulWidget {
  static const routeName = "/routine-schedule-planner";

  final RoutineTemplateDto template;

  const RoutineSchedulePlanner({super.key, required this.template});

  @override
  State<RoutineSchedulePlanner> createState() => _RoutineSchedulePlannerState();
}

class _RoutineSchedulePlannerState extends State<RoutineSchedulePlanner> {
  final List<String> daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  final List<String> selectedDays = [];

  void _toggleDay(String day) {
    setState(() {
      if (selectedDays.contains(day)) {
        selectedDays.remove(day);
      } else {
        selectedDays.add(day);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String days = joinWithAnd(items: selectedDays);

    if (selectedDays.length == 7) {
      days = 'everyday';
    } else {
      days = "on $days";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        selectedDays.isNotEmpty
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
            : Text('Select days to train ${widget.template}',
                style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white70)),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: daysOfWeek.map((day) {
            return ChoiceChip(
              label: Text(day,
                  style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: selectedDays.contains(day) ? sapphireDark : Colors.white)),
              backgroundColor: sapphireDark,
              selectedColor: vibrantGreen,
              visualDensity: VisualDensity.compact,
              checkmarkColor: sapphireDark,
              selected: selectedDays.contains(day),
              side: const BorderSide(color: Colors.transparent, width: 1.5),
              onSelected: (_) {
                _toggleDay(day);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
