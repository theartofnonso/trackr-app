import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tracker_app/screens/not_found.dart';
import 'package:tracker_app/utils/general_utils.dart';
import 'package:tracker_app/widgets/label_divider.dart';

import '../../colors.dart';
import '../../controllers/routine_user_controller.dart';
import '../../dtos/appsync/routine_user_dto.dart';
import '../../utils/dialog_utils.dart';
import '../../widgets/pickers/weight_picker.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({
    super.key,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  RoutineUserDto? _user;

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
        padding: const EdgeInsets.only(top: 16, right: 16, bottom: 28, left: 16),
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
              child: Container(
                  width: 80, // Width and height should be equal to make a perfect circle
                  height: 80,
                  decoration: BoxDecoration(
                    color: sapphireDark80,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(5), // Optional border
                    boxShadow: [
                      BoxShadow(
                        color: sapphireDark.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: const Center(child: FaIcon(FontAwesomeIcons.solidUser, color: Colors.white54, size: 34))),
            ),
            const SizedBox(
              height: 16,
            ),
            SizedBox(
              width: double.infinity,
              child: Text("@${user.name}",
                  style: GoogleFonts.ubuntu(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                  textAlign: TextAlign.center),
            ),
            const SizedBox(
              height: 26,
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
              onTap: () {
                displayBottomSheet(
                    height: 240,
                    context: context,
                    child: WeightPicker(
                        initialWeight: user.weight,
                        onSelect: (int weight) {
                          _updateWeight(newWeight: weight);
                        }));
              },
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
              trailing: Text("${user.weight}${weightLabel()}",
                  style: GoogleFonts.ubuntu(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white70),
                  textAlign: TextAlign.start),
            )
          ]),
        ),
      ),
    );
  }

  void _updateWeight({required int newWeight}) async {
    final user = _user;
    if (user != null) {
      final userToUpdate = user.copyWith(weight: newWeight);
      await Provider.of<RoutineUserController>(context, listen: false).updateUser(userDto: userToUpdate);
      if(mounted) {
        Navigator.of(context).pop();
      }
      setState(() {
        _user = userToUpdate;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _user = Provider.of<RoutineUserController>(context, listen: false).user;
  }
}
