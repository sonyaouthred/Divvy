import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:divvy/models/chore.dart';
import 'package:divvy/models/subgroup.dart';
import 'package:flutter/material.dart';

/// represents a house with a collection of users
class Member {
  // ID of the user. Same as Firestore doc ID
  MemberID _id;
  // User's name
  String _name;
  // Date/time user joined house.
  DateTime _dateJoined;
  // For now, color of user's profile picture.
  // To be changed when users can add profile pictures.
  Color _profilePicture;
  // On time record. num on time / total, rounded to int & * 100
  int _onTimePct;
  // List of chore instance IDs
  List<ChoreInstID> _chores;
  // email
  Email _email;
  // member's subgroups
  List<SubgroupID> _subgroups;

  Member({
    required MemberID id,
    required DateTime dateJoined,
    required Color profilePicture,
    required String name,
    required List<ChoreInstID> chores,
    required int onTimePct,
    required Email email,
    required List<SubgroupID> subgroups,
  }) : _id = id,
       _name = name,
       _dateJoined = dateJoined,
       _profilePicture = profilePicture,
       _onTimePct = onTimePct,
       _chores = chores,
       _email = email,
       _subgroups = subgroups;

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
      profilePicture: json['profilePicture'] as Color,
      onTimePct: json['onTimePct'] as int,
      email: json['email'],
      subgroups: (json['subgroups'] as List<dynamic>).cast<SubgroupID>(),
    );
  }

  /// Returns member object as json
  Map<String, dynamic> toJson() {
    return {
      'name': _name,
      'id': _id,
      'chores': _chores,
      'dateJoined': Timestamp.fromDate(_dateJoined),
      'profilePicture': _profilePicture,
      'onTimePct': _onTimePct,
      'email': _email,
      'subgroups': _subgroups,
    };
  }

  //// Getters
  String get id => _id;
  String get name => _name;
  int get onTimePct => _onTimePct;
  DateTime get dateJoined => _dateJoined;
  Color get profilePicture => _profilePicture;
  List<ChoreInstID> get chores => List.from(_chores);
  List<SubgroupID> get subgroups => List.from(_subgroups);
  String get email => _email;

  /// Setters
  set name(String name) => _name = name;
}

// Simplify definitions
typedef MemberID = String;
typedef Email = String;
