import 'package:divvy/models/chore.dart';
import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/models/member.dart';
import 'package:divvy/models/subgroup.dart';
import 'package:divvy/providers/divvy_provider.dart';
import 'package:divvy/screens/edit_or_add_chore.dart';
import 'package:divvy/util/dialogs.dart';
import 'package:divvy/widgets/chore_tile.dart';
import 'package:divvy/widgets/member_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Displays information about a given subgroup.
/// Displays name, members, and chores.
/// Allows user to delete subgroup.
/// Parameters:
///   - currSubgroup: the Subgroup to be displayed.
class SubgroupScreen extends StatelessWidget {
  final Subgroup currSubgroup;
  const SubgroupScreen({super.key, required this.currSubgroup});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final spacing = width * 0.05;
    return Consumer<DivvyProvider>(
      builder: (context, provider, child) {
        final List<Chore> currChores =
            currSubgroup.chores
                .map((choreID) => provider.getSuperChore(choreID))
                // filter out nulls
                .whereType<Chore>()
                .toList();
        final List<Member> members = provider.getMembersInSubgroup(
          currSubgroup.id,
        );

        return Scaffold(
          backgroundColor: DivvyTheme.background,
          appBar: AppBar(
            title: Text(currSubgroup.name, style: DivvyTheme.screenTitle),
            centerTitle: true,
            scrolledUnderElevation: 0,
            backgroundColor: DivvyTheme.background,
            actions: [
              // Allow user to take actions for this chore
              InkWell(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                onTap: () => _showActionMenu(context),
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
            child: Container(
              padding: EdgeInsets.all(spacing),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display members in subgroup
                    _displayMembers(spacing, members),
                    // Display chores for subgroup
                    _displayChores(spacing, currChores, context),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  ///////////////////////////// Widgets /////////////////////////////

  // Displays list of subgroups and button to allow user to add a subgroup
  Widget _displayMembers(double spacing, List<Member> members) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and add subgroup button
        Text('Members', style: DivvyTheme.bodyBoldBlack),
        SizedBox(height: spacing),
        // List of subgroups
        ListView.builder(
          itemCount: members.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            // Render the member's profile picture and name
            return MemberTile(member: members[index], spacing: spacing);
          },
        ),
      ],
    );
  }

  /// Listing all of subgroup chores
  Widget _displayChores(
    double spacing,
    List<Chore> currChores,
    BuildContext context,
  ) {
    // Return view of subgroup chores
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Chores', style: DivvyTheme.bodyBoldBlack),
            InkWell(
              onTap: () => _addChore(context),
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              child: SizedBox(
                height: 45,
                width: 45,
                child: Icon(CupertinoIcons.add),
              ),
            ),
          ],
        ),
        SizedBox(height: spacing / 2),
        // Display the chore tiles for all chores due today
        if (currChores.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing / 4),
            child: Column(
              children:
                  currChores
                      .map((chore) => ChoreTile(superChore: chore))
                      .toList(),
            ),
          ),
        if (currChores.isEmpty)
          Center(
            child: Text('No chores yet. Add one!', style: DivvyTheme.bodyGrey),
          ),
      ],
    );
  }

  /// Shows a Cupertino action menu that allows user to delete subgroup
  void _showActionMenu(BuildContext context) async {
    final width = MediaQuery.of(context).size.width;
    final spacing = width * 0.05;
    final currMemID =
        Provider.of<DivvyProvider>(context, listen: false).currMember.id;
    final isCurrMembersGroup = currSubgroup.members.contains(currMemID);
    final delete = await showCupertinoModalPopup<bool>(
      context: context,
      builder:
          (BuildContext context) => CupertinoActionSheet(
            title: const Text('Subgroup Actions'),
            actions: <CupertinoActionSheetAction>[
              CupertinoActionSheetAction(
                onPressed: () async {
                  // prompt for new color & change!!
                  final newColor = await openColorDialog(
                    context,
                    currSubgroup.profilePicture,
                    spacing,
                  );
                  if (!context.mounted) return;
                  Provider.of<DivvyProvider>(
                    context,
                    listen: false,
                  ).updateSubgroupColor(currSubgroup, newColor);
                  Navigator.of(context).pop(false);
                },
                child: const Text('Change Color'),
              ),
              // don't let user leave a subgroup they don't belong to
              if (isCurrMembersGroup)
                CupertinoActionSheetAction(
                  isDestructiveAction: true,
                  onPressed: () {
                    Provider.of<DivvyProvider>(
                      context,
                      listen: false,
                    ).leaveSubgroup(subgroupID: currSubgroup.id);
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Leave subgroup'),
                ),
              CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    if (delete != null && delete && context.mounted) {
      final confirm = await confirmDeleteDialog(
        context,
        'Delete Subgroup?',
        message: 'This will also delete all associated chores.',
      );
      if (confirm != null && confirm) {
        if (!context.mounted) return;
        // Leave screen
        Navigator.pop(context);
        Provider.of<DivvyProvider>(
          context,
          listen: false,
        ).deleteSubgroup(currSubgroup.id);
      }
    }
  }

  /// Add a chore for this subgroup!!
  void _addChore(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => EditOrAddChore(choreID: null, subgroup: currSubgroup),
      ),
    );
  }
}
