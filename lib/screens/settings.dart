import 'package:divvy/models/member.dart';
import 'package:divvy/screens/chores.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:divvy/models/divvy_theme.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:divvy/providers/divvy_provider.dart';
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
  late final Member _currUser;
  // Current user's profile image
  File? imageFile;
  // Used to allow user to pull their profile image
  final picker = ImagePicker();

  bool themeSwitch = true;

  @override
  void initState() {
    super.initState();
    final providerRef = Provider.of<DivvyProvider>(context, listen: false);
    _currUser = providerRef.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final spacing = width * 0.05;
    return SizedBox.expand(
      child: Container(
        padding: EdgeInsets.all(spacing),
        child: SingleChildScrollView(
          child: Consumer<DivvyProvider>(
            builder: (context, provider, child) {
              // Live update data from consumer
              _currUser = provider.currentUser;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Display user's profile image
                  _imageSelectionButton(width),
                  SizedBox(height: spacing),
                  // Greet user
                  _introPhrase(name: _currUser.name),
                  // Display various settings
                  // Account settings
                  _infoSections(
                    icon: Icon(CupertinoIcons.person_crop_circle),
                    text: 'Account Info',
                    buttons: [
                      ['Change Name', _openChoresScreen],
                      ['Reset Password', _openChoresScreen],
                      ['Delete Account', _openChoresScreen],
                    ],
                    flex: 2,
                    spacing: spacing,
                  ),
                  // Social/house settings
                  _infoSections(
                    icon: Icon(Icons.house_outlined),
                    text: 'House Info',
                    buttons: [
                      ['Leave House', _openChoresScreen],
                      ['Leave Subgroup', _openChoresScreen],
                    ],
                    flex: 2,
                    spacing: spacing,
                  ),
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
  Widget _imageSelectionButton(double width) {
    final imageSize = width / 3;
    return InkWell(
      onTap: () {
        _showPicker(context: context);
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
        image: DecorationImage(
          // TODO: connect to provider once provider has actual images
          image:
              imageFile == null
                  ? Image.asset('assets/defaultImage.jpg').image
                  : Image.file(imageFile!).image,
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  // Todo: adapt into provider info and backend once an image
  /// Gets an image from the user's photo gallery
  Future getImage(ImageSource img) async {
    // pick image from gallary
    final pickedFile = await picker.pickImage(source: img);
    // store it in a valid variable
    XFile? xfilePick = pickedFile;
    setState(() {
      if (xfilePick != null) {
        // store that in global variable galleryFile in the form of File
        imageFile = File(pickedFile!.path);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          // is this context <<<
          const SnackBar(content: Text('No image was selected')),
        );
      }
    });
  }

  /// Displays greeting to user
  Widget _introPhrase({required String name}) {
    return Text('Hi, $name!', style: DivvyTheme.bodyBlack);
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
          const Divider(color: DivvyTheme.beige, height: 1),
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
                  // Trigger the action
                  onTap:
                      () =>
                          !appearanceSwitch
                              ? entry[1](context)
                              : setState(() => themeSwitch = !themeSwitch),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry[0], style: DivvyTheme.bodyGrey),
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
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: DivvyTheme.darkRed,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        maximumSize: Size(100, 40),
      ),
      child: Text('Log Out', style: DivvyTheme.smallBodyWhite),
    );
  }

  /// Allows user to pick whether they want to upload an image
  /// or take an image.
  void _showPicker({required BuildContext context}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: DivvyTheme.background,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  getImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  getImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  ///////////////////////////// Navigation /////////////////////////////

  /// Opens the chores screen
  void _openChoresScreen(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => Chores()));
  }
}
