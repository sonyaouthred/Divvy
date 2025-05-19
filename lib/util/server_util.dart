import 'dart:convert';

import 'package:divvy/models/house.dart';
import 'package:divvy/models/user.dart';
import 'package:http/http.dart';

///////////////////////// Generic Server functions //////////////////////////

/// Posts the inputted data to the server's serverFunc.
Future<bool> postToServer({
  required Map<String, dynamic> data,
  required String serverFunc,
}) async {
  final uri = 'http://127.0.0.1:5000/$serverFunc';
  final headers = {'Content-Type': 'application/json'};
  final response = await post(
    Uri.parse(uri),
    headers: headers,
    body: json.encode(data),
  );
  json.decode(response.body);
  if (response.statusCode == 400) {
    // error occurred
    return false;
  }
  return true;
}

/// Pulls data from the server's inputted serverFunc
/// will be a single json doc
Future<Map<String, dynamic>?> getDataFromServer({
  required String serverFunc,
}) async {
  final uri = 'http://127.0.0.1:5000/$serverFunc';
  final headers = {'Content-Type': 'application/json'};
  final response = await get(Uri.parse(uri), headers: headers);
  if (response.statusCode == 400) {
    // error occurred
    return null;
  }
  return json.decode(response.body);
}

///////////////////////// Specific functions for testing //////////////////////////

/// Creates a user doc. Updates DB
Future<void> createUser(String uid, String email) async {
  final user = DivvyUser.fromNew(uid: uid, email: email);
  await postToServer(data: user.toJson(), serverFunc: 'upsert-user');
}

/// Add a user to a house. Updates DB
Future<bool> addUserToHouse(DivvyUser user, String joinCode) async {
  // TODO: Check if join code is correct. if not, return false

  // TODO: obviously, replace with valid house ID
  final houseID = 'gjkldsjfdklsjfsdfdsa';
  user.houseID = houseID;
  await postToServer(data: user.toJson(), serverFunc: 'upsert-user');
  return true;
}

/// Fetches a user doc. Updates DB
Future<DivvyUser?> fetchUser(String userID) async {
  final receivedData = await getDataFromServer(serverFunc: 'get-user-$userID');
  if (receivedData == null) return null;
  return DivvyUser.fromJson(receivedData);
}

/// Deletes a user doc. Updates DB.
Future<void> deleteUser(String userID) async {
  await postToServer(data: {'id': userID}, serverFunc: 'delete-user-$userID');
}

Future<bool> createHouse(DivvyUser user, House house) async {
  await postToServer(data: house.toJson(), serverFunc: 'add-house');
  user.houseID = house.id;
  await postToServer(data: user.toJson(), serverFunc: 'upsert-user');
  return true;
}
