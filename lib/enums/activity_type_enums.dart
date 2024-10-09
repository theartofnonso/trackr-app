import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum ActivityType {
  assaultBike("Assault Bike", FontAwesomeIcons.personBiking),
  spin("Spin", FontAwesomeIcons.personBiking),
  boxing("Boxing", FontAwesomeIcons.personHarassing, image: "boxing"),
  football("Football", FontAwesomeIcons.football),
  badminton("Badminton", FontAwesomeIcons.baseball, image: "badminton"),
  handball("Handball", FontAwesomeIcons.baseball, image: "handball"),
  hockey("Hockey", FontAwesomeIcons.baseball, image: "hockey"),
  barre("Barre", FontAwesomeIcons.personDress),
  basketball("Basketball", FontAwesomeIcons.basketball),
  baseball("Baseball", FontAwesomeIcons.baseball, image: "baseball"),

  climber("Climber", FontAwesomeIcons.person, image: "climber"),
  rockclimbing("Rock Climbing", FontAwesomeIcons.person, image: "rock_climbing"),
  rugby("Rugby", FontAwesomeIcons.football),
  cycling("Cycling", FontAwesomeIcons.personBiking),
  cricket("Cricket", FontAwesomeIcons.baseball, image: "cricket"),
  running("Running", FontAwesomeIcons.personRunning),

  dancing("Dancing", FontAwesomeIcons.personDress),
  diving("Diving", FontAwesomeIcons.personDrowning),

  hiit("HIIT", FontAwesomeIcons.dumbbell, image: 'dumbbells'),
  elliptical("Elliptical", FontAwesomeIcons.personBiking),
  fencing("Fencing", FontAwesomeIcons.chessKnight, image: "fencing"),
  golf("Golf", FontAwesomeIcons.golfBallTee),
  yoga("Yoga", FontAwesomeIcons.personPraying, image: 'yoga'),
  skating("Skating", FontAwesomeIcons.personSkating),
  kegels("Kegels", FontAwesomeIcons.person),
  skateboarding("Skateboarding", FontAwesomeIcons.personSnowboarding, image: "skateboarding"),
  martialArts("Martial Arts", FontAwesomeIcons.person, image: "martial_arts"),
  tennis("Tennis", FontAwesomeIcons.tableTennisPaddleBall, image: "tennis"),
  tableTennis("Table Tennis", FontAwesomeIcons.tableTennisPaddleBall),
  paintBall("Paint Ball", FontAwesomeIcons.gun),
  parkour("Parkour", FontAwesomeIcons.person),
  pilates("Pilates", FontAwesomeIcons.person, image: 'pilates'),
  walking("Walking", FontAwesomeIcons.personWalking),
  swimming("Swimming", FontAwesomeIcons.person, image: "swimming"),
  boxFitness("Box Fitness", FontAwesomeIcons.circle),
  snowboarding("Snow Boarding", FontAwesomeIcons.personSnowboarding),
  other("Other Activity", FontAwesomeIcons.circle),
  hiking("Hiking", FontAwesomeIcons.personHiking),
  skiing("Skiing", FontAwesomeIcons.personSkiing),
  functionalFitness("Functional Fitness", FontAwesomeIcons.dumbbell, image: 'dumbbells'),
  gymnastics("Gymnastics", FontAwesomeIcons.circle),
  netball("Netball", FontAwesomeIcons.baseball),
  padel("Padel", FontAwesomeIcons.baseball),
  powerlifting("Powerlifting", FontAwesomeIcons.dumbbell, image: 'dumbbells'),
  weightlifting("Weightlifting", FontAwesomeIcons.dumbbell, image: 'dumbbells');

  const ActivityType(this.name, this.icon, {this.image});

  final String name;
  final IconData icon;
  final String? image;

  static ActivityType fromString(String string) {
    return ActivityType.values.firstWhere((value) => value.name == string);
  }
}