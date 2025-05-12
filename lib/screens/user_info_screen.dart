import 'package:divvy/models/chore.dart';
import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/models/member.dart';
import 'package:divvy/models/subgroup.dart';
import 'package:divvy/providers/divvy_provider.dart';
import 'package:divvy/screens/chore_instance_screen.dart';
import 'package:divvy/screens/subgroup_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UserInfoScreen extends StatefulWidget {
  final MemberID memberID;

  const UserInfoScreen({super.key, required this.memberID});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final spacing = width * 0.02;

    return Consumer<DivvyProvider>(
      builder: (context, provider, child) {
        Member member = provider.getMemberById(widget.memberID);
        int memRank = provider.getRank(widget.memberID);
        List<Subgroup> memberSubgroups = provider.getSubgroupsForMember(
          widget.memberID,
        );
        List<ChoreInst> upcomingChores = provider.getUpcomingChores(
          widget.memberID,
        );

        return Scaffold(
          backgroundColor: DivvyTheme.background,
          appBar: AppBar(
            title: Text(member.name, style: DivvyTheme.screenTitle),
            centerTitle: true,
            scrolledUnderElevation: 0,
            backgroundColor: DivvyTheme.background,
          ),
          body: SizedBox.expand(
            child: SingleChildScrollView(
              child: Container(
                width: width,
                padding: EdgeInsets.symmetric(horizontal: spacing),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: spacing),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: member.profilePicture,
                          ),
                          SizedBox(width: 20),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  member.name,
                                  style: DivvyTheme.bodyBoldBlack,
                                ),
                                Text(
                                  member.email,
                                  maxLines: 1,
                                  style: DivvyTheme.bodyGrey,
                                  overflow: TextOverflow.fade,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    _statsTile(member, memRank),
                    SizedBox(height: 20),
                    _subgroupsArea(member, memberSubgroups),
                    SizedBox(height: 20),
                    _upcomingChoreArea(
                      member,
                      upcomingChores,
                      provider,
                      context,
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

  Widget _upcomingChoreArea(
    Member member,
    List<ChoreInst> upcomingChores,
    DivvyProvider provider,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            "${member.name}'s Upcoming Chores",
            style: DivvyTheme.bodyBoldGrey,
          ),
        ),
        upcomingChores.isEmpty
            ? Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text("No chores as of now", style: DivvyTheme.bodyGrey),
            )
            : SizedBox(),
        ...upcomingChores.map((choreInstance) {
          return _getChoreInstanceTile(choreInstance, provider, context);
        }),
      ],
    );
  }

  String getFormattedDate(DateTime dueDate) {
    return DateFormat.yMMMMd('en_US').format(dueDate);
  }

  Widget _getChoreInstanceTile(
    ChoreInst choreInstance,
    DivvyProvider provider,
    BuildContext context,
  ) {
    Chore chore = provider.getSuperChore(choreInstance.choreID);

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) {
              return ChoreInstanceScreen(
                choreInstanceId: choreInstance.id,
                choreID: choreInstance.choreID,
              );
            },
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Due ${getFormattedDate(choreInstance.dueDate)}",
              style: DivvyTheme.smallBodyGrey,
            ),
            ListTile(
              minTileHeight: 20,
              title: Text(chore.name),
              trailing: Icon(CupertinoIcons.right_chevron),
            ),
          ],
        ),
      ),
    );
  }

  Widget _subgroupsArea(Member member, List<Subgroup> subgroups) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            "${member.name}'s Subgroups",
            style: DivvyTheme.bodyBoldGrey,
          ),
        ),
        subgroups.isEmpty
            ? Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                "${member.name} is not part of any subgroup",
                style: DivvyTheme.bodyGrey,
              ),
            )
            : SizedBox(),
        ...subgroups.map((subgroup) {
          return _subgroupTile(subgroup, context);
        }),
      ],
    );
  }

  Widget _subgroupTile(Subgroup subgroup, BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => SubgroupScreen(currSubgroup: subgroup),
          ),
        );
      },
      child: Card(
        color: DivvyTheme.background,
        child: ListTile(
          leading: CircleAvatar(backgroundColor: subgroup.profilePicture),
          title: Text(subgroup.name),
          trailing: Icon(CupertinoIcons.right_chevron),
        ),
      ),
    );
  }

  Widget _statsTile(Member member, int memberRank) {
    return Card(
      color: DivvyTheme.background,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${member.onTimePct}%",
                  style: DivvyTheme.largeHeaderBlack,
                ),
                Text("Chores done on time"),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("#$memberRank", style: DivvyTheme.largeHeaderBlack),
                Text("In your house"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
