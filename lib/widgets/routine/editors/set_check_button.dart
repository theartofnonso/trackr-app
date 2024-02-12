import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tracker_app/colors.dart';
import '../../../dtos/set_dto.dart';

class SetCheckButton extends StatelessWidget {
  final SetDto setDto;
  final void Function() onCheck;

  const SetCheckButton({super.key, required this.setDto, required this.onCheck});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCheck,
      child: Center(
        child: FaIcon(
          setDto.checked ? FontAwesomeIcons.solidSquareCheck : FontAwesomeIcons.solidSquareCheck,
          color: setDto.checked ? vibrantGreen : sapphireDark,
          size: 30,
        ),
      ),
    );
  }
}
