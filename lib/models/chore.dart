import 'dart:io';
import 'package:divvy/models/member.dart';
import 'package:divvy/models/swap.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

typedef ChoreID = String;
typedef ChoreInstID = String;

/// Represents a chore object & general information
class Chore {
  final ChoreID _id;
  String name;
  final ChoreFrequency _frequency;
  final String emoji;
  final String description;
  // List of people this chore is assigned to
  final List<MemberID> _assignees;

  Chore({
    required ChoreID id,
    required this.name,
    required ChoreFrequency frequency,
    required this.emoji,
    required this.description,
    required List<MemberID> assignees,
  }) : _id = id,
       _frequency = frequency,
       _assignees = assignees;

  /// Creates a new parent chore object with no instances.
  factory Chore.fromNew({
    required String name,
    required Frequency pattern,
    required List<int> daysOfWeek,
    required List<MemberID> assignees,
    required String emoji,
    required String description,
    required DateTime startDate,
  }) {
    final id = uuid.v4();
    final choreFreq = ChoreFrequency(
      pattern: pattern,
      daysOfWeek: daysOfWeek,
      startDate: startDate,
    );
    return Chore(
      name: name,
      frequency: choreFreq,
      id: id,
      assignees: assignees,
      emoji: emoji,
      description: description,
    );
  }

  /// Update fields within chore, preserving the old ID.
  factory Chore.update({
    required Chore old,
    String? name,
    String? emoji,
    String? description,
  }) {
    return Chore(
      assignees: old.assignees,
      frequency: old.frequency,
      name: name ?? old.name,
      id: old.id,
      emoji: emoji ?? old.emoji,
      description: description ?? old.description,
    );
  }

  /// From a json map, returns a new Subgroup object
  /// with relevant fields filled out.
  factory Chore.fromJson(Map<String, dynamic> json) => Chore(
    name: json['name'],
    id: json['id'],
    assignees: (json['assignees'] as List<dynamic>).cast<MemberID>(),
    description: json['description'],
    emoji: json['emoji'],
    frequency: ChoreFrequency.fromJson(
      pattern: json['frequencyPattern'],
      daysOfWeek: (json['frequencyDays'] as List<dynamic>).cast<int>(),
      startDate: HttpDate.parse(json['startDate']),
    ),
  );

  /// Returns a json version of the chore object
  Map<String, dynamic> toJson() => {
    'name': name,
    'id': _id,
    'assignees': _assignees,
    'description': description,
    'emoji': emoji,
    'frequencyPattern': _frequency.pattern.name,
    'frequencyDays': _frequency.daysOfWeek,
    'startDate': HttpDate.format(_frequency.startDate),
  };

  /// Getters

  ChoreID get id => _id;
  ChoreFrequency get frequency => _frequency;
  List<MemberID> get assignees => List.from(_assignees);

  /// Changes the name of a chore
  void changeName(String newName) {
    if (newName.isNotEmpty) {
      name = newName;
    }
  }

  /// Removes assignee
  void removeAssignee(MemberID memID) {
    _assignees.remove(memID);
  }
}

enum Frequency { daily, weekly, monthly }

/// Represents a specific instance of a chore
class ChoreInst {
  // ID of parent chore
  final ChoreID _superID;
  // ID of this instance
  final ChoreInstID _id;
  // Due date
  final DateTime _dueDate;
  // True if done
  bool _isDone;
  // user chore is assigned to
  MemberID assignee;
  SwapID swapID;

  ChoreInst({
    required ChoreID choreID,
    required ChoreInstID id,
    required DateTime dueDate,
    required bool isDone,
    required this.assignee,
    required this.swapID,
  }) : _id = id,
       _dueDate = dueDate,
       _isDone = isDone,
       _superID = choreID;

  /// Returns a new chore instance object
  factory ChoreInst.fromNew({
    required ChoreID superCID,
    required DateTime due,
    required MemberID assignee,
  }) {
    final id = uuid.v4();
    return ChoreInst(
      choreID: superCID,
      id: id,
      dueDate: due,
      isDone: false,
      assignee: assignee,
      swapID: '',
    );
  }

  /// From a json map, returns a new Subgroup object
  /// with relevant fields filled out.
  factory ChoreInst.fromJson(Map<String, dynamic> json) {
    return ChoreInst(
      choreID: json['choreID'],
      id: json['id'],
      dueDate: HttpDate.parse(json['dueDate']),
      isDone: json['isDone'],
      assignee: json['assignee'],
      swapID: json['swapID'],
    );
  }

  /// Converts chore instance object to json
  Map<String, dynamic> toJson() {
    return {
      'choreID': _superID,
      'id': _id,
      'dueDate': HttpDate.format(_dueDate),
      'isDone': _isDone,
      'assignee': assignee,
      'swapID': swapID,
    };
  }

  /// Getters

  ChoreID get superID => _superID;
  ChoreInstID get id => _id;
  DateTime get dueDate => _dueDate;
  bool get isDone => _isDone;

  // toggles if a chore is done or not
  void toggleDone() {
    _isDone = !_isDone;
  }
}

/// Struct to represent frequency of a chore
class ChoreFrequency {
  final Frequency pattern;
  // 1 = monday, ... 7 = sunday
  final List<int> daysOfWeek;
  final DateTime startDate;

  ChoreFrequency({
    required this.pattern,
    required this.daysOfWeek,
    required this.startDate,
  });

  /// Returns a chore frequency object from JSON (dynamic) values.
  factory ChoreFrequency.fromJson({
    required dynamic pattern,
    required dynamic daysOfWeek,
    required dynamic startDate,
  }) {
    return ChoreFrequency(
      pattern: Frequency.values.firstWhere(
        (f) => f.name == (pattern as String),
      ),
      daysOfWeek: (daysOfWeek as List<dynamic>).cast<int>().toList(),
      startDate: startDate,
    );
  }
}
