// import 'dart:async';

import 'package:divvy/models/chore.dart';
import 'package:divvy/models/data.dart';
import 'package:divvy/models/house.dart';
import 'package:divvy/models/member.dart';
import 'package:divvy/models/subgroup.dart';
import 'package:divvy/util/date_funcs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nanoid/async.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Provides data about a given house and all subgroups,
/// chores, and members to the Divvy app UI.
/// Interfaces with the database to ensure data is live and
/// updated.
class DivvyProvider extends ChangeNotifier {
  late final Member _currentUser;
  late final House _house;
  late final List<Member> _members;
  late final List<Subgroup> _subgroups;
  late final List<Chore> _chores;
  late final Map<ChoreID, List<ChoreInst>> _choreInstances;

  DivvyProvider({required MemberID currentUserID}) {
    final data = Data();

    // get house info
    _house = House.fromJson(data.house);

    // get subgroup info
    final List<Subgroup> subs = [];
    for (var group in data.subgroups) {
      subs.add(Subgroup.fromJson(group));
    }
    _subgroups = subs;

    // get member info
    final List<Member> mems = [];
    for (var group in data.members) {
      mems.add(Member.fromJson(group));
    }
    _members = mems;

    // get chores info
    final List<Chore> chores = [];
    for (var chore in data.chores) {
      chores.add(Chore.fromJson(chore));
    }
    _chores = chores;

    // get chore instance infos
    final Map<ChoreID, List<ChoreInst>> choreinsts = {};
    for (var inst in data.choreInstances) {
      final choreInst = ChoreInst.fromJson(inst);
      choreinsts[choreInst.superID] == null
          ? choreinsts[choreInst.superID] = [choreInst]
          : choreinsts[choreInst.superID]!.add(choreInst);
    }
    _choreInstances = choreinsts;

    // Initialize current user
    _currentUser = _members.firstWhere((user) => user.id == currentUserID);
  }

  ////////////////////////////// Server Functions //////////////////////////////

  /// Posts the inputted data to the server's serverFunc.
  Future<void> postToServer({
    required Map<String, dynamic> data,
    required String serverFunc,
  }) async {
    print('[QUERYING SERVER]');
    final uri = 'http://127.0.0.1:5000/$serverFunc';
    final headers = {'Content-Type': 'application/json'};
    final response = await http.post(
      Uri.parse(uri),
      headers: headers,
      body: json.encode(data),
    );
    json.decode(response.body);
  }

  /// Pulls data from the server's inputted serverFunc
  Future<Map<String, dynamic>> getFromServer({
    required String serverFunc,
  }) async {
    final uri = 'http://127.0.0.1:5000/$serverFunc';
    final headers = {'Content-Type': 'application/json'};
    final response = await http.get(Uri.parse(uri), headers: headers);
    return json.decode(response.body);
  }

  ////////////////////////////// Getters //////////////////////////////

  String get houseName => _house.name;
  String get houseID => _house.id;
  String get houseJoinCode => _house.joinCode;
  List<Member> get members => List.from(_members);
  List<Subgroup> get subgroups => List.from(_subgroups);
  List<Chore> get chores => List.from(_chores);
  Member get currentUser => _currentUser;

  void addChore(Chore chore) {
    _chores.add(chore);
    notifyListeners();
  }

  void addChoreInstances(Chore chore, List<ChoreInst> choreInstances) {
    _choreInstances[chore.id] = choreInstances;
    print(chore.id);
    print(_choreInstances[chore.id]!.map((choreInst) => choreInst.id).toList());
    notifyListeners();
  }

  /// Get all members assigned to a given chore
  List<Member> getChoreAssignees(ChoreID id) {
    Chore? chore = getSuperChore(id);
    if (chore == null) return [];

    return chore.assignees
        .map((assigneeId) => getMemberById(assigneeId))
        // Filter out nulls
        .whereType<Member>()
        .toList();
  }

  /// Returns all super chores that belong to a given subgroup
  List<Chore> getSubgroupChores(SubgroupID id) {
    final subgroup =
        subgroups.where((subgroup) => subgroup.id == id).firstOrNull;
    if (subgroup == null) return [];
    // subgroup exists!
    return subgroup.chores
        .map((choreId) {
          return chores.where((chore) => chore.id == choreId).firstOrNull;
        })
        // filter out nulls
        .whereType<Chore>()
        .toList();
  }

  /// Returns all subgroup IDs
  List<SubgroupID> getAllSubgroupIds() {
    return subgroups.map((subgroup) => subgroup.id).toList();
  }

