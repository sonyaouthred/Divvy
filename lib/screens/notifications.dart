import 'package:divvy/models/chore.dart';
import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/providers/divvy_provider.dart';
import 'package:divvy/screens/chore_superclass_screen.dart';
import 'package:divvy/util/date_funcs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Displays the user's current notifications.
/// Not currently functional as we don't have the notifications
/// service set up.
class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  late List<ChoreInst> _notificaions; 

  @override
  void initState() {
    super.initState();
    final provRef = Provider.of<DivvyProvider>(context, listen: false);
    _notificaions = provRef.notifications.where((chore) => dayIsBefore(chore.dueDate, DateTime.now())).toList();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final spacing = width * 0.05;
    return Scaffold(
      backgroundColor: DivvyTheme.background,
      appBar: AppBar(
        title: Text('Notifications', style: DivvyTheme.screenTitle),
        centerTitle: true,
        scrolledUnderElevation: 0,
        backgroundColor: DivvyTheme.background,

        actions: [
          // Clear notifications button
          InkWell(
            // TODO: implement
            onTap: () => {
              Provider.of<DivvyProvider>(context, listen: false).clearNotificaitons()
            },
            child: Container(
              height: 50,
              padding: EdgeInsets.only(right: 20),
              child: Center(
                child: Text('Clear', style: DivvyTheme.smallBodyRed),
              ),
            ),
          ),
        ],
      ),
      body: _notificaions.isEmpty ? 
      Text('You have no notifications', style: DivvyTheme.bodyBoldGrey) :
        ListView.builder(
          itemCount: _notificaions.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            // Render the member's profile picture and name
            ChoreInst inst = _notificaions[index];
            Chore? superChore = Provider.of<DivvyProvider>(context, listen: false).getSuperChore(inst.superID);
            return InkWell(
              onTap: () => _goToSuperChore(superChore!),
              child: Padding(
      padding: EdgeInsets.symmetric(vertical: spacing / 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // render due date
          if (inst != null)
            Text(
              '${getNameOfWeekday(inst!.dueDate.weekday)}, ${DateFormat.yMMMMd('en_US').format(inst!.dueDate)}',
              style: DivvyTheme.smallBodyGrey,
            ),
          SizedBox(height: spacing / 4),
          Padding(
            padding: EdgeInsets.only(left: spacing / 4),
            child: Row(
              children: [
                // name, emoji of chore
                Flexible(
                  flex: 7,
                  child: Row(
                    children: [
                      Text(superChore!.emoji, style: TextStyle(fontSize: 20)),
                      SizedBox(width: spacing / 2),
                      Text(
                        'This is your reminder that ${superChore!.name} is due today!',
                        style: DivvyTheme.bodyBlack,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Display chevron icon
                // Display chevron icon
                Flexible(
                  flex: 1,
                  child:
                      Icon(
                        CupertinoIcons.chevron_right,
                        color: DivvyTheme.lightGrey,
                        size: 20,
                      ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
          },
      ),
    );
  }
  
  void _goToSuperChore(Chore superChore){
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => ChoreSuperclassScreen(choreID: superChore.id),
      ),
    );
  }
}
