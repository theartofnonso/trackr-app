import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../no_list_empty_state.dart';

class UserChallengesScreen extends StatelessWidget {
  const UserChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const NoListEmptyState(icon: FaIcon(
      FontAwesomeIcons.trophy,
      color: Colors.white12,
      size: 48,
    ), message: "It might feel quiet now, but your active challenges will soon appear here.",);
  }
}