  /// Returns all super chores that belong to all subgroups
  /// (excludes general house chores)
  List<Chore> getAllSubgroupChores() {
    List<Chore> allSubgroupChores = [];
    List<SubgroupID> subgroupIDs = getAllSubgroupIds();
    for (SubgroupID subgroupID in subgroupIDs) {
      allSubgroupChores.addAll(getSubgroupChores(subgroupID));
    }

    return allSubgroupChores;
  }

  /// Returns all super chores that don't belong to any
  /// subgroup
  List<Chore> getNonSubgroupChores() {
    List<Chore> allSubgroupChores = getAllSubgroupChores();

    return chores.where((chore) => !allSubgroupChores.contains(chore)).toList();
  }

  /// Returns list of chore instances with a given super chore ID
  List<ChoreInst> getChoreInstancesFromID(ChoreID id) {
    return _choreInstances[id] ?? [];
  }

  /// Returns a chore instance that belongs to the inputted
  /// super chore & matches the passed ID
  ChoreInst getChoreInstanceFromID(
    ChoreID choreID,
    ChoreInstID choreInstanceID,
  ) {
    print(choreID);
    print(_choreInstances[choreID]!.map((choreInst) => choreInst.id).toList());
    return _choreInstances[choreID]!.firstWhere(
      (ChoreInst instance) => instance.id == choreInstanceID
    );
  }

  /// Returns a super chore with the passed id
  Chore? getSuperChore(ChoreID id) {
    return _chores.where((chore) => chore.id == id).firstOrNull;
  }

  /// Returns a list of all members that are assigned to
  /// a given super chore
  List<Member> getMembersDoingChore(ChoreID choreID) {
    Chore? chore = getSuperChore(choreID);
    if (chore == null) return [];

    // chore exists!
    List<MemberID> memberIdsOfChore = chore.assignees;
    List<Member> membersDoingChore = [];

    for (MemberID memberID in memberIdsOfChore) {
      final member = getMemberById(memberID);
      // make sure member still exists
      if (member != null) membersDoingChore.add(member);
    }

    return membersDoingChore;
  }

  /// Returns the member object matching the inputted ID
  Member? getMemberById(MemberID memberId) {
    return members.where((member) => member.id == memberId).firstOrNull;
  }

  /// Returns all chore superclasses assigned to the passed member
  List<Chore> getMemberChores(MemberID member) {
    final List<Chore> chores = [];
    for (Chore chore in _chores) {
      if (chore.assignees.contains(member)) chores.add(chore);
    }
    return chores;
  }

  /// Returns all chore instances assigned to the passed member
  List<ChoreInst> getMemberChoreInstances(MemberID member) {
    final List<ChoreInst> res = [];
    final List<Chore> chores = getMemberChores(member);
    for (Chore chore in chores) {
      final instances = _choreInstances[chore.id];
      // should never be triggered
      if (instances == null) break;
      // Add all instances assigned to this user.
      res.addAll(instances.where((inst) => inst.assignee == member).toList());
    }
    return res;
  }

  /// Returns all chore instances assigned to the passed member
  /// in the next week - not overdue or due today.
  List<ChoreInst> getUpcomingChores(MemberID member) {
    final List<ChoreInst> res = [];
    final List<Chore> chores = getMemberChores(member);
    for (Chore chore in chores) {
      final instances = _choreInstances[chore.id];
      // should never be triggered
      if (instances == null) break;
      // Add all instances assigned to this user.
      res.addAll(
        instances
            .where(
              (inst) =>
                  inst.assignee == member &&
                  // Check if the due date is before now
                  !inst.dueDate.isBefore(DateTime.now()) &&
                  // check that due date is not today
                  !isSameDay(inst.dueDate, DateTime.now()) &&
                  // Checks that the due date is within a week
                  // from now
                  inst.dueDate
                      .subtract(const Duration(days: 7))
                      .isBefore(DateTime.now()),
            )
            .toList(),
      );
    }
    res.sort((a, b) => a.dueDate.isBefore(b.dueDate) ? -1 : 1);
    return res;
  }

  List<ChoreInst> getUpcomingChoresLessStrict(MemberID member) {
    final List<ChoreInst> res = [];
    final List<Chore> chores = getMemberChores(member);
    for (Chore chore in chores) {
      final instances = _choreInstances[chore.id];
      // should never be triggered
      if (instances == null) break;
      // Add all instances assigned to this user.
      res.addAll(
        instances
            .where(
              (inst) =>
                  inst.assignee == member &&
                  // Check if the due date is before now
                  !inst.dueDate.isBefore(DateTime.now())
                  // check that due date is not today
            )
            .toList(),
      );
    }
    res.sort((a, b) => a.dueDate.isBefore(b.dueDate) ? -1 : 1);
    return res;
  }

