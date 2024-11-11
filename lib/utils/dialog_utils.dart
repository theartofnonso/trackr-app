import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/enums/activity_type_enums.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/extensions/duration_extension.dart';
import 'package:tracker_app/utils/routine_utils.dart';
import 'package:tracker_app/widgets/forms/create_routine_user_profile_widget.dart';
import 'package:tracker_app/widgets/label_divider.dart';
import 'package:tracker_app/widgets/timers/datetime_picker.dart';
import 'package:tracker_app/widgets/timers/datetime_range_picker.dart';

import '../colors.dart';
import '../controllers/activity_log_controller.dart';
import '../controllers/routine_user_controller.dart';
import '../dtos/appsync/activity_log_dto.dart';
import '../widgets/buttons/opacity_button_widget.dart';
import '../widgets/buttons/solid_button_widget.dart';
import '../widgets/other_activity_selector/activity_picker.dart';
import '../widgets/timers/hour_timer_picker.dart';
import '../widgets/timers/time_picker.dart';

void showSnackbar({required BuildContext context, required Widget icon, required String message}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: sapphireDark,
      behavior: SnackBarBehavior.fixed,
      content: Row(
        children: [
          icon,
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.ubuntu(
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
        ],
      )));
}

Future<void> displayBottomSheet(
    {required BuildContext context,
    required Widget child,
    Gradient? gradient,
    double? height,
    enabledDrag = true,
    bool isDismissible = true,
      EdgeInsetsGeometry? padding,
    bool isScrollControlled = false}) {
  return showModalBottomSheet(
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enabledDrag,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: height,
                width: double.infinity,
                padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  gradient: gradient ??
                      const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          sapphireDark80,
                          sapphireDark,
                        ],
                      ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: SafeArea(child: child),
              ),
            ],
          ));
}

void displayTimePicker(
    {required BuildContext context,
    required CupertinoTimerPickerMode mode,
    required Duration initialDuration,
    required void Function(Duration duration) onChangedDuration}) {
  FocusScope.of(context).unfocus();
  displayBottomSheet(
      height: 240,
      context: context,
      child: TimePicker(mode: mode, initialDuration: initialDuration, onDurationChanged: onChangedDuration));
}

void showHourTimerPicker(
    {required BuildContext context,
    required Duration initialDuration,
    required void Function(Duration duration) onChangedDuration}) {
  FocusScope.of(context).unfocus();
  displayBottomSheet(
      height: 240,
      context: context,
      child: HourTimerPicker(
          initialDuration: initialDuration,
          onSelect: (Duration duration) {
            onChangedDuration(duration);
          }));
}

void showDateTimePicker({required BuildContext context, required void Function(DateTime datetime) onChangedDateTime}) {
  FocusScope.of(context).unfocus();
  displayBottomSheet(height: 240, context: context, child: DatetimePicker(onSelect: onChangedDateTime));
}

void showDatetimeRangePicker(
    {required BuildContext context,
    DateTimeRange? initialDateTimeRange,
    required void Function(DateTimeRange datetimeRange) onChangedDateTimeRange}) {
  FocusScope.of(context).unfocus();
  displayBottomSheet(
      context: context,
      child: DateTimeRangePicker(
        initialDateTimeRange: initialDateTimeRange,
        onSelectRange: onChangedDateTimeRange,
      ),
      isScrollControlled: true);
}

void showActivityPicker(
    {required BuildContext context,
    ActivityType? initialActivityType,
    DateTimeRange? initialDateTimeRange,
    required void Function(ActivityType activity, DateTimeRange datetimeRange) onChangedActivity}) {
  FocusScope.of(context).unfocus();
  displayBottomSheet(
      context: context,
      child: ActivityPicker(
        initialActivityType: initialActivityType,
        initialDateTimeRange: initialDateTimeRange,
        onSelectActivity: onChangedActivity,
      ),
      isScrollControlled: true);
}

