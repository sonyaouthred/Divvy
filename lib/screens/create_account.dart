import 'package:divvy/firebase/auth_service.dart';
import 'package:divvy/main.dart';
import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/util/dialogs.dart';
import 'package:divvy/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';

/// Allows a user to create account.
class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  /// Store the width of the image dynamically
  double? imageWidth;

  /// True if user wants password input displayed as ***
  late bool _hidePassword;

  /// Either red or null depending on error status of name input box.
  late Color? _nameBorderColor;

  /// Either red or null depending on error status of email input box.
  late Color? _emailBorderColor;

  /// Either red or null depending on error status of password input boxes.
  late Color? _passwordBorderColor;

  /// Error message describing error related to email input.
  late String _emailError;

  /// Error message describing error related to password input.
  late String _passwordError;

  /// TextEditingControllers
  late TextEditingController _name;
  late TextEditingController _email;
  late TextEditingController _password;
  late TextEditingController _password2;

  /// Allows action buttons to be disabled after user has started account
  /// creation process.
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    // Initialize TextEditingControllers.
    _name = TextEditingController();
    _email = TextEditingController(text: '');
    _password = TextEditingController();
    _password2 = TextEditingController();
    // All error fields are initialized to no error.
    _emailError = '';
    _passwordError = '';
    _hidePassword = true;
    _nameBorderColor = null;
    _emailBorderColor = null;
    _passwordBorderColor = null;
  }

  /// Dispose of the text editing controllers.
  @override
  void dispose() {
    super.dispose();
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _password2.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
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
                  Center(child: Text('Divvy', style: DivvyTheme.screenTitle)),
                  SizedBox(height: spacing),
                  Text('Welcome!', style: DivvyTheme.bodyBlack),
                  SizedBox(height: spacing / 4),
                  Text('Create an account', style: DivvyTheme.largeHeaderBlack),
                  SizedBox(height: spacing / 2),
                  Text('Name', style: DivvyTheme.bodyBlack),
                  SizedBox(height: spacing / 3),
                  Container(
                    height: 50,
                    decoration: DivvyTheme.standardBox.copyWith(
                      border: Border.all(
                        color: _nameBorderColor ?? Colors.transparent,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: TextFormField(
                      readOnly: _creating,
                      controller: _name,
                      autocorrect: false,
                      decoration: InputDecoration(border: InputBorder.none),
                    ),
                  ),
                  SizedBox(height: spacing / 2),
                  // Email input
                  Text('Email', style: DivvyTheme.bodyBlack),
                  SizedBox(height: spacing / 3),
                  _showEmailInput(spacing),
                  SizedBox(height: spacing / 2),
                  // Password 1 input
                  Text('Password', style: DivvyTheme.bodyBlack),
                  SizedBox(height: spacing / 3),
                  _showPasswordInput(spacing, true),
                  SizedBox(height: spacing / 2),
                  // Password 2 input
                  Text('Re-enter your password', style: DivvyTheme.bodyBlack),
                  SizedBox(height: spacing / 3),
                  _showPasswordInput(spacing, false),
                  SizedBox(height: spacing),
                  // Create account button
                  InkWell(
                    onTap: () => _registerUser(context),
                    child: Container(
                      alignment: Alignment.center,
                      height: 50,
                      decoration: DivvyTheme.standardBox.copyWith(
                        color: DivvyTheme.darkGreen,
                      ),
                      child:
                          _creating
                              ? CupertinoActivityIndicator(
                                color: DivvyTheme.background,
                              )
                              : Text(
                                'Create Account',
                                style: DivvyTheme.smallBoldMedWhite,
                              ),
                    ),
                  ),
                  SizedBox(height: spacing * 2),
                  _loginText(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Shows the password input box & updates local fields as necessary.
  /// Only shows error text if it's the top password input (isInitialInput = true).
  /// Disables field when user is creating account.
  Widget _showPasswordInput(double spacing, bool isInitialInput) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 50,
          decoration: DivvyTheme.standardBox.copyWith(
            border: Border.all(
              color: _passwordBorderColor ?? Colors.transparent,
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 5,
                child: TextFormField(
                  readOnly: _creating,
                  controller: isInitialInput ? _password : _password2,
                  autocorrect: false,
                  obscureText: _hidePassword,
                  decoration: InputDecoration(border: InputBorder.none),
                ),
              ),
              Flexible(
                flex: 1,
                child: InkWell(
                  onTap: () => setState(() => _hidePassword = !_hidePassword),
                  child: SizedBox(
                    width: 45,
                    height: 45,
                    child: Icon(
                      _hidePassword
                          ? CupertinoIcons.eye_slash_fill
                          : CupertinoIcons.eye_fill,
                      size: 20,
                      color: DivvyTheme.lightGrey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        _passwordBorderColor != null && isInitialInput
            ? Padding(
              padding: EdgeInsets.only(top: spacing / 4),
              child: Text(_passwordError, style: DivvyTheme.smallBodyRed),
            )
            : Container(),
      ],
    );
  }

  /// Shows the eamil text input box. displays errors if any are present.
  /// Read-only after user has hit "create account".
  Widget _showEmailInput(double spacing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 50,
          decoration: DivvyTheme.standardBox.copyWith(
            border: Border.all(color: _emailBorderColor ?? Colors.transparent),
          ),
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: TextFormField(
            readOnly: _creating,
            controller: _email,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp('[0-9@a-zA-Z.]')),
            ],
            autocorrect: false,
            autovalidateMode: AutovalidateMode.always,
            decoration: InputDecoration(border: InputBorder.none),
          ),
        ),
        // show error mesage, if needed
        _emailBorderColor != null
            ? Padding(
              padding: EdgeInsets.only(top: spacing / 8),
              child: Text(_emailError, style: DivvyTheme.smallBodyRed),
            )
            : Container(),
      ],
    );
  }

  /// Renders the login text
  Widget _loginText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Not yet registered?', style: DivvyTheme.bodyBlack),
        InkWell(
          highlightColor: Colors.transparent,
          onTap: () => _openLogin(context),
          child: Container(
            alignment: Alignment.centerLeft,
            height: 50,
            child: Text(
              'Login',
              style: DivvyTheme.bodyBlack.copyWith(
                color: Colors.transparent,
                shadows: [
                  Shadow(offset: Offset(0, -5), color: DivvyTheme.black),
                ],
                decoration: TextDecoration.underline,
                decorationThickness: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  ////////////////////////////// Util Functions ///////////////////////////////

  /// Opens the login screen
  void _openLogin(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageTransition(
        type: PageTransitionType.fade,
        childBuilder: (context) => Login(),
        duration: Duration(milliseconds: 100),
      ),
    );
  }

  // Run the logic to make sure all the inputted fields are OK
  void _registerUser(BuildContext context) async {
    setState(() {
      _creating = true;
    });
    // True if email is valid
    final emailValid = validateEmail(_email.text) == null;
    final pwdsMatch = _password.text == _password2.text;
    if (emailValid &&
        _email.text != '' &&
        pwdsMatch &&
        _name.text != '' &&
        _password.text.length >= 6) {
      // input is valid
      setState(() {
        _nameBorderColor = null;
        _emailBorderColor = null;
        _passwordBorderColor = null;
      });
      // Now query the authorization service
      final result = await AuthService().registration(
        email: _email.text,
        password: _password.text,
      );
      // Interpret result
      if (result!.contains('Success')) {
        if (!context.mounted) {
          return;
        }
        // Success! create database.
        _createUserDB(context);
      } else if (result == 'The password provided is too weak.') {
        setState(() {
          _passwordBorderColor = DivvyTheme.darkRed;
          _passwordError = result;
          _creating = false;
        });
      } else if (result == 'The account already exists for that email.') {
        setState(() {
          _emailBorderColor = DivvyTheme.darkRed;
          _emailError = 'An account already exists for this email.';
          _creating = false;
        });
      }
    } else {
      // If any input is invalid, reflect in UI
      setState(() {
        _creating = false;
        if (!emailValid || _email.text == '') {
          _emailBorderColor = DivvyTheme.darkRed;
          _emailError = 'Please enter a valid email.';
        } else {
          _emailBorderColor = null;
          _emailError = '';
        }
        if (!pwdsMatch) {
          _passwordBorderColor = DivvyTheme.darkRed;
          _passwordError = 'Please make sure your passwords match.';
        } else if (_password.text.length < 6) {
          _passwordBorderColor = DivvyTheme.darkRed;
          _password2.clear();
          _passwordError = 'Passwords must be longer than 6 characters.';
        } else {
          _passwordBorderColor = null;
        }
        if (_name.text == '') {
          _nameBorderColor = DivvyTheme.darkRed;
        } else {
          _nameBorderColor = null;
        }
      });
    }
  }

  /// Will need to create the user's Firestore database, after their
  /// auth account has been set up.
  void _createUserDB(BuildContext context) async {
    try {
      // // Create the user with email and password
      // final User user = FirebaseAuth.instance.currentUser!;

      // // Reference to the Firestore Users collection
      // final usersRef = FirebaseFirestore.instance.collection('Users');

      // // Create a new document with the user's UID as the document ID
      // await usersRef.doc(user.email).set({
      //   'uid': user.uid,
      //   'name': _name.text,
      //   'org': 'University of Washington',
      //   'createdAt': FieldValue.serverTimestamp(),
      // });

      // // Set user's fields
      // await user.updateDisplayName(_name.text);

      // Sign in!!
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text,
        password: _password.text,
      );
      if (!context.mounted) return;

      // Triggers AuthWrapper reload. Not sure why logging in doesn't
      // do it automatically here.
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
        (route) => false, // Clears the navigation stack
      );
    } catch (e) {
      showErrorMessage(context, 'Error', 'Error creating user: $e');
    }
  }
}
