import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:divvy/divvy_navigation.dart';
import 'package:divvy/models/divvy_theme.dart';
import 'package:divvy/screens/notifications.dart';
import 'package:flutter/material.dart';

class RouteGenerator {
  // Generate route based on setting input
  static Route<dynamic> generatorRoute(RouteSettings settings) {
    ReceivedAction? receivevdAction;

    if (settings.arguments != null && settings.arguments is ReceivedAction) {
      receivevdAction = settings.arguments as ReceivedAction;
    }

    switch(settings.name){
      case '/':
        return MaterialPageRoute(builder: (context) => const DivvyNavigation());
      case '/notification-Page':
        return MaterialPageRoute(builder: (context) => const Notifications());
      default:
        return _errorRoute();
    }
  }

  // If it goes wrong
  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (context) {
      return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No Page Found 404',
              style: DivvyTheme.bodyBoldBlack,
            ),
            Center(
              child: Text(
                'Sorry No Page Found As of Now',
                style: DivvyTheme.bodyGrey,
              )
            )
          ],
        )
      );
    });
  }
}
