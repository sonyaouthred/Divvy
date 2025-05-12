import 'package:divvy/divvy_navigation.dart';
import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/screens/join_house.dart';
import 'package:divvy/util/dialogs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

/// Allows user to join a house using a unique six-digit code.
class CreateHouse extends StatefulWidget {
  const CreateHouse({super.key});

  @override
  State<CreateHouse> createState() => _CreateHouseState();
}

class _CreateHouseState extends State<CreateHouse> {
  late final String _email;
  late TextEditingController _nameController;
  @override
  void initState() {
    super.initState();
    _email = FirebaseAuth.instance.currentUser!.email ?? '';
    _nameController = TextEditingController();
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
                  _createHouseInput(spacing, width),
                  SizedBox(height: spacing),
                  horizontalOrLine(spacing),
                  SizedBox(height: spacing),
                  Center(
                    child: InkWell(
                      onTap: () => _joinHouse(context),
                      child: SizedBox(
                        height: 50,
                        child: Text(
                          'Join a house!',
                          style: DivvyTheme.bodyBlack.copyWith(
                            decoration: TextDecoration.underline,
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
          'Create a house to get started.',
          style: DivvyTheme.largeHeaderBlack,
        ),
      ],
    );
  }

  /// Renders prompt, house name input, and create house button
  Widget _createHouseInput(double spacing, double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('First, enter your house\'s name!', style: DivvyTheme.bodyBlack),
        SizedBox(height: spacing),
        Container(
          height: 50,
          decoration: DivvyTheme.textInput,
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: TextField(
            autocorrect: false,
            controller: _nameController,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter name...',
            ),
          ),
        ),
        SizedBox(height: spacing * 2),
        Center(
          child: InkWell(
            onTap: () => _createHouse(context),
            child: Container(
              alignment: Alignment.center,
              height: 50,
              width: width / 4,
              decoration: DivvyTheme.greenBox,
              child: Text('Create', style: DivvyTheme.largeBoldMedWhite),
            ),
          ),
        ),
      ],
    );
  }

  /// Create a house and push the home screen
  void _createHouse(BuildContext context) async {
    if (_nameController.text.isEmpty) {
      await showErrorMessage(
        context,
        'Invalid name',
        'Please enter a name for your house!',
      );
      return;
    }
    // TODO: obviously, replace with db call
    // Update user's db with the code
    print('Creating house ${_nameController.text}');
    // Push user to home page
    Navigator.of(context).pushReplacement(
      PageTransition(
        type: PageTransitionType.fade,
        child: DivvyNavigation(),
        duration: Duration(milliseconds: 100),
      ),
    );
  }

  /// Push the join house page
  void _joinHouse(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageTransition(
        type: PageTransitionType.fade,
        child: JoinHouse(),
        duration: Duration(milliseconds: 100),
      ),
    );
  }
}
