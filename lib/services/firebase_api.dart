import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> backgroundHandler(RemoteMessage msg) async {}
// Future<void> handleBackgroundMessage(RemoteMessage message) async {
//   print(message.notification?.title);
//   print(message.notification?.body);

//   if (message.notification != null) {
//     print('Title: ${message.notification?.title}');
//     print('Body: ${message.notification?.body}');
//   }
// }

late AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
bool isFlutterLocalNotificationsInitialized = false;

class FirebaseApi {
  final _firebaseMessageing = FirebaseMessaging.instance;

  handleMessage(RemoteMessage? message) {
    if (message == null) return;

    //   print(message.notification?.title);
  }

  Future<void> initLocalNotification() async {
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: AndroidInitializationSettings('@drawable/ic_launcher'),
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        //     print('notificationResponse ${notificationResponse.payload}');
      },
    );
  }

  Future<void> setupFlutterNotifications() async {
    if (isFlutterLocalNotificationsInitialized) {
      return;
    }
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    isFlutterLocalNotificationsInitialized = true;
  }

  initPushNotification() {
    _firebaseMessageing.getInitialMessage().then(handleMessage);

    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(backgroundHandler);
    // FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen(showFlutterNotification);
  }

  void showFlutterNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null && !kIsWeb) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        payload: jsonEncode(message.toMap()),
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: '@drawable/ic_launcher',
          ),
        ),
      );
    }
  }

  initNotification() async {
    await _firebaseMessageing.requestPermission();
    final fcmToken = await _firebaseMessageing.getToken();
    //   print('Token : $fcmToken');
    await setupFlutterNotifications();
    initLocalNotification();
    initPushNotification();
    await saveTokenToFirestore(fcmToken);
  }

  Future<void> saveTokenToFirestore(String? token) async {
    var user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String email = user.email!;
      //    print('Saving FCM Token to Firestore for $email: $token');

      var userDocumentRef =
          FirebaseFirestore.instance.collection('deviceTokens').doc(email);

      await userDocumentRef.set({'token': token});
      //    print('FCM Token saved to Firestore successfully.');
    } else {
      // Handle the case where the user is null
      //    print('User is null. Unable to save FCM Token.');
    }
  }
}
