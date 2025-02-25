// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter/material.dart';

// //import 'package:flutter/material.dart';
// //import 'package:parking_app/models/parking_spot.dart' ;
// //import 'package:parking_app/models/saveParkingLocation.dart';


// class NotificationService {
//   static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   static Future<void> onDidReceiveNotification(
//       NotificationResponse notificationResponse) async {}

//   static Future<void> init() async {
//     const AndroidInitializationSettings androidInitializationSettings =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     const InitializationSettings initializationSettings =
//         InitializationSettings(android: androidInitializationSettings);

//     await flutterLocalNotificationsPlugin.initialize(initializationSettings,
//         onDidReceiveBackgroundNotificationResponse: onDidReceiveNotification,
//         onDidReceiveNotificationResponse: onDidReceiveNotification);

//     await flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>()
//         ?.requestNotificationsPermission();
//   }

//   static Future<void> showInstantNotification(String title, String body) async {
//     const NotificationDetails platformChannelSpecifics = NotificationDetails(
//       android: AndroidNotificationDetails(
//         "channel_Id",
//         "channel_Name",
//         importance: Importance.max,
//         priority: Priority.max,
//       ),
//     );
//     await flutterLocalNotificationsPlugin.show(
//         0, title, body, platformChannelSpecifics);
//   }

//   static Future<void> cancelAllNotifications() async {
//     await flutterLocalNotificationsPlugin.cancelAll();
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize notification settings
  static Future<void> init() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  // Show a simple notification
  static Future<void> showInstantNotification(String title, String body) async {
    try {
      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: AndroidNotificationDetails(
          "channel_Id",
          "channel_Name",
          importance: Importance.max,
          priority: Priority.max,
        ),
      );
      await flutterLocalNotificationsPlugin.show(
          0, title, body, platformChannelSpecifics);
    } catch (e) {
      print("Error showing notification: $e");
    }
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  // Show a dialog-based notification
  static Future<void> showPolygonNotification(
    BuildContext context, {
    required VoidCallback onYesPressed,
    required VoidCallback onNoPressed,
  }) async {
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Paking Notification"),
            content: const Text(
              "Is your vehicle parked..?",
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("Yes"),
                onPressed: () {
                  Navigator.of(context).pop();
                  onYesPressed(); // Call the Yes action
                },
              ),
              TextButton(
                child: const Text("No"),
                onPressed: () {
                  Navigator.of(context).pop();
                  onNoPressed(); // Call the No action
                },
              ),
            ],
          );
        },
      );
    } else {
      print('Context is not mounted. Cannot show dialog.');
    }
  }



// static Future<void> showinsidePolygonNotification(
//   BuildContext context,
// ) async {
//   if (context.mounted) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("No parking area"),
//           content: Text(
//             "This is a no parking zone, Please move your vehicle immediately. Or else you will be fined.",
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: Text("Find Nearby Parking Spots"),
//               onPressed: () {
//                 Navigator.of(context).pop();

//               },
//             ),
//           ],
//         );
//       },
//     );
//   } else {
//     print('Context is not mounted. Cannot show dialog.');
//   }
// }


static Future<void> showWrongParkingNotification(BuildContext context) async {
  // Ensure the context is still mounted before showing the dialog
  if (!context.mounted) {
    print('Context is not mounted. Cannot show dialog.');
    return;
  }

  // Show the alert dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("No parking area"),
        content: const Text(
          "This is a no parking zone, Please move your vehicle immediately. Or else you will be fined.",
        ),
        actions: <Widget>[
          TextButton(
            child: const Text("Ok"),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      );
    },
  );
}


  // Handle notification responses (optional)
  static Future<void> onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    // Add handling logic for notification taps or responses here
    print("Notification response received: ${notificationResponse.payload}");
  }
}





// class NotificationHelper {
//   static void showPolygonNotification(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Polygon Notification"),
//           content: Text("You have been inside the polygon and stationary for over one minute. Are you inside the polygon?"),
//           actions: <Widget>[
//             TextButton(
//               child: Text("Yes"),
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 // Handle Yes action
//               },
//             ),
//             TextButton(
//               child: Text("No"),
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 // Handle No action
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
// }




// void promptSaveParkingLocation(BuildContext context, ParkingSpot spot) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text('Save Parking Location'),
//         content: Text('Do you want to save your parking location?'),
//         actions: <Widget>[
//           TextButton(
//             child: Text('No'),
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//           ),
//           TextButton(
//             child: Text('Yes'),
//             onPressed: () {
//               //saveParkingLocation(spot);
//               Navigator.of(context).pop();
//             },
//           ),
//         ],
//       );
//     },
//   );
// }