import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/utils/general_utils.dart';
import 'package:tracker_app/widgets/buttons/opacity_button_widget.dart';

import '../../enums/muscle_group_enums.dart';
import '../../widgets/information_containers/information_container_with_background_image.dart';

class MuscleRecoveryScreen extends StatefulWidget {
  static const routeName = "/muscle_recovery_screen";

  final VoidCallback? onComplete;

  const MuscleRecoveryScreen({super.key, this.onComplete});

  @override
  State<MuscleRecoveryScreen> createState() => _MuscleRecoveryScreenState();
}

class _MuscleRecoveryScreenState extends State<MuscleRecoveryScreen> {
  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final muscleGroupFamilies = MuscleGroupFamily.recoveryMuscles;

    return Scaffold(
        body: Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: themeGradient(context: context),
            ),
            child: SafeArea(
              minimum: const EdgeInsets.all(10.0),
              bottom: false,
              child: Column(children: [
                BackgroundInformationContainer(
                    image: 'images/woman_barbell.jpg',
                    containerColor: Colors.green.shade900,
                    content: "Gently press and move your muscle, to feel for any tightness, tenderness, or pain.",
                    textStyle: GoogleFonts.ubuntu(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.9),
                    )),
                Expanded(
                  child: ListView.separated(
                      itemBuilder: (context, index) {
                        final muscleGroupFamily = muscleGroupFamilies[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Is your ${muscleGroupFamily.name} sore",
                                        style: Theme.of(context).textTheme.bodyLarge),
                                  ],
                                ),
                                const Spacer(),
                                _YesNoRadioButton(
                                  onChanged: (option) {},
                                )
                              ]),
                              const SizedBox(height: 10),
                              RichText(
                                  text: TextSpan(
                                      text: "Your ${muscleGroupFamily.name} has",
                                      style: GoogleFonts.ubuntu(
                                          height: 1.5,
                                          color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                      children: [
                                    const TextSpan(text: " "),
                                    TextSpan(
                                        text: "80%",
                                        style: GoogleFonts.ubuntu(
                                            color: isDarkMode ? Colors.white : Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600)),
                                    const TextSpan(text: " "),
                                    const TextSpan(text: "recovery. You can train it today."),
                                  ])),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDarkMode ? Colors.black12 : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: LinearProgressIndicator(
                                  value: 50 / 100,
                                  backgroundColor: isDarkMode ? sapphireDark : Colors.grey.shade400,
                                  color: vibrantGreen,
                                  minHeight: 25,
                                  borderRadius: BorderRadius.circular(3.0), // Border r
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Divider(height: 0.3, color: Colors.grey.withValues(alpha: 0.2));
                      },
                      itemCount: muscleGroupFamilies.length),
                ),
                const SizedBox(height: 20),
                SizedBox(
                    width: double.infinity,
                    child: OpacityButtonWidget(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      buttonColor: vibrantGreen,
                      label: "Update recovery",
                      onPressed: () {},
                    ))
              ]),
            )));
  }
}

/// The two possible options for this Yes/No radio button widget.
enum YesNoOption {
  no,
  yes,
}

class _YesNoRadioButton extends StatefulWidget {
  /// A callback that is called whenever the user selects a different option.
  /// The new selection is passed as an argument.
  final ValueChanged<YesNoOption>? onChanged;

  const _YesNoRadioButton({
    this.onChanged,
  });

  @override
  _YesNoRadioButtonState createState() => _YesNoRadioButtonState();
}

class _YesNoRadioButtonState extends State<_YesNoRadioButton> {
  late YesNoOption _selectedOption;

  @override
  void initState() {
    super.initState();
    // Set an initial option as desired. Defaults to "No" here.
    _selectedOption = YesNoOption.no;
  }

  /// Updates the local state and notifies the parent via [widget.onChanged].
  void _onSelectOption(YesNoOption option) {
    setState(() {
      _selectedOption = option;
    });
    widget.onChanged?.call(option);
  }

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return Wrap(
      spacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        OpacityButtonWidget(
            label: 'No'.toUpperCase(),
            buttonColor: _selectedOption == YesNoOption.no
                ? Colors.red
                : isDarkMode
                    ? Colors.grey
                    : Colors.grey.shade200,
            onPressed: () => _onSelectOption(YesNoOption.no)),
        OpacityButtonWidget(
            label: 'Yes'.toUpperCase(),
            buttonColor: _selectedOption == YesNoOption.yes
                ? vibrantGreen
                : isDarkMode
                    ? Colors.grey
                    : Colors.grey.shade200,
            onPressed: () => _onSelectOption(YesNoOption.yes)),
      ],
    );
  }
}
