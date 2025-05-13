import 'package:divvy/models/chore.dart';
import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/models/member.dart';
import 'package:divvy/providers/divvy_provider.dart';
import 'package:divvy/widgets/chore_tile.dart';
import 'package:divvy/widgets/leaderboard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// import 'package:divvy/models/divvy_theme.dart';
// Commented out for testing

/// Displays the current user's dashboard with their upcoming chores,
/// house leaderboard, etc.
class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late final Member _currUser;
  late List<ChoreInst> _todayChores;
  late List<ChoreInst> _thisWeekChores;
  late List<ChoreInst> _overdueChores;

  @override
  void initState() {
    super.initState();
    final providerRef = Provider.of<DivvyProvider>(context, listen: false);
    _currUser = providerRef.currentUser;
    // get tasks due today
    _todayChores = providerRef.getTodayChores(_currUser.id);
    // get tasks in next week
    _thisWeekChores =
        providerRef
            .getUpcomingChores(_currUser.id)
            .where((chore) => !chore.isDone)
            .toList();
    // get overdue chores
    _overdueChores = providerRef.getOverdueChores(_currUser.id);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final spacing = width * 0.05;
    return Consumer<DivvyProvider>(
      builder: (context, provider, child) {
        // get tasks due today
        _todayChores = provider.getTodayChores(_currUser.id);
        // get tasks in next week
        _thisWeekChores =
            provider
                .getUpcomingChores(_currUser.id)
                .where((chore) => !chore.isDone)
                .toList();
        // get overdue chores
        _overdueChores = provider.getOverdueChores(_currUser.id);
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
                    'Hi, ${_currUser.name}!',
                    style: DivvyTheme.largeHeaderBlack,
                  ),
                  // display any overdue chores
                  _displayRecentChores(spacing),
                  // Display header for upcoming chores, if it applies
                  if (_thisWeekChores.isNotEmpty)
                    Text(
                      'Your upcoming tasks:',
                      style: DivvyTheme.bodyBoldBlack,
                    ),
                  SizedBox(height: spacing / 2),
                  // Only display today's chores if overdue chores exist
                  _displayCompactTodayChores(spacing),
                  // Display a compact chore tile for all chores not due today
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: spacing / 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                          _thisWeekChores
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
  Widget _displayCompactTodayChores(double spacing) {
    if (_overdueChores.isEmpty) return Container();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing / 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Upcoming chores:', style: DivvyTheme.bodyBoldBlack),
          SizedBox(height: spacing / 2),
          ..._todayChores.map(
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
  Widget _displayRecentChores(double spacing) {
    if (_overdueChores.isEmpty) {
      // Return view of today's chores
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: spacing / 4),
          // # chores due today
          Text(
            'You have ${_todayChores.length} chore${_todayChores.length == 1 ? '' : 's'} to do today.',
            style: DivvyTheme.bodyGrey,
          ),
          SizedBox(height: spacing),
          // Display the chore tiles for all chores due today
          Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing / 4),
            child: Column(
              children:
                  _todayChores
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
          if (_todayChores.isNotEmpty) SizedBox(height: spacing / 4),
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
          'You have ${_overdueChores.length} overdue chore${_overdueChores.length == 1 ? '' : 's'}!',
          style: DivvyTheme.bodyBlack.copyWith(color: DivvyTheme.darkRed),
        ),
        SizedBox(height: spacing / 2),
        // display overdue chores
        Column(
          children:
              _overdueChores
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
