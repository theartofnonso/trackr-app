import 'package:flutter/material.dart';

import '../widgets/buttons/text_button_widget.dart';

class ActivityTrackingScreen extends StatefulWidget {
  final String activity;

  const ActivityTrackingScreen({super.key, required this.activity});

  @override
  State<ActivityTrackingScreen> createState() => _ActivityTrackingScreenState();
}

class _ActivityTrackingScreenState extends State<ActivityTrackingScreen> {
  void _navigateToActivityOverviewScreen() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Text(widget.activity,
                  style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(
                height: 3,
              ),
              const Text("2 hours 15 mins",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              const Spacer(),
              CTextButtonWidget(
                onPressed: _navigateToActivityOverviewScreen,
                label: "Stop tracking",
              )
            ],
          ),
        ),
      ),
    );
  }
}
