import 'package:divvy/models/member.dart';

/// represents a house with a collection of users
class House {
  // ID of the house. Same as Firestore doc ID
  final HouseID _id;
  // Date/time house was created. Stored in firestore as TimeStamp
  final DateTime _dateCreated;
  // image ID of the house's profile picture. Same as image ID in Cloud Storage
  final String _imageID;
  // user-assigned name of the house
  final String _name;
  // List of member IDs. Each ID is unique to the user & the same as their
  // firestore doc ID
  final List<MemberID> _members;

  House({
    required HouseID id,
    required DateTime dateCreated,
    required String imageID,
    required String name,
    required List<MemberID> members,
  }) : _id = id,
       _dateCreated = dateCreated,
       _imageID = imageID,
       _name = name,
       _members = members;

  /// From a json map, returns a new House object
  /// with relevant fields filled out.
  factory House.fromJson(Map<String, dynamic> json) {
    return House(
      name: json['name'],
      id: json['id'],
      members: (json['members'] as List<dynamic>).cast<MemberID>(),
      dateCreated: json['dateCreated'],
      imageID: json['imageID'],
    );
  }

  HouseID get id => _id;
  DateTime get dateCreated => _dateCreated;
  String get imageID => _imageID;
  String get name => _name;
  List<MemberID> get members => List.from(_members);
}

// Simplify definitions
typedef HouseID = String;
typedef ImageID = String;
