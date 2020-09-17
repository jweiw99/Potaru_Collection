import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationManager {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  AndroidInitializationSettings initializationSettingsAndroid;
  IOSInitializationSettings initializationSettingsIOS;
  InitializationSettings initializationSettings;

  Future initNotificationManager() async {
    initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    initializationSettingsIOS = IOSInitializationSettings();
    initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future showInboxNotificationWithDefaultSound(
      int id, String title, String body1, String body2) async {
    var lines = List<String>();
    lines.add(body1);
    lines.add(body2);

    var inboxStyleInformation = InboxStyleInformation(lines,
        htmlFormatLines: true,
        contentTitle: title,
        summaryText: body1,
        htmlFormatContentTitle: true,
        htmlFormatSummaryText: true);

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        "potaru", 'Potaru', 'Academic Arrangement Apps',
        groupKey: 'my.edu.utar.potaru',
        importance: Importance.Max,
        priority: Priority.High,
        enableLights: true,
        color: Colors.blue,
        ledColor: Colors.blue,
        ledOnMs: 1000,
        ledOffMs: 500,
        styleInformation: inboxStyleInformation);
    var platformChannelSpecifics =
        NotificationDetails(androidPlatformChannelSpecifics, null);
    await flutterLocalNotificationsPlugin.show(
        id, "", "", platformChannelSpecifics);
  }

  Future showNotificationWithDefaultSound(
      int id, String title, String body) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        "potaru", 'Potaru', 'Academic Arrangement Apps',
        groupKey: 'my.edu.utar.potaru',
        importance: Importance.Max,
        priority: Priority.High,
        enableLights: true,
        color: Colors.blue,
        ledColor: Colors.blue,
        ledOnMs: 1000,
        ledOffMs: 500);
    var platformChannelSpecifics =
        NotificationDetails(androidPlatformChannelSpecifics, null);
    await flutterLocalNotificationsPlugin.show(
        id, title, body, platformChannelSpecifics);
  }
}
