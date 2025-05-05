import 'package:divvy/screens/chores.dart';
import 'package:divvy/screens/house.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:divvy/models/divvy_theme.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  // To be replace with process to get actual data
  final String name = 'Temp';
  File? imageFile;
  final picker = ImagePicker();

  // To be filled out with actual pages that allow for change
  final _accountInfo = [
    ['Change Name', Chores()],
    ['Reset Password', Chores()],
    ['Delete Account', Chores()],
  ];
  // To be filled out with actual pages that allow for change
  final _houseInfo = [
    ['Leave House', House()],
    ['Leave Subgroup', House()]
  ];

  final _settings = [
    ['Appearance', 'none']
  ];

  bool themeSwitch = true;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 300,
        child:
          Column(
          children: [
            Padding(padding: EdgeInsets.all(2.0)),
            Expanded(
              flex: 2,
            child: Column(
              children: [
            Stack(
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: _profileImage()),
                Positioned(
                  bottom: 5,
                  right: 5,
                  child: _imageSelectionButton()),
              ],
            ),
            _introPhrase(name: name)
            ])
            ),
            _infoSections(icon: Icon(Icons.account_circle_outlined), text: 'Account Info', buttons: _accountInfo, flex: 2),
            _infoSections(icon: Icon(Icons.house_outlined), text: 'House Info', buttons: _houseInfo, flex: 2),
            _infoSections(icon: Icon(Icons.settings_outlined), text: 'Settings', buttons: _settings, flex: 1),
            _logoutButton(),
            Padding(padding: EdgeInsets.all(10.0))
          ]
          ))
      );
  }

  BoxDecoration _profileImage(){
    return BoxDecoration(
      shape: BoxShape.circle,
      image: DecorationImage(
        image: imageFile == null
        ? Image.asset('assets/defaultImage.jpg').image
        : Image.file(imageFile!).image,
      fit: BoxFit.fill),
      );
  }

  Widget _imageSelectionButton(){
    return IconButton(
      onPressed: () {
        _showPicker(context: context);},
      color: DivvyTheme.background,
      icon: Icon(Icons.camera_alt_outlined, color: DivvyTheme.lightGreen),
      );
  }

  // Picker for the image
  void _showPicker({
    required BuildContext context,
  }) {
    showModalBottomSheet(
      context: context,
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

  // Method that gets image
  Future getImage(
    ImageSource img,
  ) async {
    // pick image from gallary
    final pickedFile = await picker.pickImage(source: img);
    // store it in a valid variable
    XFile? xfilePick = pickedFile;
    setState(
      () {
        if (xfilePick != null) {
          // store that in global variable galleryFile in the form of File
          imageFile = File(pickedFile!.path);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(// is this context <<<
              const SnackBar(content: Text('Nothing is selected')));
        }
      },
    );
  }

  Widget _introPhrase({required String name}){
    return Text('Hi, $name', style: DivvyTheme.smallBodyBlack);
  }

  Widget _infoSections({required Icon icon, required String text, required List buttons, required int flex}) {
    return Expanded( 
      flex: flex,
      child: Center (
        child: Column(
        children:[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(padding: EdgeInsets.all(10.0), 
              child: icon),
              Text(text, style: DivvyTheme.bodyBoldBlack)
            ],
          ),
          const Divider(color: DivvyTheme.lightGrey,
            height: 5,
            thickness: 1,
            indent: 2,
            endIndent: 2,),
          ..._listButtons(buttons: buttons)
        ]
      )));
  }

  List<Widget> _listButtons({required List buttons}){
    if (buttons.length == 1) {
      return [Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              Text(buttons[0][0], style: DivvyTheme.bodyGrey),
              CupertinoSwitch(
                value: themeSwitch,
                onChanged: (bool? value) {
                  setState(() {
                    themeSwitch = value ?? false;
                  });
                },
                applyTheme: true,
              )])];
    } else {
      return buttons.map((entry) => _changeButton(text:entry[0], page:entry[1])).toList();
    }
  }

  Widget _changeButton({required String text, required page}){
    return Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              Text(text, style: DivvyTheme.bodyGrey),
              _triangleButton(page: page)]);
  }

  Widget _triangleButton({required page}) {
    return IconButton(onPressed: ()=> 
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => page)),
      icon: Transform.flip(flipX: true,
      child: Icon(Icons.arrow_back_ios, color: DivvyTheme.lightGrey)));
  }


  Widget _logoutButton(){
    return ElevatedButton(onPressed: (){},
      style: ElevatedButton.styleFrom(
        backgroundColor: DivvyTheme.darkRed,
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0)),
        maximumSize: Size(100,40)
      ),
      child: Text('Log Out', style: DivvyTheme.smallBodyWhite));
  }
}

