import 'package:divvy/models/chore.dart';
import 'package:divvy/models/member.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

/// represents a subgroup of users
class Subgroup {
  // ID of the user. Same as Firestore doc ID
  final SubgroupID _id;
  // Subgroup's name
  String name;
  // For now, color of subgroup's profile
  // To be changed when users can add profile pictures.
  ProfileColor profilePicture;
  // List of member user IDs
  final List<MemberID> members;
  // List of specific chores
  final List<ChoreID> chores;

  Subgroup({
    required SubgroupID id,
    required this.profilePicture,
    required this.name,
    required this.chores,
    required this.members,
  }) : _id = id;

  /// Creates a new subgroup object (no chores)
  factory Subgroup.fromNew({
    required List<MemberID> members,
    required String name,
    required ProfileColor color,
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
  factory Subgroup.fromJson(Map<String, dynamic> json) => Subgroup(
    name: json['name'],
    id: json['id'],
    chores: (json['chores'] as List<dynamic>).cast<ChoreInstID>(),
    members: (json['members'] as List<dynamic>).cast<MemberID>(),
    profilePicture: getColorFromName(json['profilePicture']),
  );

  /// Returns subgroup object as json
  Map<String, dynamic> toJson() => {
    'name': name,
    'id': _id,
    'chores': chores,
    'members': members,
    'profilePicture': profilePicture.name,
  };

  //// Getters
  String get id => _id;

  /// setters

  /// remove a member from subgroup
  void removeMember(MemberID memID) {
    members.remove(memID);
  }

  /// remove a chore from subgroup
  void removeChore(ChoreID choreID) {
    chores.remove(choreID);
  }
}

// Simplify definitions
typedef SubgroupID = String;
