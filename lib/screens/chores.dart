// import 'package:divvy/models/divvy_theme.dart';
// Commented out for testing
import 'package:divvy/models/chore.dart';
import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/models/subgroup.dart';
import 'package:divvy/providers/divvy_provider.dart';
import 'package:divvy/screens/chore_superclass_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Chores extends StatefulWidget {
  const Chores({super.key});

  @override
  State<Chores> createState() => _ChoresState();
}

class _ChoresState extends State<Chores> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Consumer<DivvyProvider>(
      builder: (context, provider, child) {
        String houseName = provider.houseName;

        List<Subgroup> subgroups = provider.subgroups;

        return SizedBox.expand(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: DivvyTheme.background,
                    elevation: 2,
                    child: ListTile(
                      leading: IconButton(
                        onPressed: () {},
                        icon: Icon(CupertinoIcons.add),
                      ),
                      title: Text("Add Chore", style: DivvyTheme.bodyBoldBlack),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "${provider.houseName}'s Chores",
                    style: DivvyTheme.bodyBlack,
                  ),
                  ...subgroups.map(
                    (subgroup) =>
                        _subgroupChoresWidget(subgroup, provider, context),
                  ),
                  _allHouseChoresWidget(provider, context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _allHouseChoresWidget(DivvyProvider provider, BuildContext context) {
    List<Chore> otherChores = provider.getNonSubgroupChores();
    return Column(
      children: [
        Padding(
          padding: EdgeInsetsGeometry.all(10),
          child: Row(
            children: [
              Text("All House Chores", style: DivvyTheme.bodyBoldBlack),
            ],
          ),
        ),
        ...otherChores.map((chore) => _choreSuperTile(chore, context)),
      ],
    );
  }

  Widget _subgroupChoresWidget(
    Subgroup subgroup,
    DivvyProvider provider,
    BuildContext context,
  ) {
    List<Chore> choresUnderSubgroup = provider.getSubgroupChores(subgroup.id);

    return Column(
      children: [
        Padding(
          padding: EdgeInsetsGeometry.all(10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: subgroup.profilePicture,
              ),
              SizedBox(width: 10),
              Text(subgroup.name, style: DivvyTheme.bodyBoldBlack),
            ],
          ),
        ),
        ...choresUnderSubgroup.map((chore) => _choreSuperTile(chore, context)),
        SizedBox(height: 10),
        Divider(
          indent: 10,
          endIndent: 10,
          thickness: 0.5,
          color: DivvyTheme.lightGrey,
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _choreSuperTile(Chore chore, BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => ChoreSuperclassScreen(choreID: chore.id),
          ),
        );
      },
      child: Card(
        color: DivvyTheme.background,
        child: ListTile(
          leading: Text(chore.emoji, style: TextStyle(fontSize: 40)),
          title: Text(chore.name),
          trailing: Icon(CupertinoIcons.right_chevron),
        ),
      ),
    );
  }
}
