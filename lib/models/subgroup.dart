import 'dart:ui';

import 'package:divvy/models/chore.dart';
import 'package:divvy/models/member.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

/// represents a subgroup of users
class Subgroup {
  // ID of the user. Same as Firestore doc ID
  final SubgroupID _id;
  // Subgroup's name
  final String _name;
  // For now, color of subgroup's profile
  // To be changed when users can add profile pictures.
  final Color _profilePicture;
  // List of member user IDs
  final List<MemberID> _members;
  // List of specific chores
  final List<ChoreID> _chores;

  Subgroup({
    required SubgroupID id,
    required Color profilePicture,
    required String name,
    required List<ChoreID> chores,
    required List<MemberID> members,
  }) : _id = id,
       _name = name,
       _profilePicture = profilePicture,
       _chores = chores,
       _members = members;

  /// Creates a new subgroup object (no chores)
  factory Subgroup.fromNew({
    required List<MemberID> members,
    required String name,
    required Color color,
  }) {
    final id = uuid.v4();
    return Subgroup(
      id: id,
      profilePicture: color,
      name: name,
      chores: [],
      members: members,
    );
  }

  /// From a json map, returns a new Subgroup object
  /// with relevant fields filled out.
  factory Subgroup.fromJson(Map<String, dynamic> json) {
    return Subgroup(
      name: json['name'],
      id: json['id'],
      chores: (json['chores'] as List<dynamic>).cast<ChoreInstID>(),
      members: (json['members'] as List<dynamic>).cast<MemberID>(),
      profilePicture: json['profilePicture'] as Color,
    );
  }

  /// Returns subgroup object as json
  Map<String, dynamic> toJson() {
    return {
      'name': _name,
      'id': _id,
      'chores': _chores,
      'members': _members,
      'profilePicture': _profilePicture,
    };
  }

  //// Getters
  String get id => _id;
  String get name => _name;
  Color get profilePicture => _profilePicture;
  List<ChoreInstID> get chores => List.from(_chores);
  List<MemberID> get members => List.from(_members);

  /// setters

  /// remove a member from subgroup
  void removeMember(MemberID memID) {
    _members.remove(memID);
  }
}

// Simplify definitions
typedef SubgroupID = String;
