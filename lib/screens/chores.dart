import 'package:divvy/models/divvy_theme.dart';
import 'package:flutter/material.dart';

class Chores extends StatefulWidget {
  const Chores({super.key});

  @override
  State<Chores> createState() => _ChoresState();
}

class _ChoresState extends State<Chores> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Chores'));
  }
}
