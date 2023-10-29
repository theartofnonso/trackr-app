import 'package:flutter/material.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/screens/settings_screen.dart';

import '../shared_prefs.dart';
import '../utils/general_utils.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _navigateTo(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const SettingsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: tealBlueDark,
        actions: [
          GestureDetector(
            onTap: () => _navigateTo(context),
            child: const Padding(
              padding: EdgeInsets.only(right: 14.0),
              child: Icon(Icons.settings),
            ),
          )
        ],
      ),
      body: const Center(child: Text("Profile"),),
    );
  }
}
