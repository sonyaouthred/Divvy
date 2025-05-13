import 'package:divvy/divvy_navigation.dart';
import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/screens/create_house.dart';
import 'package:divvy/screens/login.dart';
import 'package:divvy/util/dialogs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

/// Allows user to join a house using a unique six-digit code.
class JoinHouse extends StatefulWidget {
  const JoinHouse({super.key});

  @override
  State<JoinHouse> createState() => _JoinHouseState();
}

class _JoinHouseState extends State<JoinHouse> {
  late final String _email;
  late TextEditingController _codeController;
  bool _joining = false;
  @override
  void initState() {
    super.initState();
    _email = FirebaseAuth.instance.currentUser!.email ?? '';
    _codeController = TextEditingController();
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
  void _joinHouse(BuildContext context) {
    // TODO: obviously, replace with db call
    final inputValid = _codeController.text == 'lW611f30';
    if (inputValid) {
      setState(() {
        _joining = true;
      });
      // Update user's db with the code
      print('Adding user to house ${_codeController.text}');
      // Push user to home page
      Navigator.of(context).pushReplacement(
        PageTransition(
          type: PageTransitionType.fade,
          child: DivvyNavigation(),
          duration: Duration(milliseconds: 100),
        ),
      );
    } else {
      showErrorMessage(context, 'Invalid Code', 'This house doesn\'t exist.');
      return;
    }
  }

  /// Open create house page
  void _createHouse(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageTransition(
        type: PageTransitionType.fade,
        child: CreateHouse(),
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
