// import 'package:divvy/models/divvy_theme.dart';
// Commented out for testing
import 'package:divvy/models/chore.dart';
import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/models/subgroup.dart';
import 'package:divvy/providers/divvy_provider.dart';
import 'package:divvy/screens/edit_or_add_chore.dart';
import 'package:divvy/widgets/chore_tile.dart';
import 'package:divvy/widgets/subgroup_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Displays all the chores for this house in subgroup
/// and general categories. only subgroups the current user
/// is a member of are shown.
class Chores extends StatelessWidget {
  const Chores({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final spacing = width * 0.05;

    return Consumer<DivvyProvider>(
      builder: (context, provider, child) {
        // Get list of subgroups that this
        // user is in.
        List<Subgroup> subgroups = provider.getSubgroupsForMember(
          provider.currMember.id,
        );
        return SizedBox.expand(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(spacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => EditOrAddChore(choreID: null),
                        ),
                      );
                    },
                    child: Container(
                      decoration: DivvyTheme.standardBox,
                      child: ListTile(
                        leading: Icon(CupertinoIcons.add),
                        title: Text(
                          "Add Chore",
                          style: DivvyTheme.bodyBoldBlack,
                        ),
                      ),
                    ),
                  ),
                  // Display subgroup chores
                  SizedBox(height: spacing * 1.5),
                  if (subgroups.isNotEmpty)
                    _subgroupChores(spacing, subgroups, context),
                  if (subgroups.isNotEmpty) SizedBox(height: spacing),
                  Text('House Chores', style: DivvyTheme.bodyBoldBlack),
                  SizedBox(height: spacing / 2),
                  // Display house chores
                  _allHouseChoresWidget(provider, context, spacing),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Show all house chores (that don't belong to a certain subgroup)
  Widget _allHouseChoresWidget(
    DivvyProvider provider,
    BuildContext context,
    double spacing,
  ) {
    List<Chore> otherChores = provider.getNonSubgroupChores();
    if (otherChores.isEmpty) {
      return Text('No house chores yet!', style: DivvyTheme.bodyGrey);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          otherChores
              .map(
                (chore) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: spacing / 2),
                  child: ChoreTile(superChore: chore),
                ),
              )
              .toList(),
    );
  }

  /// Display all chores for user's subgroups
  Widget _subgroupChores(
    double spacing,
    List<Subgroup> subgroups,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Subgroup Chores', style: DivvyTheme.bodyBoldBlack),
        SizedBox(height: spacing),
        ...subgroups.map(
          (subgroup) => _subgroupChoresList(subgroup, context, spacing),
        ),
      ],
    );
  }

  /// Show all chores that belong to a given subgroup
  Widget _subgroupChoresList(
    Subgroup subgroup,
    BuildContext context,
    double spacing,
  ) {
    // list of chores for subgroup
    List<Chore> choresUnderSubgroup = Provider.of<DivvyProvider>(
      context,
      listen: false,
    ).getSubgroupChores(subgroup.id);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SubgroupTile(
          subgroup: subgroup,
          spacing: spacing,
          showChevron: false,
          showDivider: false,
        ),
        SizedBox(height: spacing / 4),
        if (choresUnderSubgroup.isNotEmpty)
          Column(
            children:
                choresUnderSubgroup
                    .map(
                      (chore) => Padding(
                        padding: EdgeInsets.symmetric(horizontal: spacing / 2),
                        child: ChoreTile(superChore: chore),
                      ),
                    )
                    .toList(),
          ),
        if (choresUnderSubgroup.isEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: spacing / 2),
                child: Text('No chores yet!', style: DivvyTheme.bodyGrey),
              ),
              SizedBox(height: spacing / 2),
              Divider(color: DivvyTheme.altBeige),
            ],
          ),
        SizedBox(height: spacing / 2),
      ],
    );
  }
}
