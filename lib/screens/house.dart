// import 'package:divvy/models/divvy_theme.dart';
// Commented out for testing
import 'package:divvy/models/divvy_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class House extends StatefulWidget {
  const House({super.key});

  @override
  State<House> createState() => _HouseState();
}

class _HouseState extends State<House> {
  // To be replaced with actual data types
  late Map<String, Color> _members;
  late Map<String, Color> _subgroups;
  late Map<String, double> _leaderboard;

  @override
  void initState() {
    super.initState();
    // Dummy data
    _members = {
      'Amy': DivvyTheme.darkGreen,
      'Jo': DivvyTheme.mediumGreen,
      'Meg': DivvyTheme.lightGreen,
      'Beth': DivvyTheme.darkGrey,
      'Amys': DivvyTheme.darkGreen,
      'Jos': DivvyTheme.mediumGreen,
      'Mesg': DivvyTheme.lightGreen,
      'Besth': DivvyTheme.darkGrey,
    };
    _subgroups = {
      'Upstairs Area': Colors.lightBlueAccent,
      'Main floor': Colors.yellow,
    };
    _leaderboard = {'Amy': 0.75, 'Jo': 0.72, 'Meg': 0.65};
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final spacing = width * 0.05;
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
              _displayLeaderboard(spacing),
              SizedBox(height: spacing),
              // Display add roommate and settings buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _boxButton(
                    title: 'Add Roommate',
                    icon: Icon(CupertinoIcons.person_add),
                    spacing: spacing,
                    callback: _addRoommate,
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
  }

  ///////////////////////////// Widgets /////////////////////////////

  /// Displays all members as a horizontally scrolling list
  Widget _displayMembers(double spacing) {
    final List<String> memberKeys = _members.keys.toList();
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
                memberKeys.map((name) {
                  return Padding(
                    padding: EdgeInsets.only(right: spacing),
                    child: InkWell(
                      onTap: () => _openMemberPage(context, name),
                      child: Column(
                        children: [
                          Container(
                            decoration: DivvyTheme.profileCircle(
                              _members[name]!,
                            ),
                            height: 60,
                            width: 60,
                          ),
                          SizedBox(height: spacing / 2),
                          Text(name, style: DivvyTheme.bodyBlack),
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

  /// Displays the leaderboard with their on-time percentages.
  Widget _displayLeaderboard(double spacing) {
    final leaderboardSorted = _leaderboard.keys.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Leaderboard', style: DivvyTheme.bodyBoldBlack),
        SizedBox(height: spacing),
        Container(
          padding: EdgeInsets.all(spacing),
          decoration: DivvyTheme.standardBox,
          child: Column(
            // this can be optimized haha
            children: [
              _leaderboardEntry(
                1,
                leaderboardSorted[0],
                _leaderboard[leaderboardSorted[0]]!,
                spacing,
              ),
              SizedBox(height: spacing),
              _leaderboardEntry(
                2,
                leaderboardSorted[1],
                _leaderboard[leaderboardSorted[1]]!,
                spacing,
              ),
              SizedBox(height: spacing),
              _leaderboardEntry(
                3,
                leaderboardSorted[2],
                _leaderboard[leaderboardSorted[2]]!,
                spacing,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Displays an individual entry on the leaderboard
  Widget _leaderboardEntry(
    int position,
    String name,
    double score,
    double spacing,
  ) {
    final userProfileColor = _members[name]!;
    return InkWell(
      onTap: () => _openMemberPage(context, name),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text('#$position: ', style: DivvyTheme.bodyBlack),
          SizedBox(width: spacing / 2),
          Container(
            decoration: DivvyTheme.profileCircle(userProfileColor),
            height: 25,
            width: 25,
          ),
          SizedBox(width: spacing / 2),
          Text(
            '$name, ${(score * 100).toInt()}% on time',
            style: DivvyTheme.bodyBlack,
          ),
        ],
      ),
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
    final subgroupKeys = _subgroups.keys.toList();
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
          itemCount: subgroupKeys.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            final name = subgroupKeys[index];
            bool isLast = false;
            if (index == subgroupKeys.length - 1) isLast = true;
            // Render the member's profile picture and name
            return _subgroupTile(
              name: name,
              color: _subgroups[name]!,
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
    required String name,
    required Color color,
    required double spacing,
    required bool isLast,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: spacing),
      child: InkWell(
        onTap: () => _openSubgroupPage(context, name),
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
                      decoration: DivvyTheme.profileCircle(_subgroups[name]!),
                      height: 25,
                      width: 25,
                    ),
                    SizedBox(width: spacing / 2),
                    Text(name, style: DivvyTheme.bodyBlack),
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
  void _addRoommate(BuildContext context) {
    print('Adding roommate');
    return;
  }

  /// Will open the house settings screen
  void _openSettings(BuildContext context) {
    print('Opening settings');
    return;
  }

  /// Will open the passed member's page
  void _openMemberPage(BuildContext context, String name) {
    print('Opening $name\'s page');
    return;
  }

  /// Will open the subgroups screen
  void _openSubgroupPage(BuildContext context, String name) {
    print('Opening $name\'s page');
    return;
  }
}
