import 'package:divvy/models/chore.dart';
import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/models/member.dart';
import 'package:divvy/providers/divvy_provider.dart';
import 'package:divvy/util/date_funcs.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Displays information about a given chore instance
class ChoreInstanceScreen extends StatefulWidget {
  final ChoreInstID choreInstanceId;
  final ChoreID choreID;

  const ChoreInstanceScreen({
    super.key,
    required this.choreInstanceId,
    required this.choreID,
  });

  @override
  State<ChoreInstanceScreen> createState() => _ChoreInstanceScreenState();
}

class _ChoreInstanceScreenState extends State<ChoreInstanceScreen> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final spacing = width * 0.02;

    return Consumer<DivvyProvider>(
      builder: (context, provider, child) {
        // Get the super chore for this instance
        Chore parentChore = provider.getSuperChore(widget.choreID);
        // Get the updated instance (potentially with new info) from provider
        ChoreInst choreInstance = provider.getChoreInstanceFromID(
          widget.choreID,
          widget.choreInstanceId,
        );
        // Get the assignee to the chore
        Member thisAssignee = provider.getMemberById(choreInstance.assignee);
        // Get a list of other people assigned to the chore
        List<Member> otherAssignees = provider.getMembersDoingChore(
          widget.choreID,
        );
        // Remove the current assingee from list of other assignees
        otherAssignees.removeWhere((member) => member.id == thisAssignee.id);

        return Scaffold(
          backgroundColor: DivvyTheme.background,
          appBar: AppBar(
            title: Text("Chore", style: DivvyTheme.screenTitle),
            centerTitle: true,
            scrolledUnderElevation: 0,
            backgroundColor: DivvyTheme.background,
          ),
          bottomNavigationBar:
              isInstanceOverdue(choreInstance)
                  ? Container(
                    height: 50, // 👈 this keeps it compact
                    // color: Colors.red[100], // optional background
                    padding: EdgeInsets.only(bottom: 15),
                    child: Center(
                      child: Text(
                        "CHORE OVERDUE!",
                        style: DivvyTheme.largeHeaderRed,
                      ),
                    ),
                  )
                  : null,
          body: SizedBox.expand(
            child: SingleChildScrollView(
              child: Container(
                width: width,
                padding: EdgeInsets.symmetric(horizontal: spacing),
                child: Column(
                  children: [
                    _displayChoreName(parentChore.emoji, parentChore.name),
                    _displayAssigneeAndDueDate(
                      thisAssignee.name,
                      choreInstance.dueDate,
                    ),
                    _displayOtherAssigneesAndFrequency(
                      otherAssignees,
                      parentChore.frequency,
                    ),
                    _markAsCompleteButton(choreInstance, provider),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  bool isInstanceOverdue(ChoreInst instance) {
    return instance.dueDate.isBefore(DateTime.now()) && !instance.isDone;
  }

  Widget _markAsCompleteButton(
    ChoreInst choreInstance,
    DivvyProvider provider,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          provider.toggleChoreInstanceCompletedState(
            choreInstance.choreID,
            choreInstance.id,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: DivvyTheme.beige,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(12),
          ),
        ),
        child: Text(
          choreInstance.isDone ? "MARK AS INCOMPLETE" : "MARK AS COMPLETE",
          style: DivvyTheme.largeHeaderBlack,
        ),
      ),
    );
  }

  Widget _displayChoreName(String emojiText, String choreName) {
    return Card(
      color: DivvyTheme.background,
      elevation: 2,
      child: ListTile(
        leading: Text(emojiText, style: TextStyle(fontSize: 40)),
        title: Text(choreName, style: DivvyTheme.bodyBlack),
      ),
    );
  }

  String getFormattedDate(DateTime dueDate) {
    return "${DateFormat.yMMMMd('en_US').format(dueDate)} at ${getFormattedTime(dueDate)}";
  }

  Widget _displayAssigneeAndDueDate(String assigneeName, DateTime dueDate) {
    String formattedDate = getFormattedDate(dueDate);

    return Card(
      color: DivvyTheme.background,
      elevation: 1,

      child: Container(
        padding: EdgeInsets.all(10),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Assignee Name: $assigneeName",
              style: DivvyTheme.largeHeaderGrey,
            ),
            SizedBox(width: 10),
            Text("Due Date: $formattedDate", style: DivvyTheme.largeHeaderGrey),
          ],
        ),
      ),
    );
  }

  String _getFrequencySentence(Frequency frequency) {
    if (frequency == Frequency.daily) {
      return "Once every day.";
    } else if (frequency == Frequency.monthly) {
      return "Once every month";
    } else {
      return "Once every week";
    }
  }

  Widget _displayOtherAssigneesAndFrequency(
    List<Member> otherAssignees,
    Frequency frequency,
  ) {
    return Card(
      color: DivvyTheme.background,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Other Assignees:", style: DivvyTheme.largeHeaderGrey),
            otherAssignees.isEmpty
                ? Text("None", style: DivvyTheme.bodyGrey)
                : SizedBox(),
            ...otherAssignees.map((assignee) {
              return Text(assignee.name, style: DivvyTheme.bodyGrey);
            }),
            SizedBox(height: 10),
            Text("Frequency:", style: DivvyTheme.largeHeaderGrey),
            Text(_getFrequencySentence(frequency), style: DivvyTheme.bodyGrey),
          ],
        ),
      ),
    );
  }
}
