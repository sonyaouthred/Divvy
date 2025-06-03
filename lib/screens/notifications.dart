import 'package:divvy/models/divvy_theme.dart';
import 'package:flutter/material.dart';

/// Displays the user's current notifications.
/// Not currently functional as the notifications service
/// is not complete.
class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DivvyTheme.background,
      appBar: AppBar(
        title: Text('Notifications', style: DivvyTheme.screenTitle),
        centerTitle: true,
        scrolledUnderElevation: 0,
        backgroundColor: DivvyTheme.background,

        actions: [
          // Clear notifications button
          Container(
            height: 50,
            padding: EdgeInsets.only(right: 20),
            child: Center(child: Text('Clear', style: DivvyTheme.smallBodyRed)),
          ),
        ],
      ),
      body: Center(
        child: Text('No recent notifications!', style: DivvyTheme.bodyGrey),
      ),
    );
  }
}
