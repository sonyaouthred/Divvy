import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/providers/divvy_provider.dart';

import 'package:divvy/screens/login.dart';
import 'package:divvy/screens/notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:divvy/screens/settings.dart';
import 'package:divvy/screens/calendar.dart';
import 'package:divvy/screens/chores.dart';
import 'package:divvy/screens/dashboard.dart';
import 'package:divvy/screens/house_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

/// Handles bottom navigation flow for the app
class DivvyNavigation extends StatefulWidget {
  const DivvyNavigation({super.key});

  @override
  State<DivvyNavigation> createState() => _DivvyNavigationState();
}

class _DivvyNavigationState extends State<DivvyNavigation> {
  int _selectedIndex = 2;
  static const List<Widget> _widgetOptions = <Widget>[
    Calendar(),
    Chores(),
    Dashboard(),
    House(),
    Settings(),
  ];
  late final List<Widget> _titles;
  bool dataLoaded = false;

  @override
  void initState() {
    super.initState();
    _titles = <Widget>[
      Text('Calendar', style: DivvyTheme.screenTitle),
      Text('Chores', style: DivvyTheme.screenTitle),
      Text('Divvy', style: DivvyTheme.screenTitle),
      Text('House', style: DivvyTheme.screenTitle),
      Text('Settings', style: DivvyTheme.screenTitle),
    ];
    dataLoaded = Provider.of<DivvyProvider>(context, listen: false).dataLoaded;
  }

  // sets the item tapped as the screen to be displayed
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    dataLoaded = Provider.of<DivvyProvider>(context, listen: true).dataLoaded;
    if (FirebaseAuth.instance.currentUser == null) {
      Navigator.of(context).pushReplacement(
        PageTransition(
          type: PageTransitionType.fade,
          child: Login(),
          duration: Duration(milliseconds: 100),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: _titles[_selectedIndex],
        centerTitle: true,
        scrolledUnderElevation: 0,
        backgroundColor: DivvyTheme.background,
        actions: [
          InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: () => _openNotificationsPage(context),
            child: Container(
              height: 50,
              width: 50,
              padding: EdgeInsets.only(right: 20),
              child: Icon(Icons.notifications, color: DivvyTheme.darkGreen),
            ),
          ),
        ],
      ),
      body: Container(
        color: DivvyTheme.background,
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Theme(
        // make sure there's no splash
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          backgroundColor: DivvyTheme.background,
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Calendar',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Chores'),
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_rounded),
              label: 'House',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: DivvyTheme.mediumGreen,
          unselectedItemColor: DivvyTheme.lightGrey,
          onTap: dataLoaded ? _onItemTapped : null,
        ),
      ),
    );
  }

  // Opens the notifications page
  void _openNotificationsPage(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => Notifications()));
  }
}
