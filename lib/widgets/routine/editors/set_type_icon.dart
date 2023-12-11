import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app_constants.dart';
import '../../../dtos/set_dto.dart';
import '../../buttons/text_button_widget.dart';
import '../../helper_widgets/dialog_helper.dart';

class SetTypeIcon extends StatelessWidget {
  final SetType type;
  final String label;
  final void Function(SetType type) onSelectSetType;
  final void Function() onRemoveSet;

  const SetTypeIcon({
    super.key,
    required this.type,
    required this.label,
    required this.onSelectSetType,
    required this.onRemoveSet,
  });

  void selectType(BuildContext context, SetType type) {
    Navigator.of(context).pop();
    onSelectSetType(type);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        displayBottomSheet(
            context: context,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ListTile(
                      dense: true,
                      onTap: () => selectType(context, SetType.warmUp),
                      leading: SizedBox(
                        width: 30,
                        child: Text(SetType.warmUp.label,
                            style:
                                GoogleFonts.lato(color: SetType.warmUp.color, fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      title: Text(SetType.warmUp.name, style: GoogleFonts.lato(fontSize: 14))),
                  ListTile(
                      dense: true,
                      onTap: () => selectType(context, SetType.working),
                      leading: SizedBox(
                        width: 30,
                        child: Text(SetType.working.label,
                            style: GoogleFonts.lato(
                                color: SetType.working.color, fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      title: Text(SetType.working.name, style: GoogleFonts.lato(fontSize: 14))),
                  ListTile(
                      dense: true,
                      onTap: () => selectType(context, SetType.failure),
                      leading: SizedBox(
                        width: 30,
                        child: Text(SetType.failure.label,
                            style: GoogleFonts.lato(
                                color: SetType.failure.color, fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      title: Text(SetType.failure.name, style: GoogleFonts.lato(fontSize: 14))),
                  ListTile(
                      dense: true,
                      onTap: () => selectType(context, SetType.drop),
                      leading: SizedBox(
                        width: 30,
                        child: Text(SetType.drop.label,
                            style:
                                GoogleFonts.lato(color: SetType.drop.color, fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      title: Text(SetType.drop.name, style: GoogleFonts.lato(fontSize: 14))),
                  CTextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onRemoveSet();
                    },
                    label: "Remove Set",
                    buttonColor: tealBlueLight,
                  ),
                  const SizedBox(height: 10)
                ],
              ),
            ));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.lato(color: type.color, fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }
}