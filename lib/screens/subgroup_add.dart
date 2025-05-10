import 'package:divvy/models/chore.dart';
import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/models/member.dart';
import 'package:divvy/providers/divvy_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SubgroupAdd extends StatefulWidget {
  const SubgroupAdd({super.key});

  @override
  State<SubgroupAdd> createState() => _SubgroupAddState();
}

class _SubgroupAddState extends State<SubgroupAdd> {
  late List<Member> _members;
  late List<Chore> _chores;
  List<Member> _displayMembers = [];
  final List<Member> _subgroupMember = [];
  final List<Chore> _subgroupChore = [];
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String _name = '';


  @override
  void initState() {
    super.initState();
    final providerRef = Provider.of<DivvyProvider>(context, listen: false);
    _members = providerRef.members;
    _chores = providerRef.chores;
    _displayMembers.addAll(_members);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final spacing = width * 0.05;
    return Scaffold(
      backgroundColor: DivvyTheme.background,
      appBar: AppBar(
        title: Text('Add Subgroup', style: DivvyTheme.screenTitle),
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
                _members = provider.members;
                _chores = provider.chores;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _nameInput(),
                    SizedBox(height: spacing / 2),
                    _displayAssignees(spacing),
                    SizedBox(height: spacing / 2),
                    _displayChores(spacing),
                    _buttons(spacing)
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

  // widget for name input

  // Widget for displaying assignees
  Widget _displayAssignees(double spacing) {
    // Return view of subgroup chores
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text('Assignees', style: DivvyTheme.bodyBoldBlack)],
        ),
        SizedBox(height: spacing / 4),
        _searchInput(),
        SizedBox(height: spacing / 4),
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
              padding: EdgeInsets.all(spacing / 12),
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
    bool inList = _subgroupMember.contains(member);

    return Padding(
      padding: EdgeInsets.only(right: spacing),
      child: InkWell(
        onTap: () => setState(() {
          inList ? _subgroupMember.remove(member) : _subgroupMember.add(member);
        }),
        child: Container(
          decoration: DivvyTheme.box(
            inList ? DivvyTheme.mediumGreen : DivvyTheme.white,
          ),
          child: Column(
            children: [
              SizedBox(height: spacing / 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // User profile image
                  Row(
                    children: [
                      SizedBox(width: spacing / 6),
                      Container(
                        decoration: DivvyTheme.profileCircle(
                          member.profilePicture,
                        ),
                        height: 25,
                        width: 25,
                      ),
                      SizedBox(width: spacing / 2),
                      Text(member.name, style: DivvyTheme.bodyBlack),
                    ],
                  ),
                ],
              ),
              SizedBox(height: spacing / 8),
            ],
          ),
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
          onPressed: () => setState(() {
            _displayMembers = _members;
            _searchController.clear();
          }),
        ),
        // Add a search icon or button to the search bar
        prefixIcon: IconButton(
          icon: Icon(Icons.search),
          onPressed: () => setState(() {
            // Perform the search here
            _displayMembers = _members
                .where((member) => member.name.contains(_searchController.text))
                .toList();
          }),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
      ),
      onSubmitted: (String text) => setState(() {
            // Perform the search here
            _displayMembers = _members
                .where((member) => member.name.contains(text))
                .toList();
          }),
    );
  }

  // Name controller
  Widget _nameInput() {
    return TextField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Name',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
      ),
      onSubmitted: (String text) => setState(() {
            // Adding text
            _name = text;
          }),
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
            )
          ],
        ),
        SizedBox(height: spacing / 4),
        // Display the chore tiles for all chores due today
        // List of subgroups
        ListView.builder(
          itemCount: _chores.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            bool isLast = false;
            if (index == _chores.length - 1) isLast = true;
            // Render the member's profile picture and name
            return Padding(
              padding: EdgeInsets.all(spacing / 12),
              child: _choreTile(
                chore: _chores[index],
                spacing: spacing,
                isLast: isLast,
              ),
            );
          },
        ),
      ],
    );
   }

   // Chores tile 
    Widget _choreTile({
    required Chore chore,
    required double spacing,
    required bool isLast,
  }) {
    bool inList = _subgroupChore.contains(chore);

    return Padding(
      padding: EdgeInsets.only(right: spacing),
      child: InkWell(
        onTap: () => setState(() {
          inList ? _subgroupChore.remove(chore) : _subgroupChore.add(chore);
        }),
        child: Container(
          decoration: DivvyTheme.box(
            inList ? DivvyTheme.mediumGreen : DivvyTheme.white,
          ),
          child: Column(
            children: [
              SizedBox(height: spacing / 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // User profile image
                  Row(
                    children: [
                      SizedBox(width: spacing / 6),
                      Text(chore.emoji, style: TextStyle(fontSize: 20)),
                      SizedBox(width: spacing / 1.2),
                      Text(chore.name, style: DivvyTheme.bodyBlack, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ],
              ),
              SizedBox(height: spacing / 8),
            ],
          ),
        ),
      ),
    );
  }

  // Save button
  Widget _buttons(double spacing){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(onPressed: () => _saveButton(context),
        style: ElevatedButton.styleFrom(backgroundColor: DivvyTheme.mediumGreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        minimumSize: Size(100, 50)),
        child: Text('Save', style: DivvyTheme.bodyBoldBlack)),
        SizedBox(width: spacing / 2),
        ElevatedButton(onPressed: () => _cancelButton(context), 
        style: ElevatedButton.styleFrom(backgroundColor: DivvyTheme.lightRed,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        minimumSize: Size(100, 50)),
        child: Text('Cancel', style: DivvyTheme.bodyBoldBlack,))
      ],
    );
  }

  ///////////////////////////// Util /////////////////////////////
  
  void _saveButton(BuildContext context){
    //TODO: update subgroup provider
    print('Add subgroup to the list');
    Navigator.pop(context);
  }

  void _cancelButton(BuildContext context) {
    Navigator.pop(context);
  }

  void _addChore(BuildContext context){
    //TODO: connect to add chore
    print('Add chore');
  }
}
