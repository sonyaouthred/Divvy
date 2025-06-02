import 'dart:isolate';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:divvy/main.dart';
import 'package:divvy/models/chore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Incharge of intilizing the notifications
class NotificationsUtils {
  NotificationsUtils._();

  factory NotificationsUtils() => _instance;
  static final NotificationsUtils _instance = NotificationsUtils._();
  final AwesomeNotifications awesomeNotifications = AwesomeNotifications();
  static ReceivePort? receivePort;
  bool generatedNextWeek = false;

  Future<void> configuration() async {
    await awesomeNotifications.initialize(
      null,
     [
      NotificationChannel(
      channelKey: 'basic_chore_channel',
      channelName: 'Basic Chore Notifications',
      channelDescription: 'Basic Chore Notifications Channel',
      defaultColor: Colors.teal,
      importance: NotificationImportance.High,
      channelShowBadge: true,
      channelGroupKey: 'basic_channel_group')
     ]);
  }

  void checkingPermissionNotification(BuildContext context) {
    AwesomeNotifications().isNotificationAllowed().then(
      (isAllowed) {
        if (!isAllowed) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Allow Notifications'),
              content: Text('Our app would like to send you notifications'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Don\'t Allow',
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                ),
                TextButton(
                  onPressed: () => AwesomeNotifications()
                      .requestPermissionToSendNotifications()
                      .then((_) => Navigator.pop(context)),
                  child: Text(
                    'Allow',
                    style: TextStyle(
                      color: Colors.teal,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  // Creating a scheduled based on passed in notificaiton content Notificaitons
  Future<void> createScheduleNotification(NotificationContent content, DateTime date) async {
    try {
      await awesomeNotifications.createNotification(
        schedule: NotificationCalendar(
          day: date.day,
          month: date.month,
          year: date.year,
          hour: date.hour,
        ),
        content: content);
    } catch (e) {
      // Nothing to do
    }
  }

  Future<void> jsonDataNotification(Map<String, Object> jsonData) async {
    await awesomeNotifications.createNotificationFromJsonData(jsonData);
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
     if (receivedAction.actionType == ActionType.SilentAction ||
        receivedAction.actionType == ActionType.SilentBackgroundAction) {
      // For background actions, you must hold the execution until the end\
      await executeLongTaskInBackground();
    } else {
      // this process is only necessary when you need to redirect the user
      // to a new page or use a valid context, since parallel isolates do not
      // have valid context, so you need redirect the execution to main isolate
      if (receivePort == null) {
      
        SendPort? sendPort =
            IsolateNameServer.lookupPortByName('notification_action_port');

        if (sendPort != null) {
          sendPort.send(receivedAction);
          return;
        }
      }

      return onActionReceivedImplementationMethod(receivedAction);
    }
  }

  // background task - simply a long task to do 
  static Future<void> executeLongTaskInBackground() async {
    await Future.delayed(const Duration(seconds: 4));
    final url = Uri.parse("http://google.com");
    await http.get(url);
  }

  // Implementing actions for notifications
  static Future<void> onActionReceivedImplementationMethod(
      ReceivedAction receivedAction) async {
    HouseApp.navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/notification-page',
        (route) =>
            (route.settings.name != '/notification-page') || route.isFirst,
        arguments: receivedAction);
  }

  Future<void> startListeningNotificaitonEvents() async {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod);
  }

  Future<void> cancelScheduledNotifications() async {
  await AwesomeNotifications().cancelAllSchedules();
  }

  Future<void> cancelSpecificScheduledNotification(String instID) async {
    final int id = generateId(instID: instID);
    await AwesomeNotifications().cancelSchedule(id);
  }

  // Generate next week worth of scheduled notifications
  void generateNextWeekNotificaitons(List<ChoreInst> chores, List<Chore?> superChores, String userID) async {
    createScheduleNotification(content, date)
    generatedNextWeek = true;
    List<NotificationModel> scheduledNotifications = await AwesomeNotifications().listScheduledNotifications();
    List<int> ids = [];
    for (var notif in scheduledNotifications) {
      final int id = notif.content!.id ??  -1;
      ids.add(id);
    }

    for (var chore in chores) {
      final int notifID = generateId(instID: chore.id);
      if (!ids.contains(notifID)) {
        final DateTime date = DateTime(chore.dueDate.year, chore.dueDate.month, chore.dueDate.day, 8);
        final Chore superChore = superChores.firstWhere((superchore) => superchore?.id == chore.superID);
        final NotificationContent content = NotificationContent(
          id: notifID, 
          title: superChore.name,
           
        channelKey: userID);
        createScheduleNotification(content, date);
      }
    }
  }

  int generateId ({required String instID}) {
    // Reliant on enough difference between instance ids
    if (instID.length == 36) {
      final hex1 = instID.substring(0, 8);
      final hex2 = instID.substring(24, 36);
      return int.parse(hex1, radix: 16) + int.parse(hex2, radix: 16);
    } else {
      return -1;
    }
  }

  Future<void> setUserChannel (String userID) async {
    final NotificationChannel channel = NotificationChannel(
      channelKey: userID,
       channelName: 'Current_User_channel', 
       channelDescription: 'Channel specifically for current user',
      defaultColor: Colors.teal,
      importance: NotificationImportance.High,
      channelShowBadge: true,
      channelGroupKey: 'current_user_channel_group');
    await AwesomeNotifications().setChannel(channel);
  }
}

