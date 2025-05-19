// import 'dart:async';

import 'package:divvy/models/chore.dart';
import 'package:divvy/models/house.dart';
import 'package:divvy/models/member.dart';
import 'package:divvy/models/subgroup.dart';
import 'package:divvy/models/user.dart';
import 'package:divvy/util/date_funcs.dart';
import 'package:divvy/util/server_util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Provides data about a given house and all subgroups,
/// chores, and members to the Divvy app UI.
/// Interfaces with the database to ensure data is live and
/// updated.
class DivvyProvider extends ChangeNotifier {
  // The user's current user object, independent of house.
  late final DivvyUser _user;
  // true if data has loaded from the server
  late bool dataLoaded;
  // the ID of the house currently being shown
  late final HouseID _houseID;
  // The member of the house that is currently signed in
  late final Member _currentMember;
  // the currently displayed house
  late final House _house;
  // List of members that belong to the hosue
  late final List<Member> _memberList;
  // Same as above list, but mapped to by ID for quick lookup.
  late final Map<MemberID, Member> _memberMap;
  // List of all house subgroups, but mapped to by ID for quick lookup.
  late final Map<SubgroupID, Subgroup> _subgroups;
  // list of all chores for the house, mapped to by ID for quick lookup.
  late final Map<ChoreID, Chore> _chores;
  // All chore instances, mapped to by their super chore IDs.
  late final Map<ChoreID, List<ChoreInst>> _choreInstances;

  /// Instantiate a new provider
  DivvyProvider(DivvyUser currUser) {
    _user = currUser;
    _houseID = currUser.houseID;
    dataLoaded = false;
    // fetch server data
    initialize();
  }

  ////////////////////////////// Initialization //////////////////////////////

  // Initialize all the fields from the server
  void initialize() async {
    final futures = [
      _loadHouseData(),
      _loadSubgroupData(),
      _loadMemberInfo(),
      _loadChoreData(),
      _getChoreInstanceData(),
    ];

    // load data concurrently
    await Future.wait(futures);

    // Initialize current user
    final uid = FirebaseAuth.instance.currentUser!.uid;
    _currentMember = _memberMap[uid]!;
    // data is loaded!
    dataLoaded = true;
    notifyListeners();
  }

  // load house data from server
  Future<void> _loadHouseData() async {
    final data = await getDataFromServer(serverFunc: 'get-house-$_houseID');
    final house = House.fromJson(data!);
    _house = house;
    notifyListeners();
  }

  // load subgroup data from server
  Future<void> _loadSubgroupData() async {
    final data = await getDataFromServer(
      serverFunc: 'get-house-$_houseID-subgroups',
    );
    // data is a map of subgroupIDs to subgroups
    final Map<SubgroupID, Subgroup> subs = {};
    for (SubgroupID id in data!.keys) {
      // put subgroup object in map
      final subgroup = Subgroup.fromJson(data[id]);
      subs[subgroup.id] = subgroup;
    }
    _subgroups = subs;
    notifyListeners();
  }

