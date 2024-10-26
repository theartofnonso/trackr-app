import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../controllers/routine_user_controller.dart';
import '../../dtos/routine_user_dto.dart';
import '../../shared_prefs.dart';
import '../../utils/dialog_utils.dart';
import '../buttons/opacity_button_widget.dart';

class CreateRoutineUserProfileWidget extends StatefulWidget {
  const CreateRoutineUserProfileWidget({
    super.key,
  });

  @override
  State<CreateRoutineUserProfileWidget> createState() => _CreateRoutineUserProfileState();
}

class _CreateRoutineUserProfileState extends State<CreateRoutineUserProfileWidget> {
  bool _hasError = false;

  final _editingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16, right: 16, bottom: 28, left: 16),
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              sapphireDark80,
              sapphireDark,
            ],
          )),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Follow the trail".toUpperCase(),
            style: GoogleFonts.ubuntu(fontSize: 12, fontWeight: FontWeight.w300, color: Colors.white70),
            textAlign: TextAlign.start),
        const SizedBox(
          height: 8,
        ),
        Text("TRKR User Profiles",
            textAlign: TextAlign.start,
            style: GoogleFonts.ubuntu(fontSize: 26, fontWeight: FontWeight.w500, color: Colors.white)),
        const SizedBox(
          height: 10,
        ),
        Text(
            "User profiles enable you to join TRKR communities. Stay tuned for upcoming features that will enhance your user experience.",
            style: GoogleFonts.ubuntu(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white38),
            textAlign: TextAlign.start),
        const SizedBox(
          height: 18,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _editingController,
                maxLength: 15,
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5), borderSide: const BorderSide(color: sapphireLighter)),
                    filled: true,
                    fillColor: sapphireDark,
                    hintText: "Enter a username",
                    hintStyle: GoogleFonts.ubuntu(color: Colors.grey, fontSize: 14)),
                cursorColor: Colors.white,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.none,
                style:
                    GoogleFonts.ubuntu(fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.8), fontSize: 14),
              ),
            ),
            const SizedBox(
              width: 6,
            ),
            OpacityButtonWidget(
              onPressed: _createUser,
              label: "Create",
              buttonColor: vibrantGreen,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
            ),
          ],
        ),
        if (_hasError)
          Text("Username must not contain symbols and spaces.",
              style: GoogleFonts.ubuntu(fontSize: 10, fontWeight: FontWeight.w400, color: Colors.redAccent),
              textAlign: TextAlign.start),
      ]),
    );
  }

  void _createUser() async {
    final username = _editingController.text.trim().toLowerCase();
    if (username.isNotEmpty) {
      final RegExp regex = RegExp(r'^(?=.*[^\w])\S{1,15}$');
      if (regex.hasMatch(username)) {
        setState(() {
          _hasError = true;
        });
      } else {
        setState(() {
          _hasError = false;
        });
        final routineUserController = Provider.of<RoutineUserController>(context, listen: false);
        final newUser = RoutineUserDto(
            id: "", name: username, cognitoUserId: SharedPrefs().userId, email: SharedPrefs().userEmail, owner: "");
        await routineUserController.saveUser(userDto: newUser);
        if (mounted) {
          Navigator.of(context).pop();
          showSnackbar(
              context: context,
              icon: const FaIcon(FontAwesomeIcons.circleInfo),
              message: "$username profile has been created.");
        }
      }
    }
  }

  @override
  void dispose() {
    _editingController.dispose();
    super.dispose();
  }
}
