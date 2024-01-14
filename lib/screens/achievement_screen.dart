import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/widgets/calender_heatmaps/calendar_heatmap.dart';

import '../app_constants.dart';
import '../dtos/achievement_dto.dart';
import '../utils/shareables_utils.dart';
import '../widgets/backgrounds/gradient_background.dart';
import '../widgets/buttons/text_button_widget.dart';
import '../widgets/helper_widgets/dialog_helper.dart';
import '../widgets/information_container.dart';
import '../widgets/information_container_lite.dart';

GlobalKey _achievementKey = GlobalKey();

class AchievementScreen extends StatelessWidget {
  final AchievementDto achievementDto;

  const AchievementScreen({super.key, required this.achievementDto});

  @override
  Widget build(BuildContext context) {
    final monthsHeatMap = achievementDto.progress.dates.isNotEmpty
        ? achievementDto.progress.dates.values.map((dates) {
            return CalendarHeatMap(dates: dates, initialDate: dates.first);
          }).toList()
        : [CalendarHeatMap(dates: const [], initialDate: DateTime.now())];

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onShareCalendar(context: context, monthsHeatMap: monthsHeatMap),
        heroTag: "fab_achievement_screen",
        backgroundColor: tealBlueLighter,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        child: const FaIcon(FontAwesomeIcons.arrowUpFromBracket, color: Colors.white, size: 18),
      ),
      body: Stack(children: [
        const Positioned.fill(child: GradientBackground()),
        SafeArea(
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
              Text(achievementDto.type.title, style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.w900)),
              Text(achievementDto.type.description, style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white70)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5), border: Border.all(color: tealBlueLighter, width: 2.0)),
                child: Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        minHeight: 8,
                        color: achievementDto.progress.remainder == 0 ? Colors.green : Colors.white,
                        value: achievementDto.progress.value,
                        borderRadius: const BorderRadius.all(Radius.circular(2)),
                        backgroundColor: tealBlueLighter,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text("${achievementDto.progress.remainder} left",
                        style: GoogleFonts.montserrat(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                childAspectRatio: 1,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                children: List.generate(monthsHeatMap.length, (index) => monthsHeatMap[index]),
              ),
              const SizedBox(height: 10),
              const InformationContainerLite(
                  content: 'Brightly-coloured squares represent days you logged a session for this achievement',
                  color: tealBlueLight),
              const SizedBox(height: 10),
              InformationContainer(
                  icon: const FaIcon(FontAwesomeIcons.lightbulb, size: 16),
                  title: 'Tip',
                  description: achievementDto.type.tip,
                  color: tealBlue),
            ]),
          ),
        )
      ]),
    );
  }

  void _onShareCalendar({required BuildContext context, required List<CalendarHeatMap> monthsHeatMap}) {
    displayBottomSheet(
        color: tealBlueDark,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        context: context,
        isScrollControlled: true,
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          RepaintBoundary(
              key: _achievementKey,
              child: Container(
                  color: tealBlueDark,
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(achievementDto.type.title,
                          style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.w900)),
                      Text(achievementDto.type.description,
                          style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white70)),
                      const SizedBox(height: 10),
                      GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: monthsHeatMap.length > 4 ? 4 : monthsHeatMap.length,
                        childAspectRatio: 1,
                        mainAxisSpacing: 10.0,
                        crossAxisSpacing: 10.0,
                        children: List.generate(monthsHeatMap.length, (index) => monthsHeatMap[index]),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Image.asset(
                          'assets/trackr.png',
                          fit: BoxFit.contain,
                          height: 8, // Adjust the height as needed
                        ),
                      ),
                    ],
                  ))),
          const SizedBox(height: 10),
          CTextButton(
              onPressed: () => captureImage(key: _achievementKey),
              label: "Share",
              buttonColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              buttonBorderColor: Colors.transparent)
        ]));
  }
}
