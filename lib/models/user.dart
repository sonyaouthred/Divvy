import 'package:divvy/models/house.dart';
import 'package:divvy/models/member.dart';

/// Represents basic data about a user, just their id, email, house id, and name
class DivvyUser {
  // User's uid. Same as their FirebaseAuth ID
  final String id;
  // User's email
  Email email;
  // User's house id that they belong to
  HouseID houseID;
  // The display name of the user.
  String name;

  /// Creates a DivvyUser with all fields. Should only be used by factory
  /// constructors.
  DivvyUser({
    required this.id,
    required this.email,
    required this.houseID,
    required this.name,
  });

  /// Creates a new user not in a house
  factory DivvyUser.fromNew({
    required String uid,
    required String email,
    required String name,
  }) => DivvyUser(id: uid, email: email, houseID: '', name: name);

  /// Creates a new User object from a JSON object
  factory DivvyUser.fromJson(Map<String, dynamic> data) => DivvyUser(
    email: data['email'],
    id: data['id'],
    houseID: data['houseID'],
    name: data['name'] ?? 'No name',
  );

  /// Returns a json object for the current user
  Map<String, dynamic> toJson() => {
    'email': email,
    'id': id,
    'houseID': houseID,
    'name': name,
  };
}
