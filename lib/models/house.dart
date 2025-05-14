import 'package:uuid/uuid.dart';

const uuid = Uuid();

/// represents a house with a collection of users
class House {
  // ID of the house. Same as Firestore doc ID
  final HouseID _id;
  // image ID of the house's profile picture. Same as image ID in Cloud Storage
  final String _imageID;
  // user-assigned name of the house
  String _name;
  // The unique join code for a house.
  final String _joinCode;

  House({
    required HouseID id,
    required String imageID,
    required String name,
    required String joinCode,
  }) : _id = id,
       _imageID = imageID,
       _name = name,
       _joinCode = joinCode;

  /// Creates a new house object
  factory House.fromNew({
    required String houseName,
    required String uid,
    required String joinCode,
  }) {
    // no initial members other than current user
    final houseID = uuid.v4();
    return House(id: houseID, imageID: '', name: houseName, joinCode: joinCode);
  }

  /// From a json map, returns a new House object
  /// with relevant fields filled out.
  factory House.fromJson(Map<String, dynamic> json) => House(
    name: json['name'],
    id: json['id'],
    imageID: json['imageID'],
    joinCode: json['joinCode'],
  );

  /// Converts the house object to a firestore-compatible map
  Map<String, dynamic> toJson() => {
    'name': _name,
    'id': _id,
    'imageID': _imageID,
    'joinCode': _joinCode,
  };

  HouseID get id => _id;
  String get imageID => _imageID;
  String get name => _name;
  String get joinCode => _joinCode;

  /// setters

  /// Change the house's name
  void changeName(String newName) {
    _name = newName;
  }
}

// Simplify definitions
typedef HouseID = String;
typedef ImageID = String;
