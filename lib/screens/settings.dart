import 'package:flutter/material.dart';
import 'package:divvy/models/divvy_theme.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Settings'));
  }
}
