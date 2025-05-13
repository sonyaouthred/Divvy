import 'package:divvy/models/chore.dart';
import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/models/member.dart';
import 'package:divvy/models/subgroup.dart';
import 'package:divvy/providers/divvy_provider.dart';
import 'package:divvy/util/dialogs.dart';
import 'package:divvy/widgets/chore_tile.dart';
import 'package:divvy/widgets/member_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
                onTap: () => _showActionMenu(context),
                splashColor: Colors.transparent,
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Display members in subgroup
                    _displayMembers(spacing, members),
                    // Display chores for subgroup
                    _displayChores(spacing, currChores),
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
        SizedBox(height: spacing / 2),
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
  Widget _displayChores(double spacing, List<Chore> currChores) {
    // Return view of subgroup chores
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Chores', style: DivvyTheme.bodyBoldBlack),
        SizedBox(height: spacing / 2),
        // Display the chore tiles for all chores due today
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing / 4),
          child: Column(
            children:
                currChores
                    .map((chore) => ChoreTile(superChore: chore))
                    .toList(),
          ),
        ),
      ],
    );
  }

  /// Shows a Cupertino action menu that allows user to delete subgroup
  void _showActionMenu(BuildContext context) async {
    final delete = await showCupertinoModalPopup<bool>(
      context: context,
      builder:
          (BuildContext context) => CupertinoActionSheet(
            title: const Text('Subgroup Actions'),
            actions: <CupertinoActionSheetAction>[
              CupertinoActionSheetAction(
                /// This parameter indicates the action would perform
                /// a destructive action such as delete or exit and turns
                /// the action's text color to red.
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
      final confirm = await confirmDeleteDialog(context, 'Delete Subgroup');
      if (confirm != null && confirm) {
        if (!context.mounted) return;
        Provider.of<DivvyProvider>(context, listen: false).deleteSubgroup(currSubgroup);
      }
    }
  }
}
