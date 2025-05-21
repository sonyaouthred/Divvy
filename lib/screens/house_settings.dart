import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/models/subgroup.dart';
import 'package:divvy/providers/divvy_provider.dart';
import 'package:divvy/screens/join_house.dart';
import 'package:divvy/screens/subgroup_add.dart';
import 'package:divvy/util/dialogs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

const double _kItemExtent = 32.0;

/// Displays the house's settings page
class HouseSettings extends StatefulWidget {
  const HouseSettings({super.key});

  @override
  State<HouseSettings> createState() => _HouseSettingsState();
}

class _HouseSettingsState extends State<HouseSettings> {
  late Subgroup? _selectedSubgroup;
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final spacing = width * 0.05;

    return Scaffold(
      backgroundColor: DivvyTheme.background,
      appBar: AppBar(
        title: Text('House Settings', style: DivvyTheme.screenTitle),
        centerTitle: true,
        scrolledUnderElevation: 0,
        backgroundColor: DivvyTheme.background,
      ),
      body: SizedBox.expand(
        child: Container(
          padding: EdgeInsets.all(spacing),
          child: SingleChildScrollView(
            child: Consumer<DivvyProvider>(
              builder: (context, provider, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Display various settings
                    // Account settings
                    _infoSections(
                      icon: Icon(CupertinoIcons.house),
                      text: 'House Info',
                      buttons: [
                        ['Change Name', _changeHouseName],
                        ['Delete House', _deleteHouse],
                      ],
                      flex: 2,
                      spacing: spacing,
                    ),
                    // Member settings
                    _infoSections(
                      icon: Icon(CupertinoIcons.person_fill),
                      text: 'Members',
                      buttons: [
                        ['House join code', _showJoinCode],
                        ['Remove a member', _removeUser],
                      ],
                      flex: 2,
                      spacing: spacing,
                    ),
                    // Subgroup settings
                    _infoSections(
                      icon: Icon(CupertinoIcons.person_3_fill),
                      text: 'Subgroups',
                      buttons: [
                        ['Create a subgroup', _createSubgroup],
                        ['Delete a subgroup', _deleteSubgroup],
                      ],
                      flex: 2,
                      spacing: spacing,
                    ),
                    SizedBox(height: spacing),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  ///////////////////////////// Widgets /////////////////////////////

  /// Displays account information sections
  /// Includes header, divider, and list of actions
  Widget _infoSections({
    required Icon icon,
    required String text,
    required List buttons,
    required int flex,
    required double spacing,
  }) {
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(padding: EdgeInsets.all(10.0), child: icon),
              Text(text, style: DivvyTheme.bodyBoldBlack),
            ],
          ),
          const Divider(color: DivvyTheme.beige, height: 1),
          SizedBox(height: spacing / 4),
          // Show relevant actions
          ListView.builder(
            itemCount: buttons.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              final entry = buttons[index];
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing / 2,
                  vertical: spacing * 0.45,
                ),
                child: InkWell(
                  // Trigger the action
                  onTap: () => entry[1](context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry[0], style: DivvyTheme.bodyBlack),

                      Icon(
                        CupertinoIcons.chevron_right,
                        color: DivvyTheme.lightGrey,
                        size: 15,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  ///////////////////////////// Util /////////////////////////////

  void _createSubgroup(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => SubgroupAdd()));
  }

  /// Choose a subgroup to delete, then confirm user wants to delete them
  void _deleteSubgroup(BuildContext context) async {
    // Get subgroups
    final subgroups =
        Provider.of<DivvyProvider>(context, listen: false).subgroups;
    await _pickSubgroup(context, subgroups);
    // Process selected subgroup
    if (_selectedSubgroup != null) {
      if (!context.mounted) return;
      // Confirm user wants to delete the subgroup
      // TODO: does deleting subgroup also delete their chores??
      final delete = await confirmDeleteDialog(
        context,
        'Delete subgroup ${_selectedSubgroup!.name}?',
      );
      if (delete != null && delete) {
        if (!context.mounted) return;
        Provider.of<DivvyProvider>(
          context,
          listen: false,
        ).deleteSubgroup(_selectedSubgroup!.id);
      } else {
        print('cancelled delete');
      }
    }
  }

  /// Allows user to pick a subgroup to delete
  Future<void> _pickSubgroup(
    BuildContext context,
    List<Subgroup> subgroups,
  ) async {
    /// Shows a cupertino picker dialog that allows user to select a user
    /// from their list of friends.
    await _showDialog(
      CupertinoPicker(
        magnification: 1.22,
        squeeze: 1.2,
        useMagnifier: true,
        itemExtent: _kItemExtent,
        // This sets the initial item. Ensures that selecting the first option
        // in the list is recognized as a change.
        scrollController: FixedExtentScrollController(initialItem: -1),
        // This is called when selected item is changed.
        onSelectedItemChanged: (int index) {
          setState(() {
            _selectedSubgroup = subgroups[index];
          });
        },
        children: List<Widget>.generate(subgroups.length, (int index) {
          return Center(
            child: Text(subgroups[index].name, style: DivvyTheme.bodyBlack),
          );
        }),
      ),
    );
  }

  /// Shows a cupertino modal popup with the inputted child.
  Future<void> _showDialog(Widget child) async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder:
          (BuildContext context) => Container(
            height: 216,
            padding: const EdgeInsets.only(top: 6.0),
            // The Bottom margin is provided to align the popup above the system navigation bar.
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            // Provide a background color for the popup.
            color: DivvyTheme.background,
            // Use a SafeArea widget to avoid system overlaps.
            child: SafeArea(top: false, child: child),
          ),
    );
  }

  /// Shows the join code for the user's house
  void _showJoinCode(BuildContext context) async {
    final joinCode =
        Provider.of<DivvyProvider>(context, listen: false).houseJoinCode;
    await showCupertinoDialog(
      context: context,
      builder:
          (BuildContext context) => CupertinoAlertDialog(
            title: Text('House Join Code:'),
            content: Text(joinCode),
            actions: <CupertinoDialogAction>[
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Ok'),
              ),
            ],
          ),
    );
  }

  /// Removes user, prompts for email
  void _removeUser(BuildContext context) async {
    // Get members & emails
    final members = Provider.of<DivvyProvider>(context, listen: false).members;
    final emails = members.map((member) => member.email);
    final email = await openInputDialog(
      context,
      title: 'Enter member\'s email',
      prompt: 'Enter email...',
    );
    // Process emil
    if (email != null) {
      if (!context.mounted) return;
      if (!emails.contains(email)) {
        // Email is not a valid member
        showErrorMessage(
          context,
          'Error Removing Member',
          'The email you provided does not match a member in the house.',
        );
        return;
      } else {
        final member = members.firstWhere((m) => m.email == email);
        // confirm user wants to delete the user
        final delete = await confirmDeleteDialog(
          context,
          'Delete ${member.name} ($email)?',
        );
        if (delete != null && delete) {
          if (!context.mounted) return;
          Provider.of<DivvyProvider>(context, listen: false).leaveHouse(email);
        } else {
          print('cancelled delete');
        }
      }
    }
  }

  /// Change the house's name
  void _changeHouseName(BuildContext context) async {
    final houseName =
        Provider.of<DivvyProvider>(context, listen: false).houseName;
    final newName = await openInputDialog(
      context,
      title: 'Change House Name',
      initText: houseName,
    );
    // Process name
    if (newName != null) {
      if (!context.mounted) return;
      Provider.of<DivvyProvider>(
        context,
        listen: false,
      ).updateHouseName(newName);
    }
  }

  /// Deletes the house
  /// Reauthenticates and then updates provider
  void _deleteHouse(BuildContext context) async {
    try {
      final password = await openInputDialog(
        context,
        title: 'Re-enter password',
        hideText: true,
      );
      // get current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      if (user.email != null) {
        // Now check what provider the user is signed in with.
        if (password != null) {
          // Reauthenticate user with email and password
          final credential = EmailAuthProvider.credential(
            email: user.email!,
            password: password,
          );
          await FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(
            credential,
          );
          if (!context.mounted) return;
          // confirm user wants to delete hosue
          final delete = await confirmDeleteDialog(
            context,
            'Delete house?',
            action: 'Delete',
          );
          if (delete != null && delete && context.mounted) {
            // delete house!!
            final providerRef = Provider.of<DivvyProvider>(
              context,
              listen: false,
            );
            providerRef.deleteHouse();
            // Push user to join house page
            Navigator.of(context).pushReplacement(
              PageTransition(
                type: PageTransitionType.fade,
                child: JoinHouse(currUser: providerRef.currUser),
                duration: Duration(milliseconds: 100),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (!context.mounted) return;
      showErrorMessage(context, 'Error deleting house', 'Please try again!');
    }
  }
}
