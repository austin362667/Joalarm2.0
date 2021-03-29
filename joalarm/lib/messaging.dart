import 'dart:async';
import 'dart:convert';
// import 'package:firebase/firebase.dart';
import 'package:http/http.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<FirebaseMessaging> configureMessaging() async {
  // await initializeApp();
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: true,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });

  // Replace with server token from firebase console settings.

  return messaging;
}

//   firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) async {
//     print('on Message: ${message}');
//   }, onLaunch: (Map<String, dynamic> message) async {
//     print('on Launch:');
//   }, onResume: (Map<String, dynamic> message) async {
//     print('on Resume:');
//   });
//   return firebaseMessaging;
// }

// final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

// Future<Map<String, dynamic>> sendAndRetrieveMessage(
//     String taToken, String body) async {
//   await firebaseMessaging.requestNotificationPermissions(
//     const IosNotificationSettings(
//         sound: true, badge: true, alert: true, provisional: false),
//   );

sendAndRetrieveMessage(taToken, body) async {
  final String serverToken =
      'AAAA4ozA9jE:APA91bEvb8Fj7rvSycDTtz60Qv-OMEU0i1O59RDxNo7qanLuZhhT6jjnppMufkxWL3bq6PkUaFAB5mcOdBYHfd-cxjL_U9LiYpzNqChxzH5EEnievjjdQS-nzRiMxmbzn3WMlcRPSRul';

  var url = Uri.parse('https://fcm.googleapis.com/fcm/send');
  var response = await post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverToken',
    },
    body: jsonEncode(
      <String, dynamic>{
        'notification': <String, dynamic>{
          'body': body!,
          'title': '🔔戀愛鈴:Joalarm🔔'
        },
        'priority': 'high',
        'data': <String, dynamic>{
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'id': '1',
          'status': 'done'
        },
        'to': taToken!,
      },
    ),
  );
}

// final Completer<Map<String, dynamic>> completer =
//     Completer<Map<String, dynamic>>();

// firebaseMessaging.configure(
//   onMessage: (Map<String, dynamic> message) async {
//     completer.complete(message);
//   },
// );

// return completer.future;
// }