  // / Load member info from server
  Future<void> _loadMemberInfo() async {
    try {
      final data = await getDataFromServer(
        serverFunc: 'get-house-$_houseID-members',
      );
      final List<Member> mems = [];
      final Map<MemberID, Member> memMap = {};
      for (MemberID memID in data!.keys) {
        // parse member
        final member = Member.fromJson(data[memID]);
        mems.add(member);
        memMap[member.id] = member;
      }
      _memberList = mems;
      _memberMap = memMap;
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  // load chore instance data from server
  Future<void> _getChoreInstanceData() async {
    final data = await getDataFromServer(
      serverFunc: 'get-house-$_houseID-chore-instances',
    );
    final Map<ChoreID, List<ChoreInst>> choreInstMap = {};
    for (ChoreID id in data!.keys) {
      // put subgroup object in map
      final choreInst = ChoreInst.fromJson(data[id]);
      choreInstMap[choreInst.superID] == null
          ? choreInstMap[choreInst.superID] = [choreInst]
          : choreInstMap[choreInst.superID]!.add(choreInst);
    }
    _choreInstances = choreInstMap;
    notifyListeners();
  }

  // load chore data from server
  Future<void> _loadChoreData() async {
    final data = await getDataFromServer(
      serverFunc: 'get-house-$_houseID-chores',
    );
    // data is a map of subgroupIDs to subgroups
    final Map<ChoreID, Chore> choreMap = {};
    for (ChoreID id in data!.keys) {
      // put subgroup object in map
      final chore = Chore.fromJson(data[id]);
      choreMap[chore.id] = chore;
    }
    _chores = choreMap;
    notifyListeners();
  }

  ////////////////////////////// Getters //////////////////////////////

  String get houseName => _house.name;
  String get houseID => _house.id;
  String get houseJoinCode => _house.joinCode;
  List<Member> get members => List.from(_memberList);
  List<Subgroup> get subgroups => List.from(_subgroups.values);
  List<Chore> get chores => List.from(_chores.values);
  Member get currMember => _currentMember;
  DivvyUser get currUser => _user;

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
    final subgroup = _subgroups[id];
    if (subgroup == null) return [];
    // subgroup exists!
    return subgroup.chores
        .map((choreId) => _chores[choreId])
        // filter out nulls
        .whereType<Chore>()
        .toList();
  }

  /// Returns all subgroup IDs
  List<SubgroupID> getAllSubgroupIds() {
    return List.from(_subgroups.keys);
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
    return _choreInstances[choreID]!.firstWhere(
      (ChoreInst instance) => instance.id == choreInstanceID,
    );
  }

  /// Returns a super chore with the passed id
  Chore? getSuperChore(ChoreID id) {
    return _chores[id];
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
    return _memberMap[memberId];
  }

  /// Returns all chore superclasses assigned to the passed member
  List<Chore> getMemberChores(MemberID member) {
    final List<Chore> chores = [];
    for (Chore chore in _chores.values) {
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
                  !inst.dueDate.isBefore(DateTime.now()),
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
    final List<Member> sorted = List.from(_memberList);
    sorted.sort((a, b) => b.onTimePct.compareTo(a.onTimePct));
    return sorted.take(num).toList();
  }

  /// Get the rank of a member based on their on time percentage
  int getRank(MemberID memberID) {
    final List<Member> sorted = List.from(_memberList);
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
      final subgroup = _subgroups[subID];
      // only add subgroup if it still exists
      if (subgroup != null) res.add(subgroup);
    }
    return res;
  }

  /// Returns list of members in subgroup
  List<Member> getMembersInSubgroup(SubgroupID id) {
    final subgroup = _subgroups[id];
    final List<Member> res = [];
    if (subgroup == null) return res;
    for (MemberID memID in subgroup.members) {
      final member = getMemberById(memID);
      if (member != null) res.add(member);
    }
    return res;
  }

  /// Returns the subgroup if inputted list is a subgroup.
  /// Otherwise, returns null.
  Subgroup? isSubgroup(List<MemberID> members) {
    for (Subgroup sub in _subgroups.values) {
      if (listEquals(members, sub.members)) {
        return sub;
      }
    }
    return null;
  }

  ////////////////////////////// Setters //////////////////////////////

  /// Adds a chore to this house under the correct group.
  /// Creates chore instances
  void addChore(Chore chore) {
    _chores[chore.id] = chore;
    Subgroup? sub = isSubgroup(chore.assignees);
    if (sub != null) {
      // chore should belong to this subgroup!!
      sub.chores.add(chore.id);
      // TODO: update db
    }
    // now create instances!
    final dates = getDateList(chore.frequency);

    _choreInstances[chore.id] = [];
    dates.asMap().forEach((index, date) {
      final assignee = chore.assignees[index % chore.assignees.length];
      print(assignee);
      // create chore instance
      ChoreInst choreInst = ChoreInst.fromNew(
        superCID: chore.id,
        due: date,
        assignee: assignee,
      );
      addChoreInstance(choreInst);
    });
    notifyListeners();
  }

  /// Adds a given chore instance to the database
  void addChoreInstance(ChoreInst choreInstance) {
    if (_choreInstances[choreInstance.superID] == null) return;
    _choreInstances[choreInstance.superID]!.add(choreInstance);
    // TODO: update db
    notifyListeners();
  }

  /// Updates a super chore. because frequency/members
  /// cannot be changed after a chore is created, don't have to
  /// regenerate instance list.
  void updateChore(Chore updatedChore) {
    _chores[updatedChore.id] = updatedChore;
    // TODO: update db
    notifyListeners();
  }

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
    _currentMember.name = name;
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
    _user.houseID = '';
    postToServer(data: _user.toJson(), serverFunc: 'upsert-user');
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
    _subgroups.remove(subgroupID);
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
    // don't add if a subgroup already exists with these memebrs
    for (Subgroup sub in _subgroups.values) {
      if (listEquals(sub.members, members)) {
        return;
      }
    }
    // new subgroup!!
    final newSub = Subgroup.fromNew(
      name: name,
      members: members.map((mem) => mem.id).toList(),
      color: color,
    );
    for (Chore c in chores) {
      // add each chore to db
      addChore(c);
    }
    _subgroups[newSub.id] = newSub;
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
    final keys = List.from(_subgroups.keys);
    for (SubgroupID id in keys) {
      // deletes all subgroups & their chores
      deleteSubgroup(id);
    }
    for (Chore chore in _chores.values) {
      // deletes all supers & instances
      deleteSuperclassChore(chore.id);
    }
    final members = List.from(_memberList);
    for (Member mem in members) {
      // This will also update each user's doc with
      // an empty house ID
      leaveHouse(mem.id);
    }
    // TODO: db needs to delete house doc
    print('Deleting the house....');
    notifyListeners();
  }

  /// Delete chore (superclass)
  // TODO: implement delete chore superclass
  void deleteSuperclassChore(String choreID) {
    // delete all chore instances
    _choreInstances[choreID] = [];
    // TODO: update db to delete all chore instance docs
    _chores.remove(choreID);
    // TODO: update db to delete chore doc
    print('Deleting $choreID chore');
    notifyListeners();
  }
}
