import 'package:divvy/divvy_navigation.dart';
import 'package:divvy/firebase_options.dart';
import 'package:divvy/providers/divvy_provider.dart';
import 'package:divvy/screens/login.dart';
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
          /// TODO: uncomment below code & replace with logic to see if user is in house
          // final userIsInHouse = false;
          // if (userIsInHouse) {
          return DivvyNavigation();
          // } else {
          // return JoinHouse();
          // }
        } else {
          // User is not signed in, show Login screen
          return Login();
        }
      },
    );
  }
}
