import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/controllers/routine_user_controller.dart';
import 'package:tracker_app/dtos/appsync/routine_user_dto.dart';
import 'package:tracker_app/extensions/datetime/datetime_extension.dart';
import 'package:tracker_app/utils/dialog_utils.dart';
import 'package:tracker_app/widgets/list_tile.dart';

import '../../colors.dart';
import '../../enums/gender_enums.dart';
import '../../logger.dart';
import '../../utils/general_utils.dart';
import '../../widgets/buttons/opacity_button_widget.dart';
import '../../widgets/dividers/label_divider.dart';
import '../../widgets/picker.dart';
import '../preferences/settings_screen.dart';

class UserEditorScreen extends StatefulWidget {
  static const routeName = '/user-editor';

  const UserEditorScreen({super.key});

  @override
  State<UserEditorScreen> createState() => _UserEditorScreenState();
}

class _UserEditorScreenState extends State<UserEditorScreen> {
  final logger = getLogger(className: "_UserEditorScreenState");

  late TextEditingController _nameController;

  final TextEditingController _weightController = TextEditingController();

  RoutineUserDto? _user;

  WeightUnit _weightUnit = WeightUnit.kg;

  HeightUnit _heightUnit = HeightUnit.ft;

  num _weight = 0.0;

  num _height = 0.0;

  Gender _gender = Gender.other;

  DateTime _dateOfBirth = DateTime.now();

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

