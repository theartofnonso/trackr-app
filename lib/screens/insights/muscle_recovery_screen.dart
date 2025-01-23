import 'package:flutter/material.dart';
import 'package:tracker_app/colors.dart';
import 'package:tracker_app/utils/general_utils.dart';
import 'package:tracker_app/widgets/buttons/opacity_button_widget.dart';

import '../../enums/muscle_group_enums.dart';

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
            decoration: BoxDecoration(
              gradient: themeGradient(context: context),
            ),
            child: SafeArea(
              minimum: const EdgeInsets.all(10.0),
              bottom: false,
              child: ListView.separated(
                  itemBuilder: (context, index) {
                    final muscleGroupFamily = muscleGroupFamilies[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(children: [
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
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider(height: 0.3, color: Colors.grey.withValues(alpha: 0.2));
                  },
                  itemCount: muscleGroupFamilies.length),
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
    return Wrap(
      spacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        OpacityButtonWidget(
            label: 'No'.toUpperCase(),
            buttonColor: _selectedOption == YesNoOption.no ? Colors.red : Colors.grey,
            onPressed: () => _onSelectOption(YesNoOption.no)),
        OpacityButtonWidget(
            label: 'Yes'.toUpperCase(),
            buttonColor: _selectedOption == YesNoOption.yes ? vibrantGreen : Colors.grey,
            onPressed: () => _onSelectOption(YesNoOption.yes)),
      ],
    );
  }
}
