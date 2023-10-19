import 'package:flutter/cupertino.dart';
import 'package:tracker_app/screens/routines_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screens = [const RoutinesScreen(), ];
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.search_circle_fill),
            label: 'Explore',
          ),
        ],
      ), tabBuilder: (BuildContext context, int index) { return screens[index]; },

    );
  }
}
