import 'package:divvy/models/chore.dart';
import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/models/member.dart';
import 'package:divvy/providers/divvy_provider.dart';
import 'package:divvy/screens/user_info_screen.dart';
import 'package:divvy/util/date_funcs.dart';
import 'package:divvy/util/dialogs.dart';
import 'package:divvy/widgets/member_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Displays information about a given chore instance
class ChoreInstanceScreen extends StatelessWidget {
  // The current chore instance
  final ChoreInstID choreInstanceId;
  // The ID of the superclass of the chore instance
  final ChoreID choreID;

  const ChoreInstanceScreen({
    super.key,
    required this.choreInstanceId,
    required this.choreID,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final spacing = width * 0.05;

    return Consumer<DivvyProvider>(
      builder: (context, provider, child) {
        // Get the super chore for this instance
        Chore? parentChore = provider.getSuperChore(choreID);
        // If chore no longer exists, show chore not found screen
        if (parentChore == null) return _choreNotFoundScreen(width, spacing);
        print(parentChore.id);

        // Get the updated instance (potentially with new info) from provider
        ChoreInst choreInstance = provider.getChoreInstanceFromID(
          choreID,
          choreInstanceId,
        );
        // Get the assignee to the chore
        Member? thisAssignee = provider.getMemberById(choreInstance.assignee);
        // Get a list of other people assigned to the chore
        List<Member> otherAssignees = provider.getMembersDoingChore(choreID);
        // Remove the current assingee from list of other assignees
        otherAssignees.removeWhere((member) => member.id == thisAssignee?.id);

        return Scaffold(
          backgroundColor: DivvyTheme.background,
          appBar: AppBar(
            title: Text("Chore", style: DivvyTheme.screenTitle),
            centerTitle: true,
            scrolledUnderElevation: 0,
            backgroundColor: DivvyTheme.background,
            actions: [
              // Allow user to take actions for this chore
              InkWell(
                onTap: () => _showActionMenu(context),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Container(
                  height: 45,
                  width: 45,
                  alignment: Alignment.centerLeft,
                  child: Icon(CupertinoIcons.ellipsis),
                ),
              ),
            ],
          ),
          body: SizedBox.expand(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Container(
                    width: width,
                    padding: EdgeInsets.symmetric(horizontal: spacing),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: spacing),
                        // Display name of chore, current assignee,
                        // and due date
                        _displayCurrChoreInfo(
                          context,
                          parentChore,
                          choreInstance,
                          thisAssignee,
                          spacing,
                        ),
                        SizedBox(height: spacing),
                        // Display the other people assigned to this chore
                        _displayOtherAssignees(
                          otherAssignees,
                          parentChore,
                          spacing,
                        ),
                        SizedBox(height: spacing),
                        // Display the frequency this chore repeats
                        _displayFrequency(spacing, parentChore),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _markCompleteButton(
                    context,
                    spacing,
                    choreInstance,
                    provider,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Displays chore not found screen
  Scaffold _choreNotFoundScreen(double width, double spacing) {
    return Scaffold(
      backgroundColor: DivvyTheme.background,
      appBar: AppBar(
        title: Text('Chore', style: DivvyTheme.screenTitle),
        centerTitle: true,
        scrolledUnderElevation: 0,
        backgroundColor: DivvyTheme.background,
      ),
      body: SizedBox.expand(
        child: Container(
          width: width,
          padding: EdgeInsets.symmetric(horizontal: spacing),
          child: Center(
            child: Text('404: Chore not found', style: DivvyTheme.bodyBlack),
          ),
        ),
      ),
    );
  }

  /// Returns true if the given chore instance is overdue.
  bool isInstanceOverdue(ChoreInst instance) =>
      instance.dueDate.isBefore(DateTime.now()) && !instance.isDone;

  /// Displays the information for this chore and its instance.
  Widget _displayCurrChoreInfo(
    BuildContext context,
    Chore chore,
    ChoreInst inst,
    Member? assignee,
    double spacing,
  ) => Container(
    decoration: DivvyTheme.textInput,
    padding: EdgeInsets.only(
      left: spacing,
      right: spacing,
      bottom: spacing,
      top: spacing * 0.75,
    ),
    child: Column(
      children: [
        Row(
          children: [
            Text(chore.emoji, style: TextStyle(fontSize: 30)),
            SizedBox(width: spacing),
            Text(chore.name, style: DivvyTheme.largeBodyBlack),
          ],
        ),
        SizedBox(height: spacing / 2),
        // Display current assignee adn their profile picture
        InkWell(
          onTap:
              () =>
                  (assignee != null) ? _openMemberPage(context, assignee) : (),
          child: Row(
            children: [
              Text("Assignee: ", style: DivvyTheme.bodyBoldBlack),
              SizedBox(width: spacing / 2),
              if (assignee != null)
                Container(
                  decoration: DivvyTheme.profileCircle(
                    assignee.profilePicture.color,
                  ),
                  height: 25,
                  width: 25,
                ),
              if (assignee != null) SizedBox(width: spacing / 2),
              if (assignee != null)
                Text(assignee.name, style: DivvyTheme.bodyBlack),
            ],
          ),
        ),
        SizedBox(height: spacing),
        // Displays due date, in red if overdue
        Row(
          children: [
            Text(
              "Due Date: ",
              style: DivvyTheme.bodyBoldBlack.copyWith(
                color:
                    isInstanceOverdue(inst)
                        ? DivvyTheme.darkRed
                        : DivvyTheme.black,
              ),
            ),
            SizedBox(width: spacing / 2),
            Text(
              getFormattedDate(inst.dueDate),
              style: DivvyTheme.bodyBlack.copyWith(
                color:
                    isInstanceOverdue(inst)
                        ? DivvyTheme.darkRed
                        : DivvyTheme.black,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  /// Displays the other people this chore is assigned to
  Widget _displayOtherAssignees(
    List<Member> otherAssignees,
    Chore superChore,
    double spacing,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("Other Assignees:", style: DivvyTheme.bodyBoldBlack),
      otherAssignees.isEmpty
          ? Text("None", style: DivvyTheme.bodyGrey)
          : SizedBox(),
      SizedBox(height: spacing / 2),
      ...otherAssignees.map((assignee) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing / 4),
          child: MemberTile(member: assignee, spacing: spacing),
        );
      }),
    ],
  );

  /// The frequency this chore is repeated
  Widget _displayFrequency(double spacing, Chore superChore) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("Frequency:", style: DivvyTheme.bodyBoldBlack),
      SizedBox(height: spacing / 4),
      // Text("${superChore.frequency.daysOfWeek[0].toString()}")
      Text(getFrequencySentence(superChore), style: DivvyTheme.bodyBlack),
    ],
  );

  /// Displays if chore is complete or not. Tapping toggles completion
  Widget _markCompleteButton(
    BuildContext context,
    double spacing,
    ChoreInst choreInst,
    DivvyProvider provider,
  ) => InkWell(
    onTap: () {
      bool isDone = !choreInst.isDone;
      // Toggle completion
      provider.toggleChoreInstanceCompletedState(
        superChoreID: choreInst.superID,
        choreInst: choreInst,
      );
      // Pop screen if chore is now done
      if (isDone) Navigator.of(context).pop();
    },
    highlightColor: Colors.transparent,
    splashColor: Colors.transparent,
    child: Container(
      height: 60,
      margin: EdgeInsets.all(spacing * 3),
      decoration: DivvyTheme.completeBox(choreInst.isDone),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Display check and text representing current state
          Icon(
            Icons.check,
            color:
                choreInst.isDone
                    ? DivvyTheme.background
                    : DivvyTheme.mediumGreen,
          ),
          SizedBox(width: spacing),
          Text(
            choreInst.isDone ? 'Complete' : 'Mark Complete',
            style:
                choreInst.isDone
                    ? DivvyTheme.largeBoldMedWhite
                    : DivvyTheme.largeBoldMedGreen,
          ),
        ],
      ),
    ),
  );

  /// Shows a Cupertino action menu that allows user to delete chore
  void _showActionMenu(BuildContext context) async {
    final delete = await showCupertinoModalPopup<bool>(
      context: context,
      builder:
          (BuildContext context) => CupertinoActionSheet(
            title: const Text('Chore Actions'),
            actions: <CupertinoActionSheetAction>[
              CupertinoActionSheetAction(
                /// This parameter indicates the action would perform
                /// a destructive action such as delete or exit and turns
                /// the action's text color to red.
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('Delete Chore'),
              ),
            ],
          ),
    );
    if (delete != null && delete && context.mounted) {
      final confirm = await confirmDeleteDialog(context, 'Delete Chore');
      if (confirm != null && confirm) {
        if (!context.mounted) return;
        Provider.of<DivvyProvider>(
          context,
          listen: false,
        ).deleteChoreInst(choreID, choreInstanceId);
        Navigator.of(context).pop();
      }
    }
  }

  /// Will open the passed member's page
  void _openMemberPage(BuildContext context, Member member) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => UserInfoScreen(memberID: member.id)),
    );
  }
}
