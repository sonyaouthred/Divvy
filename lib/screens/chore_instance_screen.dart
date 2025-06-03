import 'package:divvy/models/chore.dart';
import 'package:divvy/models/comment.dart';
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
/// Parameters:
///   - choreInstanceID: the ID of the chore instance being
///       displayed.
///   - choreID: the ID of the superclass of the chore instance
///       being displayed.
class ChoreInstanceScreen extends StatefulWidget {
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
  State<ChoreInstanceScreen> createState() => _ChoreInstanceScreenState();
}

class _ChoreInstanceScreenState extends State<ChoreInstanceScreen> {
  bool completing = false;
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final spacing = width * 0.05;

    return Consumer<DivvyProvider>(
      builder: (context, provider, child) {
        // Get the super chore for this instance
        Chore? parentChore = provider.getSuperChore(widget.choreID);
        // If chore no longer exists, show chore not found screen
        if (parentChore == null) return _choreNotFoundScreen(width, spacing);

        // Get the updated instance (potentially with new info) from provider
        ChoreInst? choreInstance = provider.getChoreInstanceFromID(
          widget.choreID,
          widget.choreInstanceId,
        );
        if (choreInstance == null) return _choreNotFoundScreen(width, spacing);
        // Get the assignee to the chore
        Member? thisAssignee = provider.getMemberById(choreInstance.assignee);
        if (thisAssignee == null) return _choreNotFoundScreen(width, spacing);
        // Get a list of other people assigned to the chore
        List<Member> otherAssignees = provider.getMembersDoingChore(
          widget.choreID,
        );
        // Remove the current assingee from list of other assignees
        otherAssignees.removeWhere((member) => member.id == thisAssignee.id);

        // fetch comments!
        List<Comment> comments = choreInstance.comments;

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
                onTap: () => _showActionMenu(context, choreInstance),
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
                        SizedBox(height: spacing),
                        _showComments(spacing, comments, [
                          ...otherAssignees,
                          thisAssignee,
                        ]),
                        // give extra room so that content isn't hidden behind
                        // complete button
                        SizedBox(height: spacing * 10),
                      ],
                    ),
                  ),
                ),
                // don't allow user to check off chore if they aren't the assignee
                if (choreInstance.assignee == provider.currMember.id)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: _markCompleteButton(
                      context,
                      spacing,
                      choreInstance,
                      provider,
                      width,
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
      dayIsAfter(DateTime.now(), instance.dueDate) && !instance.isDone;

  /// Displays the information for this chore and its instance.
  Widget _displayCurrChoreInfo(
    BuildContext context,
    Chore chore,
    ChoreInst inst,
    Member? assignee,
    double spacing,
  ) => Container(
    decoration: DivvyTheme.standardBox,
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
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
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
      Text(getFrequencySentence(superChore), style: DivvyTheme.bodyBlack),
    ],
  );

  // Display all comments on this chore
  Widget _showComments(
    double spacing,
    List<Comment> comments,
    List<Member> assignees,
  ) {
    final currMember =
        Provider.of<DivvyProvider>(context, listen: false).currMember.id;
    final isUsersChore =
        assignees.where((mem) => mem.id == currMember).isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Comments", style: DivvyTheme.bodyBoldBlack),
            // can only comment on chore if you are assigned to it
            if (isUsersChore)
              InkWell(
                onTap: () async {
                  final newComment = await openInputDialog(
                    context,
                    title: 'Add a comment',
                  );
                  if (newComment != null && mounted) {
                    await Provider.of<DivvyProvider>(
                      context,
                      listen: false,
                    ).addComment(
                      widget.choreID,
                      widget.choreInstanceId,
                      newComment,
                    );
                  }
                },
                child: Container(
                  padding: EdgeInsets.only(bottom: 10),
                  height: 45,
                  width: 45,
                  child: Icon(Icons.add),
                ),
              ),
          ],
        ),
        SizedBox(height: spacing / 2),
        comments.isEmpty
            ? Text('No comments yet!')
            : Container(
              decoration: DivvyTheme.standardBox,
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: spacing,
                vertical: spacing * 0.75,
              ),
              child: Column(
                children:
                    comments
                        .map(
                          (comment) => _commentTile(
                            comment,
                            assignees.firstWhere(
                              (mem) => comment.commenter == mem.id,
                            ),
                            spacing,
                          ),
                        )
                        .toList(),
              ),
            ),
      ],
    );
  }

  // Renders a tile showing an individual comment + the person who commented
  Widget _commentTile(Comment comment, Member member, double spacing) {
    final isUsersComment =
        Provider.of<DivvyProvider>(context, listen: false).currMember.id ==
        comment.commenter;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            MemberTile(
              member: member,
              spacing: spacing,
              suffix: '${isUsersComment ? '(you)' : ''} commented: ',
              button: false,
            ),
            if (isUsersComment)
              InkWell(
                // delete comment button
                onTap: () async {
                  final delete = await confirmDeleteDialog(
                    context,
                    'Delete comment',
                  );
                  if (delete != null && delete && mounted) {
                    Provider.of<DivvyProvider>(
                      context,
                      listen: false,
                    ).deleteComment(
                      widget.choreID,
                      widget.choreInstanceId,
                      comment.id,
                    );
                  }
                },
                child: Container(
                  height: 50,
                  width: 50,
                  padding: EdgeInsets.only(bottom: 8),
                  child: Icon(Icons.delete_outline, color: DivvyTheme.darkRed),
                ),
              ),
          ],
        ),
        Text(
          '${getFormattedDate(comment.date)} at ${getFormattedTime(comment.date)}',
          style: DivvyTheme.detailGrey,
        ),
        SizedBox(height: spacing / 2),
        Text(comment.comment, style: DivvyTheme.largeBodyBlack),
        SizedBox(height: spacing / 2),
      ],
    );
  }

  /// Displays if chore is complete or not. Tapping toggles completion
  Widget _markCompleteButton(
    BuildContext context,
    double spacing,
    ChoreInst choreInst,
    DivvyProvider provider,
    double width,
  ) => Container(
    height: 60,
    margin: EdgeInsets.all(spacing * 3),
    child: InkWell(
      onTap: () async {
        setState(() {
          completing = true;
        });
        bool isDone = !choreInst.isDone;
        // Toggle completion
        await provider.toggleChoreInstanceCompletedState(
          superChoreID: choreInst.superID,
          choreInst: choreInst,
        );
        // Pop screen if chore is now done
        if (isDone && context.mounted) Navigator.of(context).pop();
        setState(() {
          completing = false;
        });
      },
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Container(
        decoration: DivvyTheme.completeBox(choreInst.isDone),
        width: width * 0.75,
        child:
            !completing
                ? Row(
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
                )
                // If currently completing, mark as such
                : CupertinoActivityIndicator(
                  color:
                      choreInst.isDone
                          ? DivvyTheme.background
                          : DivvyTheme.black,
                ),
      ),
    ),
  );

  /// Shows a Cupertino action menu that allows user to delete chore
  void _showActionMenu(BuildContext context, ChoreInst choreInst) async {
    final delete = await showCupertinoModalPopup<bool>(
      context: context,
      builder:
          (BuildContext context) => CupertinoActionSheet(
            title: const Text('Chore Actions'),
            actions: <CupertinoActionSheetAction>[
              CupertinoActionSheetAction(
                onPressed: () async {
                  await _openSwap(context, choreInst);
                  if (!context.mounted) return;
                  Navigator.of(context).pop(false);
                },
                child: const Text('Swap Chore'),
              ),
              CupertinoActionSheetAction(
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
        ).deleteChoreInst(widget.choreID, widget.choreInstanceId);
        Navigator.of(context).pop();
      }
    }
  }

  /// Mark a chore as ready to be swapped
  Future<void> _openSwap(BuildContext context, ChoreInst choreInst) async {
    await Provider.of<DivvyProvider>(
      context,
      listen: false,
    ).openSwap(choreInst, widget.choreID);
  }

  /// Will open the passed member's page
  void _openMemberPage(BuildContext context, Member member) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => UserInfoScreen(memberID: member.id)),
    );
  }
}
