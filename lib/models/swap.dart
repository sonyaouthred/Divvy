import 'package:divvy/models/chore.dart';
import 'package:divvy/models/member.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

typedef SwapID = String;

/// Represents a chore swap between users.
class Swap {
  // Unique ID for swap
  final SwapID id;
  // ID of super chore being swapped
  final ChoreID choreID;
  // ID of chore instance being swapped
  final ChoreInstID choreInstID;
  // ID of member offering the swap
  MemberID from;
  // ID of member the swap is targeted to
  // empty if swap Status is open.
  MemberID to;
  // Status of swap.
  Status status;

  Swap({
    required this.id,
    required this.choreID,
    required this.choreInstID,
    required this.from,
    required this.to,
    required this.status,
  });

  /// Creates a new Swap object.
  factory Swap.fromNew({
    required ChoreID choreID,
    required ChoreInstID choreInstID,
    required MemberID from,
  }) {
    final id = uuid.v4();
    return Swap(
      choreID: choreID,
      choreInstID: choreInstID,
      id: id,
      from: from,
      to: '',
      status: Status.open,
    );
  }

  /// From a json map, returns a new Subgroup object
  /// with relevant fields filled out.
  factory Swap.fromJson(Map<String, dynamic> json) => Swap(
    id: json['id'],
    choreID: json['choreID'],
    choreInstID: json['choreInstID'],
    from: json['from'],
    to: json['to'],
    status: Status.values.firstWhere((s) => s.name == json['status']),
  );

  /// Returns subgroup object as json
  Map<String, dynamic> toJson() => {
    'id': id,
    'choreID': choreID,
    'choreInstID': choreInstID,
    'from': from,
    'to': to,
    'status': status.name,
  };
}

/// Represents the current status of a swap.
enum Status { open, pending, approved, rejected }
