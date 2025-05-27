import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/models/member.dart';
import 'package:divvy/models/subgroup.dart';
import 'package:divvy/screens/subgroup_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Displays the tile for a subgroup with their
/// image and name. When tapped, opens their page.
/// Parameters:
///   - subgroup: the Subgroup to display
///   - spacing: the spacing of the parent screen.
class SubgroupTile extends StatelessWidget {
  final Subgroup subgroup;
  final double spacing;
  const SubgroupTile({
    super.key,
    required this.subgroup,
    required this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: spacing),
      child: InkWell(
        onTap: () => _openSubgroupPage(context, subgroup),
        child: Column(
          children: [
            SizedBox(height: spacing / 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // User profile image
                Row(
                  children: [
                    Container(
                      decoration: DivvyTheme.profileCircle(
                        subgroup.profilePicture.color,
                      ),
                      height: 25,
                      width: 25,
                    ),
                    SizedBox(width: spacing / 2),
                    Text(subgroup.name, style: DivvyTheme.bodyBlack),
                  ],
                ),
                Icon(
                  CupertinoIcons.chevron_right,
                  color: DivvyTheme.lightGrey,
                  size: 15,
                ),
              ],
            ),
            SizedBox(height: spacing / 2),
            Divider(color: DivvyTheme.altBeige),
          ],
        ),
      ),
    );
  }

  /// Will open the subgroups screen
  void _openSubgroupPage(BuildContext context, Subgroup subgroup) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SubgroupScreen(currSubgroup: subgroup),
      ),
    );
  }
}
