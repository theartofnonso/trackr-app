import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../colors.dart';
import '../../utils/general_utils.dart';
import '../../widgets/buttons/opacity_button_widget.dart';
import '../../widgets/icons/apple_health_icon.dart';
import '../../widgets/icons/google_health_icon.dart';

class SahhaSensorsRequestScreen extends StatefulWidget {
  final VoidCallback onRequest;

  const SahhaSensorsRequestScreen({super.key, required this.onRequest});

  @override
  State<SahhaSensorsRequestScreen> createState() => _SahhaSensorsRequestScreenState();
}

class _SahhaSensorsRequestScreenState extends State<SahhaSensorsRequestScreen> {

  String _androidRelease = "";

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
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26.0),
                child: SizedBox(
                    height: 45,
                    width: double.infinity,
                    child: OpacityButtonWidget(
                      label: "Connect to train better",
                      buttonColor: vibrantGreen,
                      onPressed: widget.onRequest,
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _getAndroidVersion() async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final release = androidInfo.version.release;
    setState(() {
      _androidRelease = release;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _getAndroidVersion();
    });
  }
}