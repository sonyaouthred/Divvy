import 'dart:math';

import 'package:divvy/models/member.dart';
import 'package:divvy/models/swap.dart';
import 'package:divvy/providers/divvy_provider.dart';
import 'package:divvy/widgets/swap_tile.dart';
import 'package:flutter/material.dart';

/// Widgets related to swaps. More documentation to come.
Widget availableOutgoingSwaps(DivvyProvider provider) {
  List<Swap> swaps =
      provider.swaps.where((swap) {
        return swap.from == provider.currMember.id;
      }).toList();

  List<Member> members =
      swaps.map((swap) {
        return provider.getMemberById(swap.to)!;
      }).toList();

  return Column(
    children: [
      swaps.isEmpty ? SizedBox() : Text("Outgoing Swap Requests"),
      ListView.builder(
        shrinkWrap: true,
        itemCount: swaps.length,
        itemBuilder: (BuildContext context, idx) {
          return Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: members[idx].profilePicture.color,
                ),
                title: Text("To ${members[idx].name}"),
                minTileHeight: 20,
              ),
              SwapTile(swap: swaps[idx]),
            ],
          );
        },
      ),
    ],
  );
}

Widget availableIncomingSwaps(DivvyProvider provider, bool truncatedView) {
  List<Swap> swaps =
      provider.swaps.where((swap) {
        return swap.to == provider.currMember.id;
      }).toList();
  List<Member> members =
      swaps.map((swap) {
        return provider.getMemberById(swap.from)!;
      }).toList();

  return Column(
    children: [
      swaps.isEmpty ? SizedBox() : Text("Incoming Swap Requests"),
      ListView.builder(
        shrinkWrap: true,
        itemCount: truncatedView ? min(swaps.length, 1) : swaps.length,
        itemBuilder: (BuildContext context, idx) {
          return Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: members[idx].profilePicture.color,
                ),
                title: Text("${members[idx].name} Offered:"),
                minTileHeight: 20,
              ),
              SwapTile(swap: swaps[idx]),
            ],
          );
        },
      ),
    ],
  );
}
