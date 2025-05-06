// ignore_for_file: avoid_print

import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/models/member.dart';
import 'package:divvy/providers/divvy_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Leaderboard extends StatefulWidget {
  final String title;
  const Leaderboard({super.key, required this.title});

  @override
  State<Leaderboard> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  late List<Member> _sortedLeaderboard;
  late final String title;

  @override
  void initState() {
    super.initState();
    _sortedLeaderboard = Provider.of<DivvyProvider>(
      context,
      listen: false,
    ).getLeaderboardSorted(3);
    title = widget.title;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final spacing = width * 0.05;
    return Consumer<DivvyProvider>(
      builder: (context, provider, child) {
        _sortedLeaderboard = provider.getLeaderboardSorted(3);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: DivvyTheme.bodyBoldBlack),
            SizedBox(height: spacing * 0.75),
            Container(
              padding: EdgeInsets.all(spacing * 0.75),
              decoration: DivvyTheme.standardBox,
              child: Column(
                // this can be optimized haha
                children: [
                  _leaderboardEntry(1, _sortedLeaderboard[0], spacing),
                  SizedBox(height: spacing),
                  _leaderboardEntry(2, _sortedLeaderboard[1], spacing),
                  SizedBox(height: spacing),
                  _leaderboardEntry(3, _sortedLeaderboard[2], spacing),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Displays an individual entry on the leaderboard
  Widget _leaderboardEntry(int position, Member member, double spacing) {
    return InkWell(
      onTap: () => _openMemberPage(context, member),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text('#$position: ', style: DivvyTheme.smallBodyBlack),
          SizedBox(width: spacing / 2),
          Container(
            decoration: DivvyTheme.profileCircle(member.profilePicture),
            height: 25,
            width: 25,
          ),
          SizedBox(width: spacing / 2),
          Text(
            '${member.name}, ${member.onTimePct}% on time',
            style: DivvyTheme.smallBodyBlack,
          ),
        ],
      ),
    );
  }

  /// Will open the passed member's page
  void _openMemberPage(BuildContext context, Member member) {
    print('Opening ${member.name}\'s page');
    return;
  }
}
