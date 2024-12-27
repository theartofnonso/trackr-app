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
import '../icons/user_icon_widget.dart';

class CreateRoutineUserProfileWidget extends StatefulWidget {
  const CreateRoutineUserProfileWidget({
    super.key,
  });

  @override
  State<CreateRoutineUserProfileWidget> createState() => _CreateRoutineUserProfileState();
}

class _CreateRoutineUserProfileState extends State<CreateRoutineUserProfileWidget> {
  bool _hasRegexError = false;

  final _usernameEditingController = TextEditingController();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: GestureDetector(
        onTap: _dismissKeyboard,
        child: Container(
          padding: const EdgeInsets.only(top: 16, right: 16, bottom: 16, left: 16),
          decoration: BoxDecoration(
              color: isDarkMode ? sapphireDark80 : Colors.grey.shade100,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              gradient: isDarkMode ? themeGradient(context: context) : null),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(
              child: UserIconWidget(size: 60, iconSize: 22),
            ),
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
                    cursorColor: isDarkMode ? Colors.white : Colors.black,
                    decoration: InputDecoration(
                      hintText: "Enter username",
                    ),
                    maxLines: 1,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.none,
                    style: GoogleFonts.ubuntu(
                        fontWeight: FontWeight.w400, color: isDarkMode ? Colors.white : Colors.black, fontSize: 14),
                  ),
                ),
                const SizedBox(
                  width: 6,
                ),
                SizedBox(
                  height: 45,
                  child: OpacityButtonWidget(
                    onPressed: _createUser,
                    label: "Create",
                    loading: _isLoading,
                    buttonColor: vibrantGreen,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
                  ),
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

    /// Check if the username is empty
    if (username.isEmpty) {
      setState(() {
        _hasRegexError = false;
      });
      return;
    }

    /// Check if username is valid
    final RegExp regex = RegExp(r'^[a-zA-Z0-9]+$');
    if (!regex.hasMatch(username)) {
      setState(() {
        _hasRegexError = true;
      });
      return;
    }

    /// Begin loading
    setState(() {
      _isLoading = true;
      _hasRegexError = false;
    });

    if (!mounted) return;

    final routineUserController = Provider.of<RoutineUserController>(context, listen: false);
    final newUser = RoutineUserDto(
      id: "",
      name: username,
      cognitoUserId: SharedPrefs().userId,
      email: SharedPrefs().userEmail,
      weight: 0,
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
    super.dispose();
  }
}
