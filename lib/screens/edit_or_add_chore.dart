import 'package:all_emojis/all_emojis.dart';
import 'package:divvy/models/chore.dart';
import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/models/member.dart';
import 'package:divvy/models/subgroup.dart';
import 'package:divvy/providers/divvy_provider.dart';
import 'package:divvy/util/date_funcs.dart';
import 'package:divvy/util/dialogs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Allows the user to add a chore & save it to their house
/// Parameters:
///   - choreID: the ID of the chore they are editing. if null,
///       the user is adding a chore.
///   - subgroup: the ID of the subgroup this chore is being added to.
///       If null, the subgroup is not selected as the default.
class EditOrAddChore extends StatefulWidget {
  final ChoreID? choreID;
  final Subgroup? subgroup;

  const EditOrAddChore({super.key, required this.choreID, this.subgroup});

  @override
  State<EditOrAddChore> createState() => _EditOrAddChoreState();
}

class _EditOrAddChoreState extends State<EditOrAddChore> {
  // track chore's name
  late TextEditingController _nameController;
  late TextEditingController _emojiController;
  // track list of members
  late List<Member> members;
  // track list of subgroups
  late List<Subgroup> subgroups;
  // the super chore object (null if adding)
  late Chore? chore;
  // the group the user is selecting by
  AssigneeSelection assigneeSel = AssigneeSelection.subgroup;

  // List of weekdays to choose from
  final List<int> weekDays = [
    7,
    1,
    2,
    3,
    4,
    5,
    6,
  ]; // List of weekdays to choose from

  List<Member> chosenMembers = [];
  Subgroup? chosenSubgroup;

  // The selected frequency of the chore
  Frequency frequency = Frequency.weekly;
  // The list of chosen dates
  List<int> chosenDates = [];
  // Start dates
  DateTime startDate = DateTime.now();
  // track if user made changes
  bool edited = false;

  @override
  void initState() {
    super.initState();
    final providerRef = Provider.of<DivvyProvider>(context, listen: false);
    members = providerRef.members;
    subgroups = providerRef.subgroups;
    // get the actual chore object from the provider (if possible)
    chore =
        widget.choreID == null
            ? null
            : providerRef.getSuperChore(widget.choreID!);
    // If user is editing, set the initial chore name to the actual name
    _nameController = TextEditingController(text: chore?.name ?? '');
    _emojiController = TextEditingController(text: chore?.emoji ?? '');
    Subgroup? initSubgroup = widget.subgroup;
    if (initSubgroup != null) {
      chosenSubgroup = initSubgroup;
    } else {
      chosenSubgroup = subgroups.first;
    }
    if (chore != null) {
      // update relevant initial values, if necessary
      final sub = providerRef.isSubgroup(chore!.assignees);
      if (sub != null) chosenSubgroup = sub;
      frequency = chore!.frequency.pattern;
      switch (frequency) {
        case Frequency.daily || Frequency.monthly:
          startDate = chore!.frequency.startDate;
        case Frequency.weekly:
          chosenDates = chore!.frequency.daysOfWeek;
      }
    }
  }

  @override
  void dispose() {
    // dispose of text editing controllers
    _nameController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final spacing = width * 0.05;

    return Consumer<DivvyProvider>(
      builder: (context, provider, child) {
        // Refresh chore from provider
        chore = chore == null ? null : provider.getSuperChore(widget.choreID!);
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
          ),
          body: SizedBox.expand(
            child: SingleChildScrollView(
              child: PopScope(
                canPop: false,
                onPopInvokedWithResult:
                    (didPop, result) => {
                      if (!didPop) {_popBack(context)},
                    },
                child: Container(
                  width: width,
                  padding: EdgeInsets.symmetric(horizontal: spacing),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: spacing),
                      _choreNameEditor(spacing),
                      SizedBox(height: spacing),
                      _chooseEmojis(context),
                      if (chore != null) SizedBox(height: spacing),
                      if (chore != null)
                        Center(
                          child: Text(
                            'Assignees and frequency cannot be changed after creation.',
                            style: DivvyTheme.bodyGrey,
                          ),
                        ),
                      SizedBox(height: spacing),
                      _showAssigneeSelection(spacing),
                      SizedBox(height: spacing),
                      _showFrequencySelection(spacing, width, height),
                      SizedBox(height: spacing * 2),
                      _saveButton(width, provider),
                      SizedBox(height: spacing * 2),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Allow user to save the chore they've created
  Widget _saveButton(double width, DivvyProvider provider) {
    return Center(
      child: InkWell(
        onTap: () {
          // Add the chore and chore instances
          addChoreAndInstances(provider);
        },
        child: Container(
          alignment: Alignment.center,
          height: 50,
          width: width / 3,
          decoration: DivvyTheme.medGreenBox,
          child: Text("Save", style: DivvyTheme.largeBoldMedWhite),
        ),
      ),
    );
  }

  //////////////////////// Name editing ////////////////////////

  /// Allow user to view chore name/edit.
  Widget _choreNameEditor(double spacing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Chore Name:', style: DivvyTheme.bodyBoldBlack),
        SizedBox(height: spacing / 2),
        Container(
          height: 50,
          decoration: DivvyTheme.standardBox,
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: TextFormField(
            controller: _nameController,
            decoration: InputDecoration(border: InputBorder.none),
          ),
        ),
      ],
    );
  }

  /// Allow user to choose the emoji they want.
  Widget _chooseEmojis(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 1,
          child: Text("Emoji Icon:", style: DivvyTheme.bodyBoldGrey),
        ),
        Spacer(flex: 1),
        Flexible(
          flex: 1,
          child: Container(
            height: 50,
            decoration: DivvyTheme.standardBox,
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: TextFormField(
              controller: _emojiController,
              decoration: InputDecoration(border: InputBorder.none),
            ),
          ),
        ),
      ],
    );
  }

