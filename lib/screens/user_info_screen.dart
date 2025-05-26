import 'package:divvy/models/chore.dart';
import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/models/member.dart';
import 'package:divvy/models/subgroup.dart';
import 'package:divvy/providers/divvy_provider.dart';
import 'package:divvy/util/dialogs.dart';
import 'package:divvy/widgets/chore_tile.dart';
import 'package:divvy/widgets/subgroup_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Represents all the information for a given member.
/// Parameters:
///   - memberID: the unique ID of the member to be displayed.
class UserInfoScreen extends StatelessWidget {
  final MemberID memberID;

  const UserInfoScreen({super.key, required this.memberID});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final spacing = width * 0.05;

    return Consumer<DivvyProvider>(
      builder: (context, provider, child) {
        // Update fields with provider information
        Member? member = provider.getMemberById(memberID);
        int memRank = provider.getRank(memberID);
        List<Subgroup> memberSubgroups = provider.getSubgroupsForMember(
          memberID,
        );
        List<ChoreInst> upcomingChores = provider.getUpcomingChores(memberID);
        if (member == null) {
          // user no longer exists!!
          return _userNotFoundScreen(width, spacing);
        }

        return Scaffold(
          backgroundColor: DivvyTheme.background,
          appBar: AppBar(
            title: Text(member.name, style: DivvyTheme.screenTitle),
            centerTitle: true,
            scrolledUnderElevation: 0,
            backgroundColor: DivvyTheme.background,
            actions: [
              // Allow user to take actions for this chore
              InkWell(
                onTap: () => _showActionMenu(context, member),
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
            child: SingleChildScrollView(
              child: Container(
                width: width,
                padding: EdgeInsets.symmetric(horizontal: spacing),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display user information
                    // (icon, name, email)
                    _userInfo(member, spacing),
                    SizedBox(height: spacing * 1.5),
                    // Display user's on-time chore stats
                    _statsTile(member, memRank, spacing),
                    SizedBox(height: spacing * 1.5),
                    // Display the subgroups this user is a member of
                    _subgroupsArea(member, memberSubgroups, spacing),
                    SizedBox(height: spacing),
                    // Display the upcoming chores for this user
                    _upcomingChoreArea(
                      member,
                      upcomingChores,
                      provider,
                      spacing,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Displays user not found screen
  Scaffold _userNotFoundScreen(double width, double spacing) {
    return Scaffold(
      backgroundColor: DivvyTheme.background,
      appBar: AppBar(
        title: Text('Member', style: DivvyTheme.screenTitle),
        centerTitle: true,
        scrolledUnderElevation: 0,
        backgroundColor: DivvyTheme.background,
      ),
      body: SizedBox.expand(
        child: Container(
          width: width,
          padding: EdgeInsets.symmetric(horizontal: spacing),
          child: Center(
            child: Text('404: Member not found', style: DivvyTheme.bodyBlack),
          ),
        ),
      ),
    );
  }

  /// Displays user's image, name, and email
  Widget _userInfo(Member member, double spacing) {
    return Padding(
      padding: EdgeInsets.only(left: spacing / 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: member.profilePicture.color,
          ),
          SizedBox(width: 20),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.name, style: DivvyTheme.bodyBoldBlack),
                Text(
                  member.email,
                  maxLines: 2,
                  style: DivvyTheme.bodyGrey,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Displays user's upcoming chores
  Widget _upcomingChoreArea(
    Member member,
    List<ChoreInst> upcomingChores,
    DivvyProvider provider,
    double spacing,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${member.name}'s Upcoming Chores",
          style: DivvyTheme.bodyBoldBlack,
        ),
        SizedBox(height: spacing / 3),
        upcomingChores.isEmpty
            ? Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text("No upcoming chores.", style: DivvyTheme.bodyGrey),
            )
            : SizedBox(),
        ...upcomingChores.map((choreInstance) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing / 2),
            child: ChoreTile(choreInst: choreInstance),
          );
        }),
      ],
    );
  }

  /// Display subgroups for this member
  Widget _subgroupsArea(
    Member member,
    List<Subgroup> subgroups,
    double spacing,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("${member.name}'s Subgroups", style: DivvyTheme.bodyBoldBlack),
        SizedBox(height: spacing / 3),
        subgroups.isEmpty
            ? Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                "${member.name} is not part of any subgroups.",
                style: DivvyTheme.bodyGrey,
              ),
            )
            : SizedBox(),
        ...subgroups.map((subgroup) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing / 2),
            child: SubgroupTile(subgroup: subgroup, spacing: spacing),
          );
        }),
      ],
    );
  }

  /// Shows a Cupertino action menu that allows user to take action
  /// on another user
  void _showActionMenu(BuildContext context, Member member) async {
    final delete = await showCupertinoModalPopup<bool>(
      context: context,
      builder:
          (BuildContext context) => CupertinoActionSheet(
            title: const Text('User Actions'),
            actions: <CupertinoActionSheetAction>[
              CupertinoActionSheetAction(
                /// This parameter indicates the action would perform
                /// a destructive action such as delete or exit and turns
                /// the action's text color to red.
                isDestructiveAction: true,
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('Remove from house'),
              ),
            ],
          ),
    );
    if (delete != null && delete && context.mounted) {
      final confirm = await confirmDeleteDialog(
        context,
        'Remove ${member.name} from house?',
        action: 'Remove',
      );
      if (confirm != null && confirm) {
        if (!context.mounted) return;
        Provider.of<DivvyProvider>(
          context,
          listen: false,
        ).leaveHouse(member.id);
      }
    }
  }

  /// Displays statistics about this user
  Widget _statsTile(Member member, int memberRank, double spacing) {
    return Container(
      decoration: DivvyTheme.standardBox,
      padding: EdgeInsets.symmetric(
        vertical: spacing * 0.75,
        horizontal: spacing,
      ),
      child: Row(
        children: [
          Flexible(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${member.onTimePct}%",
                  style: DivvyTheme.largeHeaderBlack,
                ),
                Text("Chores done on time"),
              ],
            ),
          ),
          Spacer(flex: 1),
          Flexible(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("#$memberRank", style: DivvyTheme.largeHeaderBlack),
                Text("In your house"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
