import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/widgets/buttons/opacity_button_widget.dart';
import 'package:tracker_app/widgets/label_divider.dart';
import 'package:tracker_app/widgets/routine/editors/textfields/double_textfield.dart';
import 'package:tracker_app/widgets/user_icon_widget.dart';

import '../../colors.dart';
import '../../controllers/routine_user_controller.dart';
import '../../dtos/appsync/routine_user_dto.dart';
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
        decoration: BoxDecoration(
          gradient: themeGradient(context: context),
        ),
        child: SafeArea(
          minimum: const EdgeInsets.all(10),
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
              label: "Metrics",
              labelColor: isDarkMode ? Colors.white70 : Colors.black,
              dividerColor: sapphireLighter,
              shouldCapitalise: true,
            ),
            const SizedBox(
              height: 20,
            ),
            ListTile(
              titleAlignment: ListTileTitleAlignment.top,
              title: Text("Weight", maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.start),
              subtitle: Text("We use your weight to calculate your calories burned.", textAlign: TextAlign.start),
              trailing: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: sapphireLighter, // Border color
                      width: 1.0, // Border width
                    ),
                    borderRadius: BorderRadius.circular(5), // Rounded corners
                  ),
                  width: 70,
                  child: DoubleTextField(
                      value: _user?.weight ?? 0,
                      controller: _doubleTextFieldController,
                      onChanged: (value) {
                        setState(() {
                          _weight = value;
                        });
                      })),
            ),
            const Spacer(),
            SizedBox(
                width: double.infinity,
                child: OpacityButtonWidget(
                  onPressed: _updateWeight,
                  label: "Save",
                  buttonColor: vibrantGreen,
                  padding: EdgeInsets.symmetric(vertical: 10),
                )),
          ]),
        ),
      ),
    );
  }

  void _updateWeight() async {
    final user = _user;
    if (user != null) {
      final userToUpdate = user.copyWith(weight: _weight);
      await Provider.of<RoutineUserController>(context, listen: false).updateUser(userDto: userToUpdate);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _user = Provider.of<RoutineUserController>(context, listen: false).user;
  }
}
