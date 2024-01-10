import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:krii/homepage.dart';
import 'package:krii/notification_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AwesomeNotifications().initialize(null, [
    NotificationChannel(
        channelGroupKey: "channelGroupKey",
        channelKey: "channelKey",
        channelName: "channelName",
        channelDescription: "channelDescription")
  ], channelGroups: [
    NotificationChannelGroup(
        channelGroupKey: "channelGroupKey",
        channelGroupName: "channelGroupName")
  ]);

  bool isAllowedToSendNotification =
      await AwesomeNotifications().isNotificationAllowed();

  if (!isAllowedToSendNotification) {
    AwesomeNotifications().requestPermissionToSendNotifications();
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: NotificationController.onActionReceivedMethod,
        onNotificationCreatedMethod:
            NotificationController.onNotificationCreatedMethod,
        onDismissActionReceivedMethod:
            NotificationController.onDismissActionReceivedMethod,
        onNotificationDisplayedMethod:
            NotificationController.onNotificationDisplayedMethod);
    _scheduleDailyNotifications();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Local Notifications',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

// Function to schedule daily "Good Morning" and "Good Night" notifications
void _scheduleDailyNotifications() async {
  // Schedule Good Morning Notification
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: generateRandom4DigitInt(),
      channelKey: 'channelKey',
      title: 'Goooood Morningggg 🤗💖',
      body:
          'Good morning, loveeeee! Imagine this message as a warm hug, wrapping you in love and positivity.',
      bigPicture: 'assets/images/big_pic.jpg',
      notificationLayout: NotificationLayout.BigPicture,
    ),
    schedule: NotificationCalendar(hour: 5, minute: 30 // Schedule at 10:00 PM
        ),
  );

  // Schedule Good Night Notification
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: generateRandom4DigitInt(),
      channelKey: 'channelKey',
      title: 'Goooood Nighttttt! 🌙🤗💖',
      body:
          'Picture yourself under a blanket of stardust, wrapped in the warmth of my love',
      bigPicture: 'assets/images/big_pic.jpg',
      notificationLayout: NotificationLayout.BigPicture,
    ),
    schedule: NotificationCalendar(hour: 10, minute: 30 // Schedule at 10:00 PM
        ),
  );
}
