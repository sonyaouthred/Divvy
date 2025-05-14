import 'dart:convert';

import 'package:divvy/divvy_navigation.dart';
import 'package:divvy/firebase_options.dart';
import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/models/house.dart';
import 'package:divvy/models/user.dart';
import 'package:divvy/providers/divvy_provider.dart';
import 'package:divvy/screens/join_house.dart';
import 'package:divvy/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
          return FutureBuilder<HouseID>(
            future: getUserHouse(user.uid),
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
              final houseID = asyncSnapshot.data ?? '';
              final isInHouse = houseID.isNotEmpty;
              if (isInHouse) {
                // Return regular house app
                return ChangeNotifierProvider(
                  create: (_) => DivvyProvider(asyncSnapshot.data!),
                  child: MaterialApp(home: DivvyNavigation()),
                );
              } else {
                // Return join house screen if user is not in house
                return MaterialApp(home: JoinHouse());
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

  /// Returns user's houseID or empty string if no id
  Future<String> getUserHouse(String uid) async {
    try {
      final uri = 'http://127.0.0.1:5000/get-user-$uid';
      final headers = {'Content-Type': 'application/json'};
      final response = await get(Uri.parse(uri), headers: headers);
      final jsonData = json.decode(response.body);
      final userData = DivvyUser.fromJson(jsonData);
      return userData.houseID;
    } catch (e) {
      return '';
    }
  }
}
