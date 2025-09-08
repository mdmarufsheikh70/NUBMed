

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FCMService{
  Future<void> initialize()async{
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true,
    );
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotification);
    FirebaseMessaging.onMessage.listen(_handleNotification);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundNotification);
  }
  void _handleNotification(RemoteMessage message){
    FirebaseFirestore.instance.collection('notifications').add(
      {
        'message':message.notification?.body,
        'title':message.notification?.title,
        'data':message.data,
        'timestamp':Timestamp.now(),
        'read':false,
        'recieverID':FirebaseAuth.instance.currentUser!.uid
      }
    );
    print(message.notification?.title);
    print(message.notification?.body);
    print(message.data);
  }

  Future<String?> getFcmToken()async{
    return FirebaseMessaging.instance.getToken();
  }

  Future<void>onTokenRefresh()async{
    final uid =await FirebaseAuth.instance.currentUser?.uid;
    FirebaseMessaging.instance.onTokenRefresh.listen((String? newToken){
      FirebaseFirestore.instance.collection("users").doc(uid).update({
        'fcm_token': FieldValue.arrayUnion([newToken])
      });
    });
  }
}
Future<void> handleBackgroundNotification(RemoteMessage message)async{
  print(message.notification?.title);
  print(message.notification?.body);
  print(message.data);
}