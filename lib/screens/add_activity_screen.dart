
import 'package:flutter/material.dart';

import '../providers/activity_provider.dart';
import '../widgets/buttons/button_wrapper_widget.dart';
import '../widgets/buttons/text_button_widget.dart';

class AddActivityScreen extends StatefulWidget {

  final Activity? activity;

  const AddActivityScreen({super.key, this.activity});

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {

  late TextEditingController _activityController;


  @override
  void initState() {
    super.initState();
    _activityController = TextEditingController();
  }

  void _navigateToActivitySelectionScreen() {
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
              Row(
                children: [
                  CButtonWrapperWidget(onPressed: _navigateToActivitySelectionScreen, child: const  Icon(Icons.close, color: Colors.white,))
                ],
              ),
              const SizedBox(height: 20,),
              TextField(controller: _activityController,),
              const Spacer(),
              CTextButtonWidget(
                onPressed: _navigateToActivitySelectionScreen,
                label: "Save",
              )
            ],
          ),
        ),
      ),
    );
  }
}