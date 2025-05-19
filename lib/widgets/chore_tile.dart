// ignore_for_file: avoid_print, must_be_immutable

import 'package:divvy/models/chore.dart';
import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/providers/divvy_provider.dart';
import 'package:divvy/screens/chore_instance_screen.dart';
import 'package:divvy/screens/chore_superclass_screen.dart';
import 'package:divvy/util/date_funcs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Renders a tile with information about a chore.
/// When tapped, opens chore page.
/// Can display information for a chore instance or a super chore.
/// INV: if chore instance is not provided, you must provide a
/// super chore
class ChoreTile extends StatelessWidget {
  final ChoreInst? choreInst;
  Chore? superChore;
  final bool compact;
  final bool showFullDate;
  ChoreTile({
    super.key,
    this.choreInst,
    this.superChore,
    this.compact = false,
    this.showFullDate = false,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final spacing = width * 0.05;

    // Get super chore for information
    if (superChore == null) {
      if (choreInst == null) return Placeholder();
      superChore = Provider.of<DivvyProvider>(
        context,
        listen: false,
      ).getSuperChore(choreInst!.superID);
    }
    // Build chore tile
    return InkWell(
      onTap:
          () =>
              choreInst != null
                  ? _openChoreInstancePage(
                    context,
                    choreInst!.id,
                    choreInst!.superID,
                  )
                  : _openSuperChorePage(context, superChore!),
      child:
          compact
              ? _smallChoreTile(superChore!, spacing)
              : _largeChoreTile(superChore!, spacing),
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
          if (choreInst != null)
            Text(
              '${getNameOfWeekday(choreInst!.dueDate.weekday)}, ${DateFormat.yMMMMd('en_US').format(choreInst!.dueDate)}',
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
    // Super chore instances are never overdue
    bool isOverdue =
        (choreInst != null)
            ? (choreInst!.dueDate.isBefore(DateTime.now()) &&
                !choreInst!.isDone)
            : false;
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
                        if (choreInst != null)
                          Text(
                            choreInst!.isDone
                                ? 'Complete!'
                                : isOverdue
                                ? 'Was due ${getNameOfWeekday(choreInst!.dueDate.weekday)}, '
                                    '${getFormattedDate(choreInst!.dueDate)} at '
                                    '${getFormattedTime(choreInst!.dueDate)}'
                                : showFullDate
                                ? 'Due on ${getFormattedDate(choreInst!.dueDate)} at ${getFormattedTime(choreInst!.dueDate)}'
                                : 'Due at ${getFormattedTime(choreInst!.dueDate)}',
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

  /// Opens the chore instance page
  void _openChoreInstancePage(
    BuildContext context,
    ChoreInstID instanceID,
    ChoreID choreId,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (ctx) => ChoreInstanceScreen(
              choreInstanceId: instanceID,
              choreID: choreId,
            ),
      ),
    );
  }

  /// Opens the super chore page
  void _openSuperChorePage(BuildContext context, Chore superChore) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => ChoreSuperclassScreen(choreID: superChore.id),
      ),
    );
  }
}
