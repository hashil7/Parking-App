// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:csv/csv.dart';
// import 'dart:convert';
// import 'package:geolocator/geolocator.dart';




// // class DataSaver {
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// //   Future<void> saveData({
// //     required String response,
// //     required Position location,
// //     required double speed,
// //     Duration? stopDuration,
// //   }) async {
// //     try {
// //       await _firestore.collection('responses').add({
// //         'response': response,
// //         'latitude': location.latitude,
// //         'longitude': location.longitude,
// //         'speed': speed,
// //         'stopDuration': stopDuration?.inSeconds ?? 0,
// //         'timestamp': DateTime.now().toIso8601String(),
// //       });
// //       print('Data saved to Firestore');
// //     } catch (e) {
// //       print('Error saving data to Firestore: $e');
// //     }
// //   }
// // }

// class DataSaver {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Future<void> saveData({
//     required String response,
//     required Position location,
//     required double speed,
//     Duration? stopDuration,
//   }) async {
//     try {
//       await _firestore.collection('responses').add({
//         'response': response,
//         'latitude': location.latitude,
//         'longitude': location.longitude,
//         'speed': speed,
//         'stopDuration': stopDuration?.inSeconds ?? 0,
//         'timestamp': DateTime.now().toIso8601String(),
//       });
//       print('Data saved to Firestore');
//     } catch (e) {
//       print('Error saving data to Firestore: $e');
//     }
//   }
// }



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class DataSaver {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveData({
    required String response,
    required Position location,
    required double speed,
    Duration? stopDuration,
    String? polygonName, // Add polygonName as a parameter
  }) async {
    try {
      await _firestore.collection('responses').add({
        'response': response,
        'latitude': location.latitude,
        'longitude': location.longitude,
        'speed': speed,
        'stopDuration': stopDuration?.inSeconds ?? 0,
        'timestamp': DateTime.now().toIso8601String(),
        'polygonName': polygonName, // Save the polygon name if available
      });
      print('Data saved to Firestore');
    } catch (e) {
      print('Error saving data to Firestore: $e');
    }
  }


   Future<void> saveParkingSpotResponse({
  required String response,
  required Position location,
}) async {
  try {
    await _firestore.collection('parking_spot_responses').add({
      'response': response,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'timestamp': DateTime.now().toIso8601String(),
    });
    print('Parking spot response saved to Firestore');
  } catch (e) {
    print('Error saving parking spot response to Firestore: $e');
  }
}
}

