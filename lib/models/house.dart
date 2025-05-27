import 'dart:io';

import 'package:uuid/uuid.dart';

// used to generate unique IDs for each document.
const uuid = Uuid();

/// This class represents a house with a collection of users
class House {
  // ID of the house. Same as Firestore doc ID
  final HouseID _id;
  // image ID of the house's profile picture. Same as image ID in Cloud Storage
  final String _imageID;
  // user-assigned name of the house
  String name;
  // The unique join code for a house.
  final String _joinCode;
  // The date this house was created.
  final DateTime _dateCreated;

  /// Creates a house with all fields. Should only be used by factory
  /// constructors.
  House({
    required HouseID id,
    required String imageID,
    required this.name,
    required String joinCode,
    required DateTime dateCreated,
  }) : _id = id,
       _imageID = imageID,

       _joinCode = joinCode,
       _dateCreated = dateCreated;

  /// Creates a new house object.
  factory House.fromNew({
    required String houseName,
    required String uid,
    required String joinCode,
  }) {
    // no initial members other than current user
    final houseID = uuid.v4();
    return House(
      id: houseID,
      imageID: '',
      name: houseName,
      joinCode: joinCode,
      dateCreated: DateTime.now(),
    );
  }

  /// From a json map, returns a new House object
  /// with relevant fields filled out.
  factory House.fromJson(Map<String, dynamic> json) => House(
    name: json['name'],
    id: json['id'],
    imageID: json['imageID'],
    joinCode: json['joinCode'],
    dateCreated: HttpDate.parse(json['dateCreated']),
  );

  /// Converts the house object to a firestore-compatible map
  Map<String, dynamic> toJson() => {
    'name': name,
    'id': _id,
    'imageID': _imageID,
    'joinCode': _joinCode,
    'dateCreated': HttpDate.format(_dateCreated),
  };

  // Getters

  HouseID get id => _id;
  String get imageID => _imageID;
  String get joinCode => _joinCode;
}

// Typedefs to simplify definitions
typedef HouseID = String;
typedef ImageID = String;
