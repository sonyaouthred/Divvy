import 'package:divvy/models/chore.dart';
import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/models/member.dart';
import 'package:divvy/providers/divvy_provider.dart';
import 'package:divvy/util/dialogs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Allows user to create a subgroup with a list of
/// selected members and chores. Can type in custom name.
/// On pop back, saves subgroup (with valid input) to
/// database.
class SubgroupAdd extends StatefulWidget {
  const SubgroupAdd({super.key});

  @override
  State<SubgroupAdd> createState() => _SubgroupAddState();
}

class _SubgroupAddState extends State<SubgroupAdd> {
  late List<Member> _members;
  List<Member> _displayMembers = [];
  final List<Member> _subgroupMember = [];
  final List<Chore> _subgroupChore = [];
  late final TextEditingController _searchController;
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final providerRef = Provider.of<DivvyProvider>(context, listen: false);
    _members = providerRef.members;
    _displayMembers.addAll(_members);
    // Initialize text editing controllers
    _searchController = TextEditingController();
    _nameController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final spacing = width * 0.05;
    // Handle input vaildation
    return PopScope(
      canPop: false,
      onPopInvokedWithResult:
          (didPop, result) => {
            if (!didPop) {_popBack(context, false)},
          },
      child: Scaffold(
        backgroundColor: DivvyTheme.background,
        appBar: AppBar(
          title: Text('Add Subgroup', style: DivvyTheme.screenTitle),
          centerTitle: true,
          scrolledUnderElevation: 0,
          backgroundColor: DivvyTheme.background,
        ),
        body: SizedBox.expand(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(spacing),
              child: Consumer<DivvyProvider>(
                builder: (context, provider, child) {
                  // update members available
                  _members = provider.members;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name:', style: DivvyTheme.bodyBoldBlack),
                      SizedBox(height: spacing),
                      _nameInput(spacing),
                      SizedBox(height: spacing * 2),
                      _displayAssignees(spacing),
                      _displayChores(spacing),
                      SizedBox(height: spacing * 2),
                      Center(child: _buttons(spacing)),
                      // Buffer for end of scroll view
                      SizedBox(height: spacing * 4),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  ///////////////////////////// Widgets /////////////////////////////

  // Widget for displaying assignees
  Widget _displayAssignees(double spacing) {
    // Return view of subgroup chores
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text('Members:', style: DivvyTheme.bodyBoldBlack)],
        ),
        SizedBox(height: spacing / 2),
        _searchInput(),
        SizedBox(height: spacing),
        // Display the chore tiles for all chores due today
        // List of subgroups
        ListView.builder(
          itemCount: _displayMembers.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            bool isLast = false;
            if (index == _displayMembers.length - 1) isLast = true;
            // Render the member's profile picture and name
            return Padding(
              padding: EdgeInsets.symmetric(vertical: spacing / 3),
              child: _memberTile(
                member: _displayMembers[index],
                spacing: spacing,
                isLast: isLast,
              ),
            );
          },
        ),
      ],
    );
  }

  /// Displays the tile for a subgroup with their
  /// image and name
  Widget _memberTile({
    required Member member,
    required double spacing,
    required bool isLast,
  }) {
    // Check if tile is currently selected
    bool inList = _subgroupMember.contains(member);
    return InkWell(
      onTap:
          () => setState(() {
            // toggle selection
            inList
                ? _subgroupMember.remove(member)
                : _subgroupMember.add(member);
          }),
      child: Container(
        decoration: DivvyTheme.box(
          inList ? DivvyTheme.mediumGreen : DivvyTheme.white,
        ),
        padding: EdgeInsets.all(spacing / 2),
        // Display user info
        child: Row(
          children: [
            SizedBox(width: spacing / 6),
            // User profile image
            Container(
              decoration: DivvyTheme.profileCircle(member.profilePicture.color),
              height: 25,
              width: 25,
            ),
            SizedBox(width: spacing / 2),
            Text(member.name, style: DivvyTheme.bodyBlack),
          ],
        ),
      ),
    );
  }

