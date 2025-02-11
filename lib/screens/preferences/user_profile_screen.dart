import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/screens/training_goal_screen.dart';
import 'package:tracker_app/widgets/buttons/opacity_button_widget.dart';
import 'package:tracker_app/widgets/dividers/label_divider.dart';
import 'package:tracker_app/widgets/icons/user_icon_widget.dart';
import 'package:tracker_app/widgets/list_tile.dart';
import 'package:tracker_app/widgets/routine/editors/textfields/double_textfield.dart';

import '../../colors.dart';
import '../../controllers/routine_user_controller.dart';
import '../../dtos/appsync/routine_user_dto.dart';
import '../../enums/training_goal_enums.dart';
import '../../utils/general_utils.dart';
import '../../widgets/empty_states/not_found.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({
    super.key,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  RoutineUserDto? _user;

  final _doubleTextFieldController = TextEditingController();

  double _weight = 0;

  TrainingGoal _trainingGoal = TrainingGoal.hypertrophy;

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final user = _user;

    if (user == null) return const NotFound();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, size: 28),
          onPressed: context.pop,
        ),
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: themeGradient(context: context),
        ),
        child: SafeArea(
          minimum: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Center(
                      child: UserIconWidget(size: 60, iconSize: 22),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: Text(user.name.toUpperCase(),
                          style: Theme.of(context).textTheme.titleSmall, textAlign: TextAlign.center),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    LabelDivider(
                      label: "Enter your weight".toUpperCase(),
                      labelColor: isDarkMode ? Colors.white : Colors.black,
                      dividerColor: sapphireLighter,
                      fontSize: 14,
                    ),
                    const SizedBox(height: 8),
                    Text("We estimate the amount of calories burned using your weight.",
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w400, color: isDarkMode ? Colors.white70 : Colors.black)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDarkMode ? Colors.white10 : Colors.black38, // Border color
                          width: 1, // Border width
                        ),
                        borderRadius: BorderRadius.circular(5), // Rounded corners
                      ),
                      width: double.infinity,
                      child: DoubleTextField(
                          value: _user?.weight ?? 0,
                          controller: _doubleTextFieldController,
                          onChanged: (value) {
                            setState(() {
                              _weight = value;
                            });
                          }),
                    ),
                    const SizedBox(height: 22),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      LabelDivider(
                        label: "Select a training goal".toUpperCase(),
                        labelColor: isDarkMode ? Colors.white : Colors.black,
                        dividerColor: sapphireLighter,
                        fontSize: 14,
                      ),
                      const SizedBox(height: 8),
                      Text(user.trainingGoal.description,
                          textAlign: TextAlign.start,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w400, color: isDarkMode ? Colors.white70 : Colors.black)),
                      const SizedBox(height: 8),
                      ThemeListTile(
                        child: ListTile(
                          onTap: _updateTrainingGoal,
                          dense: true,
                          horizontalTitleGap: 0,
                          leading: Text(_trainingGoal.displayName,
                              textAlign: TextAlign.start,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: isDarkMode ? Colors.white : Colors.black)),
                          trailing: FaIcon(
                            FontAwesomeIcons.arrowRightLong,
                            size: 14,
                          ),
                        ),
                      )
                    ]),
                  ]),
                ),
              ),
              SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: OpacityButtonWidget(
                    onPressed: _updateUser,
                    label: "Save Profile",
                    buttonColor: vibrantGreen,
                    padding: EdgeInsets.symmetric(vertical: 10),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _updateUser() async {
    final user = _user;
    if (user != null) {
      final userToUpdate = user.copyWith(weight: _weight, trainingGoal: _trainingGoal);
      await Provider.of<RoutineUserController>(context, listen: false).updateUser(userDto: userToUpdate);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _updateTrainingGoal() async {
    final trainingGoal = await Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => TrainingGoalScreen(trainingGoal: _trainingGoal)))
        as TrainingGoal?;

    if (trainingGoal != null) {
      setState(() {
        _trainingGoal = trainingGoal;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _user = Provider.of<RoutineUserController>(context, listen: false).user;

    _trainingGoal = _user?.trainingGoal ?? TrainingGoal.hypertrophy;
  }
}
