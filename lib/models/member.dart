import 'package:divvy/models/chore.dart';
import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/models/subgroup.dart';
import 'package:flutter/material.dart';

/// This class represents a house with a collection of users
class Member {
  // ID of the user. Same as Firestore doc ID
  MemberID _id;
  // User's name
  String name;
  // For now, color of user's profile picture.
  // To be changed when users can add profile pictures.
  ProfileColor profilePicture;
  // On time record. num on time / total, rounded to int & * 100
  int onTimePct;
  // List of chore instance IDs
  List<ChoreInstID> chores;
  // email of the user
  Email email;
  // member's subgroups
  List<SubgroupID> subgroups;

  Member({
    required MemberID id,
    required this.profilePicture,
    required this.name,
    required this.chores,
    required this.onTimePct,
    required this.email,
    required this.subgroups,
  }) : _id = id;

  /// Creates a new member from uid, email, and name.
  factory Member.fromNew({
    required String uid,
    required Email email,
    required String name,
  }) => Member(
    chores: [],
    name: name,
    id: uid,
    email: email,
    profilePicture: ProfileColor.black,
    onTimePct: 0,
    subgroups: [],
  );

  /// From a json map, returns a new User object
  /// with relevant fields filled out.
  factory Member.fromJson(Map<String, dynamic> json) => Member(
    name: json['name'],
    id: json['id'],
    chores: (json['chores'] as List<dynamic>).cast<ChoreInstID>(),
    profilePicture: getColorFromName(json['profilePicture']),
    onTimePct:
        json['onTimePct'] is int
            ? json['onTimePct']
            : int.parse(json['onTimePct'].toString()),
    email: json['email'],
    subgroups: (json['subgroups'] as List<dynamic>).cast<SubgroupID>(),
  );

  /// Returns member object as json
  Map<String, dynamic> toJson() => {
    'name': name,
    'id': _id,
    'chores': chores,
    'profilePicture': profilePicture.name,
    'onTimePct': onTimePct,
    'email': email,
    'subgroups': subgroups,
  };

  //// Getters
  String get id => _id;
}

// Typedefs to simplify definitions
typedef MemberID = String;
typedef Email = String;

// This is used to represent the profile picture
// of a user, as we don't have a way for users to upload
// images yet.
enum ProfileColor {
  darkGreen,
  mediumGreen,
  lightGreen,
  brightRed,
  darkGrey,
  lightGrey,
  black,
}

/// helpful functions for the ProfilePicture enum.
extension ProfileColorInfo on ProfileColor {
  /// Returns a string for a given color
  String get name => switch (this) {
    ProfileColor.darkGreen => 'darkGreen',
    ProfileColor.mediumGreen => 'mediumGreen',
    ProfileColor.lightGreen => 'lightGreen',
    ProfileColor.brightRed => 'red',
    ProfileColor.darkGrey => 'darkGrey',
    ProfileColor.lightGrey => 'lightGrey',
    ProfileColor.black => 'black',
  };

  /// Returns a color for a given string
  Color get color => switch (this) {
    ProfileColor.darkGreen => DivvyTheme.darkGreen,
    ProfileColor.mediumGreen => DivvyTheme.mediumGreen,
    ProfileColor.lightGreen => DivvyTheme.lightGreen,
    ProfileColor.brightRed => DivvyTheme.brightRed,
    ProfileColor.darkGrey => DivvyTheme.darkGrey,
    ProfileColor.lightGrey => DivvyTheme.lightGrey,
    ProfileColor.black => DivvyTheme.black,
  };
}

/// Returns a ProfileColor for a given string (intended to be
/// used when de-jsonifying a ProfileColor entry).
ProfileColor getColorFromName(String name) => switch (name) {
  'darkGreen' => ProfileColor.darkGreen,
  'mediumGreen' => ProfileColor.mediumGreen,
  'lightGreen' => ProfileColor.lightGreen,
  'red' => ProfileColor.brightRed,
  'darkGrey' => ProfileColor.darkGrey,
  'lightGrey' => ProfileColor.lightGrey,
  'black' => ProfileColor.black,
  String() => ProfileColor.black,
};
