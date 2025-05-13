import 'dart:ffi';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:divvy/models/chore.dart';
import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/models/subgroup.dart';
import 'package:flutter/material.dart';

/// represents a house with a collection of users
class Member {
  // ID of the user. Same as Firestore doc ID
  MemberID _id;
  // User's name
  String name;
  // Date/time user joined house.
  DateTime _dateJoined;
  // For now, color of user's profile picture.
  // To be changed when users can add profile pictures.
  Color profilePicture;
  // On time record. num on time / total, rounded to int & * 100
  int onTimePct;
  // List of chore instance IDs
  List<ChoreInstID> chores;
  // email
  Email email;
  // member's subgroups
  List<SubgroupID> subgroups;

  Member({
    required MemberID id,
    required DateTime dateJoined,
    required this.profilePicture,
    required this.name,
    required this.chores,
    required this.onTimePct,
    required this.email,
    required this.subgroups,
  }) : _id = id,
       _dateJoined = dateJoined;

  /// Creates a new member from uid, email, and name.
  factory Member.fromNew({
    required String uid,
    required Email email,
    required String name,
  }) {
    final time = DateTime.now();
    return Member(
      chores: [],
      name: name,
      id: uid,
      email: email,
      dateJoined: time,
      profilePicture: Colors.black,
      onTimePct: 0,
      subgroups: [],
    );
  }

  /// From a json map, returns a new User object
  /// with relevant fields filled out.
  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      name: json['name'],
      id: json['id'],
      chores: (json['chores'] as List<dynamic>).cast<ChoreInstID>(),
      dateJoined: (json['dateJoined'] as Timestamp).toDate(),
      profilePicture: getColorFromName(json['profilePicture']),
      onTimePct: int.parse(json['onTimePct'] as String),
      email: json['email'],
      subgroups: (json['subgroups'] as List<dynamic>).cast<SubgroupID>(),
    );
  }

  /// Returns member object as json
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': _id,
      'chores': chores,
      'dateJoined': Timestamp.fromDate(_dateJoined),
      'profilePicture': getNameFromColor(profilePicture),
      'onTimePct': onTimePct,
      'email': email,
      'subgroups': subgroups,
    };
  }

  //// Getters
  String get id => _id;
  DateTime get dateJoined => _dateJoined;
}

// Simplify definitions
typedef MemberID = String;
typedef Email = String;

/// Returns a string for a given color
String getNameFromColor(Color color) => switch (color) {
  DivvyTheme.darkGreen => 'darkGreen',
  DivvyTheme.mediumGreen => 'mediumGreen',
  DivvyTheme.lightGreen => 'lightGreen',
  DivvyTheme.brightRed => 'red',
  DivvyTheme.darkGrey => 'darkGrey',
  DivvyTheme.lightGrey => 'lightGrey',
  DivvyTheme.black => 'black',
  Color() => 'black',
};

/// Returns a color for a given string
Color getColorFromName(String name) => switch (name) {
  'darkGreen' => DivvyTheme.darkGreen,
  'mediumGreen' => DivvyTheme.mediumGreen,
  'lightGreen' => DivvyTheme.lightGreen,
  'red' => DivvyTheme.brightRed,
  'darkGrey' => DivvyTheme.darkGrey,
  'lightGrey' => DivvyTheme.lightGrey,
  'black' => DivvyTheme.black,
  String() => DivvyTheme.black,
};
