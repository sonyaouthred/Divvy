import 'package:divvy/models/chore.dart';
import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/models/member.dart';
import 'package:divvy/providers/divvy_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class EditOrAddChore extends StatefulWidget {
  final ChoreID? choreID;

  const EditOrAddChore({super.key, required this.choreID});

  @override
  State<EditOrAddChore> createState() => _EditOrAddChoreState();
}

class _EditOrAddChoreState extends State<EditOrAddChore> {
  late TextEditingController _textController;
  late List<Member> members;

  final List<String> weekDays = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];

  int emojiIndex = 0;

  final List<String> emojis = ['🛁', '🚽', '🧑‍🍳', '🦸'];

  List<bool> chosenMembers = [];

  Frequency frequency = Frequency.daily;

  List<bool> chosenDates = [];

  DateTime startMonthDate = DateTime.now();
  DateTime startDailyDate = DateTime.now();


  final uuid = Uuid();

  @override
  void initState() {
    super.initState();
    members = Provider.of<DivvyProvider>(context, listen: false).members;

    for (int i = 0; i < members.length; i++) {
      chosenMembers.add(false);
    }

    for (int i = 0; i < 7; i++) {
      if (i == 0) {
        chosenDates.add(true);
      } else {
        chosenDates.add(false);
      }
    }

    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void addChoreAndInstances(DivvyProvider provider) {
    if (_textController.text.isEmpty) return;

    ChoreID newChoreID = uuid.v4();

    List<MemberID> chosenMemberIDs = [];

    for (int i = 0; i < chosenMembers.length; i++) {
      if (chosenMembers[i]) {
        chosenMemberIDs.add(members[i].id);
      }
    }

    if (chosenMemberIDs.isEmpty) return;

    List<int> chosenDaysOfWeek = [];
    List<ChoreInst> newChoreInstances = [];

    if (frequency == Frequency.weekly) {
      DateTime currentDate = DateTime.now().copyWith(hour: 23, minute: 59);
      int assigneeNum = 0;

      for (int i = 0; i < chosenDates.length; i++) {
        if (chosenDates[i]) {
          chosenDaysOfWeek.add(i + 1);

          while (currentDate.weekday != i + 1) {
            currentDate = currentDate.add(Duration(days: 1));
          }

          newChoreInstances.add(
            ChoreInst(
              choreID: newChoreID,
              id: uuid.v4(),
              dueDate: currentDate,
              isDone: false,
              assignee: chosenMemberIDs[assigneeNum % chosenMemberIDs.length],
            ),
          );

          assigneeNum += 1;
        }
      }

      if (chosenDaysOfWeek.isEmpty) return;
    } else if (frequency == Frequency.daily) {
      DateTime currentDate = startDailyDate.copyWith(hour: 23, minute: 59);
      int assigneeNum = 0;

      for (int i = 1; i < 8; i++) {
        chosenDaysOfWeek.add(i);
        while (currentDate.weekday != i) {
          currentDate = currentDate.add(Duration(days: 1));
        }

        newChoreInstances.add(
          ChoreInst(
            choreID: newChoreID,
            id: uuid.v4(),
            dueDate: currentDate,
            isDone: false,
            assignee: chosenMemberIDs[assigneeNum % chosenMemberIDs.length],
          ),
        );

        assigneeNum += 1;
      }
    } else {
      chosenDaysOfWeek.add(startMonthDate.weekday);
      newChoreInstances.add(
        ChoreInst(
          choreID: newChoreID,
          id: uuid.v4(),
          dueDate: startMonthDate.copyWith(hour: 23, minute: 59),
          isDone: false,
          assignee: chosenMemberIDs[0],
        ),
      );
    }

    Chore chore = Chore(
      id: newChoreID,
      name: _textController.text,
      frequency: frequency,
      emoji: emojis[emojiIndex],
      description: "",
      assignees: chosenMemberIDs,
      dayOfWeek: chosenDaysOfWeek,
      instances: newChoreInstances.map((choreInst) => choreInst.id).toList(),
    );

    provider.addChore(chore);
    provider.addChoreInstances(chore, newChoreInstances);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final spacing = width * 0.05;

    return Consumer<DivvyProvider>(
      builder: (context, provider, child) {
        Chore? chore =
            widget.choreID == null
                ? null
                : provider.getSuperChore(widget.choreID!);

        if (chore != null) {
          _textController.text = chore.name;
        }

        return Scaffold(
          backgroundColor: DivvyTheme.background,
          appBar: AppBar(
            title: Text(
              chore == null ? "Add Chore" : "Edit Chore",
              style: DivvyTheme.screenTitle,
            ),
            centerTitle: true,
            scrolledUnderElevation: 0,
            backgroundColor: DivvyTheme.background,
            actions: [
              CupertinoButton(
                child: Text("Save", style: DivvyTheme.bodyGreen),
                onPressed: () {
                  addChoreAndInstances(provider);
                },
              ),
            ],
          ),
          body: SizedBox.expand(
            child: SingleChildScrollView(
              child: Container(
                width: width,
                padding: EdgeInsets.symmetric(horizontal: spacing),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CupertinoTextField(
                      placeholder: "Enter a name;",
                      controller: _textController,
                    ),
                    _chooseEmojis(context),
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 16),
                      child: Text("Assignees:", style: DivvyTheme.bodyBoldGrey),
                    ),
                    _memberList(members, chosenMembers, context),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text("Frequency:", style: DivvyTheme.bodyBoldGrey),
                      trailing: CupertinoButton(
                        child: Text(
                          _freqToText(frequency),
                          style: DivvyTheme.bodyGreen,
                        ),
                        onPressed: () {
                          _showCupertinoPickeForFreqs();
                        },
                      ),
                    ),
                    frequency == Frequency.monthly
                        ? _chooseMonths(context)
                        : SizedBox(),
                    frequency == Frequency.daily
                        ? _chooseDays(context)
                        : SizedBox(),
                    frequency == Frequency.weekly
                        ? _chooseWeekdays(context, weekDays)
                        : SizedBox(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _chooseEmojis(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text("Choose Icon", style: DivvyTheme.bodyBoldGrey),
      trailing: CupertinoButton(
        child: Text(emojis[emojiIndex], style: TextStyle(fontSize: 20)),
        onPressed: () {
          _showCupertinoPickeForEmojis(context);
        },
      ),
    );
  }

  void _showCupertinoPickeForEmojis(context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: CupertinoPicker(
            itemExtent: 32.0,
            onSelectedItemChanged: (int index) {
              setState(() {
                emojiIndex = index;
              });
            },
            children: [...emojis.map((emoji) => Text(emoji, style: TextStyle(fontSize: 20),))],
          ),
        );
      },
    );
  }

  Widget _chooseWeekdays(BuildContext context, List<String> daysOfWeek) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 32, bottom: 16),
          child: Text("Choose recurring days:", style: DivvyTheme.bodyBoldGrey),
        ),
        SizedBox(
          height: 300,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: daysOfWeek.length,
            itemBuilder: (context, idx) {
              return Card(
                color: DivvyTheme.background,
                child: ListTile(
                  title: Text(daysOfWeek[idx]),
                  trailing: IconButton(
                    onPressed: () {
                      setState(() {
                        chosenDates[idx] = !chosenDates[idx];
                      });
                    },
                    icon: Icon(
                      chosenDates[idx]
                          ? CupertinoIcons.check_mark_circled_solid
                          : CupertinoIcons.circle,
                      color: DivvyTheme.lightGreen,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _chooseDays(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text("Choose Start Date:", style: DivvyTheme.bodyBoldGrey),
      trailing: CupertinoButton(
        child: Text(
          DateFormat('MM/dd/yyyy').format(startDailyDate),
          style: DivvyTheme.bodyGreen,
        ),
        onPressed: () {
          _showDatePickerDays(context);
        },
      ),
    );
  }

  void _showDatePickerDays(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder:
          (BuildContext context) => Container(
            height: 250,
            color: CupertinoColors.systemBackground.resolveFrom(context),
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: startDailyDate,
              maximumDate: DateTime(2100),
              minimumDate: startDailyDate,
              onDateTimeChanged: (DateTime newDate) {
                setState(() {
                  startDailyDate = newDate;
                });
              },
            ),
          ),
    );
  }

  Widget _chooseMonths(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text("Choose Start Date:", style: DivvyTheme.bodyBoldGrey),
      trailing: CupertinoButton(
        child: Text(
          DateFormat('MM/dd/yyyy').format(startMonthDate),
          style: DivvyTheme.bodyGreen,
        ),
        onPressed: () {
          _showDatePickerMonth(context);
        },
      ),
    );
  }

  void _showDatePickerMonth(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder:
          (BuildContext context) => Container(
            height: 250,
            color: CupertinoColors.systemBackground.resolveFrom(context),
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: startMonthDate,
              maximumDate: DateTime(2100),
              minimumDate: startMonthDate,
              onDateTimeChanged: (DateTime newDate) {
                setState(() {
                  startMonthDate = newDate;
                });
              },
            ),
          ),
    );
  }

  void _showCupertinoPickeForFreqs() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: CupertinoPicker(
            itemExtent: 32.0,
            onSelectedItemChanged: (int index) {
              setState(() {
                if (index == 0) {
                  frequency = Frequency.daily;
                } else if (index == 1) {
                  frequency = Frequency.weekly;
                } else {
                  frequency = Frequency.monthly;
                }
              });
            },
            children: [Text("Daily"), Text("Weekly"), Text("Monthly")],
          ),
        );
      },
    );
  }

  Widget _memberList(
    List<Member> members,
    List<bool> chosenMembers,
    BuildContext context,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: members.length,
      itemBuilder: (context, idx) {
        return Card(
          color: DivvyTheme.background,
          child: CupertinoListTile(
            leading: CircleAvatar(
              radius: 15,
              backgroundColor: members[idx].profilePicture,
            ),
            title: Text(members[idx].name, style: DivvyTheme.bodyGrey),
            trailing: IconButton(
              onPressed: () {
                setState(() {
                  chosenMembers[idx] = !chosenMembers[idx];
                });
              },
              icon: Icon(
                chosenMembers[idx]
                    ? CupertinoIcons.check_mark_circled_solid
                    : CupertinoIcons.circle,
                color: DivvyTheme.lightGreen,
              ),
            ),
          ),
        );
      },
    );
  }

  String _freqToText(Frequency freq) {
    if (freq == Frequency.daily) {
      return "Daily";
    } else if (freq == Frequency.weekly) {
      return "Weekly";
    } else {
      return "Monthly";
    }
  }
}
