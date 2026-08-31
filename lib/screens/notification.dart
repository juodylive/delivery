// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:eat_with_us/helpers/text_input_decoration.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({
    super.key,
  });

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  Future<void> _deleteNotification(String notificationId) async {
    try {
      bool? result = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirmation', style: GoogleFonts.montserrat()),
            content: Text(
              'Are you sure you want to delete this notification?',
              style: GoogleFonts.montserrat(),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text('No', style: GoogleFonts.montserrat()),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text('Yes', style: GoogleFonts.montserrat()),
              ),
            ],
          );
        },
      );

      if (result == true) {
        // Get the current user's email
        String email = FirebaseAuth.instance.currentUser!.email!;

        // Delete the notification from the user's subcollection
        await FirebaseFirestore.instance
            .collection('notifications')
            .doc(email)
            .collection('userNotifications')
            .doc(notificationId)
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification deleted successfully.'),
          ),
        );
      }
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error', style: GoogleFonts.montserrat()),
            content: Text(error.toString()),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK', style: GoogleFonts.montserrat()),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Notifications',
          style: GoogleFonts.montserrat(color: Colors.amber[100]),
        ),
        backgroundColor: AppColor.iconColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .doc(FirebaseAuth.instance.currentUser!.email!)
            .collection('userNotifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColor.mainColor,
              ),
            );
          }

          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No notifications available.',
                style: GoogleFonts.poppins(fontSize: 18),
              ),
            );
          }

          // If you reach here, there are notifications
          var notifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              var notification = notifications[index];
              var notificationData =
                  notification.data() as Map<String, dynamic>;

              // Extract the auto-generated ID of the notification
              String notificationId = notification.id;

              // Format the timestamp to display in a readable format
              String formattedDate =
                  _formatTimestamp(notificationData['timestamp'] as Timestamp);

              return ListTile(
                title: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Text(
                    notificationData['title'] as String? ?? '',
                    style: GoogleFonts.poppins(fontSize: 18),
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notificationData['body'] as String? ?? '',
                        style: GoogleFonts.poppins(
                            fontSize: 15, color: Colors.grey[700]),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Text('Received on $formattedDate'),
                    ],
                  ),
                ),
                trailing: IconButton(
                  onPressed: () {
                    _deleteNotification(notificationId);
                  },
                  icon: const Icon(Icons.delete),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    // Convert the Firestore Timestamp to a DateTime
    DateTime dateTime = timestamp.toDate();

    // Format the DateTime as a string
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);

    return formattedDate;
  }
}

// class PushNotificationService {
//   final FirebaseMessaging _fcm = FirebaseMessaging.instance;
//   final _messageStreamController = StreamController<String>();

//   // Expose the stream for listening
//   Stream<String> get messageStream => _messageStreamController.stream;

//   Future initialize() async {
//     // Request permission for receiving notifications
//     await _fcm.requestPermission(
//       alert: true,
//       announcement: false,
//       badge: true,
//       carPlay: false,
//       criticalAlert: false,
//       provisional: false,
//       sound: true,
//     );

//     // Get the device token
//     String? token = await _fcm.getToken();
//     print('FCM Token: $token');

//     // Save the device token to Firestore
//     await saveTokenToFirestore(token);

//     // Handle incoming messages when the app is in the foreground
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print('onMessage: $message');
//       _messageStreamController.add(message.notification?.body ?? '');
//       // Add logic to handle notifications when the app is in the foreground
//     });

//     // Handle notification when the app is in the background
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print('onMessageOpenedApp: ${message.notification?.body}');
//       _messageStreamController.add(message.notification?.body ?? '');
//     });

//     // Handle notification when the app is completely closed
//     RemoteMessage? initialMessage =
//         await FirebaseMessaging.instance.getInitialMessage();
//     if (initialMessage != null) {
//       print('Initial message: ${initialMessage.notification?.body}');
//       _messageStreamController.add(initialMessage.notification?.body ?? '');
//     }
//   }

//   Future<String?> getDeviceToken() async {
//     return await _fcm.getToken();
//   }

//   Future<void> saveTokenToFirestore(String? token) async {
//     if (token != null) {
//       String userId = FirebaseAuth.instance.currentUser!.uid;
//       print('Saving FCM Token to Firestore for $userId: $token');

//       var userDocumentRef =
//           FirebaseFirestore.instance.collection('users').doc(userId);

//       // Create the "notifications" subcollection if not exists
//       await userDocumentRef.collection('notifications').doc('init').set({});

//       // Save the device token to Firestore
//       await userDocumentRef
//           .collection('notifications')
//           .doc('init')
//           .update({'token': token});

//       print('FCM Token saved to Firestore successfully.');
//     }
//   }


// }