  // Search input
  Widget _searchInput() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search...',
        // Add a clear button to the search bar
        suffixIcon: IconButton(
          icon: Icon(Icons.clear),
          onPressed:
              () => setState(() {
                _displayMembers = _members;
                _searchController.clear();
              }),
        ),
        // Add a search icon or button to the search bar
        prefixIcon: IconButton(
          icon: Icon(Icons.search),
          onPressed:
              () => setState(() {
                // Perform the search here
                _displayMembers =
                    _members
                        .where(
                          (member) =>
                              member.name.contains(_searchController.text),
                        )
                        .toList();
              }),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
      ),
      onSubmitted:
          (String text) => setState(() {
            // Perform the search here
            _displayMembers =
                _members.where((member) => member.name.contains(text)).toList();
          }),
    );
  }

  // Name controller
  Widget _nameInput(double spacing) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: spacing * 0.75),
      decoration: DivvyTheme.textInput,
      child: TextFormField(
        controller: _nameController,
        autocorrect: false,
        decoration: InputDecoration(border: InputBorder.none),
      ),
    );
  }

  // Chore input
  Widget _displayChores(double spacing) {
    // Return view of subgroup chores
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Chores', style: DivvyTheme.bodyBoldBlack),
            InkWell(
              onTap: () => _addChore(context),
              child: SizedBox(
                height: 45,
                width: 45,
                child: Icon(CupertinoIcons.add),
              ),
            ),
          ],
        ),
        if (_subgroupChore.isNotEmpty) SizedBox(height: spacing / 4),
        // Display the chore tiles for all chores due today
        // List of subgroups
        if (_subgroupChore.isNotEmpty)
          ListView.builder(
            itemCount: _subgroupChore.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              bool isLast = false;
              if (index == _subgroupChore.length - 1) isLast = true;
              // Render the member's profile picture and name
              return Padding(
                padding: EdgeInsets.symmetric(vertical: spacing / 3),
                child: _choreTile(
                  chore: _subgroupChore[index],
                  spacing: spacing,
                  isLast: isLast,
                ),
              );
            },
          ),
        if (_subgroupChore.isEmpty)
          Text('Add a chore for this subgroup!', style: DivvyTheme.bodyGrey),
      ],
    );
  }

  // Chores tile
  Widget _choreTile({
    required Chore chore,
    required double spacing,
    required bool isLast,
  }) {
    // Check if chore is currently in list
    bool inList = _subgroupChore.contains(chore);
    return InkWell(
      onTap:
          () => setState(() {
            inList ? _subgroupChore.remove(chore) : _subgroupChore.add(chore);
          }),
      child: Container(
        padding: EdgeInsets.all(spacing / 2),
        decoration: DivvyTheme.box(
          inList ? DivvyTheme.mediumGreen : DivvyTheme.white,
        ),
        child:
        // User profile image
        Row(
          children: [
            Text(chore.emoji, style: TextStyle(fontSize: 20)),
            SizedBox(width: spacing / 1.2),
            Text(
              chore.name,
              style: DivvyTheme.bodyBlack,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Save button
  Widget _buttons(double spacing) {
    return InkWell(
      onTap: () => _popBack(context, true),
      child: Container(
        height: 50,
        width: 100,
        alignment: Alignment.center,
        decoration: DivvyTheme.greenBox,
        child: Text('Save', style: DivvyTheme.largeBoldMedWhite),
      ),
    );
  }

  ///////////////////////////// Util /////////////////////////////

  /// Pop back, either saving changes or abandoning them.
  /// If user has created chores but opts **not** to save subgroup,
  /// chores are forgotten
  void _popBack(BuildContext context, bool save) async {
    if (save) {
      // Save subgroup
      if (_nameController.text == '') {
        await showErrorMessage(
          context,
          'Invalid name',
          'Please enter a name for this subgroup.',
        );
        return;
      } else if (_subgroupMember.isEmpty) {
        await showErrorMessage(
          context,
          'No members selected',
          'Please choose at least one member.',
        );
        return;
      }
      // Saves chores user may have created
      if (!context.mounted) return;
      Provider.of<DivvyProvider>(context, listen: false).addSubgroup(
        _nameController.text,
        _subgroupMember,
        _subgroupChore,
        ProfileColor.black,
      );
    } else {
      if (_nameController.text != '' ||
          _subgroupMember.isNotEmpty ||
          _subgroupChore.isNotEmpty) {
        // user has made edits, confirm they want to exit
        final exit = await confirmDeleteDialog(
          context,
          'Discard changes?',
          action: 'Exit',
        );
        if (exit == null || !exit) {
          // user does not want to exit, so return
          return;
        }
      }
    }
    if (!context.mounted) return;
    Navigator.pop(context);
  }

  void _addChore(BuildContext context) {
    //TODO: connect to add chore
    // IMPORTANT: the add chore screen should **not** add this
    // chore to the database. This screen will add to db if
    // user decides to save subgroup.
    print('Add chore');
    // TODO: after adding chore, add it to _subgroupChores
  }
}
