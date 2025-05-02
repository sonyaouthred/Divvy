import 'package:flutter/material.dart';
import 'package:divvy/models/divvy_theme.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Calendar'));
  }
}
