import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/colors.dart';

class Storyboard extends StatelessWidget {
  const Storyboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const StoryboardThree();
  }
}

class StoryboardOne extends StatelessWidget {
  const StoryboardOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrangeAccent,
      body: SafeArea(
          minimum: const EdgeInsets.all(50),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: 'You spent',
                    style: GoogleFonts.montserrat(fontSize: 36, fontWeight: FontWeight.w900, color: sapphireLighter),
                    children: [
                      const TextSpan(
                        text: " ",
                      ),
                      TextSpan(
                        text: "600",
                        style: GoogleFonts.montserrat(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white70),
                      ),
                      const TextSpan(
                        text: "\n",
                      ),
                      TextSpan(
                        text: "hours training",
                        style:
                            GoogleFonts.montserrat(fontSize: 36, fontWeight: FontWeight.w900, color: sapphireLighter),
                      ),
                      const TextSpan(
                        text: "\n",
                      ),
                      TextSpan(
                        text: "this year",
                        style:
                            GoogleFonts.montserrat(fontSize: 36, fontWeight: FontWeight.w900, color: sapphireLighter),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text("This is the total number of hours you log on the TRKR app this year",
                    style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: sapphireLighter, fontSize: 14)),
              ])),
    );
  }
}

class StoryboardTwo extends StatelessWidget {
  const StoryboardTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen,
      body: SafeArea(
          minimum: const EdgeInsets.symmetric(horizontal: 20, vertical: 100),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            RichText(
              text: TextSpan(
                text: 'Your Top',
                style: GoogleFonts.montserrat(fontSize: 36, fontWeight: FontWeight.w900, color: sapphireLighter),
                children: [
                  const TextSpan(
                    text: "\n",
                  ),
                  TextSpan(
                    text: "Exercises",
                    style: GoogleFonts.montserrat(fontSize: 36, fontWeight: FontWeight.w900, color: sapphireLighter),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SingleChildScrollView(
              child: Column(
                children: [
                  ListTile(
                    leading: SizedBox(
                      width: 50,
                      child: Row(
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.hashtag,
                            color: Colors.black,
                          ),
                          const SizedBox(width: 2),
                          Text("1",
                              style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w500, color: Colors.black, fontSize: 34)),
                        ],
                      ),
                    ),
                    contentPadding: EdgeInsets.zero,
                    title: Text("Lying Leg Curls",
                        style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: Colors.black, fontSize: 18)),
                    trailing: Text("85",
                        style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: Colors.black, fontSize: 24)),
                  ),
                  const SizedBox(height: 30),
                  ListTile(
                    leading: SizedBox(
                      width: 50,
                      child: Row(
                        children: [
                          const FaIcon(FontAwesomeIcons.hashtag, color: Colors.black),
                          const SizedBox(width: 2),
                          Text("2",
                              style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w500, color: Colors.black, fontSize: 34)),
                        ],
                      ),
                    ),
                    contentPadding: EdgeInsets.zero,
                    title: Text("Romanian Deadlift",
                        style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: Colors.black, fontSize: 18)),
                    trailing: Text("72",
                        style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: Colors.black, fontSize: 24)),
                  ),
                  const SizedBox(height: 30),
                  ListTile(
                    leading: SizedBox(
                      width: 50,
                      child: Row(
                        children: [
                          const FaIcon(FontAwesomeIcons.hashtag, color: Colors.black),
                          const SizedBox(width: 2),
                          Text("3",
                              style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w500, color: Colors.black, fontSize: 34)),
                        ],
                      ),
                    ),
                    contentPadding: EdgeInsets.zero,
                    title: Text("Plank",
                        style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: Colors.black, fontSize: 18)),
                    trailing: Text("68",
                        style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: Colors.black, fontSize: 24)),
                  ),
                  const SizedBox(height: 30),
                  ListTile(
                    leading: SizedBox(
                      width: 50,
                      child: Row(
                        children: [
                          const FaIcon(FontAwesomeIcons.hashtag, color: Colors.black),
                          const SizedBox(width: 2),
                          Text("4",
                              style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w500, color: Colors.black, fontSize: 34)),
                        ],
                      ),
                    ),
                    contentPadding: EdgeInsets.zero,
                    title: Text("Reversed Lunges",
                        style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: Colors.black, fontSize: 18)),
                    trailing: Text("53",
                        style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: Colors.black, fontSize: 24)),
                  ),
                  const SizedBox(height: 30),
                  ListTile(
                    leading: SizedBox(
                      width: 50,
                      child: Row(
                        children: [
                          const FaIcon(FontAwesomeIcons.hashtag, color: Colors.black),
                          const SizedBox(width: 2),
                          Text("5",
                              style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w500, color: Colors.black, fontSize: 34)),
                        ],
                      ),
                    ),
                    contentPadding: EdgeInsets.zero,
                    title: Text("Incline Bench Press",
                        style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: Colors.black, fontSize: 18)),
                    trailing: Text("30",
                        style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: Colors.black, fontSize: 24)),
                  ),
                ],
              ),
            ),
          ])),
    );
  }
}

class StoryboardThree extends StatelessWidget {
  const StoryboardThree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
          minimum: const EdgeInsets.only(top: 100, left: 20, right: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            RichText(
              text: TextSpan(
                text: 'Consistency',
                style: GoogleFonts.montserrat(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white),
                children: [
                  const TextSpan(
                    text: "\n",
                  ),
                  TextSpan(
                    text: "History",
                    style: GoogleFonts.montserrat(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text("See your year in a commit graph week. Saturated colours represent weeks with high intensity",
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 20),
            _ConsistencyGraph()])),
    );
  }
}

class _ConsistencyGraph extends StatelessWidget {
  final List<int> activityLevels = [0, 1, 2, 3]; // Change levels to match actual data

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.builder(
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7, // 7 days per row (week)
        ),
        itemCount: 365, // Total number of squares (days)
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.all(2),
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: getColor(activityLevels[index % activityLevels.length]),
              borderRadius: BorderRadius.circular(5),
            ),
          );
        },
      ),
    );
  }

  Color getColor(int level) {
    switch (level) {
      case 1:
        return vibrantGreen.withOpacity(0.2);
      case 2:
        return vibrantGreen.withOpacity(0.5);
      case 3:
        return vibrantGreen.withOpacity(0.8);
      case 4:
        return vibrantGreen;
      default:
        return Colors.black12;
    }
  }
}
