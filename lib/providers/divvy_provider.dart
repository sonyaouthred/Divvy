// import 'dart:async';

import 'package:divvy/models/chore.dart';
import 'package:divvy/models/comment.dart';
import 'package:divvy/models/house.dart';
import 'package:divvy/models/member.dart';
import 'package:divvy/models/subgroup.dart';
import 'package:divvy/models/swap.dart';
import 'package:divvy/models/user.dart';
import 'package:divvy/util/date_funcs.dart';
import 'package:divvy/util/server_util.dart' as db;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

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
  // Same as above list, but mapped to by ID for quick lookup.
  late final Map<MemberID, Member> _memberMap;
  // List of all house subgroups, but mapped to by ID for quick lookup.
  late final Map<SubgroupID, Subgroup> _subgroups;
  // list of all chores for the house, mapped to by ID for quick lookup.
  late final Map<ChoreID, Chore> _chores;
  // All chore instances, mapped to by their super chore IDs.
  late final Map<ChoreID, List<ChoreInst>> _choreInstances;
  // list of all swaps for the house, mapped to by ID for quick lookup.
  late final Map<SwapID, Swap> _swaps;

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
      _loadSwaps(),
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
    _house = (await db.fetchHouse(_houseID))!;
    notifyListeners();
  }

  // load subgroup data from server
  Future<void> _loadSubgroupData() async {
    _subgroups = await db.fetchSubgroups(_houseID) ?? {};
    notifyListeners();
  }

  /// Load member info from server
  Future<void> _loadMemberInfo() async {
    _memberMap = await db.fetchMembers(_houseID) ?? {};
    notifyListeners();
  }

  // load chore instance data from server
  Future<void> _getChoreInstanceData() async {
    _choreInstances = await db.fetchChoreInstances(_houseID) ?? {};
    notifyListeners();
  }

  // load chore data from server
  Future<void> _loadChoreData() async {
    _chores = await db.fetchChores(_houseID) ?? {};
    notifyListeners();
  }

  // load chore data from server
  Future<void> _loadSwaps() async {
    _swaps = await db.fetchSwaps(_houseID) ?? {};
    notifyListeners();
  }

  ////////////////////////////// Getters //////////////////////////////

  String get houseName => _house.name;
  String get houseID => _house.id;
  String get houseJoinCode => _house.joinCode;
  List<Member> get members => List.from(_memberMap.values);
  List<Subgroup> get subgroups => List.from(_subgroups.values);
  List<Chore> get chores => List.from(_chores.values);
  Member get currMember => _currentMember;
  DivvyUser get currUser => _user;
  List<Swap> get swaps => List.from(_swaps.values);

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
  ChoreInst? getChoreInstanceFromID(
    ChoreID choreID,
    ChoreInstID choreInstanceID,
  ) {
    if (_choreInstances[choreID] == null) return null;
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

  /// Returns all chore instances w/ passed chore super ID assigned to the passed
  /// member that are open to be swapped. If no memberID is passed, uses current member.
  List<ChoreInst> getMemberSwappableChores({
    required ChoreID choreID,
    MemberID? memberID,
  }) {
    final List<ChoreInst> instances = _choreInstances[choreID] ?? [];
    final List<ChoreInst> available =
        instances
            .where(
              (chore) =>
                  chore.assignee == (memberID ?? _currentMember.id) &&
                  !chore.isDone,
            )
            .toList();
    return List.from(available);
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
                  (!inst.dueDate.isBefore(DateTime.now()) ||
                      isSameDay(inst.dueDate, DateTime.now())),
              // check that due date is not today
            )
            .toList(),
      );
    }
    res.sort((a, b) => a.dueDate.isBefore(b.dueDate) ? -1 : 1);
    return res;
  }

  /// Returns list of all chore instances due on a day.
  /// If member is null, searches for the current member.
  /// If day is null, searches for today.
  /// List is sorted by time
  List<ChoreInst> getChoresForDay({MemberID? member, DateTime? day}) {
    final List<ChoreInst> res = [];
    final List<Chore> chores = getMemberChores(member ?? _currentMember.id);
    for (Chore chore in chores) {
      final instances = _choreInstances[chore.id];
      // should never be triggered
      if (instances == null) break;
      // add all chores due today & assigned to this member
      res.addAll(
        instances
            .where(
              (inst) =>
                  inst.assignee == (member ?? _currentMember.id) &&
                  // Check if the due date is today
                  isSameDay(inst.dueDate, day ?? DateTime.now()),
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
                  // Check if the due date is before now && it hasn't been done
                  dayIsAfter(DateTime.now(), inst.dueDate) &&
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
      (chore) => !dayIsAfter(DateTime.now(), chore.dueDate) || chore.isDone,
    );
    res.sort((a, b) => a.dueDate.isBefore(b.dueDate) ? -1 : 1);
    return res;
  }

  /// Returns top [num] leaderboard entries
  List<Member> getLeaderboardSorted(int num) {
    final List<Member> sorted = List.from(_memberMap.values);
    sorted.sort((a, b) => b.onTimePct.compareTo(a.onTimePct));
    return sorted.take(num).toList();
  }

  /// Get the rank of a member based on their on time percentage
  int getRank(MemberID memberID) {
    final List<Member> sorted = List.from(_memberMap.values);
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

  /// Returns all open swaps that were not offered by the current member.
  List<Swap> getOpenSwaps() {
    return _swaps.values
        .where(
          (swap) =>
              (swap.status == Status.open && swap.from != _currentMember.id),
        )
        .toList();
  }

  /// Returns all open swaps that were offered by the current member.
  List<Swap> getOpenSwapsForCurrMember() {
    return _swaps.values
        .where(
          (swap) =>
              (swap.status == Status.open && swap.from == _currentMember.id),
        )
        .toList();
  }

  /// Returns swaps created by this user that have been responded to
  /// by someone. (i.e. this user needs to decide if they want to approve them)
  List<Swap> getPendingSwaps() {
    return _swaps.values
        .where(
          (swap) =>
              (swap.from == _currentMember.id && swap.status == Status.pending),
        )
        .toList();
  }

  /// Returns a swap with the given ID.
  Swap? getSwap(SwapID swapID) {
    return _swaps[swapID];
  }

  ////////////////////////////// Setters //////////////////////////////

  /// Adds a chore to this house under the correct group.
  /// Creates chore instances
  Future<void> addChore(Chore chore) async {
    _chores[chore.id] = chore;
    await db.upsertChore(chore, houseID);
    Subgroup? sub = isSubgroup(chore.assignees);
    if (sub != null) {
      // chore should belong to this subgroup!!
      sub.chores.add(chore.id);
      await db.upsertSubgroup(sub, houseID);
    }
    // now create instances!
    final dates = getDateList(chore.frequency);

    _choreInstances[chore.id] = [];
    dates.asMap().forEach((index, date) {
      final assignee = chore.assignees[index % chore.assignees.length];
      // create chore instance
      ChoreInst choreInst = ChoreInst.fromNew(
        superCID: chore.id,
        due: date,
        assignee: assignee,
      );
      _addChoreInstance(choreInst);
    });
    notifyListeners();
  }

  /// Adds a given chore instance to the database
  /// Does not notify listeners
  Future<void> _addChoreInstance(ChoreInst choreInstance) async {
    if (_choreInstances[choreInstance.superID] == null) return;
    _choreInstances[choreInstance.superID]!.add(choreInstance);
    await db.upsertChoreInst(choreInstance, houseID);
  }

  /// Updates a super chore. because frequency/members
  /// cannot be changed after a chore is created, don't have to
  /// regenerate instance list.
  Future<void> updateChore(Chore updatedChore) async {
    _chores[updatedChore.id] = updatedChore;
    await db.upsertChore(updatedChore, houseID);
    notifyListeners();
  }

  /// Changes the name of a super chore
  Future<void> changeName(ChoreID choreID, String name) async {
    Chore? chore = getSuperChore(choreID);
    if (chore == null) return;
    chore.changeName(name);
    await updateChore(chore);
  }

  /// Toggles if the chore is completed or not
  Future<void> toggleChoreInstanceCompletedState({
    required ChoreID superChoreID,
    required ChoreInst choreInst,
  }) async {
    choreInst.toggleDone();
    if (choreInst.dueDate.isAfter(DateTime.now()) && choreInst.isDone) {
      // User completed chore on time!!
      choreInst.doneOnTime = true;
    } else if (!choreInst.isDone) {
      choreInst.doneOnTime = false;
    }

    // Need to recalculate user's chore completion rate
    // get all user chores
    final choreInsts = getMemberChoreInstances(
      currMember.id,
    ).where((chore) => chore.isDone);
    int total = 0;
    int onTime = 0;
    for (ChoreInst inst in choreInsts) {
      total++;
      if (inst.doneOnTime) {
        // chore is done & was on time
        onTime++;
      }
    }
    int onTimePct = 0;
    if (total != 0) {
      onTimePct = ((onTime / total) * 100).toInt();
    }
    currMember.onTimePct = onTimePct;
    await db.upsertMember(currMember, houseID);
    await db.upsertChoreInst(choreInst, houseID);
    notifyListeners();
  }

  /// Updates user name with inputed name
  Future<void> updateUserName(String name) async {
    _currentMember.name = name;
    await db.upsertMember(_currentMember, houseID);
    notifyListeners();
  }

  /// Updates user name with inputed name
  Future<void> updateMemberColor(ProfileColor newColor) async {
    _currentMember.profilePicture = newColor;
    await db.upsertMember(_currentMember, houseID);
    notifyListeners();
  }

  /// Updates user name with inputed name
  Future<void> updateSubgroupColor(
    Subgroup subgroup,
    ProfileColor newColor,
  ) async {
    subgroup.profilePicture = newColor;
    await db.upsertSubgroup(subgroup, houseID);
    notifyListeners();
  }

  /// Removes given user from the house
  Future<void> leaveHouse(MemberID id) async {
    // remove user from all subgroups they may be in
    // delete subgroups that have nobody left
    List<Future> futures = [];
    for (Subgroup sub in getSubgroupsForMember(id)) {
      sub.removeMember(id);
      if (sub.members.isEmpty) {
        // delete subgroup!
        // this will handle db update
        deleteSubgroup(sub.id);
      } else {
        futures.add(db.upsertSubgroup(sub, houseID));
      }
    }
    await Future.wait(futures);

    futures.clear();
    for (Swap swap in swaps) {
      if (swap.from == _currentMember.id) {
        // delete swap
        deleteSwap(swap);
      } else if (swap.to == _currentMember.id &&
          swap.status != Status.rejected) {
        // this swap was destined to the current user, and has not been explicitly
        // rejected.
        // need to set swap as open again
        swap.to = '';
        swap.status = Status.open;
        futures.add(db.upsertSwap(swap, houseID));
      }
    }
    await Future.wait(futures);

    futures.clear();

    /// remove user from all chores they may have belonged to
    for (Chore chore in getMemberChores(id)) {
      chore.removeAssignee(id);
      if (chore.assignees.isEmpty) {
        // delete chore bc there are no more users on it
        // this will handle db update
        deleteSuperclassChore(chore.id);
      } else {
        futures.add(db.upsertChore(chore, houseID));
      }
    }
    await Future.wait(futures);

    await db.deleteMember(houseID: houseID, memberID: id);
    _user.houseID = '';
    await db.upsertUser(_user);
    notifyListeners();
  }

  /// Deletes a subgroup specified
  Future<void> deleteSubgroup(SubgroupID subgroupID) async {
    final subgroup = _subgroups[subgroupID];
    if (subgroup == null) return;
    // Delete any of their chores
    for (Chore c in getSubgroupChores(subgroupID)) {
      // delete super chore!
      // this will handle db update
      deleteSuperclassChore(c.id);
    }
    // Delete subgroup from member lists
    final List<Future> futures =
        subgroup.members
            .map(
              (m) => leaveSubgroup(
                subgroupID: subgroupID,
                mID: m,
                notifList: false,
              ),
            )
            .toList();
    await Future.wait(futures);
    // Finally, remove the subgroup
    _subgroups.remove(subgroupID);
    await db.deleteSubgroup(houseID: houseID, subgroupID: subgroupID);
    notifyListeners();
  }

  /// deletes current user
  Future<void> deleteMember() async {
    // Delete user from any subgroups they may be part of
    final subgroups = currMember.subgroups;
    List<Future> futures = [];
    for (SubgroupID subID in subgroups) {
      // remove user from subgroup
      final subgroup = _subgroups[subID];
      if (subgroup == null) continue;
      subgroup.removeMember(currMember.id);
      futures.add(db.upsertSubgroup(subgroup, houseID));
    }
    await Future.wait(futures);

    // now handle any chores they may be assigned to this user
    futures.clear();
    final chores = getMemberChores(currMember.id);
    for (Chore chore in chores) {
      chore.assignees.remove(currMember.id);
      futures.add(db.upsertChore(chore, houseID));

      // reassign the chore schedule
      // delete all upcoming instances
      final upcomingInstances =
          _choreInstances[chore.id]?.where(
            (inst) => inst.dueDate.isAfter(DateTime.now()),
          ) ??
          [];
      for (ChoreInst inst in upcomingInstances) {
        futures.add(db.deleteChoreInst(houseID: houseID, choreInstID: inst.id));
      }

      // now repopulate!!
      final dates =
          getDateList(
            chore.frequency,
          ).where((date) => date.isAfter(DateTime.now())).toList();
      dates.asMap().forEach((index, date) {
        final assignee = chore.assignees[index % chore.assignees.length];
        // create chore instance
        ChoreInst choreInst = ChoreInst.fromNew(
          superCID: chore.id,
          due: date,
          assignee: assignee,
        );
        _addChoreInstance(choreInst);
      });
    }
    await Future.wait(futures);

    // Finally, delete user doc
    await db.deleteMember(houseID: houseID, memberID: currMember.id);
  }

  /// Leaves the specified subgroup. If no member ID specified,
  /// assumes current user
  Future<void> leaveSubgroup({
    required SubgroupID subgroupID,
    MemberID? mID,
    bool notifList = true,
  }) async {
    // remove from member's list
    final memberID = mID ?? currMember.id;
    final member = getMemberById(memberID);
    if (member == null) return;
    member.subgroups.remove(subgroupID);
    await db.upsertMember(member, houseID);

    // remove member from subgroup's list
    final subgroup = _subgroups[subgroupID];
    if (subgroup != null) {
      subgroup.members.remove(memberID);
      await db.upsertSubgroup(subgroup, houseID);
    }

    // if m is not null, we assume this method is being called from another
    // provider func
    if (notifList) notifyListeners();
  }

  /// Add a subgroup specified
  Future<void> addSubgroup(
    String name,
    List<Member> members,
    List<Chore> chores,
    ProfileColor color,
  ) async {
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
    await db.upsertSubgroup(newSub, houseID);
    // Update each member's doc with the subgroup
    List<Future> futures = [];
    for (Member member in members) {
      member.subgroups.add(newSub.id);
      futures.add(db.upsertMember(member, houseID));
    }
    await Future.wait(futures);
    notifyListeners();
  }

  /// Updating house name
  Future<void> updateHouseName(String newName) async {
    _house.name = newName;
    await db.upsertHouse(_house);
    notifyListeners();
  }

  /// Delete the entire house. All members have the doc removed
  Future<void> deleteHouse() async {
    final members = List.from(_memberMap.values);
    for (Member mem in members) {
      final otherUser = await db.fetchUser(mem.id);
      if (otherUser != null) {
        otherUser.houseID = '';
        await db.upsertUser(otherUser);
      }
    }
    // delete house & all subcollections
    await db.deleteHouse(_houseID);
    notifyListeners();
  }

  /// Delete chore (superclass)
  Future<void> deleteSuperclassChore(String choreID) async {
    final choreInsts = _choreInstances[choreID];
    if (choreInsts != null) {
      // Delete all chore instances
      final List<Future> futures = [];
      for (ChoreInst inst in choreInsts) {
        futures.add(db.deleteChoreInst(houseID: houseID, choreInstID: inst.id));
      }
      // batch delete docs
      await Future.wait(futures);
      _choreInstances.remove(choreID);
    }

    // now delete all swaps with this chore ID
    final swaps = _swaps.values;
    final List<Future> futures = [];
    for (Swap swap in swaps) {
      if (swap.choreID == choreID) {
        // delete this swap!!
        futures.add(db.deleteSwap(houseID: houseID, swapID: swap.id));
        _swaps.remove(swap.id);
      }
    }
    await Future.wait(futures);

    _chores.remove(choreID);
    await db.deleteChore(houseID: houseID, choreID: choreID);
    notifyListeners();
  }

  /// Adds a swap to the database
  Future<void> openSwap(ChoreInst choreInst, ChoreID superID) async {
    Swap newSwap = Swap.fromNew(
      choreID: superID,
      choreInstID: choreInst.id,
      from: _currentMember.id,
    );
    await db.upsertSwap(newSwap, houseID);
    // Update the chore instance with the swap id
    choreInst.swapID = newSwap.id;
    await db.upsertChoreInst(choreInst, houseID);
    notifyListeners();
  }

  /// Allows current user to make an offer for the swap.
  Future<void> sendSwapInvite(Swap swap, ChoreInstID offered) async {
    // update the offered chore instance info
    final offeredInst = getChoreInstanceFromID(swap.choreID, offered);
    if (offeredInst == null) return;
    offeredInst.swapID = swap.id;
    await db.upsertChoreInst(offeredInst, houseID);
    // Update the swap info
    swap.status = Status.pending;
    swap.to = _currentMember.id;
    swap.offered = offered;
    await db.upsertSwap(swap, houseID);
    notifyListeners();
  }

  /// Approve a swap to take place!
  Future<void> approveSwapInvite(Swap swap) async {
    // fetch the chore instances & swap IDs
    final ogChore = getChoreInstanceFromID(swap.choreID, swap.choreInstID)!;
    final swappedChore = getChoreInstanceFromID(swap.choreID, swap.offered)!;
    ogChore.assignee = swap.to;
    swappedChore.assignee = swap.from;
    await Future.wait([
      db.upsertChoreInst(ogChore, houseID),
      db.upsertChoreInst(swappedChore, houseID),
    ]);
    // Update the swap info!
    swap.status = Status.approved;
    await db.upsertSwap(swap, houseID);
    notifyListeners();
  }

  /// Adds a swap to the database
  Future<void> rejectSwapInvite(Swap swap) async {
    // Update the chore instance with the swap id
    swap.status = Status.rejected;
    swap.to = '';
    swap.offered = '';
    await db.upsertSwap(swap, houseID);
    notifyListeners();
  }

  /// Deletes a chore instance
  Future<void> deleteChoreInst(ChoreID choreID, ChoreInstID id) async {
    if (_choreInstances[choreID] == null) return;
    _choreInstances[choreID]!.removeWhere((c) => c.id == id);
    await db.deleteChoreInst(houseID: houseID, choreInstID: id);
    notifyListeners();
  }

  /// Deletes a swap and any trace of it from chore instances.
  Future<void> deleteSwap(Swap swap) async {
    final choreInst = getChoreInstanceFromID(swap.choreID, swap.choreInstID);
    if (choreInst != null) {
      // remove trace of swap
      choreInst.swapID = '';
      await db.upsertChoreInst(choreInst, houseID);
    }
    // finally delete swap
    await db.deleteSwap(houseID: houseID, swapID: swap.id);
    notifyListeners();
  }

  // Add a comment by the current user to a chore instance
  Future<void> addComment(
    ChoreID superID,
    ChoreInstID choreInst,
    String comment,
  ) async {
    print('adding comment...');
    final newComment = Comment.fromNew(
      comment: comment,
      commenter: currMember.id,
    );
    final inst = _choreInstances[superID]?.firstWhere(
      (inst) => inst.id == choreInst,
    );
    if (inst == null) return;
    // add comment!
    inst.comments.add(newComment);
    await db.upsertChoreInst(inst, houseID);
    notifyListeners();
  }

  // Delete a given comment
  Future<void> deleteComment(
    ChoreID superID,
    ChoreInstID choreInst,
    String commentID,
  ) async {
    final inst = _choreInstances[superID]?.firstWhere(
      (inst) => inst.id == choreInst,
    );
    if (inst == null) return;
    // delete comment!
    inst.comments.removeWhere((comment) => comment.id == commentID);
    await db.upsertChoreInst(inst, houseID);
    notifyListeners();
  }
}
