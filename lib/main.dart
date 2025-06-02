import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:divvy/divvy_navigation.dart';
import 'package:divvy/firebase_options.dart';
import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/models/user.dart';
import 'package:divvy/providers/divvy_provider.dart';
import 'package:divvy/screens/join_house.dart';
import 'package:divvy/screens/login.dart';
import 'package:divvy/util/notifications_utils.dart';
import 'package:divvy/util/route_generator.dart';
import 'package:divvy/util/server_util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationsUtils().configuration();
  // Initialize the firebase app
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const AuthWrapper());
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
          final user = FirebaseAuth.instance.currentUser!;
          return FutureBuilder<DivvyUser?>(
            future: fetchUser(user.uid),
            builder: (context, asyncSnapshot) {
              if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  color: DivvyTheme.background,
                  child: Center(
                    child: CupertinoActivityIndicator(color: Colors.black),
                  ),
                );
              }
              if (asyncSnapshot.hasError) {
                return Center(child: Text('Error checking user house.'));
              }
              final DivvyUser? divvyUser = asyncSnapshot.data;
              if (divvyUser == null) {
                // log user out
                // this really should never be triggered
                FirebaseAuth.instance.signOut();
                return MaterialApp(home: Login());
              }
              final isInHouse = divvyUser.houseID != '';
              if (isInHouse) {
                // Return regular house app
                return HouseApp(user: divvyUser);
              } else {
                // Return join house screen if user is not in house
                return MaterialApp(home: JoinHouse(currUser: divvyUser));
              }
            },
          );
        } else {
          // User is not signed in, show Login screen
          return MaterialApp(home: Login());
        }
      },
    );
  }
}

/// Wraps the navigation app in a provider.
class HouseApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final DivvyUser user;
  const HouseApp({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DivvyProvider(user),
      child: MaterialApp(//home: DivvyNavigation(),
      initialRoute: '/',
      navigatorKey: navigatorKey,
      onGenerateRoute: RouteGenerator.generatorRoute,),
    );
  }
}
