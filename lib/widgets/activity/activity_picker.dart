import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/widgets/activity/activity_selector.dart';
import 'package:tracker_app/widgets/information_container_lite.dart';

import '../../enums/activity_type_enums.dart';
import '../../strings/datetime_range_picker_strings.dart';
import '../../utils/navigation_utils.dart';
import '../buttons/opacity_button_widget.dart';
import '../buttons/solid_button_widget.dart';

class ActivityPicker extends StatefulWidget {
  final DateTimeRange? initialDateTimeRange;
  final void Function(ActivityType activity, DateTimeRange range) onSelectActivity;

  const ActivityPicker({super.key, this.initialDateTimeRange, required this.onSelectActivity});

  @override
  State<ActivityPicker> createState() => _ActivityPickerState();
}

class _ActivityPickerState extends State<ActivityPicker> {
  late DateTime _startDateTime;
  late DateTime _endDateTime;

  bool _showStartDateTimeRange = false;
  bool _showEndDateTimeRange = false;

  ActivityType? _selectedActivity;

  void _navigateToActivitySelector() {
    navigateWithSlideTransition(
        context: context,
        child: ActivitySelectorScreen(
          onSelectActivity: (ActivityType activity) {
            setState(() {
              _selectedActivity = activity;
            });
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    final errorMessage = _validateDate();

    final selectedActivity = _selectedActivity;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ListTile(
            onTap: _navigateToActivitySelector,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            leading: FaIcon(selectedActivity != null ? selectedActivity.icon : FontAwesomeIcons.person,
                color: Colors.white70),
            title: Text(
              selectedActivity != null ? selectedActivity.name : "Select Activity".toUpperCase(),
              style: GoogleFonts.ubuntu(
                  color: Colors.white, fontWeight: FontWeight.w600, fontSize: selectedActivity != null ? 16 : 12),
            ),
            trailing: const FaIcon(FontAwesomeIcons.arrowRightLong),
          ),
          const SizedBox(height: 6),
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Text(
              "Duration".toUpperCase(),
              style: GoogleFonts.ubuntu(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 10),
            ),
            Expanded(
              child: Container(
                height: 0.8, // height of the divider
                width: double.infinity, // width of the divider (line thickness)
                color: sapphireLighter, // color of the divider
                margin: const EdgeInsets.symmetric(horizontal: 10), // add space around the divider
              ),
            ),
          ]),
          ListTile(
              title: Text(
                "Start Time",
                style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
              ),
              trailing: SizedBox(
                width: 150,
                child: SolidButtonWidget(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    onPressed: () {
                      setState(() {
                        _showStartDateTimeRange = !_showStartDateTimeRange;
                        _showEndDateTimeRange = false;
                      });
                    },
                    buttonColor: _showStartDateTimeRange ? vibrantGreen : sapphireDark80,
                    textColor: _showStartDateTimeRange ? sapphireDark : Colors.white,
                    label: _startDateTime.formattedDayMonthTime()),
              )),
          if (_showStartDateTimeRange)
            SizedBox(
              height: 240,
              child: CupertinoDatePicker(
                  use24hFormat: true,
                  initialDateTime: _startDateTime,
                  onDateTimeChanged: (DateTime value) {
                    setState(() {
                      _startDateTime = value;
                    });
                  }),
            ),
          ListTile(
              title: Text(
                "End Time",
                style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
              ),
              trailing: SizedBox(
                width: 150,
                child: SolidButtonWidget(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    onPressed: () {
                      setState(() {
                        _showStartDateTimeRange = false;
                        _showEndDateTimeRange = !_showEndDateTimeRange;
                      });
                    },
                    buttonColor: _showEndDateTimeRange ? vibrantGreen : sapphireDark80,
                    textColor: _showEndDateTimeRange ? sapphireDark : Colors.white,
                    label: _endDateTime.formattedDayMonthTime()),
              )),
          if (_showEndDateTimeRange)
            SizedBox(
              height: 240,
              child: CupertinoDatePicker(
                  use24hFormat: true,
                  initialDateTime: _endDateTime,
                  onDateTimeChanged: (DateTime value) {
                    setState(() {
                      _endDateTime = value;
                    });
                  }),
            ),
          SizedBox(
            height: 90,
            child: AnimatedSwitcher(
                duration: const Duration(seconds: 1),
                child: errorMessage != null
                    ? Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: InformationContainerLite(content: errorMessage, color: Colors.orange),
                      )
                    : SizedBox(
                        width: double.infinity,
                        child: OpacityButtonWidget(
                            onPressed: selectedActivity != null
                                ? () {
                                    final range = DateTimeRange(start: _startDateTime, end: _endDateTime);
                                    widget.onSelectActivity(selectedActivity, range);
                                  }
                                : null,
                            label: selectedActivity != null
                                ? "Log ${_calculateDuration().hmsAnalog()} of ${selectedActivity.name}"
                                : "Log ${_calculateDuration().hmsAnalog()} of activity",
                            buttonColor: vibrantGreen,
                            padding: const EdgeInsets.all(10.0)),
                      )),
          ),
        ],
      ),
    );
  }

  String? _validateDate() {
    if (_startDateTime.isAfter(_endDateTime)) {
      return editStartDateMustBeBeforeEndDate;
    }

    if (_endDateTime.isBefore(_startDateTime)) {
      return editEndDateMustBeAfterStartDate;
    }

    if (_endDateTime.millisecondsSinceEpoch > DateTime.now().millisecondsSinceEpoch) {
      return editFutureDateRestriction;
    }

    Duration difference = _endDateTime.difference(_startDateTime);

    if (difference.inHours > 24) {
      return edit24HourRestriction;
    }

    return null;
  }

  Duration _calculateDuration() {
    return _endDateTime.difference(_startDateTime);
  }

  @override
  void initState() {
    super.initState();
    _startDateTime = widget.initialDateTimeRange?.start ?? DateTime.now().subtract(const Duration(hours: 1));
    _endDateTime = widget.initialDateTimeRange?.end ?? DateTime.now();
  }
}
