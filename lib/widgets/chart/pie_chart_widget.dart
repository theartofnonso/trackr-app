import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/app_constants.dart';
import 'package:tracker_app/models/BodyPart.dart';

class PieChartWidget extends StatelessWidget {
  final List<MapEntry<BodyPart, int>> segments;

  const PieChartWidget({super.key, required this.segments});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: tealBlueDark,
      child: Row(
        children: <Widget>[
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 5,
                  centerSpaceRadius: 35,
                  sections: showingSections(),
                ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  Container(color: Colors.green, width: 10, height: 10),
                  const SizedBox(width: 5),
                  Text(segments[0].key.name)
                ],
              ),
              const SizedBox(
                height: 4,
              ),
              Row(
                children: [
                  Container(
                    color: Colors.blue,
                    width: 10,
                    height: 10,
                  ),
                  const SizedBox(width: 5),
                  Text(segments[1].key.name)
                ],
              ),
              const SizedBox(
                height: 4,
              ),
              Row(
                children: [
                  Container(
                    color: Colors.yellow,
                    width: 10,
                    height: 10,
                  ),
                  const SizedBox(width: 5),
                  Text(segments[2].key.name)
                ],
              ),
              const SizedBox(
                height: 4,
              ),
              Row(
                children: [
                  Container(
                    color: Colors.purpleAccent,
                    width: 10,
                    height: 10,
                  ),
                  const SizedBox(width: 5),
                  Text(segments[3].key.name)
                ],
              ),
              const SizedBox(
                height: 4,
              ),
              Row(
                children: [
                  Container(
                    color: Colors.pinkAccent,
                    width: 10,
                    height: 10,
                  ),
                  const SizedBox(width: 5),
                  Text(segments[4].key.name)
                ],
              )
            ],
          ),
          const SizedBox(
            width: 28,
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    final textStyle = GoogleFonts.lato(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      shadows: [const Shadow(color: Colors.white60, blurRadius: 1)],
    );

    return List.generate(5, (i) {
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Colors.green,
            value: segments[0].value.toDouble(),
            title: '${segments[0].value}',
            radius: 70,
            titleStyle: textStyle,
          );
        case 1:
          return PieChartSectionData(
            color: Colors.blue,
            value: segments[1].value.toDouble(),
            title: '${segments[1].value}',
            radius: 60,
            titleStyle: textStyle,
          );
        case 2:
          return PieChartSectionData(
            color: Colors.amber,
            value: segments[2].value.toDouble(),
            title: '${segments[2].value}',
            radius: 50,
            titleStyle: textStyle,
          );
        case 3:
          return PieChartSectionData(
            color: Colors.purpleAccent,
            value: segments[3].value.toDouble(),
            title: '${segments[3].value}',
            radius: 40,
            titleStyle: textStyle,
          );
        case 4:
          return PieChartSectionData(
            color: Colors.pinkAccent,
            value: segments[4].value.toDouble(),
            title: '${segments[4].value}',
            radius: 30,
            titleStyle: textStyle,
          );
        default:
          throw Error();
      }
    });
  }
}
