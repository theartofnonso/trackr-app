import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/controllers/routine_template_controller.dart';
import 'package:tracker_app/utils/string_utils.dart';
import 'package:tracker_app/widgets/empty_states/routine_empty_state.dart';
import '../../utils/dialog_utils.dart';
import '../../dtos/routine_template_dto.dart';
import '../../utils/navigation_utils.dart';

class RoutinesScreen extends StatelessWidget {
  const RoutinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RoutineTemplateController>(builder: (_, provider, __) {
      return Scaffold(
          floatingActionButton: FloatingActionButton(
            heroTag: "fab_routines_screen",
            onPressed: () => navigateToRoutineEditor(context: context),
            backgroundColor: tealBlueLighter,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: const FaIcon(FontAwesomeIcons.plus, color: Colors.white, size: 28),
          ),
          body: SafeArea(
              minimum: const EdgeInsets.all(10.0),
              child: Column(children: [
                provider.templates.isNotEmpty
                    ? Expanded(
                        child: ListView.separated(
                            padding: const EdgeInsets.only(bottom: 150),
                            itemBuilder: (BuildContext context, int index) => _RoutineWidget(
                                  template: provider.templates[index],
                                ),
                            separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 8),
                            itemCount: provider.templates.length),
                      )
                    : const Expanded(child: RoutineEmptyState()),
              ])));
    });
  }
}

class _RoutineWidget extends StatelessWidget {
  final RoutineTemplateDto template;

  const _RoutineWidget({required this.template});

  @override
  Widget build(BuildContext context) {

    final menuActions = [
      MenuItemButton(
        onPressed: () {
          navigateToRoutineEditor(context: context, template: template);
        },
        child: Text("Edit", style: GoogleFonts.montserrat(color: Colors.white)),
      ),
      MenuItemButton(
        onPressed: () {
          showAlertDialogWithMultiActions(
              context: context,
              message: 'Delete workout?',
              leftAction: Navigator.of(context).pop,
              rightAction: () {
                Navigator.of(context).pop();
                _deleteRoutine(context);
              },
              leftActionLabel: 'Cancel',
              rightActionLabel: 'Delete',
              isRightActionDestructive: true);
        },
        child: Text("Delete", style: GoogleFonts.montserrat(color: Colors.red)),
      )
    ];

    return Theme(
        data: ThemeData(splashColor: tealBlueLight),
        child: ListTile(
          tileColor: tealBlueLight,
          onTap: () => navigateToRoutineTemplatePreview(context: context, template: template),
          dense: true,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          leading: GestureDetector(
              onTap: () => navigateToRoutineLogEditor(context: context, log: template.log()),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 35,
              )),
          title: Text(template.name, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14)),
          subtitle: Text(
              "${template.exercises.length} ${pluralize(word: "exercise", count: template.exercises.length)}",
              style: GoogleFonts.montserrat(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500)),
          trailing: MenuAnchor(
            style: MenuStyle(
              backgroundColor: MaterialStateProperty.all(tealBlueLighter),
            ),
            builder: (BuildContext context, MenuController controller, Widget? child) {
              return IconButton(
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                icon: const Icon(
                  Icons.more_horiz_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                tooltip: 'Show menu',
              );
            },
            menuChildren: menuActions,
          ),
        ));
  }

  void _deleteRoutine(BuildContext context) {
    Provider.of<RoutineTemplateController>(context, listen: false).removeTemplate(template: template).onError((_, __) {
      showSnackbar(context: context, icon: const Icon(Icons.info_outline), message: "Oops, unable to delete workout");
    });
  }
}