  /// Returns list of all chore instances due today for a given member
  /// List is sorted by time
  List<ChoreInst> getTodayChores(MemberID member) {
    final List<ChoreInst> res = [];
    final List<Chore> chores = getMemberChores(member);
    for (Chore chore in chores) {
      final instances = _choreInstances[chore.id];
      // should never be triggered
      if (instances == null) break;
      // add all chores due today & assigned to this member
      res.addAll(
        instances
            .where(
              (inst) =>
                  inst.assignee == member &&
                  // Check if the due date is today
                  isSameDay(inst.dueDate, DateTime.now()),
            )
            .toList(),
      );
    }
    res.sort((a, b) => a.dueDate.isBefore(b.dueDate) ? -1 : 1);
    return res;
  }

  /// Retuns list of all chore instances overdue for a given member
  /// List is sorted by date
  List<ChoreInst> getOverdueChores(MemberID member) {
    final List<ChoreInst> res = [];
    final List<Chore> chores = getMemberChores(member);
    for (Chore chore in chores) {
      final instances = _choreInstances[chore.id];
      // should never be triggered
      if (instances == null) break;
      // add all chores overdue & assigned to this member
      res.addAll(
        instances
            .where(
              (inst) =>
                  inst.assignee == member &&
                  // Check if the due date is before now
                  inst.dueDate.isBefore(DateTime.now()) &&
                  // make sure it hasn't been done
                  !inst.isDone,
            )
            .toList(),
      );
    }
    res.sort((a, b) => a.dueDate.isBefore(b.dueDate) ? -1 : 1);
    return res;
  }

  /// Retuns list of all chore instances overdue for a given super chore
  /// List is sorted by date
  List<ChoreInst> getOverdueChoresByID(Chore chore) {
    List<ChoreInst>? res = _choreInstances[chore.id];
    if (res == null) return [];
    res = [..._choreInstances[chore.id]!];
    res.removeWhere(
      (chore) => chore.dueDate.isAfter(DateTime.now()) || chore.isDone,
    );
    res.sort((a, b) => a.dueDate.isBefore(b.dueDate) ? -1 : 1);
    return res;
  }

  /// Returns top [num] leaderboard entries
  List<Member> getLeaderboardSorted(int num) {
    final List<Member> sorted = List.from(_members);
    sorted.sort((a, b) => b.onTimePct.compareTo(a.onTimePct));
    return sorted.take(num).toList();
  }

  /// Get the rank of a member based on their on time percentage
  int getRank(MemberID memberID) {
    final List<Member> sorted = List.from(_members);
    sorted.sort((a, b) => b.onTimePct.compareTo(a.onTimePct));
    return sorted.indexWhere((member) {
          return member.id == memberID;
        }) +
        1;
  }

  /// Returns list of subgroups user is involved in
  List<Subgroup> getSubgroupsForMember(MemberID id) {
    final List<Subgroup> res = [];
    final member = getMemberById(id);
    if (member == null) return res;
    for (SubgroupID subID in member.subgroups) {
      final subgroup = _subgroups.where((s) => s.id == subID).firstOrNull;
      // only add subgroup if it still exists
      if (subgroup != null) res.add(subgroup);
    }
    return res;
  }

  /// Returns list of members in subgroup
  List<Member> getMembersInSubgroup(SubgroupID id) {
    final subgroup = _subgroups.where((s) => s.id == id).firstOrNull;
    final List<Member> res = [];
    if (subgroup == null) return res;
    for (MemberID memID in subgroup.members) {
      final member = getMemberById(memID);
      if (member != null) res.add(member);
    }
    return res;
  }

  ////////////////////////////// Setters //////////////////////////////

  /// Changes the name of a super chore
  void changeName(ChoreID choreID, String name) {
    Chore? chore = getSuperChore(choreID);
    if (chore == null) return;
    chore.changeName(name);
    // TODO: update DB
    // postToServer();
    // getFromServer();
    notifyListeners();
  }

  /// Toggles if the chore is completed or not
  void toggleChoreInstanceCompletedState({
    required ChoreID superChoreID,
    required ChoreInstID choreInstId,
  }) {
    ChoreInst choreInstance = _choreInstances[superChoreID]!.firstWhere(
      (instance) => instance.id == choreInstId,
    );
    choreInstance.toggleDone();
    // TODO: update db
    notifyListeners();
  }

  /// Updates user name with inputed name
  void updateUserName(String name) {
    _currentUser.name = name;
    // TODO: update db's members collection
    notifyListeners();
  }

