// import 'dart:async';

// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:divvy/models/chore.dart';
import 'package:divvy/models/data.dart';
import 'package:divvy/models/house.dart';
import 'package:divvy/models/member.dart';
import 'package:divvy/models/subgroup.dart';
import 'package:flutter/foundation.dart';

// typedef ChoreID = String;

// // Names of databases
// const choresDB = 'chores';
// const membersDB = 'members';
// const subgroupsDB = 'subgroups';

// class WorkbookProvider extends ChangeNotifier {
//   late DocumentReference<Map<String, dynamic>> _houseDB;

//   Map<ChoreID, Chore> _choreList = {};
//   StreamSubscription? _choresListener;

//   WorkbookProvider({required DocumentReference<Map<String, dynamic>> houseDB})
//     : _houseDB = houseDB;

//   /// Load the list of chores
//   void _loadChores() async {
//     _choresListener = _houseDB
//         .collection(choresDB)
//         .withConverter(
//           fromFirestore: Chore.fromFirestore,
//           toFirestore: (Chore chore, _) => chore.toFirestore(),
//         )
//         .snapshots()
//         .listen((querySnapshot) async {
//           // This code runs every time the query snapshot is updated.
//           final Map<ChoreID, Chore> chores = {};
//           for (var doc in querySnapshot.docs) {
//             // Add Chore to list!
//             final newChore = doc.data();
//             chores[newChore.id] = newChore;
//           }
//           // now override the list
//           _choreList = chores;
//           notifyListeners();
//         });
//   }

//   /// Add a chore to the house
//   /// Returns relevant error message
//   Future<String?> addChore(String name) async {
//     try {
//       // Create new chore JSON object
//       final newChore = Chore(id: '', name: name).toFirestore();
//       await _houseDB.collection(choresDB).add(newChore);
//       // No need to notifyListeners() as stream subscription
//       // will automatically update.
//       return null;
//     } catch (e) {
//       return e.toString();
//     }
//   }
// }

class DivvyProvider extends ChangeNotifier {
  late final House _house;
  late final List<Member> _members;
  late final List<Subgroup> _subgroups;
  late final List<Chore> _chores;
  late final Map<ChoreID, List<ChoreInst>> _choreInstances;

  DivvyProvider() {
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
  }

  /// Getters
  String get houseName => _house.name;
  String get houseID => _house.id;
  List<Member> get members => List.from(_members);
  List<Subgroup> get subgroups => List.from(_subgroups);
  List<Chore> get chores => List.from(_chores);

  /// Returns list of chore instances with a given super chore ID
  List<ChoreInst> getChoreInstancesFromID(ChoreID id) {
    return _choreInstances[id] ?? [];
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
