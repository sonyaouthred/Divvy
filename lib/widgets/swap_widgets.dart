import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/models/swap.dart';
import 'package:divvy/providers/divvy_provider.dart';
import 'package:divvy/widgets/pending_swap_tile.dart';
import 'package:divvy/widgets/swap_tile.dart';
import 'package:flutter/material.dart';

/// Display the available (open) swaps
Widget displayOpenSwaps(DivvyProvider provider, double spacing) {
  final openSwaps = provider.getOpenSwaps();
  if (openSwaps.isEmpty) return Container();
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('Available swaps', style: DivvyTheme.bodyBoldBlack),
          InkWell(
            onTap: () => print('seeing all'),
            child: Container(
              alignment: Alignment.bottomCenter,
              height: 45,
              child: Text('View all', style: DivvyTheme.smallBodyGrey),
            ),
          ),
        ],
      ),
      SizedBox(height: spacing),
      ...openSwaps.map((swap) => SwapTile(swap: swap)),
    ],
  );
}

/// Dixplays swaps suggested by current user that are pending
Widget displayPendingSwaps(DivvyProvider provider, double spacing) {
  List<Swap> swaps = provider.getPendingSwaps();
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (swaps.isNotEmpty) SizedBox(height: spacing),
      if (swaps.isNotEmpty)
        Text("Your pending swaps:", style: DivvyTheme.bodyBoldBlack),
      if (swaps.isNotEmpty) SizedBox(height: spacing / 2),
      ListView.builder(
        shrinkWrap: true,
        itemCount: swaps.length,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, idx) {
          return PendingSwapTile(swap: swaps[idx]);
        },
      ),
    ],
  );
}

/// Display the available (open) swaps
Widget displayOpenSwapsForCurrMember(DivvyProvider provider, double spacing) {
  final openSwaps = provider.getOpenSwapsForCurrMember();
  if (openSwaps.isEmpty) return Container();
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('Your open swaps:', style: DivvyTheme.bodyBoldBlack),
          InkWell(
            onTap: () => print('seeing all'),
            child: Container(
              alignment: Alignment.bottomCenter,
              height: 45,
              child: Text('View all', style: DivvyTheme.smallBodyGrey),
            ),
          ),
        ],
      ),
      SizedBox(height: spacing),
      ...openSwaps.map((swap) => SwapTile(swap: swap, showMemberTile: false)),
    ],
  );
}
