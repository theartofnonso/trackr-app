import 'package:flutter/cupertino.dart';
import 'package:tracker_app/utils/datetime_utils.dart';
import 'package:tracker_app/widgets/buttons/text_button_widget.dart';

import '../../../dtos/duration_num_pair.dart';
import '../../helper_widgets/dialog_helper.dart';
import '../../time_picker.dart';

class TimerWidget extends StatelessWidget {
  final DurationNumPair durationDto;
  final void Function(Duration duration) onChangedDuration;

  const TimerWidget({super.key, required this.durationDto, required this.onChangedDuration});

  @override
  Widget build(BuildContext context) {
    return CTextButton(
        onPressed: () => _showRestIntervalTimePicker(context: context), label: durationDto.value1.digitalTime());
  }

  void _showRestIntervalTimePicker({required BuildContext context}) {
    FocusScope.of(context).unfocus();
    displayBottomSheet(
        context: context,
        child: TimePicker(
          mode: CupertinoTimerPickerMode.hms,
          initialDuration: durationDto.value1,
          onSelect: (Duration duration) {
            Navigator.of(context).pop();
            onChangedDuration(duration);
          },
        ));
  }
}
