import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/dtos/appsync/activity_log_dto.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/widgets/information_containers/information_container_lite.dart';
import 'package:tracker_app/widgets/other_activity_selector/activity_selector.dart';

import '../../controllers/activity_log_controller.dart';
import '../../enums/activity_type_enums.dart';
import '../../strings/datetime_range_picker_strings.dart';
import '../../utils/general_utils.dart';
import '../../utils/navigation_utils.dart';
import '../../widgets/buttons/opacity_button_widget.dart';
import '../../widgets/buttons/solid_button_widget.dart';

class ActivityEditorScreen extends StatefulWidget {
  final ActivityLogDto? activityLogDto;

  const ActivityEditorScreen({super.key, this.activityLogDto});

  @override
  State<ActivityEditorScreen> createState() => _ActivityEditorScreenState();
}

class _ActivityEditorScreenState extends State<ActivityEditorScreen> {
  late DateTime _startDateTime;
  late DateTime _endDateTime;

  bool _showStartDateTimeRange = false;
  bool _showEndDateTimeRange = false;

  ActivityType _selectedActivity = ActivityType.other;

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

    final image = selectedActivity.image;

    final leadingWidget = image != null
        ? Image.asset(
            'icons/$image.png',
            fit: BoxFit.contain,
            height: 24,
            color: isDarkMode ? Colors.white : Colors.black, // Adjust the height as needed
          )
        : FaIcon(selectedActivity.icon);

    final activity = widget.activityLogDto;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.squareXmark,
            size: 28,
          ),
          onPressed: context.pop,
        ),
        title: Text(activity?.nameOrSummary ?? "Log Activity".toUpperCase()),
        centerTitle: true,
        actions: [
          activity != null
              ? IconButton(icon: const FaIcon(FontAwesomeIcons.solidSquareCheck, size: 28), onPressed: _updateActivity)
              : const SizedBox.shrink(),
          const SizedBox(width: 12)
        ],
      ),
      body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: themeGradient(context: context),
          ),
          child: SafeArea(
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
                    leading: leadingWidget,
                    title: Text(
                      selectedActivity.name.toUpperCase(),
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
                              fontWeight: FontWeight.w400,
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontSize: 14),
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
                ]),
              ),
              const Spacer(),
              if (activity == null)
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
                                    onPressed: _createActivity,
                                    label: "Log ${_calculateDuration().hmsAnalog()} of ${selectedActivity.name}",
                                    buttonColor: Colors.greenAccent,
                                    padding: const EdgeInsets.all(10.0)),
                              )),
                  ),
                ),
            ],
          ))),
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

  void _createActivity() async {
    final activityLog = ActivityLogDto(
        id: "id",
        name: _selectedActivity.name,
        notes: "",
        summary: _activitySummaryController.text.trim(),
        startTime: _startDateTime,
        endTime: _endDateTime,
        createdAt: _startDateTime,
        updatedAt: _endDateTime,
        owner: '');
    Provider.of<ActivityLogController>(context, listen: false).saveLog(logDto: activityLog);
    if (mounted) {
      context.pop();
    }
  }

  void _updateActivity() async {
    final activity = widget.activityLogDto;
    if (activity == null) return;
    final activityToBeUpdated = activity.copyWith(
      name: _selectedActivity.name,
      summary: _activitySummaryController.text.trim(),
      startTime: _startDateTime,
      endTime: _endDateTime,
      createdAt: _startDateTime,
      updatedAt: _endDateTime,
    );
    await Provider.of<ActivityLogController>(context, listen: false).updateLog(log: activityToBeUpdated);
    if (mounted) {
      context.pop();
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedActivity = widget.activityLogDto?.activityType ?? ActivityType.other;
    _activitySummaryController = TextEditingController(text: widget.activityLogDto?.summary);
    _startDateTime = widget.activityLogDto?.startTime ?? DateTime.now().subtract(const Duration(hours: 1));
    _endDateTime = widget.activityLogDto?.endTime ?? DateTime.now();
  }
}
