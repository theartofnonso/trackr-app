import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dialog_utils.dart';

Future<void> openUrl({required String url, required BuildContext context}) async {
  final Uri uri = Uri.parse(url);
  final isSuccessful = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!isSuccessful) {
    if (context.mounted) {
      showSnackbar(
          context: context, icon: const FaIcon(FontAwesomeIcons.circleInfo), message: "Oops! Something went wrong.");
    }
  }
}