import 'package:divvy/models/member.dart';

/// Represents a chore object & general information
class Chore {
  final ChoreID _id;
  final String _name;
  final Frequency _frequency;
  final String _emoji;
  final String _description;
  // List of people this chore is assigned to
  final List<MemberID> _assignees;
  final List<ChoreInstID> _instances;
  // 1 = monday, ... 7 = sunday
  final List<int> _dayOfWeek;

  Chore({
    required ChoreID id,
    required String name,
    required Frequency frequency,
    required String emoji,
    required String description,
    required List<MemberID> assignees,
    required List<ChoreInstID> instances,
    required List<int> dayOfWeek,
  }) : _id = id,
       _name = name,
       _frequency = frequency,
       _emoji = emoji,
       _description = description,
       _assignees = assignees,
       _instances = instances,
       _dayOfWeek = dayOfWeek;

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
      frequency: Frequency.values.firstWhere(
        (f) => f.name == json['frequency'],
      ),
      dayOfWeek: (json['dayOfWeek'] as List<dynamic>).cast<int>(),
    );
  }

  /// Getters

  ChoreID get id => _id;
  String get name => _name;
  Frequency get frequency => _frequency;
  String get emoji => _emoji;
  String get description => _description;
  List<MemberID> get assignees => List.from(_assignees);
  List<ChoreInstID> get instances => List.from(_instances);
  List<int> get dayOfWeek => List.from(_dayOfWeek);
}

enum Frequency { daily, weekly, biweekly, monthly }

/// Represents a specific instance of a chore
class ChoreInst {
  // ID of parent chore
  final ChoreID _parentID;
  // ID of this instance
  final ChoreInstID _id;
  // Due date
  final DateTime _dueDate;
  // True if done
  final bool _isDone;
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
       _parentID = choreID,
       _assignee = assignee;

  /// From a json map, returns a new Subgroup object
  /// with relevant fields filled out.
  factory ChoreInst.fromJson(Map<String, dynamic> json) {
    return ChoreInst(
      choreID: json['choreID'],
      id: json['id'],
      dueDate: json['dueDate'],
      isDone: json['isDone'],
      assignee: json['assignee'],
    );
  }

  /// Getters

  ChoreID get choreID => _parentID;
  ChoreInstID get id => _id;
  DateTime get dueDate => _dueDate;
  bool get isDone => _isDone;
  MemberID get assignee => _assignee;
}

typedef ChoreID = String;
typedef ChoreInstID = String;
