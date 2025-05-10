import 'package:divvy/models/chore.dart';
import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/models/member.dart';
import 'package:divvy/models/subgroup.dart';
import 'package:divvy/providers/divvy_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SubgroupScreen extends StatefulWidget {
  const SubgroupScreen({super.key, required this.currSubgroup});

  final Subgroup currSubgroup;
  @override
  State<SubgroupScreen> createState() => _SubgroupScreenState();
}

class _SubgroupScreenState extends State<SubgroupScreen> {
  late Subgroup _currSubgroup;
  late List<Chore> _currChores;
  late List<Member> _currMemeber;

  @override
  void initState() {
    super.initState();
    final providerRef = Provider.of<DivvyProvider>(context, listen: false);
    _currSubgroup = widget.currSubgroup;
    _currChores = _currSubgroup.chores
        .map((choreID) => providerRef.getSuperChore(choreID))
        .toList();
    _currMemeber = providerRef.getMembersInSubgroup(_currSubgroup.id);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final spacing = width * 0.05;
    return Scaffold(
      backgroundColor: DivvyTheme.background,
      appBar: AppBar(
        title: Text(_currSubgroup.name, style: DivvyTheme.screenTitle),
        centerTitle: true,
        scrolledUnderElevation: 0,
        backgroundColor: DivvyTheme.background,
      ),
      body: SizedBox.expand(
        child: Container(
          padding: EdgeInsets.all(spacing),
          child: SingleChildScrollView(
            child: Consumer<DivvyProvider>(
              builder: (context, provider, child) {
                _currChores = _currSubgroup.chores
                    .map((choreID) => provider.getSuperChore(choreID))
                    .toList();
                _currMemeber = provider.getMembersInSubgroup(_currSubgroup.id);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _displayMembers(spacing),
                    _displayChores(spacing),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  ///////////////////////////// Widgets /////////////////////////////
  

  /// Listing all of subgroup chores
  Widget _displayChores(double spacing) {
    // Return view of subgroup chores
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Chores', style: DivvyTheme.bodyBoldBlack)
          ],
        ),
        SizedBox(height: spacing / 4),
        // Display the chore tiles for all chores due today
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing / 4),
          child: Column(
            children: _currChores
                .map((chore) => _outerChoreTile(chore, spacing / 4))
                .toList(),
          ),
        ),
        if (_currChores.isNotEmpty) SizedBox(height: spacing / 4),
      ],
    );
  }

  // Button of tile
  Widget _outerChoreTile(Chore superChore, double spacing) {
    return InkWell(
      onTap: () => _openSuperChorePage(context, superChore),
      child: _smallChoreTile(superChore, spacing),
    );
  }

  /// Returns a small chore tile
  Widget _smallChoreTile(Chore superChore, double spacing) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing / 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: spacing / 4),
          Row(
            children: [
              // name, emoji of chore
              Flexible(
                flex: 7,
                child: Row(
                  children: [
                    Text(superChore.emoji, style: TextStyle(fontSize: 40)),
                    SizedBox(width: spacing / 1.2),
                    // Display name and details
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            superChore.name,
                            style: DivvyTheme.bodyBlack,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Tap to view details',
                            style: DivvyTheme.detailGrey,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Display chevron icon
              Flexible(
                flex: 1,
                child: Icon(
                  CupertinoIcons.chevron_right,
                  color: DivvyTheme.lightGrey,
                  size: 20,
                ),
              ),
            ],
          ),
          Divider(color: DivvyTheme.shadow),
        ],
      ),
    );
  }

  // Displays list of subgroups and button to allow user to add a subgroup
  Widget _displayMembers(double spacing) {
    return Column(
      children: [
        // Title and add subgroup button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Members', style: DivvyTheme.bodyBoldBlack)
          ],
        ),
        // List of subgroups
        ListView.builder(
          itemCount: _currMemeber.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            bool isLast = false;
            if (index == _currMemeber.length - 1) isLast = true;
            // Render the member's profile picture and name
            return _memberTile(
              member: _currMemeber[index],
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
  Widget _memberTile({
    required Member member,
    required double spacing,
    required bool isLast,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: spacing),
      child: InkWell(
        onTap: () => _openMemberPage(context, member),
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
                        member.profilePicture,
                      ),
                      height: 25,
                      width: 25,
                    ),
                    SizedBox(width: spacing / 2),
                    Text(member.name, style: DivvyTheme.bodyBlack),
                  ],
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
  void _openMemberPage(BuildContext context, Member member) {
    print('Opening ${member.name}\'s page');
    return;
  }

  void _openSuperChorePage(BuildContext context, Chore chore) {
    print('Opening ${chore.name} supre chore page');
    return;
  }
}
