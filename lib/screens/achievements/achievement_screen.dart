import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/widgets/calender_heatmaps/calendar_heatmap.dart';

import '../../colors.dart';
import '../../dtos/achievement_dto.dart';
import '../../utils/shareables_utils.dart';
import '../../widgets/buttons/text_button_widget.dart';
import '../../utils/dialog_utils.dart';
import '../../widgets/information_container.dart';
import '../../widgets/information_container_lite.dart';
import '../../widgets/shareables/achievement_share.dart';

GlobalKey _achievementKey = GlobalKey();

class AchievementScreen extends StatelessWidget {
  final AchievementDto achievementDto;

  const AchievementScreen({super.key, required this.achievementDto});

  @override
  Widget build(BuildContext context) {
    final completed = achievementDto.progress.remainder == 0;

    final monthsHeatMaps = achievementDto.progress.dates.isNotEmpty
        ? achievementDto.progress.dates.values.map((dates) {
            return CalendarHeatMap(dates: dates, initialDate: dates.first, spacing: 4);
          }).toList()
        : [CalendarHeatMap(dates: const [], initialDate: DateTime.now(), spacing: 4)];

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onShareCalendar(context: context, monthsHeatMaps: monthsHeatMaps, completed: completed),
        heroTag: "fab_achievement_screen",
        backgroundColor: sapphireLighter,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        child: const FaIcon(FontAwesomeIcons.arrowUpFromBracket, color: Colors.white, size: 18),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.only(right: 10.0, bottom: 10.0, left: 10.0),
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              )
            ]),
            const SizedBox(height: 10),
            Text(achievementDto.type.title.toUpperCase(),
                style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            Text(completed ? achievementDto.type.completionMessage : achievementDto.type.description,
                style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w500)),
            if (!completed)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5), border: Border.all(color: sapphireLighter, width: 2.0)),
                  child: Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          minHeight: 8,
                          color: completed ? Colors.green : Colors.white,
                          value: achievementDto.progress.value,
                          borderRadius: const BorderRadius.all(Radius.circular(2)),
                          backgroundColor: sapphireLighter,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text("${achievementDto.progress.remainder} left",
                          style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 10),
            GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: 1,
                childAspectRatio: 1.2,
                mainAxisSpacing: 4.0,
                crossAxisSpacing: 4.0,
                children: monthsHeatMaps),
            const InformationContainerLite(
                content: 'Brightly-coloured squares represent days you logged a session for this achievement',
                color: sapphireLight),
            const SizedBox(height: 10),
            InformationContainer(
                icon: const FaIcon(FontAwesomeIcons.lightbulb, size: 16),
                title: 'Tip',
                description: achievementDto.type.tip,
                color: sapphireDark),
          ]),
        ),
      ),
    );
  }

  void _onShareCalendar(
      {required BuildContext context, required List<CalendarHeatMap> monthsHeatMaps, required bool completed}) {
    displayBottomSheet(
        color: sapphireDark,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        context: context,
        isScrollControlled: true,
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          AchievementShare(globalKey: _achievementKey, achievementDto: achievementDto),
          const SizedBox(height: 10),
          CTextButton(
              onPressed: () {
                captureImage(key: _achievementKey, pixelRatio: 5);
                Navigator.of(context).pop();
              },
              label: "Share",
              buttonColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              buttonBorderColor: Colors.transparent)
        ]));
  }
}
