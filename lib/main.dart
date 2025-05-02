import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/screens/calendar.dart';
import 'package:divvy/screens/chores.dart';
import 'package:divvy/screens/dashboard.dart';
import 'package:divvy/screens/house.dart';
import 'package:divvy/screens/settings.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBarExample(),
      ),
    );
  }
}

class BottomNavigationBarExample extends StatefulWidget {
  const BottomNavigationBarExample({super.key});

  @override
  State<BottomNavigationBarExample> createState() =>
      _BottomNavigationBarExampleState();
}

class _BottomNavigationBarExampleState
    extends State<BottomNavigationBarExample> {
  int _selectedIndex = 2;
  static const TextStyle optionStyle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
  );
  static const List<Widget> _widgetOptions = <Widget>[
    Calendar(),
    Chores(),
    Dashboard(),
    House(),
    Settings(),
  ];
  final List<Widget> _titles = <Widget>[
    Text('Calendar', style: DivvyTheme.screenTitle),
    Text('Chores', style: DivvyTheme.screenTitle),
    Text('Divvy', style: DivvyTheme.screenTitle),
    Text('House', style: DivvyTheme.screenTitle),
    Text('Settings', style: DivvyTheme.screenTitle),
  ];

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
        actions: [
          Container(
            height: 50,
            width: 50,
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.notifications),
          ),
        ],
      ),
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
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
    );
  }
}
