import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker_app/screens/routines/routine_plans_screen.dart';
import 'package:tracker_app/screens/routines/routine_templates_screen.dart';

import '../../utils/dialog_utils.dart';
import '../../utils/navigation_utils.dart';

class RoutinesHomeScreen extends StatefulWidget {
  static const routeName = '/routines_home_screen';

  const RoutinesHomeScreen({super.key});

  @override
  State<RoutinesHomeScreen> createState() => _RoutinesHomeScreenState();
}

class _RoutinesHomeScreenState extends State<RoutinesHomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, size: 28),
              onPressed: context.pop,
            ),
            actions: [IconButton(onPressed: _showMenuBottomSheet, icon: const FaIcon(FontAwesomeIcons.plus, size: 28))],
          ),
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(
                        child: Text("Templates".toUpperCase(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600))),
                    Tab(
                        child: Text("Plans".toUpperCase(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600))),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [RoutineTemplatesScreen(), RoutinePlansScreen()],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  void _showMenuBottomSheet() {
    displayBottomSheet(
        context: context,
        isScrollControlled: true,
        child: SafeArea(
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const FaIcon(
                FontAwesomeIcons.plus,
                size: 18,
              ),
              horizontalTitleGap: 6,
              title: Text("Create new workout template", style: Theme.of(context).textTheme.bodyLarge),
              onTap: () {
                Navigator.of(context).pop();
                navigateToRoutineTemplateEditor(context: context);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const FaIcon(
                FontAwesomeIcons.plus,
                size: 18,
              ),
              horizontalTitleGap: 6,
              title: Text("Create new workout plan", style: Theme.of(context).textTheme.bodyLarge),
              onTap: () {
                Navigator.of(context).pop();
                navigateToRoutineTemplateEditor(context: context);
              },
            ),
          ]),
        ));
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
