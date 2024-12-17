import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../controllers/routine_user_controller.dart';
import '../../dtos/appsync/routine_user_dto.dart';
import '../../shared_prefs.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/general_utils.dart';
import '../buttons/opacity_button_widget.dart';
import '../routine/editors/textfields/double_textfield.dart';
import '../user_icon_widget.dart';

class CreateRoutineUserProfileWidget extends StatefulWidget {
  const CreateRoutineUserProfileWidget({
    super.key,
  });

  @override
  State<CreateRoutineUserProfileWidget> createState() => _CreateRoutineUserProfileState();
}

class _CreateRoutineUserProfileState extends State<CreateRoutineUserProfileWidget> {
  bool _hasRegexError = false;
  bool _hasWeightError = false;

  double _weight = 0;

  final _usernameEditingController = TextEditingController();

  final _weightEditingController = TextEditingController();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: GestureDetector(
        onTap: _dismissKeyboard,
        child: Container(
          padding: const EdgeInsets.only(top: 16, right: 16, bottom: 16, left: 16),
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
            Center(
              child: UserIconWidget(size: 60, iconSize: 22),
            ),
            const SizedBox(
              height: 20,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              titleAlignment: ListTileTitleAlignment.center,
              minTileHeight: 8,
              title: Text("Weight",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.ubuntu(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                  textAlign: TextAlign.start),
              subtitle: Text("Enter your weight in ${weightLabel().toUpperCase()}",
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
                      value: _weight,
                      controller: _weightEditingController,
                      onChanged: (value) {
                        setState(() {
                          _weight = value;
                        });
                      })),
            ),
            if (_hasWeightError)
              Text("Please enter your weight.",
                  style: GoogleFonts.ubuntu(fontSize: 10, fontWeight: FontWeight.w400, color: Colors.redAccent),
                  textAlign: TextAlign.start),
            const SizedBox(
              height: 20,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _usernameEditingController,
                    maxLength: 15,
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(color: sapphireLighter)),
                        filled: true,
                        fillColor: sapphireDark,
                        hintText: "Enter a username",
                        hintStyle: GoogleFonts.ubuntu(color: Colors.grey, fontSize: 14)),
                    cursorColor: Colors.white,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.none,
                    style: GoogleFonts.ubuntu(
                        fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha:0.8), fontSize: 14),
                  ),
                ),
                const SizedBox(
                  width: 6,
                ),
                OpacityButtonWidget(
                  onPressed: _createUser,
                  label: "Create",
                  loading: _isLoading,
                  buttonColor: vibrantGreen,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
                ),
              ],
            ),
            if (_hasRegexError)
              Text("Username must not contain symbols or spaces.",
                  style: GoogleFonts.ubuntu(fontSize: 10, fontWeight: FontWeight.w400, color: Colors.redAccent),
                  textAlign: TextAlign.start),
          ]),
        ),
      ),
    );
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void _createUser() async {
    _dismissKeyboard();
    final username = _usernameEditingController.text.trim().toLowerCase();

    /// Check if the weight is set
    if (_weight == 0) {
      setState(() {
        _hasWeightError = true;
        _hasRegexError = false;
      });
      return;
    }

    /// Check if the username is empty
    if (username.isEmpty) {
      setState(() {
        _hasRegexError = false;
        _hasWeightError = false;
      });
      return;
    }

    /// Check if username is valid
    final RegExp regex = RegExp(r'^[a-zA-Z0-9]+$');
    if (!regex.hasMatch(username)) {
      setState(() {
        _hasRegexError = true;
        _hasWeightError = false;
      });
      return;
    }

    /// Begin loading
    setState(() {
      _isLoading = true;
      _hasRegexError = false;
      _hasWeightError = false;
    });

    if (!mounted) return;

    final routineUserController = Provider.of<RoutineUserController>(context, listen: false);
    final newUser = RoutineUserDto(
      id: "",
      name: username,
      cognitoUserId: SharedPrefs().userId,
      email: SharedPrefs().userEmail,
      weight: _weight,
      owner: "",
    );

    final createdUser = await routineUserController.saveUser(userDto: newUser);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    // Navigate back and show the result
    Navigator.of(context).pop();

    if (createdUser != null) {
      showSnackbar(
        context: context,
        icon: const FaIcon(FontAwesomeIcons.circleInfo),
        message: "$username profile has been created.",
      );
    } else {
      showSnackbar(
        context: context,
        icon: const FaIcon(FontAwesomeIcons.triangleExclamation),
        message: "Unable to create $username profile.",
      );
    }
  }

  @override
  void dispose() {
    _usernameEditingController.dispose();
    _weightEditingController.dispose();
    super.dispose();
  }
}
