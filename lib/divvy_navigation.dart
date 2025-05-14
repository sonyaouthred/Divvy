import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/screens/notifications.dart';
import 'package:flutter/material.dart';
import 'package:divvy/screens/settings.dart';
import 'package:divvy/screens/calendar.dart';
import 'package:divvy/screens/chores.dart';
import 'package:divvy/screens/dashboard.dart';
import 'package:divvy/screens/house_screen.dart';

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
  }

  // sets the item tapped as the screen to be displayed
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _titles[_selectedIndex],
        centerTitle: true,
        scrolledUnderElevation: 0,
        backgroundColor: DivvyTheme.background,
        actions: [
          InkWell(
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
          onTap: _onItemTapped,
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
