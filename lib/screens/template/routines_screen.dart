import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/screens/template/routine_preview_screen.dart';
import 'package:tracker_app/utils/snackbar_utils.dart';
import 'package:tracker_app/widgets/banners/minimised_routine_banner.dart';
import '../../../models/Routine.dart';
import '../../../providers/routine_provider.dart';
import '../../../widgets/helper_widgets/dialog_helper.dart';
import '../../shared_prefs.dart';
import '../../utils/general_utils.dart';
import '../../utils/navigation_utils.dart';
import '../../widgets/empty_states/list_view_empty_state.dart';
import '../editors/routine_editor_screen.dart';

class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({super.key});

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  bool _showRoutineLogBanner = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<RoutineProvider>(builder: (_, provider, __) {
      return Scaffold(
          floatingActionButton: FloatingActionButton(
            heroTag: "fab_routines_screen",
            onPressed: () => navigateToRoutineEditor(context: context, mode: RoutineEditorMode.edit),
            backgroundColor: tealBlueLighter,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: const Icon(Icons.add, size: 28),
          ),
          body: SafeArea(
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                  child: Column(children: [
                    MinimisedRoutineBanner(onCloseRoutineBanner: () => _toggleRoutineLogBanner(visible: false)),
                    provider.routines.isNotEmpty
                        ? Expanded(
                            child: RefreshIndicator(
                              onRefresh: () => loadAppData(context),
                              child: ListView.separated(
                                  padding: const EdgeInsets.only(bottom: 150),
                                  itemBuilder: (BuildContext context, int index) => _RoutineWidget(
                                        routine: provider.routines[index],
                                        onShowRoutineBanner: () => _toggleRoutineLogBanner(visible: true),
                                        onCloseRoutineBanner: () => _toggleRoutineLogBanner(visible: false),
                                      ),
                                  separatorBuilder: (BuildContext context, int index) =>
                                      Divider(color: Colors.white70.withOpacity(0.1)),
                                  itemCount: provider.routines.length),
                            ),
                          )
                        : ListViewEmptyState(onRefresh: () => loadAppData(context)),
                  ]))));
    });
  }

  void _toggleRoutineLogBanner({required bool visible}) {
    setState(() {
    });
  }

  void _checkForCachedRoutineLog() {
    final cachedRoutineLog = SharedPrefs().cachedRoutineLog;
    if (cachedRoutineLog.isNotEmpty) {
      _toggleRoutineLogBanner(visible: true);
    }
  }

  @override
  void initState() {
    super.initState();
    _checkForCachedRoutineLog();
  }
}

class _RoutineWidget extends StatelessWidget {
  final Routine routine;
  final VoidCallback onShowRoutineBanner;
  final VoidCallback onCloseRoutineBanner;

  const _RoutineWidget({required this.routine, required this.onShowRoutineBanner, required this.onCloseRoutineBanner});

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: ThemeData(splashColor: tealBlueLight),
        child: ListTile(
          onTap: () => _navigateToRoutinePreview(context: context),
          dense: true,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
          leading: GestureDetector(
              onTap: () => _logRoutineLog(context: context),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 35,
              )),
          title: Text(routine.name, style: Theme.of(context).textTheme.labelLarge),
          subtitle: Row(children: [
            const Icon(
              Icons.numbers,
              color: Colors.white,
              size: 12,
            ),
            Text("${routine.procedures.length} exercises",
                style: GoogleFonts.lato(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500)),
          ]),
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
            menuChildren: _menuActionButtons(context: context, routine: routine),
          ),
        ));
  }

  void _logRoutineLog({required BuildContext context}) {
    final log = cachedRoutineLog();
    if (log == null) {
      navigateToRoutineEditor(
          context: context,
          routine: routine,
          mode: RoutineEditorMode.log,
          onShowRoutineBanner: onShowRoutineBanner,
          onCloseRoutineBanner: onCloseRoutineBanner);
    } else {
      showSnackbar(
          context: context,
          icon: const Icon(Icons.info_outline_rounded),
          message: "${log.routine?.name ?? "Workout"} is running");
    }
  }

  List<Widget> _menuActionButtons({required BuildContext context, required Routine routine}) {
    return [
      MenuItemButton(
        onPressed: () {
          navigateToRoutineEditor(context: context, routine: routine, mode: RoutineEditorMode.edit);
        },
        child: Text("Edit", style: GoogleFonts.lato(color: Colors.white)),
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
        child: Text("Delete", style: GoogleFonts.lato(color: Colors.red)),
      )
    ];
  }

  void _deleteRoutine(BuildContext context) {
    Provider.of<RoutineProvider>(context, listen: false).removeRoutine(id: routine.id).onError((_, __) {
      showSnackbar(context: context, icon: const Icon(Icons.info_outline), message: "Oops, unable to delete workout");
    });
  }

  void _navigateToRoutinePreview({required BuildContext context}) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => RoutinePreviewScreen(routineId: routine.id)));
  }
}
