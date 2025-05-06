// ignore_for_file: avoid_print

import 'package:divvy/models/chore.dart';
import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/providers/divvy_provider.dart';
import 'package:divvy/util/date_funcs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Renders a tile with information about a chore.
/// When tapped, opens chore page
class ChoreTile extends StatelessWidget {
  final ChoreInst choreInst;
  final bool compact;
  const ChoreTile({super.key, required this.choreInst, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final spacing = width * 0.05;
    // Get super chore for information
    final superChore = Provider.of<DivvyProvider>(
      context,
      listen: false,
    ).getSuperChore(choreInst.choreID);
    // Build chore tile
    return InkWell(
      onTap: () => _openChoreInstancePage(context, choreInst.id),
      child:
          compact
              ? _smallChoreTile(superChore, spacing)
              : _largeChoreTile(superChore, spacing),
    );
  }

  /// Returns a small chore tile
  Widget _smallChoreTile(Chore superChore, double spacing) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing / 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // render due date
          Text(
            '${getNameOfWeekday(choreInst.dueDate.weekday)}, ${DateFormat.yMMMMd('en_US').format(choreInst.dueDate)}',
            style: DivvyTheme.smallBodyGrey,
          ),
          SizedBox(height: spacing / 4),
          Row(
            children: [
              // name, emoji of chore
              Flexible(
                flex: 7,
                child: Row(
                  children: [
                    Text(superChore.emoji, style: TextStyle(fontSize: 20)),
                    SizedBox(width: spacing / 2),
                    Text(
                      superChore.name,
                      style: DivvyTheme.bodyBlack,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Display chevron icon
              Flexible(
                flex: 1,
                child: Icon(
                  CupertinoIcons.chevron_right,
                  color: DivvyTheme.lightGrey,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Returns a large chore tile
  Column _largeChoreTile(Chore superChore, double spacing) {
    bool isOverdue =
        choreInst.dueDate.isBefore(DateTime.now()) && !choreInst.isDone;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 7,
              child: Row(
                children: [
                  // Display chore emoji
                  Text(superChore.emoji, style: TextStyle(fontSize: 40)),
                  SizedBox(width: spacing / 1.2),
                  // display chore name & time due
                  // wrapped with flexible to ensure text wraps
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          superChore.name,
                          style: DivvyTheme.bodyBlack,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          isOverdue
                              ? 'Was due ${getNameOfWeekday(choreInst.dueDate.weekday)}, ${DateFormat.yMMMMd('en_US').format(choreInst.dueDate)} at ${getFormattedTime(choreInst.dueDate)}'
                              : 'Due at ${getFormattedTime(choreInst.dueDate)}',
                          style: DivvyTheme.detailGrey.copyWith(
                            color:
                                isOverdue
                                    ? DivvyTheme.darkRed
                                    : DivvyTheme.lightGrey,
                          ),
                        ),
                        Text(
                          'Tap to view details',
                          style: DivvyTheme.detailGrey,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Display chevron icon
            Flexible(
              flex: 1,
              child: Icon(
                CupertinoIcons.chevron_right,
                color: DivvyTheme.lightGrey,
                size: 20,
              ),
            ),
          ],
        ),
        Divider(color: DivvyTheme.shadow),
      ],
    );
  }

  void _openChoreInstancePage(BuildContext context, ChoreInstID id) {
    print('Opening chore instance $id');
  }
}
