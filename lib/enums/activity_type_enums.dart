import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum ActivityType {
  assaultBike("Assault Bike", FontAwesomeIcons.personBiking),
  football("Football", FontAwesomeIcons.football),
  badminton("Badminton", FontAwesomeIcons.baseball),
  barre("Barre", FontAwesomeIcons.personDress),
  basketball("Basketball", FontAwesomeIcons.basketball),
  baseball("Baseball", FontAwesomeIcons.baseball),
  boxing("Boxing", FontAwesomeIcons.baseball),
  climber("Climber", FontAwesomeIcons.baseball),
  running("Running", FontAwesomeIcons.personRunning),
  cycling("Cycling", FontAwesomeIcons.personBiking),
  dancing("Dancing", FontAwesomeIcons.personDress),
  diving("Diving", FontAwesomeIcons.personDrowning),
  cricket("Cricket", FontAwesomeIcons.baseball),
  hiit("HIIT", FontAwesomeIcons.peopleCarryBox),
  elliptical("Elliptical", FontAwesomeIcons.personBiking),
  fencing("Fencing", FontAwesomeIcons.chessKnight),
  golf("Golf", FontAwesomeIcons.golfBallTee),
  yoga("Yoga", FontAwesomeIcons.golfBallTee),
  skating("Skating", FontAwesomeIcons.personSkating),
  martialArts("Martial Arts", FontAwesomeIcons.person),
  netBall("Net Ball", FontAwesomeIcons.basketball),
  tennis("Tennis", FontAwesomeIcons.tableTennisPaddleBall),
  paintBall("Paint Ball", FontAwesomeIcons.gun),
  parkour("Parkour", FontAwesomeIcons.person),
  pilates("Pilates", FontAwesomeIcons.person),
  walking("Walking", FontAwesomeIcons.personWalking),
  swimming("Swimming", FontAwesomeIcons.personSwimming),
  boxFitness("Box Fitness", FontAwesomeIcons.box),
  other("Other Activity", FontAwesomeIcons.circle),
  hiking("Hiking", FontAwesomeIcons.personHiking),
  recovery("Recovery", FontAwesomeIcons.person),
  functionalFitness("Functional Fitness", FontAwesomeIcons.dumbbell);

  const ActivityType(this.name, this.icon);

  final String name;
  final IconData icon;

  static ActivityType fromString(String string) {
    return ActivityType.values.firstWhere((value) => value.name == string);
  }
}