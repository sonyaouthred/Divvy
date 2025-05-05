import 'package:cloud_firestore/cloud_firestore.dart';

/// represents a house with a collection of users
class House {
  // ID of the house. Same as Firestore doc ID
  HouseID id;
  // Date/time house was created. Stored in firestore as TimeStamp
  DateTime dateCreated;
  // image ID of the house's profile picture. Same as image ID in Cloud Storage
  String imageID;
  // user-assigned name of the house
  String name;
  // List of member IDs. Each ID is unique to the user & the same as their
  // firestore doc ID
  List<MemberID> members;

  House({
    required this.id,
    required this.dateCreated,
    required this.imageID,
    required this.name,
    required this.members,
  });

  /// From a Firestore document snapshot, return a new Project object
  /// with relevant fields filled out.
  factory House.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return House(
      name: data?['name'],
      id: snapshot.id,
      members: (data?['members'] as List<dynamic>).cast<MemberID>(),
      dateCreated: (data?['dateCreated'] as Timestamp).toDate(),
      imageID: data?['imageID'],
    );
  }

  /// Create a JSON-like object to be stored in firestore.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'members': members,
      'dateCreated': Timestamp.fromDate(dateCreated),
      'imageID': imageID,
    };
  }
}

// Simplify definitions
typedef HouseID = String;
typedef ImageID = String;
typedef MemberID = String;
