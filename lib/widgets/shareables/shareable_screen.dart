import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tracker_app/widgets/shareables/achievement_share.dart';
import 'package:tracker_app/widgets/shareables/log_milestone_shareable.dart';
import 'package:tracker_app/widgets/shareables/routine_log_shareable.dart';
import 'package:tracker_app/widgets/shareables/pbs_shareable_shareable.dart';
import 'package:tracker_app/widgets/shareables/routine_log_shareable_lite.dart';

import '../../colors.dart';
import '../../controllers/routine_log_controller.dart';
import '../../dtos/routine_log_dto.dart';
import '../../enums/muscle_group_enums.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/exercise_logs_utils.dart';
import '../../utils/shareables_utils.dart';
import '../buttons/text_button_widget.dart';
import 'package:image_picker/image_picker.dart';

class ShareableScreen extends StatefulWidget {
  final RoutineLogDto log;
  final Map<MuscleGroupFamily, double> frequencyData;

  const ShareableScreen({super.key, required this.log, required this.frequencyData});

  @override
  State<ShareableScreen> createState() => _ShareableScreenState();
}

class _ShareableScreenState extends State<ShareableScreen> {
  bool _hasImage = false;

  Image? _image;

  final _controller = PageController(viewportFraction: 1);

  bool isMultipleOfFive(int number) {
    return number % 5 == 0;
  }

  @override
  Widget build(BuildContext context) {
    final routineLogController = Provider.of<RoutineLogController>(context, listen: false);

    final allLogs = routineLogController.routineLogs;

    final achievements = routineLogController.calculateNewLogAchievements();

    List<Widget> achievementsShareAssets = [];
    final achievementsShareAssetsKeys = [];

    for (final achievement in achievements) {
      final key = GlobalKey();
      final shareable =
          AchievementShare(globalKey: key, achievementDto: achievement, width: MediaQuery.of(context).size.width - 20);
      achievementsShareAssets.add(shareable);
      achievementsShareAssetsKeys.add(key);
    }

    List<Widget> pbShareAssets = [];
    final pbShareAssetsKeys = [];

    for (final exerciseLog in widget.log.exerciseLogs) {
      final pastExerciseLogs =
          routineLogController.whereExerciseLogsBefore(exercise: exerciseLog.exercise, date: exerciseLog.createdAt);
      final pbs = calculatePBs(
          pastExerciseLogs: pastExerciseLogs, exerciseType: exerciseLog.exercise.type, exerciseLog: exerciseLog);
      final setAndPBs = groupBy(pbs, (pb) => pb.set);
      for (final setAndPB in setAndPBs.entries) {
        final pbs = setAndPB.value;
        for (final pb in pbs) {
          final key = GlobalKey();
          final shareable = PBsShareable(set: setAndPB.key, pbDto: pb, globalKey: key, image: _image);
          pbShareAssets.add(shareable);
          pbShareAssetsKeys.add(key);
        }
      }
    }

    final pages = [
      ...achievementsShareAssets,
      if (isMultipleOfFive(allLogs.length)) LogMilestoneShareable(label: "${allLogs.length}th", image: _image),
      ...pbShareAssets,
      RoutineLogShareableLite(log: widget.log, frequencyData: widget.frequencyData, image: _image),
    ];

    final pagesKeys = [
      ...achievementsShareAssetsKeys,
      if (isMultipleOfFive(allLogs.length)) logMilestoneShareableKey,
      ...pbShareAssetsKeys,
      routineLogShareableKey,
      routineLogShareableLiteKey,
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: sapphireDark80,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.xmark, color: Colors.white, size: 28),
          onPressed: Navigator.of(context).pop,
        ),
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.solidImage, color: Colors.white, size: 24),
            onPressed: _showBottomSheet,
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              sapphireDark80,
              sapphireDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              Expanded(
                child: PageView.builder(
                  scrollDirection: Axis.horizontal,
                  controller: _controller,
                  itemCount: pages.length,
                  itemBuilder: (_, index) {
                    return pages[index % pages.length];
                  },
                ),
              ),
              const Spacer(),
              SmoothPageIndicator(
                controller: _controller,
                count: pages.length,
                effect: const ExpandingDotsEffect(activeDotColor: vibrantGreen),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: CTextButton(
                    onPressed: () => captureImage(key: pagesKeys[_controller.page!.toInt()], pixelRatio: 3.5),
                    label: "Share",
                    buttonColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    buttonBorderColor: Colors.transparent),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showBottomSheet() {
    displayBottomSheet(
        context: context,
        child: SafeArea(
          child: Column(children: [
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text("Camera",
                  style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16)),
              onTap: () => _pickFromLibrary(camera: true),
            ),
            const Divider(
              color: sapphireLighter,
              thickness: 0.6,
            ),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text("Library",
                  style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16)),
              onTap: () => _pickFromLibrary(camera: false),
            ),
            if (_hasImage)
              Column(children: [
                const Divider(
                  color: sapphireLighter,
                  thickness: 0.6,
                ),
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text("Remove Image",
                      style: GoogleFonts.montserrat(color: Colors.red, fontWeight: FontWeight.w500, fontSize: 16)),
                  onTap: _removeImage,
                ),
              ])
          ]),
        ));
  }

  void _pickFromLibrary({required bool camera}) async {
    Navigator.of(context).pop();
    final ImagePicker picker = ImagePicker();
    final XFile? xFile = await picker.pickImage(source: camera ? ImageSource.camera : ImageSource.gallery);
    if (xFile != null) {
      final Uint8List bytes = await xFile.readAsBytes();
      setState(() {
        _image = Image.memory(bytes);
        _hasImage = true;
      });
    }
  }

  void _removeImage() {
    Navigator.of(context).pop();
    setState(() {
      _image = null;
      _hasImage = false;
    });
  }
}
