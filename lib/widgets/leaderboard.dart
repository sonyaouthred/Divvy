import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/models/member.dart';
import 'package:divvy/providers/divvy_provider.dart';
import 'package:divvy/screens/user_info_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Displays the leaderboard of the top 3 users
/// in the house, sorted by completion rate. If fewer than 3
/// users are in the house, simply sorts all users by completion
/// rate.
/// Parameters:
///   - title: String title to be displayed above leaderboard.
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
        if (_sortedLeaderboard.length == 3) {
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
        } else {
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
                  children:
                      _sortedLeaderboard
                          .map(
                            (entry) => Column(
                              children: [
                                _leaderboardEntry(1, entry, spacing),
                                SizedBox(height: spacing),
                              ],
                            ),
                          )
                          .toList(),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  /// Displays an individual entry on the leaderboard
  Widget _leaderboardEntry(int position, Member member, double spacing) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () => _openMemberPage(context, member),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text('#$position: ', style: DivvyTheme.smallBodyBlack),
          SizedBox(width: spacing / 2),
          Container(
            decoration: DivvyTheme.profileCircle(member.profilePicture.color),
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
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => UserInfoScreen(memberID: member.id)),
    );
  }
}
