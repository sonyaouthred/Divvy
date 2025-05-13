// import 'package:divvy/models/divvy_theme.dart';
// Commented out for testing
import 'package:divvy/models/chore.dart';
import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/models/subgroup.dart';
import 'package:divvy/providers/divvy_provider.dart';
import 'package:divvy/widgets/chore_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Displays all the chores for this house in subgroup
/// and general categories.
class HouseChores extends StatelessWidget {
  const HouseChores({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final spacing = width * 0.05;

    return Consumer<DivvyProvider>(
      builder: (context, provider, child) {
        // Get list of subgroups that this
        // user is in.
        List<Subgroup> subgroups = provider.subgroups;
        return Scaffold(
          backgroundColor: DivvyTheme.background,
          appBar: AppBar(
            title: Text('House Chores', style: DivvyTheme.screenTitle),
            centerTitle: true,
            scrolledUnderElevation: 0,
            backgroundColor: DivvyTheme.background,
          ),
          body: SizedBox.expand(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(spacing),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Add chore button
                    InkWell(
                      onTap: () => print('adding chore'),
                      child: Container(
                        decoration: DivvyTheme.textInput,
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
                    SizedBox(height: spacing),
                    Text('Subgroup Chores', style: DivvyTheme.bodyBoldBlack),
                    SizedBox(height: spacing),
                    ...subgroups.map(
                      (subgroup) => _subgroupChoresWidget(
                        subgroup,
                        provider,
                        context,
                        spacing,
                      ),
                    ),
                    SizedBox(height: spacing / 2),
                    Text('House Chores', style: DivvyTheme.bodyBoldBlack),
                    SizedBox(height: spacing / 2),
                    // Display house chores
                    _allHouseChoresWidget(provider, context, spacing),
                  ],
                ),
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

  /// Show all chores that belong to a given subgroup
  Widget _subgroupChoresWidget(
    Subgroup subgroup,
    DivvyProvider provider,
    BuildContext context,
    double spacing,
  ) {
    // list of chores for subgroup
    List<Chore> choresUnderSubgroup = provider.getSubgroupChores(subgroup.id);
    return Column(
      children: [
        Row(
          children: [
            CircleAvatar(radius: 12, backgroundColor: subgroup.profilePicture),
            SizedBox(width: 10),
            Text(subgroup.name, style: DivvyTheme.bodyBlack),
          ],
        ),
        SizedBox(height: spacing / 2),
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
        SizedBox(height: spacing / 2),
      ],
    );
  }
}
