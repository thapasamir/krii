import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:krii/notification_controller.dart';
import 'package:krii/notimsg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('krii'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Hellooo kriiii 💖',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            WaterReminderButton(),
          ],
        ),
      ),
    );
  }
}

class WaterReminderButton extends StatefulWidget {
  const WaterReminderButton({Key? key});

  @override
  _WaterReminderButtonState createState() => _WaterReminderButtonState();
}

class _WaterReminderButtonState extends State<WaterReminderButton>
    with SingleTickerProviderStateMixin {
  bool remindToDrinkWater = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 1),
    ]).animate(_controller);

    // Load water reminder state from SharedPreferences
    _loadWaterReminderState();
  }

  void _loadWaterReminderState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      remindToDrinkWater = prefs.getBool('remindToDrinkWater') ?? false;
    });

    // Schedule periodic water reminder notifications if reminder is on
    if (remindToDrinkWater) {
      _scheduleWaterReminderNotifications();
    }
  }

  void _saveWaterReminderState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('remindToDrinkWater', remindToDrinkWater);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          remindToDrinkWater = !remindToDrinkWater;
          _saveWaterReminderState();

          if (remindToDrinkWater) {
            _controller.repeat(reverse: true);
            _scheduleWaterReminderNotifications();
          } else {
            _controller.reset();
            _cancelWaterReminderNotifications();
          }
        });
        _showReminder();
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: remindToDrinkWater ? Colors.green.shade400 : Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _animation,
                  child: remindToDrinkWater
                      ? const Icon(
                          Icons.check,
                          size: 30,
                          color: Colors.white,
                        )
                      : const Icon(
                          Icons.close,
                          size: 30,
                          color: Colors.white,
                        ),
                ),
                const SizedBox(width: 10),
                Text(
                  remindToDrinkWater
                      ? 'Malai Pani Khana Samjau'
                      : 'Nasamja tero didi lai ',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showReminder() {
    String reminderText = remindToDrinkWater ? 'remind' : "dontremind";
    String snackBarText = remindToDrinkWater
        ? 'Stay Hydrated! You will receive reminders.'
        : 'You won\'t receive reminders to drink water.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(snackBarText),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            setState(() {
              remindToDrinkWater = !remindToDrinkWater;
              _saveWaterReminderState();

              if (remindToDrinkWater) {
                _controller.repeat(reverse: true);
                _scheduleWaterReminderNotifications();
              } else {
                _controller.reset();
                _cancelWaterReminderNotifications();
              }
            });
          },
        ),
      ),
    );
  }

  void _scheduleWaterReminderNotifications() {
    // Assign a unique group key for water reminder notifications
    const waterReminderGroupKey = 'waterReminderGroup';

    // Cancel existing water reminder notifications before scheduling new ones
    _cancelWaterReminderNotifications();

    // Get the current local time
    DateTime now = DateTime.now();
    int currentHour = now.hour;

    // Schedule periodic water reminder notifications every 2 hours
    // between 8 am to 10 pm

    // Check if the current time is within the desired range
    if (currentHour >= 8 && currentHour <= 22) {
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: generateRandom4DigitInt(),
          channelKey: 'channelKey',
          title: 'Drink Water Reminder 💧',
          body: getRandomMessage(waterReminderMessages),
          groupKey: waterReminderGroupKey,
        ),
        schedule: NotificationInterval(
          interval: 7200, // Repeat every 2 hours
        ),
      );
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: generateRandom4DigitInt(),
          channelKey: 'channelKey',
          title: 'Drink Water Reminder 💧',
          body: getRandomMessage(waterReminderMessages),
          groupKey: waterReminderGroupKey,
        ),
      );
    }
  }

  void _cancelWaterReminderNotifications() {
    // Assign the same unique group key for canceling water reminder notifications
    const waterReminderGroupKey = 'waterReminderGroup';

    // Cancel only water reminder notifications by specifying the group
    AwesomeNotifications().cancelSchedulesByGroupKey(waterReminderGroupKey);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
