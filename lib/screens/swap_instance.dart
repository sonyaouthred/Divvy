import 'package:divvy/models/chore.dart';
import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/models/member.dart';
import 'package:divvy/models/swap.dart';
import 'package:divvy/providers/divvy_provider.dart';
import 'package:divvy/util/date_funcs.dart';
import 'package:divvy/screens/choose_swap.dart';
import 'package:divvy/widgets/chore_tile.dart';
import 'package:divvy/widgets/member_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

/// Displays information about a given swap.
/// Parameters:
///   - swap: the swap to be displayed.
class SwapInstance extends StatefulWidget {
  final Swap swap;
  const SwapInstance({super.key, required this.swap});

  @override
  State<SwapInstance> createState() => _SwapInstanceState();
}

class _SwapInstanceState extends State<SwapInstance> {
  late Swap? _swap;
  late Chore? _superChore;
  late ChoreInst? _choreInst;

  @override
  void initState() {
    super.initState();
    _swap = widget.swap;
    final provRef = Provider.of<DivvyProvider>(context, listen: false);
    _superChore = provRef.getSuperChore(_swap!.choreID);
    _choreInst = provRef.getChoreInstanceFromID(
      _swap!.choreID,
      _swap!.choreInstID,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final spacing = width * 0.05;

    return Consumer<DivvyProvider>(
      builder: (context, provider, child) {
        // Get data from the provider
        _swap = provider.getSwap(_swap!.id);
        if (_swap == null) {
          return _invalidDataScreen();
        }
        _superChore = provider.getSuperChore(_swap!.choreID);
        _choreInst = provider.getChoreInstanceFromID(
          _swap!.choreID,
          _swap!.choreInstID,
        );
        if (_superChore == null || _choreInst == null) {
          return _invalidDataScreen();
        }

        // True if the user is the one offering the swap
        final member = provider.getMemberById(_swap!.from);
        if (member == null) {
          return _invalidDataScreen();
        }
        final isUsersSwap = member.id == provider.currMember.id;

        return Scaffold(
          backgroundColor: DivvyTheme.background,
          appBar: AppBar(
            title: Text("Swap", style: DivvyTheme.screenTitle),
            centerTitle: true,
            scrolledUnderElevation: 0,
            backgroundColor: DivvyTheme.background,
          ),
          body: SizedBox.expand(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Container(
                    width: width,
                    padding: EdgeInsets.symmetric(horizontal: spacing),
                    child: Column(
                      children: [
                        SizedBox(height: spacing),
                        if (_swap!.status == Status.open)
                          _openSwapTile(isUsersSwap, member, spacing),
                        SizedBox(height: spacing),

                        _dayChores(spacing, provider),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _actionButton(spacing, provider),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Shows an open swap's information
  Widget _openSwapTile(bool isUsersSwap, Member owner, double spacing) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: spacing, vertical: spacing / 2),
      decoration: DivvyTheme.standardBox,
      child: Column(
        children: [
          isUsersSwap
              ? Text('Your open swap: ', style: DivvyTheme.bodyBlack)
              : MemberTile(
                member: owner,
                spacing: spacing,
                suffix: 'wants to swap:',
                button: false,
              ),
          SizedBox(height: spacing / 3),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing / 2),
            child: ChoreTile(
              choreInst: _choreInst,
              superChore: _superChore,
              showDivider: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dayChores(double spacing, DivvyProvider provider) {
    final choresOnDay = provider.getChoresForDay(day: _choreInst!.dueDate);
    if (choresOnDay.isEmpty) {
      return Text(
        'You have no other chores on that day!',
        style: DivvyTheme.bodyBlack,
      );
    }
    return Container(
      padding: EdgeInsets.all(spacing / 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You have ${choresOnDay.length} chore${choresOnDay.length != 1 ? 's' : ''} on ${getFormattedDate(_choreInst!.dueDate)}:',
            style: DivvyTheme.bodyBlack,
          ),
          SizedBox(height: spacing / 2),
          ...choresOnDay.map(
            (chore) => ChoreTile(choreInst: chore, compact: true),
          ),
        ],
      ),
    );
  }

  /// Triggers the swap action
  Widget _actionButton(double spacing, DivvyProvider provider) => Container(
    height: 60,
    margin: EdgeInsets.all(spacing * 3),
    child: InkWell(
      onTap: () async {
        if (_swap!.status == Status.open) {
          // pop up a calendar view where the user can select another chore instance
          // they'd like to swap (of the same chore super class).
          final chosenChoreInst = await _openChooseChoreScreen(context);
          if (chosenChoreInst == null || chosenChoreInst is! ChoreID) return;
          provider.sendSwapInvite(_swap!, chosenChoreInst);
          if (!mounted) return;
          // pop back to a previous screen
          Navigator.pop(context);
        }
      },
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Container(
        decoration: DivvyTheme.completeBox(true),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display check and text representing current state
            Icon(Icons.swap_horiz, color: DivvyTheme.background, size: 40),
            SizedBox(width: spacing / 2),
            Text('Swap!', style: DivvyTheme.largeBoldMedWhite),
          ],
        ),
      ),
    ),
  );

  // Indicates invalid data
  Widget _invalidDataScreen() {
    return Scaffold(
      backgroundColor: DivvyTheme.background,
      appBar: AppBar(
        title: Text("Swap not found", style: DivvyTheme.screenTitle),
        centerTitle: true,
        scrolledUnderElevation: 0,
        backgroundColor: DivvyTheme.background,
      ),
      body: SizedBox.expand(child: CupertinoActivityIndicator()),
    );
  }

  /// Open the choose chore screen to swap
  Future<dynamic> _openChooseChoreScreen(BuildContext context) async {
    final chosenChoreinst = await Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.bottomToTop,
        duration: Duration(milliseconds: 200),
        childBuilder: (context) => ChooseSwap(choreID: _swap!.choreID),
      ),
    );
    return chosenChoreinst;
  }
}
