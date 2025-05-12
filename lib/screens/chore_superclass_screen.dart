import 'package:divvy/models/chore.dart';
import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/models/member.dart';
import 'package:divvy/providers/divvy_provider.dart';
import 'package:divvy/screens/chore_instance_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ChoreSuperclassScreen extends StatefulWidget {
  final ChoreID choreID;

  const ChoreSuperclassScreen({super.key, required this.choreID});

  @override
  State<ChoreSuperclassScreen> createState() => _ChoreSuperclassScreenState();
}

class _ChoreSuperclassScreenState extends State<ChoreSuperclassScreen> {
  String _choreTitle = "";

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final spacing = width * 0.02;

    return Consumer<DivvyProvider>(
      builder: (context, provider, child) {
        Chore chore = provider.getSuperChore(widget.choreID);
        List<Member> choreAssignees = provider.getChoreAssignees(
          widget.choreID,
        );

        List<ChoreInst> upcomingChores = [];

        for (Member member in choreAssignees) {
          upcomingChores.addAll(
            provider
                .getUpcomingChores(member.id)
                .where((chore) => chore.choreID == widget.choreID),
          );
        }

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
                    _choreEditableTile(chore, _choreTitle, context, provider),
                    _customDivider(),
                    _frequencyWidget(chore),
                    _customDivider(),
                    _getAssigneesWidget(choreAssignees),
                    _customDivider(),
                    upcomingChores.isEmpty
                        ? SizedBox()
                        : Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            "Upcoming:",
                            style: DivvyTheme.bodyBoldGrey,
                          ),
                        ),
                    ...upcomingChores.map((ChoreInst choreInst) {
                      return _upcomingChoreInstanceTile(
                        choreInst,
                        choreAssignees.firstWhere(
                          (member) => member.id == choreInst.assignee,
                        ),
                        context
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void showCupertinoTextInputSheet(BuildContext context, DivvyProvider provider) {
    String inputText = '';

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text('New Chore Name', style: DivvyTheme.bodyBoldBlack,),
          message: Column(
            children: [
              CupertinoTextField(
                placeholder: 'Type something...',
                onChanged: (value) {
                  inputText = value;
                },
                autofocus: true,
              ),
              SizedBox(height: 16),
            ],
          ),
          actions: [
            CupertinoActionSheetAction(
              isDefaultAction: true,
              onPressed: () {
                if (inputText.isNotEmpty) {
                  provider.changeName(widget.choreID, inputText);
                }

                Navigator.pop(context);
              },
              child: Text('Save', style: DivvyTheme.largeBoldMedGreen,),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
        );
      },
    );
  }

  Widget _upcomingChoreInstanceTile(ChoreInst choreInstance, Member member, BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (ctx) => ChoreInstanceScreen(choreInstanceId: choreInstance.id, choreID: choreInstance.choreID))
        );
      },
      child: Card(
        color: DivvyTheme.background,
        child: ListTile(
          leading: CircleAvatar(backgroundColor: member.profilePicture),
          title: Text(member.name),
          trailing: Text(getFormattedDate(choreInstance.dueDate)),
        ),
      ),
    );
  }

  String getFormattedDate(DateTime dueDate) {
    return DateFormat.yMMMMd('en_US').format(dueDate);
  }

  String _getFrequencySentence(Frequency frequency) {
    if (frequency == Frequency.daily) {
      return "Once every day.";
    } else if (frequency == Frequency.monthly) {
      return "Once every month";
    } else {
      return "Once every week";
    }
  }

  Widget _frequencyWidget(Chore chore) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text("Frequency:", style: DivvyTheme.bodyBoldGrey),
        ),

        ListTile(
          title: Text(
            _getFrequencySentence(chore.frequency),
            style: DivvyTheme.bodyBlack,
          ),
        ),
      ],
    );
  }

  Widget _getAssigneesWidget(List<Member> members) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text("Assignees:", style: DivvyTheme.bodyBoldGrey),
        ),
        ...members.map((member) {
          return Card(
            color: DivvyTheme.background,
            child: ListTile(
              leading: CircleAvatar(backgroundColor: member.profilePicture),
              title: Text(member.name, style: DivvyTheme.bodyBlack),
            ),
          );
        }),
      ],
    );
  }

  Widget _customDivider() {
    return Column(
      children: [
        SizedBox(height: 10),
        Divider(
          indent: 10,
          endIndent: 10,
          color: const Color.fromARGB(255, 181, 181, 181),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _choreEditableTile(Chore chore, String title, BuildContext context, DivvyProvider provider) {
    return Card(
      color: DivvyTheme.background,
      child: ListTile(
        leading: Text(chore.emoji, style: TextStyle(fontSize: 40)),
        title: Text(title, style: DivvyTheme.bodyBlack),
        trailing: IconButton(
          onPressed: () {
            showCupertinoTextInputSheet(context, provider);
          },
          icon: Icon(CupertinoIcons.pencil),
        ),
      ),
    );
  }
}
