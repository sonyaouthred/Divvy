import 'package:divvy/models/house.dart';
import 'package:divvy/models/member.dart';

/// Represents basic data about a user, just their id, email, and house id
class User {
  // User's uid. Same as their FirebaseAuth ID
  final String id;
  // User's email
  final Email email;
  // User's house id that they belong to
  final HouseID houseID;

  User({required this.id, required this.email, required this.houseID});

  /// Creates a new user not in a house
  factory User.fromNew({required String uid, required String email}) {
    return User(id: uid, email: email, houseID: '');
  }

  /// Creates a new User object from a JSON object
  factory User.fromJson(Map<String, dynamic> data) {
    return User(email: data['email'], id: data['id'], houseID: data['houseID']);
  }

  /// Returns a json object for the current user
  Map<String, dynamic> toJson() {
    return {'email': email, 'id': id, 'houseID': houseID};
  }
}
