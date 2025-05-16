import 'package:divvy/models/chore.dart';
import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/models/member.dart';
import 'package:divvy/providers/divvy_provider.dart';
import 'package:divvy/widgets/chore_tile.dart';
import 'package:divvy/widgets/leaderboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// import 'package:divvy/models/divvy_theme.dart';
// Commented out for testing

/// Displays the current user's dashboard with their upcoming chores,
/// house leaderboard, etc.
class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final spacing = width * 0.05;
    return Consumer<DivvyProvider>(
      builder: (context, provider, child) {
        if (!provider.dataLoaded) {
          return Center(child: CupertinoActivityIndicator());
        }
        Member currUser = provider.currentUser;
        // get tasks due today
        List<ChoreInst> todayChores = provider.getTodayChores(currUser.id);
        // get tasks in next week
        List<ChoreInst> thisWeekChores =
            provider
                .getUpcomingChores(currUser.id)
                .where((chore) => !chore.isDone)
                .toList();
        // get overdue chores
        List<ChoreInst> overdueChores = provider.getOverdueChores(currUser.id);
        return SizedBox.expand(
          child: SingleChildScrollView(
            child: Container(
              width: width,
              padding: EdgeInsets.symmetric(horizontal: spacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: spacing / 2),
                  Text(
                    'Hi, ${currUser.name}!',
                    style: DivvyTheme.largeHeaderBlack,
                  ),
                  // display any overdue chores
                  _displayRecentChores(spacing, overdueChores, todayChores),
                  // Display header for upcoming chores, if it applies
                  SizedBox(height: spacing / 2),
                  // Only display today's chores if overdue chores exist
                  _displayCompactTodayChores(
                    spacing,
                    overdueChores,
                    todayChores,
                  ),
                  // Display a compact chore tile for all chores not due today
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: spacing / 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          thisWeekChores
                              .map(
                                (chore) =>
                                    ChoreTile(choreInst: chore, compact: true),
                              )
                              .toList(),
                    ),
                  ),
                  Divider(color: DivvyTheme.shadow),
                  SizedBox(height: spacing / 2),
                  Leaderboard(title: 'House Leaderboard'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Concatenate today's chores to start of upcoming tasks list
  /// if overdue chores are being displayed at top of screen.
  /// Otherwise, return container
  Widget _displayCompactTodayChores(
    double spacing,
    List<ChoreInst> overdue,
    List<ChoreInst> today,
  ) {
    if (overdue.isEmpty) return Container();
    if (today.isEmpty) return Container();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing / 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Upcoming chores:', style: DivvyTheme.bodyBoldBlack),
          SizedBox(height: spacing / 2),
          ...today.map(
            (chore) => Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing / 2),
              child: ChoreTile(choreInst: chore, compact: true),
            ),
          ),
        ],
      ),
    );
  }

  /// If user has overdue chores, display them.
  Widget _displayRecentChores(
    double spacing,
    List<ChoreInst> overdue,
    List<ChoreInst> today,
  ) {
    if (overdue.isEmpty) {
      // Return view of today's chores
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: spacing / 4),
          // # chores due today
          Text(
            'You have ${today.length} chore${today.length == 1 ? '' : 's'} to do today.',
            style: DivvyTheme.bodyGrey,
          ),
          SizedBox(height: spacing),
          // Display the chore tiles for all chores due today
          Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing / 4),
            child: Column(
              children:
                  today
                      .map(
                        (chore) => Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: spacing / 2,
                          ),
                          child: ChoreTile(choreInst: chore),
                        ),
                      )
                      .toList(),
            ),
          ),
          if (today.isNotEmpty) SizedBox(height: spacing / 4),
        ],
      );
    }
    // Return overdue chore list
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: spacing / 4),
        // # overdue chores
        Text(
          'You have ${overdue.length} overdue chore${overdue.length == 1 ? '' : 's'}!',
          style: DivvyTheme.bodyBlack.copyWith(color: DivvyTheme.darkRed),
        ),
        SizedBox(height: spacing / 2),
        // display overdue chores
        Column(
          children:
              overdue
                  .map(
                    (chore) => Padding(
                      padding: EdgeInsets.symmetric(horizontal: spacing / 2),
                      child: ChoreTile(choreInst: chore),
                    ),
                  )
                  .toList(),
        ),
        SizedBox(height: spacing / 2),
      ],
    );
  }
}
