// import 'package:divvy/models/divvy_theme.dart';
// Commented out for testing
// ignore_for_file: avoid_print

import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/models/member.dart';
import 'package:divvy/models/subgroup.dart';
import 'package:divvy/providers/divvy_provider.dart';
import 'package:divvy/screens/house_settings.dart';
import 'package:divvy/widgets/leaderboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class House extends StatefulWidget {
  const House({super.key});

  @override
  State<House> createState() => _HouseState();
}

class _HouseState extends State<House> {
  // List of members in the house
  late List<Member> _members;
  // list of subgroups in the house
  late List<Subgroup> _subgroups;

  @override
  void initState() {
    super.initState();
    final providerRef = Provider.of<DivvyProvider>(context, listen: false);
    _members = providerRef.members;
    _subgroups = providerRef.subgroups;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final spacing = width * 0.05;
    return Consumer<DivvyProvider>(
      builder: (context, provider, child) {
        // refresh data from provider
        _members = provider.members;
        _subgroups = provider.subgroups;

        return SizedBox.expand(
          child: SingleChildScrollView(
            child: Container(
              width: width,
              padding: EdgeInsets.symmetric(horizontal: spacing),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Members list
                  _displayMembers(spacing),
                  SizedBox(height: spacing),
                  Leaderboard(title: 'Leaderboard'),
                  SizedBox(height: spacing),
                  // Display add roommate and settings buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _boxButton(
                        title: 'Manage Chores',
                        icon: Icon(CupertinoIcons.list_bullet),
                        spacing: spacing,
                        callback: _manageChores,
                      ),
                      SizedBox(width: spacing),
                      _boxButton(
                        title: 'Settings',
                        icon: Icon(CupertinoIcons.settings),
                        spacing: spacing,
                        callback: _openSettings,
                      ),
                    ],
                  ),
                  SizedBox(height: spacing),
                  // Display subgroups
                  _displaySubgroups(spacing),
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
  Widget _displayMembers(double spacing) {
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
                _members.map((member) {
                  return Padding(
                    padding: EdgeInsets.only(right: spacing),
                    child: InkWell(
                      onTap: () => _openMemberPage(context, member),
                      child: Column(
                        children: [
                          Container(
                            decoration: DivvyTheme.profileCircle(
                              member.profilePicture,
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
  Widget _displaySubgroups(double spacing) {
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
        ListView.builder(
          itemCount: _subgroups.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            bool isLast = false;
            if (index == _subgroups.length - 1) isLast = true;
            // Render the member's profile picture and name
            return _subgroupTile(
              subgroup: _subgroups[index],
              spacing: spacing,
              isLast: isLast,
            );
          },
        ),
      ],
    );
  }

  /// Displays the tile for a subgroup with their
  /// image and name
  Widget _subgroupTile({
    required Subgroup subgroup,
    required double spacing,
    required bool isLast,
  }) {
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
                        subgroup.profilePicture,
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
            if (!isLast) Divider(color: DivvyTheme.beige),
          ],
        ),
      ),
    );
  }

  ///////////////////////////// util /////////////////////////////

  /// Will trigger the screen to add a subgroup
  void _addSubgroup(BuildContext context) {
    print('Adding subgroup');
    return;
  }

  /// Will trigger the screen to add a roommate
  void _manageChores(BuildContext context) {
    print('Opening manage chore page');
    return;
  }

  /// Opens the house settings screen
  void _openSettings(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => HouseSettings()));
  }

  /// Will open the passed member's page
  void _openMemberPage(BuildContext context, Member member) {
    print('Opening ${member.name}\'s page');
    return;
  }

  /// Will open the subgroups screen
  void _openSubgroupPage(BuildContext context, Subgroup subgroup) {
    print('Opening ${subgroup.name}\'s page');
    return;
  }
}
