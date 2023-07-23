import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/activity_provider.dart';
import '../widgets/buttons/button_wrapper_widget.dart';
import '../widgets/buttons/gradient_button_widget.dart';
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

  Activity? _newActivity;

  @override
  void initState() {
    super.initState();
    _activityController = TextEditingController(text: widget.activity?.label);
    _activityProvider = Provider.of<ActivityProvider>(context, listen: false);
  }

  void _goBack() {
    Navigator.of(context).pop(_newActivity);
  }

  void _showActivityTrackingScreen({required String activityId}) async {
    await showDialog(
        context: context,
        builder: ((context) {
          return ActivityTrackingScreen(
            activityId: activityId,
            activityLabel: _activityController.text,
          );
        }));
    if (mounted) {
      _goBack();
    }
  }

  void _addNewActivity() {
    final activityToAdd = _activityController.text;
    if (activityToAdd.isNotEmpty) {
      final newActivity =
          _activityProvider.addNewActivity(name: _activityController.text);
      _showActivityTrackingScreen(activityId: newActivity.id);
      setState(() {
        _newActivity = newActivity;
      });
    }
  }

  void _editNewActivity() {
    final activityToAdd = _activityController.text;
    if (activityToAdd.isNotEmpty) {
      _activityProvider.editNewActivity(
        oldActivity: widget.activity!,
        activityLabel: _activityController.text,
      );
      _goBack();
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
                      onPressed: _goBack,
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
                textCapitalization: TextCapitalization.words,
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
              GradientButton(
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
