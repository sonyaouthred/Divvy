// import 'package:divvy/models/divvy_theme.dart';
// Commented out for testing
import 'package:flutter/material.dart';

class House extends StatefulWidget {
  const House({super.key});

  @override
  State<House> createState() => _HouseState();
}

class _HouseState extends State<House> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('House'));
  }
}
