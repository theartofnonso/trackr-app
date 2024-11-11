import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/screens/empty_state_screens/not_found.dart';
import 'package:tracker_app/widgets/buttons/opacity_button_widget.dart';
import 'package:tracker_app/widgets/label_divider.dart';
import 'package:tracker_app/widgets/routine/editors/textfields/double_textfield.dart';
import 'package:tracker_app/widgets/user_icon_widget.dart';

import '../../colors.dart';
import '../../controllers/routine_user_controller.dart';
import '../../dtos/appsync/routine_user_dto.dart';

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
    final user = _user;

    if (user == null) return const NotFound();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: sapphireDark80,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
          onPressed: context.pop,
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            sapphireDark80,
            sapphireDark,
          ],
        )),
        child: SafeArea(
          minimum: const EdgeInsets.all(10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(
              child: UserIconWidget(size: 60, iconSize: 22),
            ),
            const SizedBox(
              height: 40,
            ),
            const LabelDivider(
              label: "Metrics",
              labelColor: Colors.white70,
              dividerColor: sapphireLighter,
              shouldCapitalise: true,
            ),
            const SizedBox(
              height: 20,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              titleAlignment: ListTileTitleAlignment.top,
              title: Text("Weight",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.ubuntu(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                  textAlign: TextAlign.start),
              subtitle: Text("We use your weight to calculate your calories burned",
                  style: GoogleFonts.ubuntu(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white70),
                  textAlign: TextAlign.start),
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
