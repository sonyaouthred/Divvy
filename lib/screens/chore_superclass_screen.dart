import 'package:divvy/models/chore.dart';
import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/models/member.dart';
import 'package:divvy/providers/divvy_provider.dart';
import 'package:divvy/screens/chore_instance_screen.dart';
import 'package:divvy/screens/edit_or_add_chore.dart';
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
        Chore? chore = provider.getSuperChore(choreID);
        // If chore no longer exists, show chore not found screen
        if (chore == null) return _choreNotFoundScreen(width, spacing);
        List<Member> choreAssignees = provider.getChoreAssignees(choreID);

        // Get the list of upcoming chores for this super class
        List<ChoreInst> upcomingChores = [];
        for (Member member in choreAssignees) {
          upcomingChores.addAll(
            provider
                .getUpcomingChoresLessStrict(member.id)
                .where((chore) => chore.superID == choreID),
          );
        }

        upcomingChores.sort((a, b) => a.dueDate.isBefore(b.dueDate) ? -1 : 1);

        // Get the list of overdue chores for this super class
        List<ChoreInst> overdueChores = provider.getOverdueChoresByID(chore);

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
                    _choreNameTile(chore, context, spacing),
                    SizedBox(height: spacing / 2),
                    _customDivider(spacing),
                    _frequencyWidget(chore, spacing),
                    _customDivider(spacing),
                    _getAssigneesWidget(context, choreAssignees, spacing),
                    SizedBox(height: spacing / 2),
                    // Display overdue chores (if any)
                    _displayOverdueChores(
                      context,
                      overdueChores,
                      choreAssignees,
                      spacing,
                    ),
                    // Display upcoming chores (if any)
                    _displayUpcomingChores(
                      context,
                      upcomingChores,
                      choreAssignees,
                      spacing,
                    ),
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
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('Edit Chore'),
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
        ).deleteSuperclassChore(choreID);
        // leave screen
        Navigator.of(context).pop();
      }
    } else if (delete != null && !delete && context.mounted) {
      // user wants to edit chore
      Navigator.of(context).push(
        MaterialPageRoute(builder: (ctx) => EditOrAddChore(choreID: choreID)),
      );
    }
  }

  /// Displays all overdue chores for this chore superclass
  Widget _displayUpcomingChores(
    BuildContext context,
    List<ChoreInst> upcomingChores,
    List<Member> members,
    double spacing,
  ) {
    if (upcomingChores.isEmpty) return Container();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Upcoming:", style: DivvyTheme.bodyBoldGrey),
        SizedBox(height: spacing),
        ...upcomingChores.map((ChoreInst choreInst) {
          return _choreInstTileWAssignee(
            choreInst,
            members.firstWhere((member) => member.id == choreInst.assignee),
            context,
            spacing,
          );
        }),
      ],
    );
  }

  /// Displays all overdue chores for this chore superclass
  Widget _displayOverdueChores(
    BuildContext context,
    List<ChoreInst> overdueChores,
    List<Member> members,
    double spacing,
  ) {
    if (overdueChores.isEmpty) return Container();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Overdue:", style: DivvyTheme.bodyBoldRed),
        SizedBox(height: spacing),
        ...overdueChores.map((ChoreInst choreInst) {
          return _choreInstTileWAssignee(
            choreInst,
            members.firstWhere((member) => member.id == choreInst.assignee),
            context,
            spacing,
          );
        }),
      ],
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

  /// Shows an upcoming chore instance and who it's assigned to
  Widget _choreInstTileWAssignee(
    ChoreInst choreInstance,
    Member member,
    BuildContext context,
    double spacing,
  ) => InkWell(
    highlightColor: Colors.transparent,
    splashColor: Colors.transparent,
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

  /// Displays the frequency of the chore
  Widget _frequencyWidget(Chore chore, double spacing) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("Frequency:", style: DivvyTheme.bodyBoldBlack),
      SizedBox(height: spacing / 2),
      // The frequency of the chore
      Text(getFrequencySentence(chore), style: DivvyTheme.bodyBlack),
    ],
  );

  /// Displays all the members currently assigned to this chore
  Widget _getAssigneesWidget(
    BuildContext context,
    List<Member> members,
    double spacing,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("Assignees:", style: DivvyTheme.bodyBoldBlack),
      SizedBox(height: spacing / 2),
      ...members.map((member) {
        return MemberTile(member: member, spacing: spacing);
      }),
    ],
  );

  // Displays a tile for a given member, including profile photo
  // and name
  Widget _memberTile(Member member, double spacing) => Row(
    children: [
      Container(
        decoration: DivvyTheme.profileCircle(member.profilePicture.color),
        height: 25,
        width: 25,
      ),
      SizedBox(width: spacing / 2),
      Text(member.name, style: DivvyTheme.smallBodyBlack),
    ],
  );

  /// Displays a horizontal divider
  Widget _customDivider(double spacing) => Column(
    children: [
      SizedBox(height: spacing / 2),
      Divider(indent: 10, color: DivvyTheme.altBeige),
      SizedBox(height: spacing / 2),
    ],
  );

  /// Displays the title of the chore
  Widget _choreNameTile(Chore chore, BuildContext context, double spacing) =>
      Container(
        decoration: DivvyTheme.standardBox,
        padding: EdgeInsets.symmetric(vertical: spacing / 2),
        child: ListTile(
          leading: Text(chore.emoji, style: TextStyle(fontSize: 40)),
          title: Text(chore.name, style: DivvyTheme.largeBodyBlack),
        ),
      );

  ////////////////////////////// Util //////////////////////////////

  /// Opens screen for a given chore instance
  void _openChoreInstance(BuildContext context, ChoreInst choreInstance) =>
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
