import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum ActivityType {
  assaultBike("Assault Bike", FontAwesomeIcons.personBiking),
  boxing("Boxing", FontAwesomeIcons.personHarassing),
  football("Football", FontAwesomeIcons.football),
  badminton("Badminton", FontAwesomeIcons.baseball),
  barre("Barre", FontAwesomeIcons.personDress),
  basketball("Basketball", FontAwesomeIcons.basketball),
  baseball("Baseball", FontAwesomeIcons.baseball),

  climber("Climber", FontAwesomeIcons.person),
  cycling("Cycling", FontAwesomeIcons.personBiking),
  cricket("Cricket", FontAwesomeIcons.baseball),
  running("Running", FontAwesomeIcons.personRunning),

  dancing("Dancing", FontAwesomeIcons.personDress),
  diving("Diving", FontAwesomeIcons.personDrowning),

  hiit("HIIT", FontAwesomeIcons.dumbbell),
  elliptical("Elliptical", FontAwesomeIcons.personBiking),
  fencing("Fencing", FontAwesomeIcons.chessKnight),
  golf("Golf", FontAwesomeIcons.golfBallTee),
  yoga("Yoga", FontAwesomeIcons.personPraying),
  skating("Skating", FontAwesomeIcons.personSkating),
  martialArts("Martial Arts", FontAwesomeIcons.person),
  netBall("Net Ball", FontAwesomeIcons.circle),
  tennis("Tennis", FontAwesomeIcons.tableTennisPaddleBall),
  paintBall("Paint Ball", FontAwesomeIcons.gun),
  parkour("Parkour", FontAwesomeIcons.person),
  pilates("Pilates", FontAwesomeIcons.person),
  walking("Walking", FontAwesomeIcons.personWalking),
  swimming("Swimming", FontAwesomeIcons.person),
  boxFitness("Box Fitness", FontAwesomeIcons.circle),
  snowboarding("Snow Boarding", FontAwesomeIcons.personSnowboarding),
  other("Other Activity", FontAwesomeIcons.circle),
  hiking("Hiking", FontAwesomeIcons.personHiking),
  skiing("Box Fitness", FontAwesomeIcons.personSkiing),
  functionalFitness("Functional Fitness", FontAwesomeIcons.dumbbell);

  const ActivityType(this.name, this.icon);

  final String name;
  final IconData icon;

  static ActivityType fromString(String string) {
    return ActivityType.values.firstWhere((value) => value.name == string);
  }
}