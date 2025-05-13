import 'package:divvy/models/chore.dart';
import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/models/member.dart';
import 'package:divvy/providers/divvy_provider.dart';
import 'package:divvy/screens/chore_instance_screen.dart';
import 'package:divvy/util/date_funcs.dart';
import 'package:divvy/util/dialogs.dart';
import 'package:divvy/widgets/chore_tile.dart';
import 'package:divvy/widgets/member_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Displays basic information about a chore superclass
class ChoreSuperclassScreen extends StatelessWidget {
  // The current chore superclass being displayed
  final ChoreID choreID;

  const ChoreSuperclassScreen({super.key, required this.choreID});
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final spacing = width * 0.05;

    return Consumer<DivvyProvider>(
      builder: (context, provider, child) {
        // Update data from provider
        Chore chore = provider.getSuperChore(choreID);
        List<Member> choreAssignees = provider.getChoreAssignees(choreID);

        // Get the list of upcoming chores for this super class
        List<ChoreInst> upcomingChores = [];
        for (Member member in choreAssignees) {
          upcomingChores.addAll(
            provider
                .getUpcomingChores(member.id)
                .where((chore) => chore.superID == choreID),
          );
        }

        // Sort the upcoming chores by due date
        upcomingChores.sort((a, b) => a.dueDate.isBefore(b.dueDate) ? -1 : 1);

        return Scaffold(
          backgroundColor: DivvyTheme.background,
          appBar: AppBar(
            title: Text("Chore Information", style: DivvyTheme.screenTitle),
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
            child: SingleChildScrollView(
              child: Container(
                width: width,
                padding: EdgeInsets.symmetric(horizontal: spacing),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: spacing),
                    _choreEditableTile(chore, context, spacing),
                    SizedBox(height: spacing / 2),
                    _customDivider(spacing),
                    _frequencyWidget(chore, spacing),
                    _customDivider(spacing),
                    _getAssigneesWidget(context, choreAssignees, spacing),
                    SizedBox(height: spacing),
                    upcomingChores.isEmpty
                        ? SizedBox()
                        : Text("Upcoming:", style: DivvyTheme.bodyBoldGrey),
                    SizedBox(height: spacing),
                    ...upcomingChores.map((ChoreInst choreInst) {
                      return _upcomingChoreInstanceTile(
                        choreInst,
                        choreAssignees.firstWhere(
                          (member) => member.id == choreInst.assignee,
                        ),
                        context,
                        spacing,
                      );
                    }),
                    SizedBox(height: spacing * 3),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

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
        // TODO: update provider
        print('Ok, finally deleting');
      }
    }
  }

  /// Shows an upcoming chore instance and who it's assigned to
  Widget _upcomingChoreInstanceTile(
    ChoreInst choreInstance,
    Member member,
    BuildContext context,
    double spacing,
  ) {
    return InkWell(
      onTap: () => _openChoreInstance(context, choreInstance),
      child: Column(
        children: [
          _memberTile(member, spacing),
          SizedBox(height: spacing / 2),
          ChoreTile(choreInst: choreInstance),
          SizedBox(height: spacing / 2),
        ],
      ),
    );
  }

  /// Displays the frequency of the chore
  Widget _frequencyWidget(Chore chore, double spacing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Frequency:", style: DivvyTheme.bodyBoldBlack),
        SizedBox(height: spacing / 2),
        // The frequency of the chore
        Text(getFrequencySentence(chore), style: DivvyTheme.bodyBlack),
      ],
    );
  }

  /// Displays all the members currently assigned to this chore
  Widget _getAssigneesWidget(
    BuildContext context,
    List<Member> members,
    double spacing,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Assignees:", style: DivvyTheme.bodyBoldBlack),
        SizedBox(height: spacing / 3),
        ...members.map((member) {
          return MemberTile(member: member, spacing: spacing);
        }),
      ],
    );
  }

  // Displays a tile for a given member, including profile photo
  // and name
  Widget _memberTile(Member member, double spacing) {
    return Row(
      children: [
        Container(
          decoration: DivvyTheme.profileCircle(member.profilePicture),
          height: 25,
          width: 25,
        ),
        SizedBox(width: spacing / 2),
        Text(member.name, style: DivvyTheme.smallBodyBlack),
      ],
    );
  }

  /// Displays a horizontal divider
  Widget _customDivider(double spacing) {
    return Column(
      children: [
        SizedBox(height: spacing / 2),
        Divider(indent: 10, color: DivvyTheme.altBeige),
        SizedBox(height: spacing / 2),
      ],
    );
  }

  /// Displays the title of the chore and allows user to edit
  Widget _choreEditableTile(Chore chore, BuildContext context, double spacing) {
    return Container(
      decoration: DivvyTheme.standardBox,
      padding: EdgeInsets.symmetric(vertical: spacing / 2),
      child: ListTile(
        leading: Text(chore.emoji, style: TextStyle(fontSize: 40)),
        title: Text(chore.name, style: DivvyTheme.bodyBlack),
        trailing: IconButton(
          onPressed: () async {
            // prompt for new name and assign if valid
            final newName = await openInputDialog(
              context,
              title: 'Edit Chore Name',
              initText: chore.name,
            );
            if (newName != null && context.mounted) {
              Provider.of<DivvyProvider>(
                context,
                listen: false,
              ).changeName(choreID, newName);
            }
          },
          icon: Icon(CupertinoIcons.pencil),
        ),
      ),
    );
  }

  ////////////////////////////// Util //////////////////////////////

  /// Opens screen for a given chore instance
  void _openChoreInstance(BuildContext context, ChoreInst choreInstance) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (ctx) => ChoreInstanceScreen(
              choreInstanceId: choreInstance.id,
              choreID: choreInstance.superID,
            ),
      ),
    );
  }
}
