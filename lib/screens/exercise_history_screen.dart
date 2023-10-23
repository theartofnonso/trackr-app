import 'package:flutter/material.dart';
import 'package:tracker_app/app_constants.dart';

class ExerciseHistoryScreen extends StatelessWidget {
  const ExerciseHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Deadlift", style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const SizedBox(height: 20),
            ListTile(
              tileColor: tealBlueLight,
              title: Text("Heaviest weight", style: const TextStyle(fontSize: 16, color: Colors.white)),
              subtitle: Text("Heaviest weight since 24th, Oct 2023", style: const TextStyle(fontSize: 12, color: Colors.white70)),
              trailing: Text("160kg", style: const TextStyle(fontSize: 16, color: Colors.white)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 10),
            ListTile(
              tileColor: tealBlueLight,
              title: Text("Best Set Volume", style: const TextStyle(fontSize: 16, color: Colors.white)),
              subtitle: Text("Heaviest set since 20th Oct 2023", style: const TextStyle(fontSize: 12, color: Colors.white70)),
              trailing: Text("160kg x 8", style: const TextStyle(fontSize: 16, color: Colors.white)),
            ),
            const SizedBox(height: 10),
            ListTile(
              tileColor: tealBlueLight,
              title: Text("Best Session Volume", style: const TextStyle(fontSize: 16, color: Colors.white)),
              subtitle: Text("Heaviest session since 20th Oct 2023", style: const TextStyle(fontSize: 12, color: Colors.white70)),
              trailing: Text("2345kg", style: const TextStyle(fontSize: 16, color: Colors.white)),
            ),
            const SizedBox(height: 10),
            ListTile(
              tileColor: tealBlueLight,
              title: Text("Best 1RM", style: const TextStyle(fontSize: 16, color: Colors.white)),
              subtitle: Text("Heaviest 1RM since 20th Oct 2023", style: const TextStyle(fontSize: 12, color: Colors.white70)),
              trailing: Text("235kg", style: const TextStyle(fontSize: 16, color: Colors.white)),
            )
          ],
        ),
      )),
    );
  }
}
