// import 'dart:async';

import 'package:divvy/models/chore.dart';
import 'package:divvy/models/data.dart';
import 'package:divvy/models/house.dart';
import 'package:divvy/models/member.dart';
import 'package:divvy/models/subgroup.dart';
import 'package:divvy/util/date_funcs.dart';
import 'package:flutter/foundation.dart';

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

  /// Getters
  String get houseName => _house.name;
  String get houseID => _house.id;
  List<Member> get members => List.from(_members);
  List<Subgroup> get subgroups => List.from(_subgroups);
  List<Chore> get chores => List.from(_chores);
  Member get currentUser => _currentUser;

  /// Get all members assigned to a given chore
  List<Member> getChoreAssignees(ChoreID id) {
    Chore chore = getSuperChore(id);

    return chore.assignees.map((assigneeId) {
      return members.firstWhere((member) => member.id == assigneeId);
    }).toList();
  }

  /// Returns all super chores that belong to a given subgroup
  List<Chore> getSubgroupChores(SubgroupID id) {
    Subgroup subgroup = subgroups.firstWhere((subgroup) => subgroup.id == id);

    return subgroup.chores.map((choreId) {
      return chores.firstWhere((chore) => chore.id == choreId);
    }).toList();
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
    return _choreInstances[choreID]!.firstWhere(
      (ChoreInst instance) => instance.id == choreInstanceID,
    );
  }

  /// Returns a super chore with the passed id
  Chore getSuperChore(ChoreID id) {
    return _chores.firstWhere((chore) => chore.id == id);
  }

  /// Returns a list of all members that are assigned to
  /// a given super chore
  List<Member> getMembersDoingChore(ChoreID choreID) {
    Chore chore = getSuperChore(choreID);

    List<MemberID> memberIdsOfChore = chore.assignees;

    List<Member> membersDoingChore = [];

    for (MemberID memberID in memberIdsOfChore) {
      membersDoingChore.add(
        members.firstWhere((member) => member.id == memberID),
      );
    }

    return membersDoingChore;
  }

  /// Changes the name of a super chore
  void changeName(ChoreID choreID, String name) {
    Chore chore = getSuperChore(choreID);
    chore.changeName(name);
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
    notifyListeners();
  }

  /// Returns the member object matching the inputted ID
  Member getMemberById(MemberID memberId) {
    return members.firstWhere((member) => member.id == memberId);
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
    final List<ChoreInst>? res = _choreInstances[chore.id];
    if (res == null) return [];
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
    final member = _members.firstWhere((mem) => mem.id == id);
    final List<Subgroup> res = [];
    for (SubgroupID subID in member.subgroups) {
      res.add(_subgroups.firstWhere((s) => s.id == subID));
    }
    return res;
  }

  /// Returns list of members in subgroup
  List<Member> getMembersInSubgroup(SubgroupID id) {
    final subgroup = _subgroups.firstWhere((s) => s.id == id);
    final List<Member> res = [];
    for (MemberID memID in subgroup.members) {
      res.add(_members.firstWhere((m) => m.id == memID));
    }
    return res;
  }

  /// Updates user name with inputed name
  // TODO: complete update user name
  void updateUserName(String name) {
    _currentUser = Member(
      id: _currentUser.id,
      dateJoined: _currentUser.dateJoined,
      profilePicture: _currentUser.profilePicture,
      name: name,
      chores: _currentUser.chores,
      onTimePct: _currentUser.onTimePct,
      email: _currentUser.email,
      subgroups: _currentUser.subgroups,
    );
    notifyListeners();
    print('Update user name');
  }

  /// Removes given user from the house
  // TODO: complete user removeal from house
  void userLeavesHouse(Member user) {
    print('${user.name} left the house');
  }

  /// Deletes a subgroup specified
  // TODO: complete deleting subgroups
  void deleteSubgroup(Subgroup subgroup) {
    print('${subgroup.name} has been deleted');
  }

  /// Add a subgroup specified
  // TODO: complete adding subgroups
  void addSubgroup(String name, List<Member> members, List<Chore> chores) {
    print('${name} subgroup added');
  }

  /// Removes user from house
  // TODO: implement remove user from house
  void removeUserHouse(String email) {
    print('$email removed from house');
  }

  /// Add user to house
  // TODO: implement add user to house
  void addUserHouse(String email) {
    print('$email added to house');
  }

  /// Updating house name
  // TODO: implemnet update house name
  void updateHouseName(String newName) {
    print('$newName is now house name');
  }

  /// Delete the entire house
  // TODO: implement delete entire house
  void deleteHouse() {
    print('Deleting the house....');
  }

  /// Delete chore (superclass)
  // TODO: implement delete chore superclass
  void deleteSuperclassChore(String choreID) {
    print('Deleting ${choreID} chore');
  }
}
