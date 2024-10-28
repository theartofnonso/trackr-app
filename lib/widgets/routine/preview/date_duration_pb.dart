import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/extensions/duration_extension.dart';

import '../../../colors.dart';
import '../../pbs/pb_icon.dart';

class DateDurationPBWidget extends StatelessWidget {
  final DateTime dateTime;
  final Duration duration;
  final int pbs;
  final bool durationSince;

  const DateDurationPBWidget({
    super.key,
    required this.dateTime,
    required this.duration,
    required this.pbs,
    this.durationSince = false,
  });

  @override
  Widget build(BuildContext context) {

    final datetimeSummary = durationSince ? dateTime.durationSinceOrDate() : dateTime.formattedDayAndMonth();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FaIcon(
              FontAwesomeIcons.calendarDay,
              color: Colors.white,
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(datetimeSummary,
                style:
                    GoogleFonts.ubuntu(color: Colors.white.withOpacity(0.95), fontWeight: FontWeight.w500, fontSize: 12)),
          ],
        ),
        const SizedBox(width: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FaIcon(
              FontAwesomeIcons.solidClock,
              color: Colors.white,
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(duration.hmsAnalog(),
                style:
                    GoogleFonts.ubuntu(color: Colors.white.withOpacity(0.95), fontWeight: FontWeight.w500, fontSize: 12)),
          ],
        ),
        const SizedBox(width: 10),
        pbs > 0 ? PBIcon(color: sapphireLight, label: "$pbs") : const SizedBox.shrink(),
      ],
    );
  }
}
