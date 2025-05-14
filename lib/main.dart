import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:divvy/divvy_navigation.dart';
import 'package:divvy/firebase_options.dart';
import 'package:divvy/models/house.dart';
import 'package:divvy/models/user.dart';
import 'package:divvy/providers/divvy_provider.dart';
import 'package:divvy/screens/join_house.dart';
import 'package:divvy/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
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
      create: (_) => DivvyProvider(),
      child: MaterialApp(home: AuthWrapper()),
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
          final user = FirebaseAuth.instance.currentUser!;
          return FutureBuilder<HouseID>(
            future: getUserHouse(user.uid),
            builder: (context, asyncSnapshot) {
              if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CupertinoActivityIndicator(color: Colors.white),
                );
              }
              if (asyncSnapshot.hasError) {
                return Center(child: Text('Error checking user house.'));
              }
              final houseID = asyncSnapshot.data ?? '';
              final isInHouse = houseID.isNotEmpty;
              // Return join house screen if user is not in house
              if (isInHouse) {
                // initialize provider with house data
                final provider = Provider.of<DivvyProvider>(
                  context,
                  listen: false,
                );
                provider.initialize(houseID: asyncSnapshot.data!);
                // push nav screen
                return DivvyNavigation();
              } else {
                // user is not member of house
                return JoinHouse();
              }
            },
          );
        } else {
          // User is not signed in, show Login screen
          return Login();
        }
      },
    );
  }

  /// Returns user's houseID or empty string if no id
  Future<String> getUserHouse(String uid) async {
    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .withConverter(
              fromFirestore: DivvyUser.fromFirestore,
              toFirestore: (DivvyUser user, _) => user.toFirestore(),
            )
            .get();

    final user = userDoc.data();
    if (user == null) return '';
    return user.houseID;
  }
}
