import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/models/member.dart';
import 'package:divvy/models/swap.dart';
import 'package:divvy/providers/divvy_provider.dart';
import 'package:divvy/screens/swap_instance.dart';
import 'package:divvy/util/date_funcs.dart';
import 'package:divvy/widgets/member_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Represents a tile for a swap.
/// parameters:
///   - swap: the Swap instance to display
///   - showMemberTile: if true, shows a preceding widget with
///       the name of the member offering the swap + their profile image.
class SwapTile extends StatelessWidget {
  final Swap swap;
  final bool showMemberTile;

  const SwapTile({super.key, required this.swap, this.showMemberTile = true});
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final spacing = width * 0.05;

    return InkWell(
      onTap: () => _openSwapScreen(context),
      child: Consumer<DivvyProvider>(
        builder: (context, provider, child) {
          final chore = provider.getSuperChore(swap.choreID);
          final choreInst = provider.getChoreInstanceFromID(
            swap.choreID,
            swap.choreInstID,
          );
          final fromMember = provider.getMemberById(swap.from);
          if (chore == null || choreInst == null || fromMember == null) {
            return Container();
          }
          final numChoresOnDay =
              provider.getChoresForDay(day: choreInst.dueDate).length;
          return Column(
            children: [
              if (showMemberTile)
                _showSwappingMember(context, spacing, fromMember),
              if (showMemberTile) SizedBox(height: spacing / 2),
              Container(
                decoration: DivvyTheme.standardBox,
                padding: EdgeInsets.symmetric(
                  horizontal: spacing,
                  vertical: spacing * 0.75,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${getShortDate(choreInst.dueDate)}:  ',
                              style: DivvyTheme.bodyBlack,
                            ),
                            Text(chore.emoji),
                            SizedBox(width: spacing * 0.25),
                            Text(chore.name, style: DivvyTheme.bodyBlack),
                          ],
                        ),
                        SizedBox(height: spacing * 0.25),
                        Text(
                          'You have $numChoresOnDay other chore${numChoresOnDay != 1 ? 's' : ''} on that day.',
                          style: DivvyTheme.smallBodyGrey,
                        ),
                      ],
                    ),
                    iconWidget(swap.status, spacing),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Displays an icon to represent current status of swap.
  Widget iconWidget(Status swapSatus, double spacing) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(swapSatus.icon, color: DivvyTheme.lightGrey),
        SizedBox(height: spacing / 5),
        Text(swapSatus.displayName, style: DivvyTheme.detailGrey),
      ],
    );
  }

  /// Displays the member looking to swap the chore.
  Widget _showSwappingMember(
    BuildContext context,
    double spacing,
    Member from,
  ) {
    return MemberTile(
      member: from,
      spacing: spacing,
      suffix: 'wants to swap:',
      button: false,
    );
  }

  /// opens an informational page about a swap.
  void _openSwapScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SwapInstance(swap: swap)),
    );
  }
}
