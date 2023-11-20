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
                      leading: Text("W",
                          style:
                              GoogleFonts.lato(color: SetType.warmUp.color, fontWeight: FontWeight.bold, fontSize: 16)),
                      title: Text("Warm up Set", style: GoogleFonts.lato(fontSize: 14))),
                  ListTile(
                      dense: true,
                      onTap: () => selectType(context, SetType.working),
                      leading: Text("1",
                          style: GoogleFonts.lato(
                              color: SetType.working.color, fontWeight: FontWeight.bold, fontSize: 16)),
                      title: Text("Working Set", style: GoogleFonts.lato(fontSize: 14))),
                  ListTile(
                      dense: true,
                      onTap: () => selectType(context, SetType.failure),
                      leading: Text("F",
                          style: GoogleFonts.lato(
                              color: SetType.failure.color, fontWeight: FontWeight.bold, fontSize: 16)),
                      title: Text("Failure Set", style: GoogleFonts.lato(fontSize: 14))),
                  ListTile(
                      dense: true,
                      onTap: () => selectType(context, SetType.drop),
                      leading: Text("D",
                          style:
                              GoogleFonts.lato(color: SetType.drop.color, fontWeight: FontWeight.bold, fontSize: 16)),
                      title: Text("Drop Set", style: GoogleFonts.lato(fontSize: 14))),
                  CTextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onRemoveSet();
                    },
                    label: "Remove Set",
                    buttonColor: tealBlueLighter,
                  )
                ],
              ),
            ));
      },
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: GoogleFonts.lato(color: type.color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
