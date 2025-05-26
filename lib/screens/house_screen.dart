import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/models/member.dart';
import 'package:divvy/models/subgroup.dart';
import 'package:divvy/providers/divvy_provider.dart';
import 'package:divvy/screens/house_chores.dart';
import 'package:divvy/screens/house_settings.dart';
import 'package:divvy/screens/subgroup_add.dart';
import 'package:divvy/screens/user_info_screen.dart';
import 'package:divvy/widgets/leaderboard.dart';
import 'package:divvy/widgets/subgroup_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Displays the current house's dashboard.
/// Shows the list of current members/subgroups, allows
/// users to open house settings, allows users to view
/// all chores for house, etc.
class House extends StatelessWidget {
  const House({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final spacing = width * 0.05;
    return Consumer<DivvyProvider>(
      builder: (context, provider, child) {
        // List of members in the house
        final List<Member> members = provider.members;
        // list of subgroups in the house
        final List<Subgroup> subgroups = provider.subgroups;

        return SizedBox.expand(
          child: SingleChildScrollView(
            child: Container(
              width: width,
              padding: EdgeInsets.symmetric(horizontal: spacing),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Members list
                  _displayMembers(context, spacing, members),
                  SizedBox(height: spacing),
                  Leaderboard(title: 'Leaderboard'),
                  SizedBox(height: spacing),
                  // Display add roommate and settings buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _boxButton(
                        context: context,
                        title: 'Manage Chores',
                        icon: Icon(CupertinoIcons.list_bullet),
                        spacing: spacing,
                        callback: _manageChores,
                      ),
                      SizedBox(width: spacing),
                      _boxButton(
                        context: context,
                        title: 'Settings',
                        icon: Icon(CupertinoIcons.settings),
                        spacing: spacing,
                        callback: _openSettings,
                      ),
                    ],
                  ),
                  SizedBox(height: spacing),
                  // Display subgroups
                  _displaySubgroups(context, spacing, subgroups),
                  SizedBox(height: spacing * 3),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  ///////////////////////////// Widgets /////////////////////////////

  /// Displays all members as a horizontally scrolling list
  Widget _displayMembers(
    BuildContext context,
    double spacing,
    List<Member> members,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Members', style: DivvyTheme.bodyBoldBlack),
        SizedBox(height: spacing),
        // Display all member tiles
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children:
                members.map((member) {
                  return Padding(
                    padding: EdgeInsets.only(right: spacing),
                    child: InkWell(
                      onTap: () => _openMemberPage(context, member),
                      child: Column(
                        children: [
                          Container(
                            decoration: DivvyTheme.profileCircle(
                              member.profilePicture.color,
                            ),
                            height: 60,
                            width: 60,
                          ),
                          SizedBox(height: spacing / 2),
                          Text(member.name, style: DivvyTheme.smallBodyBlack),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  /// Button to perform action on tap.
  Widget _boxButton({
    required BuildContext context,
    required String title,
    required Icon icon,
    required double spacing,
    required Function callback,
  }) {
    return Flexible(
      flex: 1,
      child: InkWell(
        onTap: () => callback(context),
        child: Container(
          width: double.infinity,
          decoration: DivvyTheme.standardBox,
          padding: EdgeInsets.all(spacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              icon,
              SizedBox(height: spacing),
              Text(title, style: DivvyTheme.bodyBoldBlack),
            ],
          ),
        ),
      ),
    );
  }

  /// Displays list of subgroups and button to allow user to add a subgroup
  Widget _displaySubgroups(
    BuildContext context,
    double spacing,
    List<Subgroup> subgroups,
  ) {
    return Column(
      children: [
        // Title and add subgroup button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Subgroups', style: DivvyTheme.bodyBoldBlack),
            InkWell(
              onTap: () => _addSubgroup(context),
              child: SizedBox(
                height: 45,
                width: 45,
                child: Icon(CupertinoIcons.add),
              ),
            ),
          ],
        ),
        // List of subgroups
        ...subgroups.map(
          (sub) => SubgroupTile(subgroup: sub, spacing: spacing),
        ),
      ],
    );
  }

  ///////////////////////////// util /////////////////////////////

  /// Will trigger the screen to add a subgroup
  void _addSubgroup(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => SubgroupAdd()));
    //return;
  }

  /// Will trigger the screen to add a roommate
  void _manageChores(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (ctx) => HouseChores()));
  }

  /// Opens the house settings screen
  void _openSettings(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => HouseSettings()));
  }

  /// Will open the passed member's page
  void _openMemberPage(BuildContext context, Member member) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => UserInfoScreen(memberID: member.id)),
    );
  }
}
