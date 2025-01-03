import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/colors.dart';

import '../../utils/general_utils.dart';
import '../../widgets/buttons/opacity_button_widget.dart';

class WorkoutVideoGeneratorScreen extends StatefulWidget {
  const WorkoutVideoGeneratorScreen({super.key});

  @override
  State<WorkoutVideoGeneratorScreen> createState() => _WorkoutVideoGeneratorScreenState();
}

class _WorkoutVideoGeneratorScreenState extends State<WorkoutVideoGeneratorScreen> {
  late TextEditingController _textEditingController;

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.squareXmark,
            size: 28,
          ),
          onPressed: context.pop,
        ),
        title: Text("Create a guided session".toUpperCase()),
        centerTitle: true,
      ),
      body: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: themeGradient(context: context),
          ),
          child: SafeArea(
              minimum: const EdgeInsets.all(10.0),
              child: Column(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _textEditingController,
                    cursorColor: isDarkMode ? Colors.white : Colors.black,
                    decoration: InputDecoration(
                      hintText: "Describe Activity",
                    ),
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.words,
                    style: GoogleFonts.ubuntu(
                        fontWeight: FontWeight.w400, color: isDarkMode ? Colors.white : Colors.black, fontSize: 14),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: OpacityButtonWidget(
                        onPressed: () {},
                        label: "Create guided session",
                        buttonColor: vibrantGreen,
                        padding: const EdgeInsets.all(10.0)),
                  )
                ],
              ))),
    );
  }

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
  }
}
