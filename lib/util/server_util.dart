import 'dart:convert';

import 'package:divvy/models/chore.dart';
import 'package:divvy/models/house.dart';
import 'package:divvy/models/member.dart';
import 'package:divvy/models/subgroup.dart';
import 'package:divvy/models/swap.dart';
import 'package:divvy/models/user.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart';

///////////////////////// Generic Server functions //////////////////////////

/// Posts the inputted data to the server's serverFunc.
Future<bool> _postToServer({
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
Future<Map<String, dynamic>?> _getDataFromServer({
  required String serverFunc,
}) async {
  final uri = 'http://127.0.0.1:5000/$serverFunc';
  final headers = {'Content-Type': 'application/json'};
  final response = await get(Uri.parse(uri), headers: headers);

  if (response.statusCode != 200) {
    // error occurred
    return null;
  }
  return json.decode(response.body);
}

///////////////////////// Fetch //////////////////////////

/// Fetches a user doc. Updates DB
Future<DivvyUser?> fetchUser(String userID) async {
  final receivedData = await _getDataFromServer(serverFunc: 'get-user-$userID');
  if (receivedData == null) return null;
  return DivvyUser.fromJson(receivedData);
}

/// Fetches house data. If not found, returns null.
Future<House?> fetchHouse(HouseID house) async {
  final data = await _getDataFromServer(serverFunc: 'get-house-$house');
  if (data == null) return null;
  return House.fromJson(data);
}

/// Fetches member data. If not found, returns null.
Future<Map<MemberID, Member>?> fetchMembers(HouseID houseID) async {
  final data = await _getDataFromServer(
    serverFunc: 'get-house-$houseID-members',
  );
  if (data == null) return null;
  final Map<MemberID, Member> memMap = {};
  for (MemberID memID in data.keys) {
    // parse member
    final member = Member.fromJson(data[memID]);
    memMap[member.id] = member;
  }
  return memMap;
}

/// Fetches swap data. If not found, returns null.
Future<Map<SwapID, Swap>?> fetchSwaps(HouseID houseID) async {
  final data = await _getDataFromServer(serverFunc: 'get-house-$houseID-swaps');
  if (data == null) return null;
  final Map<SwapID, Swap> swapMap = {};
  for (SwapID swapID in data.keys) {
    // parse member
    final swap = Swap.fromJson(data[swapID]);
    swapMap[swap.id] = swap;
  }
  return swapMap;
}

/// Fetches subgroup data. If not found, returns null or {}.
Future<Map<SubgroupID, Subgroup>?> fetchSubgroups(HouseID houseID) async {
  final data = await _getDataFromServer(
    serverFunc: 'get-house-$houseID-subgroups',
  );
  if (data == null) return null;
  final Map<SubgroupID, Subgroup> subs = {};
  for (SubgroupID id in data.keys) {
    // put subgroup object in map
    final subgroup = Subgroup.fromJson(data[id]);
    subs[subgroup.id] = subgroup;
  }
  return subs;
}

/// Fetches a single subgroup. If not found, returns null.
Future<Subgroup?> fetchSubgroup(SubgroupID subID, HouseID houseID) async {
  final data = await _getDataFromServer(
    serverFunc: 'get-house-$houseID-subgroup-$subID',
  );
  if (data == null) return null;
  return Subgroup.fromJson(data);
}

/// Fetches chore data. If not found, returns null.
Future<Map<ChoreID, Chore>?> fetchChores(HouseID houseID) async {
  final data = await _getDataFromServer(
    serverFunc: 'get-house-$houseID-chores',
  );
  if (data == null) return null;
  // data is a map of subgroupIDs to subgroups
  final Map<ChoreID, Chore> choreMap = {};
  for (ChoreID id in data.keys) {
    // put subgroup object in map
    final chore = Chore.fromJson(data[id]);
    choreMap[chore.id] = chore;
  }
  return choreMap;
}

/// Fetches chore instance data. If not found, returns null.
Future<Map<ChoreID, List<ChoreInst>>?> fetchChoreInstances(
  HouseID houseID,
) async {
  final data = await _getDataFromServer(
    serverFunc: 'get-house-$houseID-chore-instances',
  );
  if (data == null) return null;
  final Map<ChoreID, List<ChoreInst>> choreInstMap = {};
  for (ChoreID id in data.keys) {
    // put subgroup object in map
    final choreInst = ChoreInst.fromJson(data[id]);
    choreInstMap[choreInst.superID] == null
        ? choreInstMap[choreInst.superID] = [choreInst]
        : choreInstMap[choreInst.superID]!.add(choreInst);
  }
  return choreInstMap;
}

// Fetches notifications data
Future<Map<ChoreID, List<ChoreInst>>?> fetchNotificationInstances(
  HouseID houseID, String userID
) async {
  // final data = await _getDataFromServer(serverFunc: );
}

///////////////////////// Upsert //////////////////////////

/// Creates a user doc. Updates DB. TESTED
Future<bool> createUser(String uid, String email, String name) async {
  final user = DivvyUser.fromNew(uid: uid, email: email, name: name);
  return await upsertUser(user);
}

/// Add a user to a house. Updates DB. Returns House object, or null. TESTED
Future<House?> addUserToHouse(DivvyUser user, String joinCode) async {
  final houseJson = await _getDataFromServer(
    serverFunc: 'get-house-join-$joinCode',
  );
  if (houseJson == null) return null;
  final House house = House.fromJson(houseJson);
  // add member doc
  final member = Member.fromNew(
    uid: user.id,
    email: user.email,
    name: user.name,
  );
  await upsertMember(member, house.id);
  // Now add user to house
  user.houseID = house.id;
  await upsertUser(user);
  return house;
}

/// Upserts a user doc. Updates DB. TESTED
Future<bool> upsertUser(DivvyUser user) async {
  return await _postToServer(data: user.toJson(), serverFunc: 'upsert-user');
}

/// Deletes a user doc. Updates DB. TESTED
Future<void> deleteUser(String userID) async {
  await _postToServer(data: {'id': userID}, serverFunc: 'delete-user-$userID');
}

/// Upserts a member doc. Updates DB. TESTED
Future<void> upsertMember(Member member, HouseID houseID) async {
  await _postToServer(
    data: member.toJson(),
    serverFunc: 'upsert-member-$houseID',
  );
}

/// Deletes a member doc. Updates DB. TESTED
Future<void> deleteMember({
  required HouseID houseID,
  required MemberID memberID,
}) async {
  await _postToServer(
    data: {'id': memberID},
    serverFunc: 'delete-member-$houseID',
  );
}

/// Upserts a member doc. Updates DB. TESTED
Future<void> upsertSwap(Swap swap, HouseID houseID) async {
  await _postToServer(data: swap.toJson(), serverFunc: 'upsert-swap-$houseID');
}

/// Deletes a member doc. Updates DB. TESTED
Future<void> deleteSwap({
  required HouseID houseID,
  required SwapID swapID,
}) async {
  await _postToServer(data: {'id': swapID}, serverFunc: 'delete-swap-$houseID');
}

/// Create a house & update the user's doc with the houseID. TESTED
/// Three writes: Creates house document, adds user as a member, updates user's
/// doc with the house ID. TESTED
Future<bool> createHouse(DivvyUser user, House house, String userName) async {
  await _postToServer(data: house.toJson(), serverFunc: 'add-house');
  // add member doc & update user doc
  final member = Member.fromNew(
    uid: user.id,
    email: user.email,
    name: userName,
  );
  await upsertMember(member, house.id);
  user.houseID = house.id;
  await upsertUser(user);
  return true;
}

/// Upserts a house doc. Updates DB. TESTED
Future<void> upsertHouse(House house) async {
  await _postToServer(data: house.toJson(), serverFunc: 'upsert-house');
}

/// Deletes house data. TESTED
Future<void> deleteHouse(HouseID houseID) async {
  await _postToServer(
    data: {'id': houseID},
    serverFunc: 'delete-house-$houseID',
  );
}

/// Upserts a subgroup doc. Updates DB. TESTED
Future<void> upsertSubgroup(Subgroup sub, HouseID houseID) async {
  await _postToServer(
    data: sub.toJson(),
    serverFunc: 'upsert-subgroup-$houseID',
  );
}

/// Deletes a super chore doc. Updates DB. TESTED
Future<void> deleteSubgroup({
  required HouseID houseID,
  required SubgroupID subgroupID,
}) async {
  await _postToServer(
    data: {'id': subgroupID},
    serverFunc: 'delete-subgroup-$houseID',
  );
}

/// Upserts a super chore. Updates DB. TESTED
Future<void> upsertChore(Chore chore, HouseID houseID) async {
  await _postToServer(
    data: chore.toJson(),
    serverFunc: 'upsert-chore-$houseID',
  );
}

/// Deletes a super chore doc. Updates DB. TESTED
Future<void> deleteChore({
  required HouseID houseID,
  required ChoreID choreID,
}) async {
  await _postToServer(
    data: {'id': choreID},
    serverFunc: 'delete-chore-$houseID',
  );
}

/// Upserts a chore instance. Updates DB.
Future<void> upsertChoreInst(ChoreInst choreInst, HouseID houseID) async {
  await _postToServer(
    data: choreInst.toJson(),
    serverFunc: 'upsert-chore-instance-$houseID',
  );
}

/// Deletes a super chore doc. Updates DB.
Future<void> deleteChoreInst({
  required HouseID houseID,
  required ChoreInstID choreInstID,
}) async {
  await _postToServer(
    data: {'id': choreInstID},
    serverFunc: 'delete-chore-instance-$houseID',
  );
}
