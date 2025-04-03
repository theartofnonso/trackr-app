import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/controllers/routine_user_controller.dart';
import 'package:tracker_app/dtos/appsync/routine_user_dto.dart';
import 'package:tracker_app/utils/dialog_utils.dart';
import 'package:tracker_app/widgets/list_tile.dart';

import '../../colors.dart';
import '../../enums/gender_enums.dart';
import '../../logger.dart';
import '../../utils/general_utils.dart';
import '../../widgets/buttons/opacity_button_widget.dart';
import '../../widgets/dividers/label_divider.dart';
import '../../widgets/routine/editors/textfields/double_textfield.dart';

class UserEditorScreen extends StatefulWidget {
  static const routeName = '/user-editor';

  final RoutineUserDto? user;

  const UserEditorScreen({super.key, this.user});

  @override
  State<UserEditorScreen> createState() => _UserEditorScreenState();
}

class _UserEditorScreenState extends State<UserEditorScreen> {
  final logger = getLogger(className: "_UserEditorScreenState");

  late TextEditingController _nameController;

  final TextEditingController _weightController = TextEditingController();

  RoutineUserDto? _user;

  double _weight = 0;

  Gender _gender = Gender.other;

  DateTime? _dateOfBirth;

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final routineUserController = Provider.of<RoutineUserController>(context, listen: true);

    if (routineUserController.errorMessage.isNotEmpty) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _showSnackbar(routineUserController.errorMessage);
      });
    }

    final user = widget.user;

    return PopScope(
        canPop: false,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const FaIcon(
                FontAwesomeIcons.squareXmark,
                size: 28,
              ),
              onPressed: context.pop,
            ),
            title: Text("Personalise your profile".toUpperCase()),
            centerTitle: true,
          ),
          body: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: themeGradient(context: context),
            ),
            child: SafeArea(
              minimum: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Column(spacing: 20, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LabelDivider(
                        label: "Username",
                        labelColor: isDarkMode ? Colors.white : Colors.black,
                        dividerColor: sapphireLighter,
                        fontSize: 16,
                      ),
                      const SizedBox(height: 4),
                      Text(
                          "Allow us to remind you about long-running workouts if you’ve become distracted. We’ll also send reminders on your training days.",
                          textAlign: TextAlign.start,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w400, color: isDarkMode ? Colors.white70 : Colors.black)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _nameController,
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
                    ],
                  ),
                  Column(children: [
                    LabelDivider(
                      label: "Weight",
                      labelColor: isDarkMode ? Colors.white : Colors.black,
                      dividerColor: sapphireLighter,
                      fontSize: 16,
                    ),
                    const SizedBox(height: 4),
                    Text("We estimate the amount of calories burned using your weight.",
                        textAlign: TextAlign.start,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w400, color: isDarkMode ? Colors.white70 : Colors.black)),
                    const SizedBox(height: 10),
                    DoubleTextField(
                        value: _user?.weight ?? 0,
                        controller: _weightController,
                        textAlign: TextAlign.start,
                        onChanged: (value) {
                          setState(() {
                            _weight = value;
                          });
                        })
                  ]),
                  Column(children: [
                    LabelDivider(
                      label: "Gender",
                      labelColor: isDarkMode ? Colors.white : Colors.black,
                      dividerColor: sapphireLighter,
                      fontSize: 16,
                    ),
                    const SizedBox(height: 4),
                    Text("We estimate the amount of calories burned using your weight.",
                        textAlign: TextAlign.start,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w400, color: isDarkMode ? Colors.white70 : Colors.black)),
                    const SizedBox(height: 10),
                    ThemeListTile(
                      child: ListTile(
                        onTap: () {},
                        dense: true,
                        horizontalTitleGap: 0,
                        leading: Text(_gender.name,
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
                  Column(children: [
                    LabelDivider(
                      label: "Age",
                      labelColor: isDarkMode ? Colors.white : Colors.black,
                      dividerColor: sapphireLighter,
                      fontSize: 16,
                    ),
                    const SizedBox(height: 4),
                    Text("We estimate the amount of calories burned using your weight.",
                        textAlign: TextAlign.start,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w400, color: isDarkMode ? Colors.white70 : Colors.black)),
                    const SizedBox(height: 10),
                    ThemeListTile(
                      child: ListTile(
                        onTap: _selectDate,
                        dense: true,
                        horizontalTitleGap: 0,
                        leading: Text(_gender.name,
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
                  if (user != null)
                    SafeArea(
                      minimum: EdgeInsets.all(10),
                      child: SizedBox(
                        width: double.infinity,
                        child: OpacityButtonWidget(
                            onPressed: () {},
                            label: "Update Profile",
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                            buttonColor: vibrantGreen),
                      ),
                    ),
                ]),
              ),
            ),
          ),
        ));
  }

  void _showSnackbar(String message) {
    showSnackbar(context: context, icon: const Icon(Icons.info_outline), message: message);
  }

  void _selectDate() {
    showDateTimePicker(context: context, onChangedDateTime: (DateTime datetime) {
      setState(() {
        _dateOfBirth = datetime;
      });
    }, mode: CupertinoDatePickerMode.date);
  }

  @override
  void initState() {
    super.initState();
    _user = Provider.of<RoutineUserController>(context, listen: false).user;
    _nameController = TextEditingController(text: _user?.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    super.dispose();
  }


}