void showActivityBottomSheet({required BuildContext context, required ActivityLogDto activity}) {
  final activityType = ActivityType.fromString(activity.name);

  final image = activityType.image;

  final routineUserController = Provider.of<RoutineUserController>(context, listen: false);

  final calories = calculateCalories(duration: activity.duration(), bodyWeight: routineUserController.weight(), activity: activity.activityType);

  displayBottomSheet(
      context: context,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            image != null
                ? Image.asset(
                    'icons/$image.png',
                    fit: BoxFit.contain,
                    height: 24, // Adjust the height as needed
                  )
                : FaIcon(
                    activityType.icon,
                    color: Colors.white,
                  ),
            const SizedBox(
              width: 8,
            ),
            Text("${activity.name} Activity".toUpperCase(),
                style: GoogleFonts.ubuntu(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                textAlign: TextAlign.start),
          ],
        ),
        const SizedBox(
          height: 12,
        ),
        Text("You completed ${activity.duration().hmsAnalog()} of ${activity.name}",
            style: GoogleFonts.ubuntu(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white),
            textAlign: TextAlign.start),
        const SizedBox(
          height: 6,
        ),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const FaIcon(
              FontAwesomeIcons.calendarDay,
              color: Colors.white70,
              size: 12,
            ),
            const SizedBox(width: 4),
            Text(activity.createdAt.formattedDayAndMonthAndYear(),
                style: GoogleFonts.ubuntu(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white70),
                textAlign: TextAlign.start),
            const SizedBox(width: 12),
            const FaIcon(
              FontAwesomeIcons.fire,
              color: Colors.white70,
              size: 12,
            ),
            const SizedBox(width: 4),
            Text("$calories calories",
                style: GoogleFonts.ubuntu(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white70),
                textAlign: TextAlign.start),
          ],
        ),
        const SizedBox(
          height: 16,
        ),
        LabelDivider(
            label: "Want to change activity?".toUpperCase(), labelColor: Colors.white70, dividerColor: sapphireLighter),
        const SizedBox(
          height: 4,
        ),
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: const FaIcon(FontAwesomeIcons.penToSquare, size: 18),
          horizontalTitleGap: 6,
          title:
              Text("Edit", style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16)),
          onTap: () {
            Navigator.of(context).pop();
            showActivityPicker(
                initialActivityType: activityType,
                initialDateTimeRange: DateTimeRange(start: activity.startTime, end: activity.endTime),
                context: context,
                onChangedActivity: (ActivityType activityType, DateTimeRange datetimeRange) {
                  Navigator.of(context).pop();
                  final updatedActivity = activity.copyWith(
                      name: activityType.name,
                      startTime: datetimeRange.start,
                      endTime: datetimeRange.end,
                      createdAt: datetimeRange.start,
                      updatedAt: DateTime.now());
                  Provider.of<ActivityLogController>(context, listen: false).updateLog(log: updatedActivity);
                });
          },
        ),
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: const FaIcon(
            FontAwesomeIcons.trash,
            size: 18,
            color: Colors.red,
          ),
          horizontalTitleGap: 6,
          title:
              Text("Delete", style: GoogleFonts.ubuntu(color: Colors.red, fontWeight: FontWeight.w500, fontSize: 16)),
          onTap: () {
            Navigator.of(context).pop(); // Close the previous BottomSheet
            showBottomSheetWithMultiActions(
                context: context,
                title: "Delete activity?",
                description: "Are you sure you want to delete this activity?",
                leftAction: context.pop,
                rightAction: () {
                  Navigator.pop(context); // Close current BottomSheet
                  Provider.of<ActivityLogController>(context, listen: false).removeLog(log: activity);
                },
                leftActionLabel: 'Cancel',
                rightActionLabel: 'Delete',
                isRightActionDestructive: true);
          },
        ),
      ]));
}

void showCreateProfileBottomSheet({required BuildContext context}) {
  showModalBottomSheet(
      isScrollControlled: true,
      isDismissible: false,
      useSafeArea: true,
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: const SingleChildScrollView(
            child: CreateRoutineUserProfileWidget(),
          ),
        );
      });
}

void showBottomSheetWithNoAction({required BuildContext context, required String title, required String description}) {
  displayBottomSheet(
      context: context,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: GoogleFonts.ubuntu(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
            textAlign: TextAlign.start),
        const SizedBox(
          height: 4,
        ),
        Text(description,
            style: GoogleFonts.ubuntu(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white),
            textAlign: TextAlign.start)
      ]));
}

void showBottomSheetWithMultiActions(
    {required BuildContext context,
    required String title,
    required String description,
    required void Function() leftAction,
    required void Function() rightAction,
    required String leftActionLabel,
    required String rightActionLabel,
    bool isLeftActionDestructive = false,
    bool isRightActionDestructive = true,
    Color? rightActionColor}) {
  displayBottomSheet(
      context: context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title,
              style: GoogleFonts.ubuntu(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
              textAlign: TextAlign.start),
          Text(description,
              style: GoogleFonts.ubuntu(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white70),
              textAlign: TextAlign.start),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            SolidButtonWidget(
                onPressed: leftAction,
                label: leftActionLabel,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
            const SizedBox(width: 10),
            OpacityButtonWidget(
                onPressed: rightAction,
                label: rightActionLabel,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                buttonColor: vibrantGreen)
          ])
        ],
      ));
}
