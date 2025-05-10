import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/models/subgroup.dart';
import 'package:divvy/providers/divvy_provider.dart';
import 'package:divvy/screens/chores.dart';
import 'package:divvy/screens/subgroup_add.dart';
import 'package:divvy/util/dialogs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
                        ['Delete House', _openChoresScreen],
                      ],
                      flex: 2,
                      spacing: spacing,
                    ),
                    // Member settings
                    _infoSections(
                      icon: Icon(CupertinoIcons.person_fill),
                      text: 'Members',
                      buttons: [
                        ['Add a member', _addMember],
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
                      Text(entry[0], style: DivvyTheme.bodyGrey),

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
    // TODO: navigate to subgroup screen
    print('Adding subgroup...');
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
        print('Deleting subgroup ${_selectedSubgroup!.name}');
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

  /// Removes user, prompts for email
  void _addMember(BuildContext context) async {
    final email = await openInputDialog(
      context,
      title: 'Enter member\'s email',
      prompt: 'Enter email...',
    );
    // Process emil
    if (email != null) {
      // TODO(bhoop2b): update provider
      print('Adding user: $email');
    }
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
          // TODO(bhoop2b): update provider
          print('Removing user: $email');
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
      // TODO(bhoop2b): update provider
      print('Changing house name to: $newName');
    }
  }

  /// Opens the chores screen
  void _openChoresScreen(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => Chores()));
  }
}
