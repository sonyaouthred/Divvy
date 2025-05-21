import 'package:divvy/models/chore.dart';
import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/models/swap.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SwapTile extends StatelessWidget {

  final Swap swap;
  final Chore chore;
  final ChoreInst choreInst;

  const SwapTile({super.key, required this.swap, required this.chore, required this.choreInst});

  static Map<Status, String> swapStatusToString = const {
    Status.approved : "Approved",
    Status.open : "Open",
    Status.pending: "Pending",
    Status.rejected: "Rejected"
  };

  static Map<Status, IconData> swapStatusToIcon = const {
    Status.approved: CupertinoIcons.check_mark_circled_solid,
    Status.open: CupertinoIcons.circle,
    Status.pending: CupertinoIcons.refresh_circled,
    Status.rejected: CupertinoIcons.clear_circled_solid
  };

  String getFormattedDate(ChoreInst choreInst) {
    return DateFormat.MMMd().format(choreInst.dueDate);
  }

  Widget iconWidget(Status swapSatus) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(swapStatusToIcon[swapSatus]),
        Text(swapStatusToString[swapSatus]!)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Text(chore.emoji),
        title: Text(
          chore.name,
          style: DivvyTheme.bodyBoldBlack,
        ),
        subtitle: Text(
          getFormattedDate(choreInst)
        ),
        trailing: iconWidget(swap.status),
      ),
    );
  }
}