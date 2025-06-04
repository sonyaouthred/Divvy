import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/models/member.dart';
import 'package:divvy/models/swap.dart';
import 'package:divvy/providers/divvy_provider.dart';
import 'package:divvy/widgets/chore_tile.dart';
import 'package:divvy/widgets/member_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Represents a pending swap tile. Displays the
/// chore put up to be swapped, the chore offered (and the
/// offering member), and allows the user to accept or reject the swap.
/// Parameters:
///   - swap: the Swap to display. Must have status = Status.pending.
class PendingSwapTile extends StatelessWidget {
  final Swap swap;

  const PendingSwapTile({super.key, required this.swap});
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final spacing = width * 0.05;

    return Consumer<DivvyProvider>(
      builder: (context, provider, child) {
        final chore = provider.getSuperChore(swap.choreID);
        final choreInst = provider.getChoreInstanceFromID(
          swap.choreID,
          swap.choreInstID,
        );
        final offered = provider.getChoreInstanceFromID(
          swap.choreID,
          swap.offered,
        );
        final toMember = provider.getMemberById(swap.to);
        if (chore == null || choreInst == null || toMember == null) {
          return Container();
        }
        return Column(
          children: [
            _showSwappingMember(context, spacing, toMember),
            SizedBox(height: spacing / 2),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing / 2),
              child: Column(
                children: [
                  ChoreTile(choreInst: offered, showDivider: false),
                  SizedBox(height: spacing / 2),
                  Text('for your chore', style: DivvyTheme.bodyBlack),
                  SizedBox(height: spacing / 2),
                  ChoreTile(choreInst: choreInst, showDivider: false),
                  SizedBox(height: spacing),
                  SizedBox(
                    width: width * 0.75,
                    child: Row(
                      children: [
                        _acceptButton(spacing, provider),
                        SizedBox(width: spacing),
                        _rejectButton(spacing, provider),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
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
    Member offerer,
  ) {
    return MemberTile(
      member: offerer,
      spacing: spacing,
      suffix: 'offered to swap:',
      button: false,
    );
  }

  /// Accept a pending swap offer
  Widget _acceptButton(double spacing, DivvyProvider provider) => Flexible(
    flex: 1,
    child: InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () => provider.approveSwapInvite(swap),
      child: Container(
        width: double.infinity,
        height: 45,
        decoration: DivvyTheme.medGreenBox,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check, color: DivvyTheme.background),
            Text(' Accept', style: DivvyTheme.smallBoldMedWhite),
          ],
        ),
      ),
    ),
  );

  /// Reject a pending swap
  Widget _rejectButton(double spacing, DivvyProvider provider) => Flexible(
    flex: 1,
    child: InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () => provider.rejectSwapInvite(swap),
      child: Container(
        width: double.infinity,
        height: 45,
        alignment: Alignment.center,
        decoration: DivvyTheme.standardBox,
        child: Text('Reject', style: DivvyTheme.bodyBoldRed),
      ),
    ),
  );
}
