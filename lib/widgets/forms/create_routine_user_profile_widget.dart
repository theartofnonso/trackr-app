import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../colors.dart';
import '../../controllers/routine_user_controller.dart';
import '../../dtos/appsync/routine_user_dto.dart';
import '../../screens/preferences/settings_screen.dart';
import '../../shared_prefs.dart';
import '../../utils/dialog_utils.dart';
import '../../utils/https_utils.dart';
import '../buttons/opacity_button_widget.dart';

class CreateRoutineUserProfileWidget extends StatefulWidget {
  const CreateRoutineUserProfileWidget({
    super.key,
  });

  @override
  State<CreateRoutineUserProfileWidget> createState() => _CreateRoutineUserProfileState();
}

class _CreateRoutineUserProfileState extends State<CreateRoutineUserProfileWidget> {
  bool _hasRegexError = false;
  bool _usernameExistsError = false;

  final _editingController = TextEditingController();

  bool _isLoading = false;

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
        Text("TRKR User Profiles",
            textAlign: TextAlign.start,
            style: GoogleFonts.ubuntu(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white)),
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
        if (_usernameExistsError)
          Text("${_editingController.text} already exists.",
              style: GoogleFonts.ubuntu(fontSize: 10, fontWeight: FontWeight.w400, color: Colors.redAccent),
              textAlign: TextAlign.start),
        const SizedBox(
          height: 10,
        ),
        ListTile(
          onTap: () {
            Navigator.of(context).pop();
            showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                isDismissible: false,
                builder: (context) {
                  return const SafeArea(child: SettingsScreen());
                });
          },
          leading: Text("Settings",
              style: GoogleFonts.ubuntu(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
              textAlign: TextAlign.center),
          trailing: const FaIcon(FontAwesomeIcons.gear, color: Colors.grey),
        )
      ]),
    );
  }

  Future<bool> _doesUsernameExists({required String username}) async {
    bool doesExists = false;
    final response = await getAPI(endpoint: "/users/$username");
    if (response.isNotEmpty) {
      final json = jsonDecode(response);
      final body = json["data"];
      final routineUsers = body["listRoutineUsers"];
      final items = routineUsers["items"] as List<dynamic>;
      doesExists = items.isNotEmpty;
    }
    return doesExists;
  }

  void _createUser() async {
    final username = _editingController.text.trim().toLowerCase();
    if (username.isNotEmpty) {
      final RegExp regex = RegExp(r'^[a-zA-Z0-9]+$');
      if (!regex.hasMatch(username)) {
        setState(() {
          _hasRegexError = true;
          _usernameExistsError = false;
        });
      } else {
        setState(() {
          _isLoading = true;
          _hasRegexError = false;
        });
        final doesUserAlreadyExists = await _doesUsernameExists(username: username);
        if (doesUserAlreadyExists) {
          setState(() {
            _usernameExistsError = true;
            _hasRegexError = false;
            _isLoading = false;
          });
        } else {
          setState(() {
            _usernameExistsError = false;
          });
          if (mounted) {
            final routineUserController = Provider.of<RoutineUserController>(context, listen: false);
            final newUser = RoutineUserDto(
                id: "", name: username, cognitoUserId: SharedPrefs().userId, email: SharedPrefs().userEmail, owner: "");
            final createdUser = await routineUserController.saveUser(userDto: newUser);
            if (mounted) {
              Navigator.of(context).pop();
              if (createdUser != null) {
                showSnackbar(
                    context: context,
                    icon: const FaIcon(FontAwesomeIcons.circleInfo),
                    message: "$username profile has been created.");
              } else {
                showSnackbar(
                    context: context,
                    icon: const FaIcon(FontAwesomeIcons.circleInfo),
                    message: "Unable to create $username profile.");
              }
            }
            setState(() {
              _isLoading = false;
            });
          }
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
