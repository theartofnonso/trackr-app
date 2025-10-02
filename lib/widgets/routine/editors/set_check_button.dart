import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tracker_app/colors.dart';
import 'package:flutter/services.dart';

import '../../../dtos/set_dtos/set_dto.dart';

class SetCheckButton extends StatelessWidget {
  final SetDto setDto;
  final void Function() onCheck;

  const SetCheckButton(
      {super.key, required this.setDto, required this.onCheck});

  void _handleOnCheck() {
    HapticFeedback.heavyImpact();
    onCheck();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleOnCheck,
      child: Center(
        child: FaIcon(
          FontAwesomeIcons.solidSquareCheck,
          color: setDto.checked ? vibrantGreen : darkSurface,
          size: 30,
        ),
      ),
    );
  }
}
