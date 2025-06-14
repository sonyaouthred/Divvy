import 'package:divvy/main.dart';
import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/models/user.dart';
import 'package:divvy/screens/create_house.dart';
import 'package:divvy/screens/login.dart';
import 'package:divvy/util/dialogs.dart';
import 'package:divvy/util/server_util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

/// Allows user to join a house using a unique six-digit code.
class JoinHouse extends StatefulWidget {
  final DivvyUser currUser;
  const JoinHouse({super.key, required this.currUser});

  @override
  State<JoinHouse> createState() => _JoinHouseState();
}

class _JoinHouseState extends State<JoinHouse> {
  // Email of the current user
  late final String _email;
  // Handle the inputted code
  late TextEditingController _codeController;
  // True if user is currently joining a house
  bool _joining = false;
  // The current signed in user.
  late final DivvyUser _currUser;
  @override
  void initState() {
    super.initState();
    _email = FirebaseAuth.instance.currentUser!.email ?? '';
    _codeController = TextEditingController();
    _currUser = widget.currUser;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final double spacing = width * 0.05;
    return Scaffold(
      backgroundColor: DivvyTheme.background,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Align(
            alignment: Alignment.center,
            child: SizedBox(
              // Add extra spacing on the bottom to make it easier to
              // enter text in fields
              height: height,
              width: width * 0.85,
              child: Column(
                // render text entry fields
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: spacing),
                  _headerText(spacing),
                  SizedBox(height: spacing),
                  _houseCodeInput(spacing, width),
                  SizedBox(height: spacing),
                  horizontalOrLine(spacing),
                  SizedBox(height: spacing),
                  Center(
                    child: InkWell(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: () => _createHouse(context),
                      child: SizedBox(
                        height: 50,
                        child: Text(
                          'Create a house!',
                          style: DivvyTheme.bodyBlack.copyWith(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // or logout
                  Center(
                    child: InkWell(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: () => _logout(context),
                      child: SizedBox(
                        height: 50,
                        child: Text(
                          'Log out',
                          style: DivvyTheme.bodyBlack.copyWith(
                            decoration: TextDecoration.underline,
                            color: DivvyTheme.darkRed,
                            decorationColor: DivvyTheme.darkRed,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Displays divvy logo & introduction text
  Widget _headerText(double spacing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: Text('Divvy', style: DivvyTheme.screenTitle)),
        SizedBox(height: spacing),
        Text('Hi, $_email!', style: DivvyTheme.bodyBlack),
        SizedBox(height: spacing / 4),
        Text(
          'It looks like you\'re not in a house yet.',
          style: DivvyTheme.largeHeaderBlack,
        ),
        SizedBox(height: spacing),
        Text(
          'Enter your house\'s code below to join.',
          style: DivvyTheme.bodyBlack,
        ),
      ],
    );
  }

  /// Renders prompt & code input box, along with join button
  Widget _houseCodeInput(double spacing, double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 50,
          decoration: DivvyTheme.textInput,
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: TextField(
            autocorrect: false,
            controller: _codeController,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter code....',
            ),
          ),
        ),
        SizedBox(height: spacing),
        Center(
          child: InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: () => _joinHouse(context),
            child: Container(
              alignment: Alignment.center,
              height: 50,
              width: width / 4,
              decoration: DivvyTheme.greenBox,
              child:
                  _joining
                      ? CupertinoActivityIndicator(color: DivvyTheme.background)
                      : Text('Join', style: DivvyTheme.largeBoldMedWhite),
            ),
          ),
        ),
      ],
    );
  }

  /// Join a house and push the home screen
  void _joinHouse(BuildContext context) async {
    try {
      setState(() {
        _joining = true;
      });
      // Try to add user to house
      final house = await addUserToHouse(_currUser, _codeController.text);
      if (!context.mounted) return;
      if (house == null) {
        // handle errors in adding user
        showErrorMessage(
          context,
          'Error',
          'Could not join house. Check that you have the correct join code.',
        );
      }
      // Push user to home page
      if (!context.mounted) return;
      Navigator.of(context).pushReplacement(
        PageTransition(
          type: PageTransitionType.fade,
          child: HouseApp(user: _currUser),
          duration: Duration(milliseconds: 100),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  /// Open create house page
  void _createHouse(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageTransition(
        type: PageTransitionType.fade,
        child: CreateHouse(currUser: _currUser),
        duration: Duration(milliseconds: 100),
      ),
    );
  }

  // log the user out
  void _logout(BuildContext context) async {
    FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      PageTransition(
        type: PageTransitionType.fade,
        child: Login(),
        duration: Duration(milliseconds: 100),
      ),
    );
  }
}

/// Shows 'or' surrounded by a horizontal divider.
Padding horizontalOrLine(double spacing) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: spacing),
    child: Row(
      children: [
        Flexible(flex: 2, child: Container(height: 1, color: Colors.grey)),
        Flexible(
          flex: 1,
          child: Container(
            alignment: Alignment.center,
            child: Text('or', style: DivvyTheme.bodyBlack),
          ),
        ),
        Flexible(flex: 2, child: Container(height: 1, color: Colors.grey)),
      ],
    ),
  );
}
