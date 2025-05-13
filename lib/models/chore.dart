import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:divvy/models/member.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

typedef ChoreID = String;
typedef ChoreInstID = String;

/// Represents a chore object & general information
class Chore {
  final ChoreID _id;
  String _name;
  final ChoreFrequency _frequency;
  final String _emoji;
  final String _description;
  // List of people this chore is assigned to
  final List<MemberID> _assignees;
  final List<ChoreInstID> _instances;

  Chore({
    required ChoreID id,
    required String name,
    required ChoreFrequency frequency,
    required String emoji,
    required String description,
    required List<MemberID> assignees,
    required List<ChoreInstID> instances,
  }) : _id = id,
       _name = name,
       _frequency = frequency,
       _emoji = emoji,
       _description = description,
       _assignees = assignees,
       _instances = instances;

  /// Creates a new parent chore object with no instances.
  factory Chore.fromNew({
    required String name,
    required Frequency pattern,
    required List<int> daysOfWeek,
    required List<MemberID> assignees,
    required String emoji,
    required String description,
  }) {
    final id = uuid.v4();
    final choreFreq = ChoreFrequency(pattern: pattern, daysOfWeek: daysOfWeek);
    return Chore(
      name: name,
      frequency: choreFreq,
      id: id,
      instances: [],
      assignees: assignees,
      emoji: emoji,
      description: description,
    );
  }

  /// From a json map, returns a new Subgroup object
  /// with relevant fields filled out.
  factory Chore.fromJson(Map<String, dynamic> json) {
    return Chore(
      name: json['name'],
      id: json['id'],
      instances: (json['instances'] as List<dynamic>).cast<ChoreInstID>(),
      assignees: (json['assignees'] as List<dynamic>).cast<MemberID>(),
      description: json['description'],
      emoji: json['emoji'],
      frequency: ChoreFrequency.fromJson(
        pattern: json['frequencyPattern'],
        daysOfWeek: json['frequencyDays'],
      ),
    );
  }

  /// Returns a json version of the chore object
  Map<String, dynamic> toJson() {
    return {
      'name': _name,
      'id': _id,
      'instances': _instances,
      'assignees': _assignees,
      'description': _description,
      'emoji': _emoji,
      'frequencyPattern': _frequency.pattern.name,
      'frequencyDays': _frequency.daysOfWeek,
    };
  }

  /// Getters

  ChoreID get id => _id;
  String get name => _name;
  ChoreFrequency get frequency => _frequency;
  String get emoji => _emoji;
  String get description => _description;
  List<MemberID> get assignees => List.from(_assignees);
  List<ChoreInstID> get instances => List.from(_instances);

  /// Changes the name of a chore
  void changeName(String newName) {
    if (newName.isNotEmpty) {
      _name = newName;
    }
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
  final MemberID _assignee;

  ChoreInst({
    required ChoreID choreID,
    required ChoreInstID id,
    required DateTime dueDate,
    required bool isDone,
    required MemberID assignee,
  }) : _id = id,
       _dueDate = dueDate,
       _isDone = isDone,
       _superID = choreID,
       _assignee = assignee;

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
    );
  }

  /// From a json map, returns a new Subgroup object
  /// with relevant fields filled out.
  factory ChoreInst.fromJson(Map<String, dynamic> json) {
    return ChoreInst(
      choreID: json['choreID'],
      id: json['id'],
      dueDate: (json['dueDate'] as Timestamp).toDate(),
      isDone: json['isDone'],
      assignee: json['assignee'],
    );
  }

  /// Converts chore instance object to json
  Map<String, dynamic> toJson() {
    return {
      'choreID': _superID,
      'id': _id,
      'dueDate': Timestamp.fromDate(_dueDate),
      'isDone': _isDone,
      'assignee': _assignee,
    };
  }

  /// Getters

  ChoreID get superID => _superID;
  ChoreInstID get id => _id;
  DateTime get dueDate => _dueDate;
  bool get isDone => _isDone;
  MemberID get assignee => _assignee;

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

  ChoreFrequency({required this.pattern, required this.daysOfWeek});

  /// Returns a chore frequency object from JSON (dynamic) values.
  factory ChoreFrequency.fromJson({
    required dynamic pattern,
    required dynamic daysOfWeek,
  }) {
    return ChoreFrequency(
      pattern: Frequency.values.firstWhere(
        (f) => f.name == (pattern as String),
      ),
      daysOfWeek: (daysOfWeek as List<dynamic>).cast<int>(),
    );
  }
}
