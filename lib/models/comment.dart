import 'dart:io';

import 'package:divvy/models/member.dart';
import 'package:uuid/uuid.dart';

// used to generate unique IDs for each document.
const uuid = Uuid();

/// Simple class representing a comment left by a user
/// on a chore
class Comment {
  final String id;
  String comment;
  final MemberID commenter;
  final DateTime date;

  Comment({
    required this.comment,
    required this.commenter,
    required this.id,
    required this.date,
  });

  factory Comment.fromNew({
    required String comment,
    required MemberID commenter,
  }) {
    return Comment(
      comment: comment,
      commenter: commenter,
      date: DateTime.now(),
      id: uuid.v4(),
    );
  }

  /// From a json map, returns a new Subgroup object
  /// with relevant fields filled out.
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      comment: json['comment'],
      commenter: json['commenter'],
      id: json['id'],
      date: HttpDate.parse(json['date']),
    );
  }

  /// Converts chore instance object to json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'comment': comment,
      'commenter': commenter,
      'date': HttpDate.format(date),
    };
  }
}
