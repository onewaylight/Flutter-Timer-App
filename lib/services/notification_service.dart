import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';

class NotificationService {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  
  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }
  
  Future<void> requestPermissions() async {
    await Permission.notification.request();
    
    // For Android 13+ (API level 33+)
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
  }
  
  Future<void> showBackgroundNotification(int remainingSeconds) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'timer_channel',
      'Timer Notifications',
      channelDescription: 'Notifications for timer app',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showProgress: true,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('alarm'),
    );
    
    const DarwinNotificationDetails iOSNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: false,
      presentSound: false,
    );
    
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOSNotificationDetails,
    );
    
    await flutterLocalNotificationsPlugin.show(
      1,
      'Timer Running',
      'Time remaining: ${_formatDuration(remainingSeconds)}',
      notificationDetails,
    );
  }
  
  Future<void> showCompletionNotification(int totalSeconds) async {
    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'timer_complete_channel_v3',
      'Timer Complete',
      channelDescription: 'Timer completion notifications',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      vibrationPattern: Int64List.fromList(const [0, 1000, 500, 1000]),
      playSound: true,
      sound: RawResourceAndroidNotificationSound('danger_alarm_fixed'),
      //sound: UriAndroidNotificationSound('content://settings/system/notification_sound'),
      //sound: UriAndroidNotificationSound('content://settings/system/alarm_alert'),
      // Uses system default notification sound instead of custom alarm
    );
    
    const DarwinNotificationDetails iOSNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'alarm.wav',
    );
    
    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOSNotificationDetails,
    );
    
    await flutterLocalNotificationsPlugin.show(
      2,
      'Timer Complete!',
      'Your ${_formatDuration(totalSeconds)} timer has finished.',
      notificationDetails,
    );
  }
  
  Future<void> cancelBackgroundNotification() async {
    await flutterLocalNotificationsPlugin.cancel(1);
  }
  
  String _formatDuration(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
  }
}