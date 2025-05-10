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
      choreinsts[choreInst.choreID] == null
          ? choreinsts[choreInst.choreID] = [choreInst]
          : choreinsts[choreInst.choreID]!.add(choreInst);
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

  /// Returns list of chore instances with a given super chore ID
  List<ChoreInst> getChoreInstancesFromID(ChoreID id) {
    return _choreInstances[id] ?? [];
  }

  /// Returns a super chore with the passed id
  Chore getSuperChore(ChoreID id) {
    return _chores.firstWhere((chore) => chore.id == id);
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

  /// Returns top [num] leaderboard entries
  List<Member> getLeaderboardSorted(int num) {
    final List<Member> sorted = List.from(_members);
    sorted.sort((a, b) => b.onTimePct.compareTo(a.onTimePct));
    return sorted.take(num).toList();
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
}
