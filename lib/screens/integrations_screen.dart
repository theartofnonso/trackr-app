import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../colors.dart';
import '../utils/health_utils.dart';

class IntegrationsScreen extends StatefulWidget {
  const IntegrationsScreen({super.key});

  @override
  State<IntegrationsScreen> createState() => _IntegrationsScreenState();
}

class _IntegrationsScreenState extends State<IntegrationsScreen> {

  bool _hasPermission = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sapphireDark,
      appBar: AppBar(
        backgroundColor: sapphireDark80,
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.arrowLeftLong, color: Colors.white, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        )
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              sapphireDark80,
              sapphireDark,
            ],
          ),
        ),
        child: SafeArea(
          minimum: const EdgeInsets.only(right: 10.0, bottom: 10.0, left: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text("Integrations",
                  style: GoogleFonts.montserrat(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 24),
              ListTile(
                onTap: _hasPermission ? null : _connectAppleHealth,
                leading: const FaIcon(
                  FontAwesomeIcons.link,
                  color: Colors.white,
                  size: 16,
                ),
                title: Text(
                  'Apple Health',
                  style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  _hasPermission ? 'Connected' : 'Connect to sync workouts',
                  style: GoogleFonts.montserrat(color: Colors.white, fontSize: 12),
                ),
                trailing: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.asset(
                      'images/apple_health.png',
                      fit: BoxFit.cover,
                      height: 35, // Adjust the height as needed
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _connectAppleHealth() async {
    final success = await connectAppleHealth();
    setState(() {
      _hasPermission = success;
    });
  }

  void _checkAppleHealthConnectivity() async {
    final success = await checkAppleHealthConnectivity();
    setState(() {
      _hasPermission = success;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAppleHealthConnectivity();
    });
  }
}
