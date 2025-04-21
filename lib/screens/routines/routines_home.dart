import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker_app/screens/routines/routine_plans_screen.dart';
import 'package:tracker_app/screens/routines/routine_templates_screen.dart';

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
