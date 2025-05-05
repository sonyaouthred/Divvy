import 'package:flutter/material.dart';

// import 'package:divvy/models/divvy_theme.dart';
// Commented out for testing
class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Dashboard'));
  }
}
