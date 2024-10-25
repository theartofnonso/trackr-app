import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/enums/routine_schedule_type_enums.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/utils/string_utils.dart';

import '../../../controllers/routine_template_controller.dart';
import '../../../dtos/routine_template_dto.dart';
import '../../../widgets/buttons/opacity_button_widget.dart';

class RoutineFrequencyPlanner extends StatefulWidget {
  final RoutineTemplateDto template;

  const RoutineFrequencyPlanner({super.key, required this.template});

  @override
  State<RoutineFrequencyPlanner> createState() => _RoutineFrequencyPlannerState();
}

class _RoutineFrequencyPlannerState extends State<RoutineFrequencyPlanner> {
  int _interval = 0;

  FixedExtentScrollController? _intervalsScrollController;

  @override
  Widget build(BuildContext context) {
    final days = List<Widget>.generate(31, (int index) {
      return Center(
          child: Text(index.toString(),
              style: GoogleFonts.ubuntu(fontWeight: FontWeight.w500, fontSize: 32, color: Colors.white)));
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RichText(
          text: TextSpan(
            text: _interval > 0 ? 'Train ${widget.template.name} ' : "No schedule",
            style: GoogleFonts.ubuntu(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white70),
            children: [
              if (_interval > 0)
                TextSpan(
                  text: _interval == 1 ? "everyday" : "every $_interval ${pluralize(word: "day", count: _interval)}",
                  style: GoogleFonts.ubuntu(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                )
            ],
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: CupertinoPicker(
            scrollController: _intervalsScrollController,
            looping: true,
            itemExtent: 38.0,
            onSelectedItemChanged: (int index) {
              setState(() {
                _interval = index;
              });
            },
            squeeze: 1,
            children: days,
          ),
        ),
        const SizedBox(height: 10),
        OpacityButtonWidget(
            onPressed: _updateRoutineTemplateIntervals,
            label: "Schedule intervals",
            buttonColor: vibrantGreen,
            padding: const EdgeInsets.all(10.0))
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _interval = widget.template.scheduleIntervals;
    _intervalsScrollController = FixedExtentScrollController(initialItem: widget.template.scheduleIntervals);
  }

  @override
  void dispose() {
    _intervalsScrollController?.dispose();
    super.dispose();
  }

  void _updateRoutineTemplateIntervals() async {
    if (_interval > 0) {
      final scheduledDate = DateTime.now().add(Duration(days: _interval)).withoutTime();
      final template = widget.template.copyWith(
          scheduledDate: scheduledDate,
          scheduleType: RoutineScheduleType.intervals,
          scheduleIntervals: _interval,
          scheduledDays: []);
      await Provider.of<RoutineTemplateController>(context, listen: false).updateTemplate(template: template);
    } else {
      final template = widget.template.copyWith(
          scheduledDays: [], scheduleType: RoutineScheduleType.days, scheduleIntervals: 0, scheduledDate: null);
      await Provider.of<RoutineTemplateController>(context, listen: false).updateTemplate(template: template);
    }
    if (mounted) {
      context.pop();
    }
  }
}