  //////////////////////// Date Selection ////////////////////////

  /// Displays row of selectable dates for the inputted week
  Widget _weekDayDisplay(double width, double spacing, double height) {
    return Padding(
      padding: EdgeInsets.only(top: spacing),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:
            weekDays.map((date) {
              return _dateTile(date, width / 10, spacing, height);
            }).toList(),
      ),
    );
  }

  /// Displays a tile for the selected date.
  Widget _dateTile(int weekDay, double width, double spacing, double height) {
    // True if current date is selected
    bool isSelected = chosenDates.contains(weekDay);
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap:
          () => setState(() {
            if (chore != null) return;
            // add or remove current date
            if (chosenDates.contains(weekDay)) {
              chosenDates.remove(weekDay);
            } else {
              chosenDates.add(weekDay);
            }
          }),
      child: IntrinsicHeight(
        child: Container(
          decoration: DivvyTheme.oval(
            isSelected
                ? (chore != null
                    ? DivvyTheme.lightGrey
                    : const Color.fromARGB(255, 10, 13, 10))
                : DivvyTheme.white,
          ),
          width: width,
          padding: EdgeInsets.symmetric(vertical: spacing / 2),
          child: Column(
            children: [
              SizedBox(height: spacing * 0.3),
              // Display weekday letter
              Text(
                getLetterForWeekday(weekDay),
                style:
                    isSelected
                        ? DivvyTheme.largeBoldMedWhite
                        : chore != null
                        ? DivvyTheme.largeBoldMedGrey
                        : DivvyTheme.largeBoldMedGreen,
              ),
              SizedBox(height: spacing * 0.3),
            ],
          ),
        ),
      ),
    );
  }

  /// Allow user to choose a start date for repetition.
  Widget _chooseStartDate(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text("Choose Start Date:", style: DivvyTheme.bodyBoldGrey),
      trailing: CupertinoButton(
        child: Text(
          DateFormat('MM/dd/yyyy').format(startDate),
          style:
              chore != null
                  ? DivvyTheme.smallBoldMedGrey
                  : DivvyTheme.smallBoldMedGreen,
        ),
        onPressed: () {
          chore != null ? () : _showDatePickerDays(context);
        },
      ),
    );
  }

  /// Allow user to select a date to start repetition on
  void _showDatePickerDays(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder:
          (BuildContext context) => Container(
            height: 250,
            color: CupertinoColors.systemBackground.resolveFrom(context),
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: startDate,
              maximumDate: DateTime(2100),
              minimumDate: startDate,
              onDateTimeChanged: (DateTime newDate) {
                setState(() {
                  startDate = newDate;
                });
              },
            ),
          ),
    );
  }

  /// Show the user's current frequency selection & allow them to change it
  Widget _showFrequencySelection(double spacing, double width, double height) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Frequency:", style: DivvyTheme.bodyBoldGrey),
            _frequencySelector(spacing),
          ],
        ),
        SizedBox(height: spacing),
        // Show date/weekday selection
        if (frequency == Frequency.monthly || frequency == Frequency.daily)
          _chooseStartDate(context),
        if (frequency == Frequency.weekly)
          _weekDayDisplay(width, spacing, height),
      ],
    );
  }

  /// Display a box the user uses to select a frequency pattern
  Widget _frequencySelector(double spacing) {
    return IntrinsicWidth(
      child: Container(
        height: 45,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: spacing),
        decoration: DivvyTheme.standardBox,
        child: DropdownButtonFormField(
          value: frequency,
          borderRadius: BorderRadius.circular(15),
          elevation: 3,
          decoration: const InputDecoration(border: InputBorder.none),
          dropdownColor: DivvyTheme.background,
          iconEnabledColor: DivvyTheme.mediumGreen,
          iconDisabledColor: DivvyTheme.lightGrey,
          items:
              Frequency.values
                  .map<DropdownMenuItem<Frequency>>(
                    (Frequency sel) => DropdownMenuItem<Frequency>(
                      value: sel,
                      child: Text(
                        sel.name,
                        style:
                            chore != null
                                ? DivvyTheme.smallBoldMedGrey
                                : DivvyTheme.smallBoldMedGreen,
                      ),
                    ),
                  )
                  .toList(),
          onChanged:
              (chore != null)
                  ? null
                  : (Frequency? value) async {
                    if (value != null) {
                      setState(() {
                        frequency = value;
                      });
                    }
                  },
        ),
      ),
    );
  }

  //////////////////////// Assignees ////////////////////////

  // Allows user to select members or groups or whole house
  Widget _showAssigneeSelection(double spacing) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing / 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Choose assignees by:", style: DivvyTheme.bodyBoldGrey),
              SizedBox(width: spacing / 2),
              _assigneeSelector(spacing),
            ],
          ),
          if (assigneeSel != AssigneeSelection.house) SizedBox(height: spacing),
          if (assigneeSel == AssigneeSelection.member)
            _memberList(context, spacing),
          if (assigneeSel == AssigneeSelection.subgroup)
            _subgroupList(context, spacing),
        ],
      ),
    );
  }

  /// Display a box the user uses to select a date range
  Widget _assigneeSelector(double spacing) {
    return IntrinsicWidth(
      child: Container(
        height: 45,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: spacing),
        decoration: DivvyTheme.standardBox,
        child: DropdownButtonFormField(
          value: assigneeSel,
          borderRadius: BorderRadius.circular(15),
          elevation: 3,
          decoration: const InputDecoration(border: InputBorder.none),
          dropdownColor: DivvyTheme.background,
          iconEnabledColor: DivvyTheme.mediumGreen,
          items:
              AssigneeSelection.values
                  .map<DropdownMenuItem<AssigneeSelection>>(
                    (AssigneeSelection sel) =>
                        DropdownMenuItem<AssigneeSelection>(
                          value: sel,
                          child: Text(
                            sel.name,
                            style:
                                chore != null
                                    ? DivvyTheme.smallBoldMedGrey
                                    : DivvyTheme.smallBoldMedGreen,
                          ),
                        ),
                  )
                  .toList(),
          onChanged:
              (chore != null)
                  ? null
                  : (AssigneeSelection? value) async {
                    if (value != null) {
                      setState(() {
                        assigneeSel = value;
                      });
                    }
                  },
        ),
      ),
    );
  }

  /// Display the list of all subgroups and if they have been chosen.
  Widget _subgroupList(BuildContext context, double spacing) {
    return Column(
      children:
          subgroups
              .map(
                (s) => Padding(
                  padding: EdgeInsets.symmetric(vertical: spacing / 2),
                  child: Container(
                    decoration: DivvyTheme.standardBox,
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: spacing * 0.75),
                    child: InkWell(
                      onTap: () {
                        chore != null
                            ? ()
                            : setState(() {
                              chosenSubgroup = s;
                            });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 15,
                                backgroundColor: s.profilePicture.color,
                              ),
                              SizedBox(width: spacing / 2),
                              Text(s.name, style: DivvyTheme.bodyBlack),
                            ],
                          ),
                          Icon(
                            chosenSubgroup != null && chosenSubgroup == s
                                ? CupertinoIcons.check_mark_circled_solid
                                : CupertinoIcons.circle,
                            color:
                                chore != null
                                    ? DivvyTheme.lightGrey
                                    : DivvyTheme.lightGreen,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }

  /// Display the list of all members and if they have been chosen.
  Widget _memberList(BuildContext context, double spacing) {
    return Column(
      children:
          members
              .map(
                (m) => Padding(
                  padding: EdgeInsets.symmetric(vertical: spacing / 2),
                  child: Container(
                    decoration: DivvyTheme.standardBox,
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: spacing * 0.75),
                    child: InkWell(
                      onTap: () {
                        // disable mods if user is editing a chore instance
                        chore != null
                            ? ()
                            : setState(() {
                              if (chosenMembers.contains(m)) {
                                chosenMembers.remove(m);
                              } else {
                                chosenMembers.add(m);
                              }
                            });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 15,
                                backgroundColor: m.profilePicture.color,
                              ),
                              SizedBox(width: spacing / 2),
                              Text(m.name, style: DivvyTheme.bodyBlack),
                            ],
                          ),
                          Icon(
                            chosenMembers.contains(m)
                                ? CupertinoIcons.check_mark_circled_solid
                                : CupertinoIcons.circle,
                            color:
                                chore != null
                                    ? DivvyTheme.lightGrey
                                    : DivvyTheme.lightGreen,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }

  //////////////////////// Saving ////////////////////////

  /// Add a new super chore and all instances to the database (via provider)
  void addChoreAndInstances(DivvyProvider provider) {
    // if no name has been entered, show error dialog
    if (_nameController.text.isEmpty) {
      showErrorMessage(
        context,
        'Invalid Input',
        'Please enter a name for your chore!',
      );
      return;
    } else if (assigneeSel == AssigneeSelection.member &&
        chosenMembers.isEmpty) {
      // Make sure at least one member has been chosen
      showErrorMessage(
        context,
        'Invalid Input',
        'Please choose at least one member.',
      );
      return;
    } else if (assigneeSel == AssigneeSelection.subgroup &&
        chosenSubgroup == null) {
      // Make sure at least one member has been chosen
      showErrorMessage(
        context,
        'Invalid Input',
        'Please choose at least one subgroup.',
      );
      return;
    } else if (frequency == Frequency.weekly && chosenDates.isEmpty) {
      // No weekdays have been chosen
      showErrorMessage(
        context,
        'Invalid Input',
        'Please choose at least one weekday to repeat on.',
      );
      return;
    } else if (!isEmoji(_emojiController.text)) {
      // Emoji is invalid
      showErrorMessage(
        context,
        'Invalid Input',
        'Please choose a single emoji to represent the chore.',
      );
      return;
    }

    // Get all member IDs
    List<MemberID> chosenMemberIDs = switch (assigneeSel) {
      // all house members should be added
      AssigneeSelection.house => members.map((m) => m.id).toList(),
      AssigneeSelection.member => chosenMembers.map((m) => m.id).toList(),
      AssigneeSelection.subgroup => chosenSubgroup!.members,
    };
    if (chore == null) {
      // Add new chore!
      Chore newChore = Chore.fromNew(
        name: _nameController.text,
        pattern: frequency,
        daysOfWeek: chosenDates,
        emoji: _emojiController.text,
        description: "",
        assignees: chosenMemberIDs,
        // default start at midnight
        startDate: DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
          11,
          59,
          59,
        ),
      );

      // Provider will handle adding new chore instances
      provider.addChore(newChore);
    } else {
      // update existing chore
      Chore updatedChore = Chore.update(
        old: chore!,
        name: _nameController.text,
        emoji: _emojiController.text,
        description: "",
      );
      provider.updateChore(updatedChore);
    }

    Navigator.of(context).pop();
  }

  // Make sure user does not want to save changes.
  void _popBack(BuildContext context) async {
    print('here');
    // Check for edits
    if (chore != null) {
      if (_nameController.text != chore!.name) edited = true;
      if (_emojiController.text != chore!.emoji) edited = true;
    }
    print(edited);
    if (edited) {
      final save = await confirmSaveDialog(context);
      if (save != null && save) {
        print('saving');
        // User wants to save!
        // update existing chore
        Chore updatedChore = Chore.update(
          old: chore!,
          name: _nameController.text,
          emoji: _emojiController.text,
          description: "",
        );
        if (!context.mounted) return;
        // update chore!
        Provider.of<DivvyProvider>(
          context,
          listen: false,
        ).updateChore(updatedChore);
        Navigator.of(context).pop();
      } else {
        if (!context.mounted) return;
        Navigator.of(context).pop();
      }
    } else {
      Navigator.of(context).pop();
    }
  }
}

//////////////////////// Misc Util ////////////////////////

enum AssigneeSelection { member, subgroup, house }

extension AssigneeSelectionInfo on AssigneeSelection {
  String get name => switch (this) {
    AssigneeSelection.member => 'Member',
    AssigneeSelection.subgroup => 'Subgroup',
    AssigneeSelection.house => 'Whole house',
  };
}

/// Returns true if inputted string is an emoji
bool isEmoji(String text) {
  if (text.isEmpty) return false;
  return allEmojis[text] != null;
}

/// Gets an appropriate string for a frequency
String getFrequencyName(Frequency freq) => switch (freq) {
  Frequency.daily => 'Daily',
  Frequency.weekly => 'Weekly',
  Frequency.monthly => 'Monthly',
};