    final user = _user;

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
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: themeGradient(context: context),
            ),
            child: SafeArea(
              minimum: const EdgeInsets.all(10),
              bottom: false,
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(spacing: 10, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                  Divider(color: isDarkMode ? Colors.white70.withValues(alpha: 0.1) : Colors.grey.shade200),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                       const Spacer(),
                        CupertinoSlidingSegmentedControl<WeightUnit>(
                          backgroundColor: isDarkMode ? sapphireDark : Colors.grey.shade400,
                          thumbColor: isDarkMode ? sapphireDark80 : Colors.white,
                          groupValue: _weightUnit,
                          children: {
                            WeightUnit.kg: SizedBox(
                                width: 30,
                                child: Text(WeightUnit.kg.display,
                                    style: Theme.of(context).textTheme.bodySmall,
                                    textAlign: TextAlign.center)),
                            WeightUnit.lbs: SizedBox(
                                width: 30,
                                child: Text(WeightUnit.lbs.display,
                                    style: Theme.of(context).textTheme.bodySmall,
                                    textAlign: TextAlign.center)),
                          },
                          onValueChanged: (WeightUnit? value) {
                            if (value != null) {
                              setState(() {
                                _weightUnit = value;
                              });
                            }
                          },
                        ),
                      ]),
                      Column(children: [
                        LabelDivider(
                          label: "Weight",
                          labelColor: isDarkMode ? Colors.white : Colors.black,
                          dividerColor: sapphireLighter,
                          fontSize: 16,
                        ),
                        const SizedBox(height: 4),
                        Text("Establishes a baseline for tracking progress, estimating calorie needs, and personalizing your fitness plan.",
                            textAlign: TextAlign.start,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w400, color: isDarkMode ? Colors.white70 : Colors.black)),
                        const SizedBox(height: 10),
                        ThemeListTile(
                          child: ListTile(
                            onTap: _selectWeight,
                            leading: Text("$_weight ${_weightUnit.display}",
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
                    ],
                  ),
                  Divider(color: isDarkMode ? Colors.white70.withValues(alpha: 0.1) : Colors.grey.shade200),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Spacer(),
                        CupertinoSlidingSegmentedControl<HeightUnit>(
                          backgroundColor: isDarkMode ? sapphireDark : Colors.grey.shade400,
                          thumbColor: isDarkMode ? sapphireDark80 : Colors.white,
                          groupValue: _heightUnit,
                          children: {
                            HeightUnit.ft: SizedBox(
                                width: 30,
                                child: Text("Kg",
                                    style: Theme.of(context).textTheme.bodySmall,
                                    textAlign: TextAlign.center)),
                            HeightUnit.cm: SizedBox(
                                width: 30,
                                child: Text("Lbs",
                                    style: Theme.of(context).textTheme.bodySmall,
                                    textAlign: TextAlign.center)),
                          },
                          onValueChanged: (HeightUnit? value) {
                            if (value != null) {
                              setState(() {
                                _heightUnit = value;
                              });
                            }
                          },
                        ),
                      ]),
                      Column(children: [
                        LabelDivider(
                          label: "Height",
                          labelColor: isDarkMode ? Colors.white : Colors.black,
                          dividerColor: sapphireLighter,
                          fontSize: 16,
                        ),
                        const SizedBox(height: 4),
                        Text("Establishes a baseline for tracking progress, estimating calorie needs, and personalizing your fitness plan.",
                            textAlign: TextAlign.start,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w400, color: isDarkMode ? Colors.white70 : Colors.black)),
                        const SizedBox(height: 10),
                        ThemeListTile(
                          child: ListTile(
                            onTap: _selectGender,
                            leading: Text("$_weight${weightLabel()}",
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
                    ],
                  ),
                  Divider(color: isDarkMode ? Colors.white70.withValues(alpha: 0.1) : Colors.grey.shade200),
                  Column(children: [
                    LabelDivider(
                      label: "Gender",
                      labelColor: isDarkMode ? Colors.white : Colors.black,
                      dividerColor: sapphireLighter,
                      fontSize: 16,
                    ),
                    const SizedBox(height: 4),
                    Text("Helps tailor workout intensity and recovery guidance, as biological differences can affect training responses.",
                        textAlign: TextAlign.start,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w400, color: isDarkMode ? Colors.white70 : Colors.black)),
                    const SizedBox(height: 10),
                    ThemeListTile(
                      child: ListTile(
                        onTap: _selectGender,
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
                  Divider(color: isDarkMode ? Colors.white70.withValues(alpha: 0.1) : Colors.grey.shade200),
                  Column(children: [
                    LabelDivider(
                      label: "Age",
                      labelColor: isDarkMode ? Colors.white : Colors.black,
                      dividerColor: sapphireLighter,
                      fontSize: 16,
                    ),
                    const SizedBox(height: 4),
                    Text("Influences metabolism, recovery speed, and risk factors, so we can customize your program safely.",
                        textAlign: TextAlign.start,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w400, color: isDarkMode ? Colors.white70 : Colors.black)),
                    const SizedBox(height: 10),
                    ThemeListTile(
                      child: ListTile(
                        onTap: _selectDate,
                        leading: Text(_dateOfBirth.formattedDayAndMonthAndYear(),
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
                    SafeArea(
                      minimum: EdgeInsets.all(10),
                      child: SizedBox(
                        width: double.infinity,
                        child: OpacityButtonWidget(
                            onPressed: _updateUser,
                            label: user != null ? "Update Profile" : "Create Profile",
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
    showDateTimePicker(
        context: context,
        onChangedDateTime: (DateTime datetime) {
          Navigator.of(context).pop();
          setState(() {
            _dateOfBirth = datetime;
          });
        },
        mode: CupertinoDatePickerMode.date);
  }

  void _selectWeight() {
    final values = switch(_weightUnit) {
      WeightUnit.kg => generateNumbers(start: 23, end: 204),
      WeightUnit.lbs => generateNumbers(start: 51, end: 450),
    };

    final unitLabel = switch(_weightUnit) {
      WeightUnit.kg => WeightUnit.kg.display,
      WeightUnit.lbs => WeightUnit.lbs.display,
    };

    FocusScope.of(context).unfocus();
    displayBottomSheet(
        height: 240,
        context: context,
        child: GenericPicker(
          items: values,
          labelBuilder: (value) => "$value $unitLabel",
          onItemSelected: (value) {
            Navigator.of(context).pop();
            setState(() {
              _weight = value;
            });
          },
        ));
  }

  void _selectHeight() {
    final values = switch(_weightUnit) {
      WeightUnit.kg => generateNumbers(start: 23, end: 204),
      WeightUnit.lbs => generateNumbers(start: 51, end: 450),
    };

    final unitLabel = switch(_weightUnit) {
      WeightUnit.kg => "kg",
      WeightUnit.lbs => "lbs",
    };

    FocusScope.of(context).unfocus();
    displayBottomSheet(
        height: 240,
        context: context,
        child: GenericPicker(
          items: values,
          labelBuilder: (value) => "$value $unitLabel",
          onItemSelected: (value) {
            Navigator.of(context).pop();
            setState(() {
              _weight = value;
            });
          },
        ));
  }

  void _selectGender() {
    FocusScope.of(context).unfocus();
    displayBottomSheet(
        height: 240,
        context: context,
        child: GenericPicker(
          items: Gender.values,
          labelBuilder: (gender) => gender.name,
          onItemSelected: (value) {
            Navigator.of(context).pop();
            setState(() {
              _gender = value;
            });
          },
        ));
  }

  void _updateUser() async {
    final user = _user;
    if (user != null) {
      final userToUpdate =
          user.copyWith(weight: _weight, height: _height, name: _nameController.text, dateOfBirth: _dateOfBirth, gender: _gender);
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
    _nameController = TextEditingController(text: _user?.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    super.dispose();
  }
}
