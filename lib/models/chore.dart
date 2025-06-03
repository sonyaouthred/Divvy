import 'dart:io';
import 'package:divvy/models/member.dart';
import 'package:divvy/models/swap.dart';
import 'package:uuid/uuid.dart';

// used to generate unique IDs for each document.
const uuid = Uuid();

typedef ChoreID = String;
typedef ChoreInstID = String;

/// This class represents a chore object & general information
/// about it.
class Chore {
  // The ID of this chore. Matches the Firebase Firestore doc ID.
  final ChoreID _id;
  // The name of this chore
  String name;
  // The frequency this chore should be assigned according to.
  final ChoreFrequency _frequency;
  // The emoji representing the chore.
  final String emoji;
  // A user inputted description of the chore
  final String description;
  // List of member IDs this chore is assigned to
  final List<MemberID> _assignees;

  /// Creates a chore with all fields. Should only be used by factory
  /// constructors.
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

  /// Removes an assignee from the chore's list
  void removeAssignee(MemberID memID) {
    _assignees.remove(memID);
  }
}

/// Represents the types of repetition a chore can have.
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
  // The member ID the chore is assigned to
  MemberID assignee;
  // The swap ID for this chore, if it is being swapped.
  // If this chore is not being swapped, this field is empty.
  SwapID swapID;
  // True if the assignment was done before the due date.
  // Should only be looked at if _isDone is true
  bool doneOnTime;

  /// Creates a chore instancewith all fields. Should only be used by
  /// factory constructors.
  ChoreInst({
    required ChoreID choreID,
    required ChoreInstID id,
    required DateTime dueDate,
    required bool isDone,
    required this.assignee,
    required this.swapID,
    required this.doneOnTime,
  }) : _id = id,
       _dueDate = dueDate,
       _isDone = isDone,
       _superID = choreID;

  /// Returns a new chore instance object.
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
      doneOnTime: false,
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
      swapID: json['swapID'] ?? '',
      doneOnTime: json['doneOnTime'],
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
      'doneOnTime': false,
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

/// Struct to represent the repetition pattern of a chore
class ChoreFrequency {
  // The pattern to be repeated (weekly, monthly, daily)
  final Frequency pattern;
  // the days of the week this chore should be repeated on,
  // if the pattern is weekly.
  // 1 = monday, ... 7 = sunday
  final List<int> daysOfWeek;
  // The start date of this chore's schedule.
  final DateTime startDate;

  /// Creates a new chore frequency object with all fields filled out.
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
