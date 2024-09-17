import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tracker_app/enums/share_content_type_enum.dart';
import 'package:tracker_app/extensions/datetime_extension.dart';
import 'package:tracker_app/widgets/shareables/session_milestone_shareable.dart';
import 'package:tracker_app/widgets/shareables/pbs_shareable.dart';
import 'package:tracker_app/widgets/shareables/routine_log_shareable_lite.dart';

import '../colors.dart';
import '../controllers/routine_log_controller.dart';
import '../dtos/routine_log_dto.dart';
import '../enums/muscle_group_enums.dart';
import '../utils/dialog_utils.dart';
import '../utils/exercise_logs_utils.dart';
import '../utils/app_analytics.dart';
import '../utils/shareables_utils.dart';
import '../widgets/buttons/opacity_button_widget.dart';
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

    final logsByDay = groupBy(routineLogController.routineLogs, (log) => log.createdAt.withoutTime());

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
      if (isMultipleOfFive(logsByDay.length)) SessionMilestoneShareable(label: "${logsByDay.length}th", image: _image),
      ...pbShareAssets,
      RoutineLogShareableLite(log: widget.log, frequencyData: widget.frequencyData, image: _image),
    ];

    final pagesKeys = [
      if (isMultipleOfFive(logsByDay.length)) sessionMilestoneShareableKey,
      ...pbShareAssetsKeys,
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
              OpacityButtonWidget(
                  onPressed: () {
                    final index = _controller.page!.toInt();
                    captureImage(key: pagesKeys[index], pixelRatio: 3.5);
                    final contentType = _shareContentType(index: index);
                    contentShared(contentType: contentType);
                  },
                  label: "Share",
                  buttonColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14))
            ],
          ),
        ),
      ),
    );
  }

  ShareContentType _shareContentType({required int index}) {

    if(index == 0) {
      return ShareContentType.milestoneAchievement;
    } else if(index == 1) {
      return ShareContentType.logMilestone;
    } else if(index == 2) {
      return ShareContentType.pbs;
    } else {
      return ShareContentType.sessionSummary;
    }
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
