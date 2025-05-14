import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:divvy/models/house.dart';
import 'package:divvy/models/member.dart';

/// Represents basic data about a user, just their id, email, and house id
class DivvyUser {
  // User's uid. Same as their FirebaseAuth ID
  final String id;
  // User's email
  final Email email;
  // User's house id that they belong to
  final HouseID houseID;

  DivvyUser({required this.id, required this.email, required this.houseID});

  /// Creates a new user not in a house
  factory DivvyUser.fromNew({required String uid, required String email}) {
    return DivvyUser(id: uid, email: email, houseID: '');
  }

  /// Creates a new User object from a JSON object
  factory DivvyUser.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return DivvyUser(
      email: data?['email'],
      id: data?['id'],
      houseID: data?['houseID'],
    );
  }

  /// Returns a json object for the current user
  Map<String, dynamic> toFirestore() {
    return {'email': email, 'id': id, 'houseID': houseID};
  }
}
