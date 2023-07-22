import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/activity_provider.dart';
import '../utils/navigator_utils.dart';
import '../widgets/buttons/button_wrapper_widget.dart';
import '../widgets/buttons/text_button_widget.dart';
import 'activity_tracking_screen.dart';

class AddActivityScreen extends StatefulWidget {
  final Activity? activity;

  const AddActivityScreen({super.key, this.activity});

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  late TextEditingController _activityController;
  late ActivityProvider _activityProvider;

  @override
  void initState() {
    super.initState();
    _activityController = TextEditingController(text: widget.activity?.label);
    _activityProvider = Provider.of<ActivityProvider>(context, listen: false);
  }

  void _navigateToActivitySelectionScreen() {
    Navigator.of(context).pop();
  }

  void _navigateToActivityTrackingScreen({required String activityId}) {
    final route = createNewRouteFadeTransition(
        ActivityTrackingScreen(activityId: activityId));
    Navigator.of(context).push(route);
  }

  void _addNewActivity() {
    final activityToAdd = _activityController.text;
    if (activityToAdd.isNotEmpty) {
      final newActivity =
          _activityProvider.addNewActivity(name: _activityController.text);
      Navigator.of(context).pop();
      _navigateToActivityTrackingScreen(activityId: newActivity.id);
    }
  }

  void _editNewActivity() {
    final activityToAdd = _activityController.text;
    if (activityToAdd.isNotEmpty) {
      _activityProvider.editNewActivity(
        oldActivity: widget.activity!,
        activityLabel: _activityController.text,
      );
      _navigateToActivitySelectionScreen();
    }
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
              Row(
                children: [
                  CButtonWrapperWidget(
                      onPressed: _navigateToActivitySelectionScreen,
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ))
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                cursorColor: Colors.white,
                controller: _activityController,
                decoration: const InputDecoration(
                    hintText: "What do you want track ?",
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.black,
                    focusColor: Colors.green // Set
                    ),
              ),
              const Spacer(),
              CTextButtonWidget(
                onPressed: widget.activity == null
                    ? _addNewActivity
                    : _editNewActivity,
                label: widget.activity == null
                    ? "Start tracking"
                    : "Update activity",
              )
            ],
          ),
        ),
      ),
    );
  }
}
