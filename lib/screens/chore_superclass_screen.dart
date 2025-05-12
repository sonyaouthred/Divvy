import 'package:divvy/models/chore.dart';
import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/models/member.dart';
import 'package:divvy/providers/divvy_provider.dart';
import 'package:divvy/screens/chore_instance_screen.dart';
import 'package:divvy/util/date_funcs.dart';
import 'package:divvy/util/dialogs.dart';
import 'package:divvy/widgets/chore_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Displays basic information about a chore superclass
class ChoreSuperclassScreen extends StatefulWidget {
  final ChoreID choreID;

  const ChoreSuperclassScreen({super.key, required this.choreID});

  @override
  State<ChoreSuperclassScreen> createState() => _ChoreSuperclassScreenState();
}

class _ChoreSuperclassScreenState extends State<ChoreSuperclassScreen> {
  String _choreTitle = "";
  late Chore chore;
  late List<Member> choreAssignees;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final providerInst = Provider.of<DivvyProvider>(context, listen: false);
    chore = providerInst.getSuperChore(widget.choreID);
    choreAssignees = providerInst.getChoreAssignees(widget.choreID);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final spacing = width * 0.05;

    return Consumer<DivvyProvider>(
      builder: (context, provider, child) {
        // Update data from provider
        chore = provider.getSuperChore(widget.choreID);
        choreAssignees = provider.getChoreAssignees(widget.choreID);

        // Get the list of upcoming chores for this super class
        List<ChoreInst> upcomingChores = [];
        for (Member member in choreAssignees) {
          upcomingChores.addAll(
            provider
                .getUpcomingChores(member.id)
                .where((chore) => chore.choreID == widget.choreID),
          );
        }

        // Sort the upcoming chores by due date
        upcomingChores.sort((a, b) => a.dueDate.isBefore(b.dueDate) ? -1 : 1);
        _choreTitle = chore.name;

        return Scaffold(
          backgroundColor: DivvyTheme.background,
          appBar: AppBar(
            title: Text("Chore Information", style: DivvyTheme.screenTitle),
            centerTitle: true,
            scrolledUnderElevation: 0,
            backgroundColor: DivvyTheme.background,
          ),
          body: SizedBox.expand(
            child: SingleChildScrollView(
              child: Container(
                width: width,
                padding: EdgeInsets.symmetric(horizontal: spacing),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: spacing),
                    _choreEditableTile(chore, _choreTitle, context, provider),
                    _customDivider(spacing),
                    _frequencyWidget(chore, spacing),
                    _customDivider(spacing),
                    _getAssigneesWidget(choreAssignees, spacing),
                    _customDivider(spacing),
                    upcomingChores.isEmpty
                        ? SizedBox()
                        : Text("Upcoming:", style: DivvyTheme.bodyBoldGrey),
                    SizedBox(height: spacing),
                    ...upcomingChores.map((ChoreInst choreInst) {
                      return _upcomingChoreInstanceTile(
                        choreInst,
                        choreAssignees.firstWhere(
                          (member) => member.id == choreInst.assignee,
                        ),
                        context,
                        spacing,
                      );
                    }),
                    SizedBox(height: spacing * 3),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Shows an upcoming chore instance and who it's assigned to
  Widget _upcomingChoreInstanceTile(
    ChoreInst choreInstance,
    Member member,
    BuildContext context,
    double spacing,
  ) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (ctx) => ChoreInstanceScreen(
                  choreInstanceId: choreInstance.id,
                  choreID: choreInstance.choreID,
                ),
          ),
        );
      },
      child: Column(
        children: [
          _memberTile(member, spacing),
          SizedBox(height: spacing / 2),
          ChoreTile(choreInst: choreInstance),
          SizedBox(height: spacing / 2),
        ],
      ),
    );
  }

  /// Returns a string representing the frequency
  String _getFrequencySentence(Frequency frequency) {
    String dates = '';
    if (frequency == Frequency.weekly) {
      for (int day in chore.dayOfWeek) {
        dates += '${getNameOfWeekday(day)}, ';
      }
      // slice trailing comma
      dates = dates.substring(0, dates.length - 2);
    }
    switch (frequency) {
      case Frequency.daily:
        return "Once every day";
      case Frequency.monthly:
        return "Once every month";
      case Frequency.weekly:
        return "${_getRepetition(chore.dayOfWeek.length)} on $dates";
    }
  }

  // A string representing how many times this chore is repeated
  // a week
  String _getRepetition(int numDays) => switch (numDays) {
    1 => 'Once every week',
    2 => 'Twice a week',
    3 => 'Three times a week',
    4 => 'Four times a week',
    5 => 'Five times a week',
    6 => 'Six times a week',
    7 => 'Seven times a week',
    int() => 'Error',
  };

  /// Displays the frequency of the chore
  Widget _frequencyWidget(Chore chore, double spacing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Frequency:", style: DivvyTheme.bodyBoldBlack),
        SizedBox(height: spacing / 2),
        // The frequency of the chore
        Text(
          _getFrequencySentence(chore.frequency),
          style: DivvyTheme.bodyBlack,
        ),
      ],
    );
  }

  /// Displays all the members currently assigned to this chore
  Widget _getAssigneesWidget(List<Member> members, double spacing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Assignees:", style: DivvyTheme.bodyBoldBlack),
        ...members.map((member) {
          return Column(
            children: [
              SizedBox(height: spacing / 2),
              Container(
                padding: EdgeInsets.all(spacing / 2),
                child: _memberTile(member, spacing),
              ),
            ],
          );
        }),
      ],
    );
  }

  // Displays a tile for a given member, including profile photo
  // and name
  Widget _memberTile(Member member, double spacing) {
    return Row(
      children: [
        Container(
          decoration: DivvyTheme.profileCircle(member.profilePicture),
          height: 25,
          width: 25,
        ),
        SizedBox(width: spacing / 2),
        Text(member.name, style: DivvyTheme.smallBodyBlack),
      ],
    );
  }

  /// Displays a horizontal divider
  Widget _customDivider(double spacing) {
    return Column(
      children: [
        SizedBox(height: spacing / 2),
        Divider(indent: 10, color: DivvyTheme.altBeige),
        SizedBox(height: spacing / 2),
      ],
    );
  }

  /// Displays the title of the chore and allows user to edit
  Widget _choreEditableTile(
    Chore chore,
    String title,
    BuildContext context,
    DivvyProvider provider,
  ) {
    return Container(
      decoration: DivvyTheme.textInput,
      child: ListTile(
        leading: Text(chore.emoji, style: TextStyle(fontSize: 40)),
        title: Text(title, style: DivvyTheme.bodyBlack),
        trailing: IconButton(
          onPressed: () async {
            // prompt for new name and assign if valid
            final newName = await openInputDialog(
              context,
              title: 'Edit Chore Name',
              initText: chore.name,
            );
            if (newName != null) {
              provider.changeName(widget.choreID, newName);
            }
          },
          icon: Icon(CupertinoIcons.pencil),
        ),
      ),
    );
  }
}
