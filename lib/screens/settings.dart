import 'package:divvy/models/member.dart';
import 'package:divvy/screens/join_house.dart';
import 'package:divvy/screens/login.dart';
import 'package:divvy/util/dialogs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/providers/divvy_provider.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

/// Displays a settings screen where the user can modify account
/// settings and leave house/other functions.
class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  // Current user's data
  late Member _currUser;
  bool themeSwitch = true;

  /// show loading indicator when user is logging out
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    final providerRef = Provider.of<DivvyProvider>(context, listen: false);
    _currUser = providerRef.currMember;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final spacing = width * 0.05;
    if (FirebaseAuth.instance.currentUser == null) {
      // Ensure no null fields are referenced
      return Container();
    }
    return SizedBox.expand(
      child: Container(
        padding: EdgeInsets.all(spacing),
        child: SingleChildScrollView(
          child: Consumer<DivvyProvider>(
            builder: (context, provider, child) {
              // Live update data from consumer
              _currUser = provider.currMember;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Display user's profile image
                  _imageSelectionButton(provider, width, spacing),
                  SizedBox(height: spacing),
                  // Greet user
                  _introPhrase(name: _currUser.name),
                  SizedBox(height: spacing),
                  // Display various settings
                  // Account settings
                  _infoSections(
                    icon: Icon(CupertinoIcons.person_crop_circle),
                    text: 'Account Info',
                    buttons: [
                      ['Change Name', _changeName],
                      ['Delete Account', _deleteAccount],
                    ],
                    flex: 2,
                    spacing: spacing,
                  ),
                  SizedBox(height: spacing / 2),
                  // Social/house settings
                  _infoSections(
                    icon: Icon(Icons.house_outlined),
                    text: 'House',
                    buttons: [
                      ['Leave House', _leaveHouse],
                    ],
                    flex: 2,
                    spacing: spacing,
                  ),
                  SizedBox(height: spacing / 2),
                  // App settings
                  _infoSections(
                    icon: Icon(Icons.settings_outlined),
                    text: 'Settings',
                    buttons: [
                      ['Appearance', null],
                    ],
                    flex: 1,
                    spacing: spacing,
                  ),
                  // Logout button
                  _logoutButton(),
                  SizedBox(height: spacing),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  ///////////////////////////// Widgets /////////////////////////////

  /// Displays the user's profile picture and the upload image
  /// icon. Entire area is tappable.
  Widget _imageSelectionButton(
    DivvyProvider provider,
    double width,
    double spacing,
  ) {
    final imageSize = width / 3;
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () async {
        await _changeColor(context, provider);
      },
      child: Stack(
        children: [
          _profileImage(imageSize),
          // Image icon
          Positioned(
            bottom: 5,
            right: 5,
            child: Container(
              decoration: DivvyTheme.circleWhite,
              height: 35,
              width: 35,
              child: Icon(
                Icons.camera_alt_outlined,
                color: DivvyTheme.lightGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Displays the user's profile image with the given size.
  Widget _profileImage(double imageSize) {
    return Container(
      width: imageSize,
      height: imageSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currUser.profilePicture.color,
      ),
    );
  }

  /// Displays greeting to user
  Widget _introPhrase({required String name}) {
    final email = FirebaseAuth.instance.currentUser!.email!;
    return Column(
      children: [
        Text('Hi, $name!', style: DivvyTheme.largeHeaderBlack),
        // show current user's email
        Text(email, style: DivvyTheme.bodyGrey),
      ],
    );
  }

  /// Displays account information sections
  /// Includes header, divider, and list of actions
  Widget _infoSections({
    required Icon icon,
    required String text,
    required List buttons,
    required int flex,
    required double spacing,
  }) {
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(padding: EdgeInsets.all(10.0), child: icon),
              Text(text, style: DivvyTheme.bodyBoldBlack),
            ],
          ),
          const Divider(color: DivvyTheme.altBeige, height: 1),
          SizedBox(height: spacing / 4),
          // Show relevant actions
          ListView.builder(
            itemCount: buttons.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              final entry = buttons[index];
              final appearanceSwitch = entry[1] == null;
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing / 2,
                  vertical: spacing * 0.45,
                ),
                child: InkWell(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  // Trigger the action
                  onTap:
                      () =>
                          !appearanceSwitch
                              ? entry[1](context)
                              : setState(() => themeSwitch = !themeSwitch),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry[0], style: DivvyTheme.bodyBlack),
                      if (!appearanceSwitch)
                        Icon(
                          CupertinoIcons.chevron_right,
                          color: DivvyTheme.lightGrey,
                          size: 15,
                        ),
                      if (appearanceSwitch)
                        // Show the appearance switcher
                        CupertinoSwitch(
                          value: themeSwitch,
                          onChanged: (bool? value) {
                            setState(() {
                              themeSwitch = value ?? false;
                            });
                          },
                          applyTheme: true,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Renders a logout button
  Widget _logoutButton() {
    return ElevatedButton(
      onPressed: () => _logout(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: DivvyTheme.darkRed,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        minimumSize: Size(100, 40),
      ),
      child:
          _isLoggingOut
              ? CupertinoActivityIndicator(color: DivvyTheme.background)
              : Text('Log Out', style: DivvyTheme.smallBoldMedWhite),
    );
  }

  ///////////////////////////// Util /////////////////////////////

  /// Change the house's name
  void _changeName(BuildContext context) async {
    // get new name
    final newName = await openInputDialog(
      context,
      title: 'Change Name',
      initText: _currUser.name,
    );
    // Process name
    if (newName != null) {
      if (!context.mounted) return;
      Provider.of<DivvyProvider>(
        context,
        listen: false,
      ).updateUserName(newName);
    }
  }

  /// Change the user's profile color
  Future<void> _changeColor(
    BuildContext context,
    DivvyProvider provider,
  ) async {
    final width = MediaQuery.of(context).size.width;
    final spacing = width * 0.05;
    // get new color
    final newColor = await openColorDialog(
      context,
      _currUser.profilePicture,
      spacing,
    );
    // Process color
    if (newColor != _currUser.profilePicture) {
      provider.updateMemberColor(newColor);
    }
  }

  /// Re-authenticate and delete account for email and password users.
  /// Must supply password parameter if user is an email user. Otherwise, can be null.
  void _deleteAccount(BuildContext context) async {
    final password = await openInputDialog(
      context,
      title: 'Re-enter password',
      hideText: true,
    );
    final user = FirebaseAuth.instance.currentUser;
    // Ensure user is not logged out (makes compiler happy)
    if (user == null) return;
    // Get user's username & password
    try {
      if (user.email != null) {
        // Now check what provider the user is signed in with.
        if (password != null) {
          // Reauthenticate user with email and password
          final credential = EmailAuthProvider.credential(
            email: user.email!,
            password: password,
          );
          await FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(
            credential,
          );
        }
        // Non-email/pwd clients are already reauthenticated
        if (!context.mounted) return;
        Provider.of<DivvyProvider>(context, listen: false).deleteMember();
      }
    } catch (e) {
      if (!context.mounted) return;
      showErrorMessage(context, 'Invalid password', 'Please try again!');
    }
  }

  /// Allow user to leave a house
  void _leaveHouse(BuildContext context) async {
    // Confirm user wants to leave the house
    final leave = await confirmDeleteDialog(
      context,
      'Leave house?',
      action: 'Leave',
    );
    if (leave != null && leave) {
      if (!context.mounted) return;
      final provider = Provider.of<DivvyProvider>(context, listen: false);
      provider.leaveHouse(_currUser.id);
      // Push join hosue screen
      Navigator.of(context).pushReplacement(
        PageTransition(
          type: PageTransitionType.fade,
          childBuilder: (context) => JoinHouse(currUser: provider.currUser),
          duration: Duration(milliseconds: 100),
        ),
      );
    }
  }

  // log the user out
  void _logout(BuildContext context) async {
    setState(() {
      _isLoggingOut = true;
    });
    FirebaseAuth.instance.signOut();
    // push login screen

    Navigator.of(context).pushReplacement(
      PageTransition(
        type: PageTransitionType.fade,
        child: Login(),
        duration: Duration(milliseconds: 100),
      ),
    );
  }
}