  /// Removes given user from the house
  void leaveHouse(MemberID id) {
    // remove user from all subgroups they may be in
    // delete subgroups that have nobody left
    for (Subgroup sub in getSubgroupsForMember(id)) {
      sub.removeMember(id);
      if (sub.members.isEmpty) {
        // delete subgroup!
        // this will handle db update
        deleteSubgroup(sub.id);
      }
    }

    /// remove user from all chores they may have belonged to
    for (Chore chore in getMemberChores(id)) {
      chore.removeAssignee(id);
      if (chore.assignees.isEmpty) {
        // delete chore bc there are no more users on it
        // this will handle db update
        deleteSuperclassChore(chore.id);
      }
    }

    // TODO: update db with updated list of house members
    print('$id left the house');
    notifyListeners();
  }

  /// Deletes a subgroup specified
  void deleteSubgroup(SubgroupID subgroupID) {
    // Delete any of their chores
    for (Chore c in getSubgroupChores(subgroupID)) {
      // delete super chore!
      // this will handle db update
      deleteSuperclassChore(c.id);
    }
    // Finally, remove the subgroup
    _subgroups.removeWhere((sub) => sub.id == subgroupID);
    // TODO: update with subgroup data
    print('$subgroupID has been deleted');
    notifyListeners();
  }

  /// Add a subgroup specified
  // TODO: complete adding subgroups
  void addSubgroup(
    String name,
    List<Member> members,
    List<Chore> chores,
    Color color,
  ) {
    final newSub = Subgroup.fromNew(
      name: name,
      members: members.map((mem) => mem.id).toList(),
      color: color,
    );
    for (Chore c in chores) {
      // add each chore to db
      addChore(c);
    }
    _subgroups.add(newSub);
    // TODO: update db with new subgroup doc
    print('$name subgroup added');
    notifyListeners();
  }

  /// Updating house name
  void updateHouseName(String newName) {
    _house.changeName(newName);
    // TODO: update DB
    print('$newName is now house name');
    notifyListeners();
  }

  /// Delete the entire house
  // TODO: implement delete entire house
  void deleteHouse() {
    // delete all subgroups
    final subgroups = List.from(_subgroups);
    for (Subgroup subgroup in subgroups) {
      // deletes all subgroups & their chores
      deleteSubgroup(subgroup.id);
    }
    final chores = List.from(_chores);
    for (Chore chore in chores) {
      // deletes all supers & instances
      deleteSuperclassChore(chore.id);
    }
    final members = List.from(_members);
    for (Member mem in members) {
      leaveHouse(mem.id);
    }
    // TODO: db needs to delete house doc
    print('Deleting the house....');
    notifyListeners();
  }

  /// Create a new house with the given name
  void createHouse(String houseName) async {
    final joinCode = await nanoid(10);
    final newHouse = House.fromNew(
      houseName: houseName,
      uid: FirebaseAuth.instance.currentUser!.uid,
      joinCode: joinCode,
    );
    print(
      'Creating ${newHouse.name} house (id: ${newHouse.id}): join code ${newHouse.joinCode}}',
    );
    await postToServer(data: newHouse.toJson(), serverFunc: 'house');
    // TODO: update user's user doc with id
    notifyListeners();
  }

  /// Delete chore (superclass)
  // TODO: implement delete chore superclass
  void deleteSuperclassChore(String choreID) {
    // delete all chore instances
    _choreInstances[choreID] = [];
    // TODO: update db to delete all chore instance docs
    _chores.removeWhere((chore) => chore.id == choreID);
    // TODO: update db to delete chore doc
    print('Deleting $choreID chore');
    notifyListeners();
  }

  /// Adds a created chore superclass object to the database.
  /// auto generates instances for the next 90 days
  // void addChore(Chore chore) {
  //   _chores.add(chore);
  //   final assignees = chore.assignees;
  //   // get list of dates we should make instances for
  //   final dateList = getDateList(chore.frequency, DateTime.now());
  //   final List<ChoreInst> instList = [];
  //   for (int i = 0; i < dateList.length; i++) {
  //     // get date
  //     final date = dateList[i];
  //     // get assignee
  //     final assignee = assignees[i % assignees.length];
  //     // create chore instance
  //     final choreInst = ChoreInst.fromNew(
  //       superCID: chore.id,
  //       due: date,
  //       assignee: assignee,
  //     );
  //     instList.add(choreInst);
  //   }
  //   // update stored map
  //   _choreInstances[chore.id] = instList;
  //   // TODO: update db!!!!
  //   print('adding chore object to db');
  //   notifyListeners();
  // }
}
