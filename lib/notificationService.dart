// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
// class NotificationService {
//   static final FlutterLocalNotificationsPlugin _notificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//
//   static Future<void> initialize() async {
//     const AndroidInitializationSettings initializationSettingsAndroid =
//     AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     final InitializationSettings initializationSettings =
//     InitializationSettings(android: initializationSettingsAndroid);
//
//     await _notificationsPlugin.initialize(
//       initializationSettings,
//       onSelectNotification: (String? payload) async {
//         // Handle notification tap
//       },
//     );
//   }
//
//   static Future<void> _showLocalNotification(RemoteMessage message) async {
//     final androidDetails = AndroidNotificationDetails(
//       'channel_id',
//       'channel_name',
//       importance: Importance.high,
//       priority: Priority.high,
//     );
//
//     final notificationDetails = NotificationDetails(android: androidDetails);
//
//     await _notificationsPlugin.show(
//       DateTime.now().millisecondsSinceEpoch ~/ 1000,
//       message.notification?.title,
//       message.notification?.body,
//       notificationDetails,
//       payload: message.data.toString(),
//     );
//   }
// }