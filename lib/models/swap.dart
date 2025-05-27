import 'package:divvy/models/chore.dart';
import 'package:divvy/models/member.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';

// used to generate unique IDs for each document.
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
  // Other chore suggested to be swapped for this one.
  // Empty if status is open.
  ChoreInstID offered;

  /// Creates a swap with all fields. Should only be used by factory
  /// constructors.
  Swap({
    required this.id,
    required this.choreID,
    required this.choreInstID,
    required this.from,
    required this.to,
    required this.status,
    required this.offered,
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
      offered: '',
    );
  }

  /// From a json map, returns a new Subgroup object
  /// with relevant fields filled out.
  factory Swap.fromJson(Map<String, dynamic> json) => Swap(
    id: json['id'],
    choreID: json['choreID'],
    choreInstID: json['choreInstID'],
    from: json['from'],
    to: json['to'] ?? '',
    status: Status.values.firstWhere((s) => s.name == json['status']),
    offered: json['offered'] ?? '',
  );

  /// Returns subgroup object as json
  Map<String, dynamic> toJson() => {
    'id': id,
    'choreID': choreID,
    'choreInstID': choreInstID,
    'from': from,
    'to': to,
    'status': status.name,
    'offered': offered,
  };
}

/// Represents the current status of a swap.
enum Status { open, pending, approved, rejected }

/// Helper methods for the Status enum.
extension StatusInfo on Status {
  // Returns the display name for the UI
  String get displayName => switch (this) {
    Status.approved => "Approved",
    Status.open => "Open",
    Status.pending => "Pending",
    Status.rejected => "Rejected",
  };

  // Returns an icon to be used for swaps with this status.
  IconData get icon => switch (this) {
    Status.approved => CupertinoIcons.check_mark_circled_solid,
    Status.open => CupertinoIcons.circle,
    Status.pending => CupertinoIcons.refresh_circled,
    Status.rejected => CupertinoIcons.clear_circled_solid,
  };
}
