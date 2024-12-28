import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum ActivityType {
  assaultBike("Assault Bike", FontAwesomeIcons.circle, 5.0, image: "assault"),
  spin("Spin", FontAwesomeIcons.personBiking, 5.0),
  boxing("Boxing", FontAwesomeIcons.circle, 12.3, image: "boxing"),
  football("Football", FontAwesomeIcons.football, 8.0),
  badminton("Badminton", FontAwesomeIcons.circle, 5.5, image: "badminton"),
  handball("Handball", FontAwesomeIcons.circle, 12.0, image: "handball"),
  hockey("Hockey", FontAwesomeIcons.circle, 8.0, image: "hockey"),
  barre("Barre", FontAwesomeIcons.personDress, 2.8),
  basketball("Basketball", FontAwesomeIcons.basketball, 7.5),
  baseball("Baseball", FontAwesomeIcons.circle, 4.0, image: "baseball"),
  jumpingRope("Jumping Rope", FontAwesomeIcons.circle, 9.0, image: "jumping_rope"),
  climber("Climber", FontAwesomeIcons.circle, 11.0, image: "climber"),
  rockClimbing("Rock Climbing", FontAwesomeIcons.circle, 8.8, image: "rock_climbing"),
  kayaking("Kayaking", FontAwesomeIcons.circle, 5.0, image: "kayaking"),
  stretching("Stretching", FontAwesomeIcons.circle, 2.8, image: "stretching"),
  volley("Volley Ball", FontAwesomeIcons.circle, 3.0, image: "volley"),
  rugby("Rugby", FontAwesomeIcons.football, 6.3),
  cycling("Cycling", FontAwesomeIcons.personBiking, 7),
  cricket("Cricket", FontAwesomeIcons.circle, 4.8, image: "cricket"),
  running("Running", FontAwesomeIcons.personRunning, 10.5),
  dancing("Dancing", FontAwesomeIcons.personDress, 3.8),
  horsebackRiding("Horseback Riding", FontAwesomeIcons.horse, 5.5),
  diving("Diving", FontAwesomeIcons.personDrowning, 3.0),
  hiit("HIIT", FontAwesomeIcons.circle, image: 'dumbbells', 7.0),
  elliptical("Elliptical", FontAwesomeIcons.circle, 5.0, image: "assault"),
  fencing("Fencing", FontAwesomeIcons.circle, 6.0, image: "fencing"),
  golf("Golf", FontAwesomeIcons.golfBallTee, 4.5),
  yoga("Yoga", FontAwesomeIcons.circle, image: 'yoga', 2.3),
  skating("Skating", FontAwesomeIcons.personSkating, 7.0),
  kegels("Kegels", FontAwesomeIcons.person, 1.5),
  skateboarding("Skateboarding", FontAwesomeIcons.circle, 5.0, image: "skateboarding"),
  martialArts("Martial Arts", FontAwesomeIcons.circle, 10.3, image: "martial_arts"),
  tennis("Tennis", FontAwesomeIcons.circle, 6.8, image: "tennis"),
  tableTennis("Table Tennis", FontAwesomeIcons.circle, 4.0, image: "tennis"),
  paintBall("Paint Ball", FontAwesomeIcons.gun, 3.5),
  parkour("Parkour", FontAwesomeIcons.person, 3.5),
  pilates("Pilates", FontAwesomeIcons.circle, 2.8, image: 'pilates'),
  walking("Walking", FontAwesomeIcons.personWalking, 8.8),
  swimming("Swimming", FontAwesomeIcons.circle, 7.0, image: "swimming"),
  boxFitness("Box Fitness", FontAwesomeIcons.circle, 3.5),
  snowboarding("Snow Boarding", FontAwesomeIcons.personSnowboarding, 7.5),
  other("Other Activity", FontAwesomeIcons.circle, 1),
  hiking("Hiking", FontAwesomeIcons.personHiking, 5.3),
  skiing("Skiing", FontAwesomeIcons.personSkiing, 7.0),
  functionalFitness("Functional Fitness", FontAwesomeIcons.dumbbell, 3.5, image: 'dumbbells'),
  gymnastics("Gymnastics", FontAwesomeIcons.person, 3.8),
  netball("Netball", FontAwesomeIcons.baseball, 7.0),
  paddleBall("PaddleBall", FontAwesomeIcons.tableTennisPaddleBall, 6.0),
  powerlifting("Powerlifting", FontAwesomeIcons.circle, 6.0, image: 'dumbbells'),
  heatTherapy("Heat Therapy", FontAwesomeIcons.circle, 1.0, image: 'heat'),
  coldTherapy("Cold Therapy", FontAwesomeIcons.circle, 1.0, image: 'cold'),
  weightlifting("Weightlifting", FontAwesomeIcons.circle, image: 'dumbbells', 3.5);

  const ActivityType(this.name, this.icon, this.met, {this.image});

  final String name;
  final IconData icon;
  final double met;
  final String? image;

  static ActivityType fromJson(String string) {
    return ActivityType.values.firstWhere((value) => value.name.toLowerCase() == string.toLowerCase());
  }
}
