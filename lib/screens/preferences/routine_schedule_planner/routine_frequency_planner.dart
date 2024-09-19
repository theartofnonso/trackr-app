import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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
  int _intervals = 0;

  FixedExtentScrollController? _intervalsScrollController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RichText(
          text: TextSpan(
            text: 'Train ${widget.template.name} ',
            style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white70),
            children: [
              TextSpan(
                text: "every $_intervals ${pluralize(word: "day", count: _intervals)}",
                style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
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
                _intervals = index;
              });
            },
            squeeze: 1,
            children: List<Widget>.generate(31, (int index) {
              return Center(
                  child: Text(index.toString(),
                      style: GoogleFonts.montserrat(fontWeight: FontWeight.w500, fontSize: 32, color: Colors.white)));
            }),
          ),
        ),
        const SizedBox(height: 10),
        OpacityButtonWidget(
            onPressed: _updateRoutineTemplateIntervals,
            label: "Schedule intervals",
            buttonColor: Colors.transparent,
            padding: const EdgeInsets.all(10.0))
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _intervals = widget.template.scheduleIntervals;
    _intervalsScrollController = FixedExtentScrollController(initialItem: widget.template.scheduleIntervals);
  }

  @override
  void dispose() {
    _intervalsScrollController?.dispose();
    super.dispose();
  }

  void _updateRoutineTemplateIntervals() async {
    if (_intervals > 0) {
      final scheduledDate = DateTime.now().add(Duration(days: _intervals)).withoutTime();
      final template = widget.template.copyWith(
          scheduledDate: scheduledDate,
          scheduleType: RoutineScheduleType.intervals,
          scheduleIntervals: _intervals,
          scheduledDays: []);
      await Provider.of<RoutineTemplateController>(context, listen: false).updateTemplate(template: template);
    } else {
      final template = widget.template.copyWith(
          scheduledDays: [], scheduleType: RoutineScheduleType.days, scheduleIntervals: 0, scheduledDate: null);
      await Provider.of<RoutineTemplateController>(context, listen: false).updateTemplate(template: template);
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
