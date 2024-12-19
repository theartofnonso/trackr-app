import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/widgets/information_containers/information_container_lite.dart';
import 'package:tracker_app/widgets/other_activity_selector/activity_selector.dart';

import '../../enums/activity_type_enums.dart';
import '../../strings/datetime_range_picker_strings.dart';
import '../../utils/navigation_utils.dart';
import '../buttons/opacity_button_widget.dart';
import '../buttons/solid_button_widget.dart';

class ActivityPicker extends StatefulWidget {
  final ActivityType? initialActivityType;
  final DateTimeRange? initialDateTimeRange;
  final String? activitySummary;
  final String? activityColor;
  final void Function(ActivityType activity, DateTimeRange range, String summary, String color) onSelectActivity;

  const ActivityPicker(
      {super.key,
      this.initialActivityType,
      this.initialDateTimeRange,
      required this.onSelectActivity,
      this.activitySummary, this.activityColor});

  @override
  State<ActivityPicker> createState() => _ActivityPickerState();
}

class _ActivityPickerState extends State<ActivityPicker> {
  late DateTime _startDateTime;
  late DateTime _endDateTime;

  bool _showStartDateTimeRange = false;
  bool _showEndDateTimeRange = false;

  ActivityType? _selectedActivity;

  Color _selectedColor = Colors.greenAccent;

  late TextEditingController _activitySummaryController;

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
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final errorMessage = _validateDate();

    final selectedActivity = _selectedActivity;

    final image = selectedActivity?.image;

    final leadingWidget = image != null
        ? Image.asset(
            'icons/$image.png',
            fit: BoxFit.contain,
            height: 24,
            color: isDarkMode ? Colors.white : Colors.black, // Adjust the height as needed
          )
        : FaIcon(selectedActivity?.icon);

    final colorCodes =
        [Colors.red, Colors.orange, Colors.yellow, Colors.blue, Colors.pink, Colors.purple, Colors.greenAccent]
            .map((color) => GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: SizedBox(width: 45, height: 45, child: ColoredBox(color: color)),
                  ),
                ))
            .toList();

    return SingleChildScrollView(
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ListTile(
                onTap: _navigateToActivitySelector,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                leading: selectedActivity != null ? leadingWidget : const FaIcon(FontAwesomeIcons.personWalking),
                title: Text(
                  selectedActivity != null ? selectedActivity.name : "Select Activity".toUpperCase(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                trailing: const FaIcon(FontAwesomeIcons.arrowRightLong),
              ),
              if (_selectedActivity == ActivityType.other)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _activitySummaryController,
                      decoration: InputDecoration(
                        hintText: "Describe Activity",
                      ),
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.words,
                      style: GoogleFonts.ubuntu(
                          fontWeight: FontWeight.w400, color: isDarkMode ? Colors.white : Colors.black, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Text(
                  "Duration".toUpperCase(),
                  style: Theme.of(context).textTheme.bodySmall,
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
                  title: Text("Start Time", style: Theme.of(context).textTheme.bodyLarge),
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
                    style: Theme.of(context).textTheme.bodyLarge,
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
              Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Text(
                  "Choose Activity Colour".toUpperCase(),
                  style: Theme.of(context).textTheme.bodySmall,
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
            ]),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(spacing: 10, children: [SizedBox(width: 10,), ...colorCodes, SizedBox(width: 10,)]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
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
                          height: 45,
                          child: OpacityButtonWidget(
                              onPressed: selectedActivity != null
                                  ? () {
                                      final range = DateTimeRange(start: _startDateTime, end: _endDateTime);
                                      widget.onSelectActivity(
                                          selectedActivity, range, _activitySummaryController.text.trim(), _selectedColor.);
                                    }
                                  : null,
                              label: selectedActivity != null
                                  ? "Log ${_calculateDuration().hmsAnalog()} of ${selectedActivity.name}"
                                  : "Log ${_calculateDuration().hmsAnalog()} of activity",
                              buttonColor: _selectedColor,
                              padding: const EdgeInsets.all(10.0)),
                        )),
            ),
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
    _selectedActivity = widget.initialActivityType;
    _activitySummaryController = TextEditingController(text: widget.activitySummary);
    _startDateTime = widget.initialDateTimeRange?.start ?? DateTime.now().subtract(const Duration(hours: 1));
    _endDateTime = widget.initialDateTimeRange?.end ?? DateTime.now();
  }
}
