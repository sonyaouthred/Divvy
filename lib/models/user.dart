import 'package:divvy/models/house.dart';
import 'package:divvy/models/member.dart';

/// Represents basic data about a user, just their id, email, and house id
class DivvyUser {
  // User's uid. Same as their FirebaseAuth ID
  final String id;
  // User's email
  Email email;
  // User's house id that they belong to
  HouseID houseID;

  DivvyUser({required this.id, required this.email, required this.houseID});

  /// Creates a new user not in a house
  factory DivvyUser.fromNew({required String uid, required String email}) =>
      DivvyUser(id: uid, email: email, houseID: '');

  /// Creates a new User object from a JSON object
  factory DivvyUser.fromJson(Map<String, dynamic> data) =>
      DivvyUser(email: data['email'], id: data['id'], houseID: data['houseID']);

  /// Returns a json object for the current user
  Map<String, dynamic> toJson() => {
    'email': email,
    'id': id,
    'houseID': houseID,
  };
}
