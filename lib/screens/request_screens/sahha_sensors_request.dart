import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../colors.dart';
import '../../utils/general_utils.dart';
import '../../widgets/buttons/opacity_button_widget_two.dart';
import '../../widgets/icons/apple_health_icon.dart';
import '../../widgets/icons/google_health_icon.dart';

class SahhaSensorsRequestScreen extends StatefulWidget {
  final VoidCallback onRequest;

  const SahhaSensorsRequestScreen({super.key, required this.onRequest});

  @override
  State<SahhaSensorsRequestScreen> createState() => _SahhaSensorsRequestScreenState();
}

class _SahhaSensorsRequestScreenState extends State<SahhaSensorsRequestScreen> {
  int _androidSDK = 0;

  @override
  Widget build(BuildContext context) {
    Brightness systemBrightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = systemBrightness == Brightness.dark;

    final deviceOS = Platform.isIOS ? "Apple Health" : "Google Health";
    final deviceIcon = Platform.isIOS
        ? AppleHealthIcon(isDarkMode: isDarkMode, height: 80)
        : GoogleHealthIcon(
            isDarkMode: isDarkMode,
            height: 80,
            elevation: isDarkMode,
          );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const FaIcon(FontAwesomeIcons.squareXmark, size: 28), onPressed: Navigator.of(context).pop),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: themeGradient(context: context)),
        child: SafeArea(
          minimum: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              deviceIcon,
              const SizedBox(height: 50),
              Text(
                "Connect to $deviceOS",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),
              Text(
                "We’d like to connect to ${deviceOS.toLowerCase()} to better understand your health and provide a more personalized training experience.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              if (_androidSDK >= 29 && _androidSDK <= 33)
                SizedBox(
                    width: double.infinity,
                    child: OpacityButtonWidgetTwo(
                      label: "Download Google Health Connect",
                      buttonColor: Colors.transparent,
                      onPressed: _openPlayStore,
                    )),
              const SizedBox(height: 50),
              SizedBox(
                  width: double.infinity,
                  child: OpacityButtonWidgetTwo(
                    label: "Connect to train better",
                    buttonColor: vibrantGreen,
                    onPressed: widget.onRequest,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _getAndroidVersion() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdk = androidInfo.version.sdkInt;
      setState(() {
        _androidSDK = sdk;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _getAndroidVersion();
    });
  }

  Future<void> _openPlayStore() async {
    final uri = Uri.parse("https://play.google.com/store/apps/details?id=com.google.android.apps.healthdata&hl=en");

    // Prefer launching in the Play-Store app; fall back to the browser.
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      // Optionally show a snackbar / dialog.
      debugPrint('Could not open the Play-Store link.');
    }
  }
}
