import 'package:divvy/firebase_options.dart';
import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/providers/divvy_provider.dart';
import 'package:divvy/screens/calendar.dart';
import 'package:divvy/screens/chores.dart';
import 'package:divvy/screens/dashboard.dart';
import 'package:divvy/screens/house_screen.dart';
import 'package:divvy/screens/login.dart';
import 'package:divvy/screens/notifications.dart';
import 'package:divvy/screens/settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the firebase app
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // dummy current user is Tony Stark
      create: (_) => DivvyProvider(currentUserID: '24889rhgksje'),
      child: MaterialApp(
        home: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: AuthWrapper(),
        ),
      ),
    );
  }
}

/// Ensures that login is shown when the user is not signed in.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Listen for auth state changes
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          // User is signed in
          // final user = snapshot.data;
          // user database is under their email
          // final userDb = FirebaseFirestore.instance.doc('Users/${user!.email}');
          // final userPathReference =
          //     FirebaseStorage.instance.ref().child(user.email!);

          // final workbookProvider =
          //     Provider.of<WorkbookProvider>(context, listen: false);

          // workbookProvider.initialize(
          //     userDB: userDb, usrImgs: userPathReference);

          // Provide the user-specific WorkbookProvider at the top level
          return Navigation();
        } else {
          // User is not signed in, show Login screen
          return Login();
        }
      },
    );
  }
}

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _selectedIndex = 2;
  static const List<Widget> _widgetOptions = <Widget>[
    Calendar(),
    Chores(),
    Dashboard(),
    House(),
    Settings(),
  ];
  late final List<Widget> _titles;
  late final String _houseName;

  @override
  void initState() {
    super.initState();
    _houseName = Provider.of<DivvyProvider>(context, listen: false).houseName;
    _titles = <Widget>[
      Text('Calendar', style: DivvyTheme.screenTitle),
      Text('Chores', style: DivvyTheme.screenTitle),
      Text('Divvy', style: DivvyTheme.screenTitle),
      Text(_houseName, style: DivvyTheme.screenTitle),
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
              child: Icon(Icons.notifications),
            ),
          ),
        ],
      ),
      body: Container(
        color: DivvyTheme.background,
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
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
    );
  }

  // Opens the notifications page
  void _openNotificationsPage(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => Notifications()));
  }
}
