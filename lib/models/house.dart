import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:divvy/models/member.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

/// represents a house with a collection of users
class House {
  // ID of the house. Same as Firestore doc ID
  final HouseID _id;
  // Date/time house was created. Stored in firestore as TimeStamp
  final DateTime _dateCreated;
  // image ID of the house's profile picture. Same as image ID in Cloud Storage
  final String _imageID;
  // user-assigned name of the house
  String _name;
  // List of member IDs. Each ID is unique to the user & the same as their
  // firestore doc ID
  final List<MemberID> _members;
  // The unique join code for a house.
  final String _joinCode;

  House({
    required HouseID id,
    required DateTime dateCreated,
    required String imageID,
    required String name,
    required List<MemberID> members,
    required String joinCode,
  }) : _id = id,
       _dateCreated = dateCreated,
       _imageID = imageID,
       _name = name,
       _members = members,
       _joinCode = joinCode;

  /// Creates a new house object
  factory House.fromNew({
    required String houseName,
    required String uid,
    required String joinCode,
  }) {
    final dateCreated = DateTime.now();
    // no initial members other than current user
    final houseID = uuid.v4();
    final members = [uid];
    return House(
      dateCreated: dateCreated,
      id: houseID,
      imageID: '',
      members: members,
      name: houseName,
      joinCode: joinCode,
    );
  }

  /// From a json map, returns a new House object
  /// with relevant fields filled out.
  factory House.fromJson(Map<String, dynamic> json) {
    return House(
      name: json['name'],
      id: json['id'],
      members: (json['members'] as List<dynamic>).cast<MemberID>(),
      dateCreated: (json['dateCreated'] as Timestamp).toDate(),
      imageID: json['imageID'],
      joinCode: json['joinCode'],
    );
  }

  /// Converts the house object to a firestore-compatible map
  Map<String, dynamic> toJson() {
    return {
      'name': _name,
      'id': _id,
      'members': _members,
      'dateCreated': Timestamp.fromDate(_dateCreated),
      'imageID': _imageID,
      'joinCode': _joinCode,
    };
  }

  HouseID get id => _id;
  DateTime get dateCreated => _dateCreated;
  String get imageID => _imageID;
  String get name => _name;
  List<MemberID> get members => List.from(_members);
  String get joinCode => _joinCode;

  /// setters

  /// Removes a member from the house
  void removeMember(MemberID memID) {
    _members.remove(memID);
  }

  /// Change the house's name
  void changeName(String newName) {
    _name = newName;
  }
}

// Simplify definitions
typedef HouseID = String;
typedef ImageID = String;
