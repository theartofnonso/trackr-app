import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker_app/screens/templates/routine_plans.dart';
import 'package:tracker_app/screens/templates/routine_templates_screen.dart';

class RoutineTemplatesHomeScreen extends StatefulWidget {

  static const routeName = '/routine_templates_home_screen';

  const RoutineTemplatesHomeScreen({super.key});

  @override
  State<RoutineTemplatesHomeScreen> createState() => _RoutineTemplatesHomeScreenState();
}

class _RoutineTemplatesHomeScreenState extends State<RoutineTemplatesHomeScreen> with SingleTickerProviderStateMixin {
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
                        child: Text("Pathways".toUpperCase(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600))),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      RoutineTemplatesScreen(),
                      RoutinePlansScreen()
                    ],
                  ),
                ),
              ],
            ),
          ),
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
