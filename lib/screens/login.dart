import 'package:divvy/firebase/auth_service.dart';
import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/screens/create_account.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';

/// Allows a user to login with an exiting email and password combo.
/// Also allows them to sign in using a provider - Apple, Google.
/// The user can choose to navigate to the create account page if they don't
/// already have an account.
// TODO(bhoop2b): enable Microsoft authentication. Complicated, will need Azure dev account
class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  /// Store the width of the image dynamically
  double? imageWidth;

  /// True if the user wants password input to be displayed as ***
  late bool _hidePassword;

  /// Either red or null depending on error status of email input box.
  late Color? _emailBorderColor;

  /// Either red or null depending on error status of password input box.
  late Color? _passwordBorderColor;

  /// Controls email input text
  late TextEditingController _email;

  /// Controls password input text
  late TextEditingController _password;

  /// Stores any error messages associated with the password, or ''
  late String _passwordError;

  /// Stores any error messages associated with the email, or ''
  late String _emailError;

  /// True if user is currently signing in.
  bool _signingIn = false;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
    // Initialize all error fields to non-error state.
    _hidePassword = true;
    _emailBorderColor = null;
    _passwordBorderColor = null;
    _passwordError = '';
    _emailError = '';
  }

  /// Dispose of the text editing controllers.
  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
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
                  Text('Welcome back!', style: DivvyTheme.bodyBlack),
                  SizedBox(height: spacing / 4),
                  Text(
                    'Login to your account',
                    style: DivvyTheme.largeHeaderBlack,
                  ),
                  SizedBox(height: spacing),
                  // Email input
                  Text('Email', style: DivvyTheme.bodyBlack),
                  SizedBox(height: spacing / 3),
                  _showEmailInput(spacing),
                  SizedBox(height: spacing / 2),
                  // Password input
                  Text('Password', style: DivvyTheme.bodyBlack),
                  SizedBox(height: spacing / 3),
                  _showPasswordInput(spacing),
                  SizedBox(height: spacing),
                  // Login button
                  InkWell(
                    onTap: () => _login(context),
                    child: Container(
                      alignment: Alignment.center,
                      height: 50,
                      decoration: DivvyTheme.textInput.copyWith(
                        color: DivvyTheme.darkGreen,
                      ),
                      child:
                          _signingIn
                              ? CupertinoActivityIndicator(
                                color: DivvyTheme.white,
                              )
                              : Text(
                                'Login',
                                style: DivvyTheme.smallBoldMedWhite,
                              ),
                    ),
                  ),
                  SizedBox(height: spacing * 2),
                  _createAccountText(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  ////////////////////////////// Widgets ///////////////////////////////
  /// Shows the password text input box. displays errors if any are present.
  /// Read-only after user has hit "login".
  Widget _showPasswordInput(double spacing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 50,
          decoration: DivvyTheme.standardBox.copyWith(
            // show red border if there was an error
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
                  readOnly: _signingIn,
                  controller: _password,
                  autocorrect: false,
                  obscureText: _hidePassword,
                  decoration: InputDecoration(border: InputBorder.none),
                ),
              ),
              // Button to allow user to hide/show password
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
        // Show password error message if applicable
        _passwordBorderColor != null
            ? Padding(
              padding: EdgeInsets.only(top: spacing / 8),
              child: Text(_passwordError, style: DivvyTheme.smallBodyRed),
            )
            : SizedBox(height: spacing / 2),
      ],
    );
  }

  /// Shows the email text input box. displays errors if any are present.
  /// Read-only after user has hit "login".
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
            readOnly: _signingIn,
            controller: _email,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp('[0-9@a-zA-Z.]')),
            ],
            autocorrect: false,
            autovalidateMode: AutovalidateMode.always,
            decoration: InputDecoration(border: InputBorder.none),
          ),
        ),
        _emailBorderColor != null
            ? Padding(
              padding: EdgeInsets.only(top: spacing / 8),
              child: Text(_emailError, style: DivvyTheme.smallBodyRed),
            )
            : Container(),
      ],
    );
  }

  /// Renders the create an account text, allows user
  /// to tap and open the create account page
  Widget _createAccountText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Not yet registered?', style: DivvyTheme.bodyBlack),
        InkWell(
          highlightColor: Colors.transparent,
          onTap: () => _openCreateAccount(context),
          child: Container(
            alignment: Alignment.centerLeft,
            height: 50,
            child: Text(
              'Create an account',
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

  /// Opens the create account screen
  void _openCreateAccount(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageTransition(
        type: PageTransitionType.fade,
        child: CreateAccount(),
        duration: Duration(milliseconds: 100),
      ),
    );
  }

  // Validate login information, transition to the home screen if possible
  void _login(BuildContext context) async {
    setState(() {
      _signingIn = true;
    });
    // Ensure email is valid
    final emailValid = validateEmail(_email.text) == null;
    if (emailValid && _email.text != '') {
      // input is valid
      setState(() {
        _emailBorderColor = null;
        _passwordBorderColor = null;
      });
      // Now query the authorization service to sign user in
      final result = await AuthService().login(
        email: _email.text,
        password: _password.text,
      );
      // Interpret result if the user isn't automatically rerouted
      if (result != 'Success') {
        setState(() {
          _emailBorderColor = DivvyTheme.darkRed;
          _passwordBorderColor = DivvyTheme.darkRed;
          _passwordError = 'The email or password provided is incorrect.';
          _signingIn = false;
        });
      }
    } else {
      // If any input is invalid, reflect in UI
      setState(() {
        _passwordBorderColor = null;
        _emailBorderColor = DivvyTheme.darkRed;
        _emailError = 'Please enter a valid email.';
        _signingIn = false;
      });
    }
  }
}

/// Validates a string as an email. If string is not a valid email,
/// Returns null. Otherwise returns ''.
String? validateEmail(String? value) {
  const pattern =
      r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
      r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
      r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
      r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
      r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
      r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
      r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
  final regex = RegExp(pattern);

  return value!.isNotEmpty && !regex.hasMatch(value) ? '' : null;
}
