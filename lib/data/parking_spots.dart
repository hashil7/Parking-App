// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:parking_app/models/parking_spot.dart';
// import 'package:firebase_database/firebase_database.dart';

// final databaseReference = FirebaseDatabase.instance.ref();

// List<ParkingSpot> parking_spots = [
//   ParkingSpot(
//     name: 'Lions Park Beach Rd',
//     latitude: 11.260972535975798,
//     longitude: 75.76841490051594,
//     freeCarSlots: 5,
//     freeBikeSlots: 1,
//     locationImage: AssetImage('assets/images/sample_image.jfif'),
//   ),
//   ParkingSpot(
//     name: 'Corporation Office',
//     latitude: 11.25761055291817,
//     longitude: 75.770810503895,
//     freeCarSlots: 15,
//     freeBikeSlots: 5,
//     locationImage: AssetImage('assets/images/corporation_office.jpg'),
//   )
// ];
// void syncParkingSpots() {
//   databaseReference.onValue.listen((event) {
//     var snapshot = event.snapshot;
//     var value = snapshot.value;
//     if (value != null) {
//       (value as Map).forEach((key, values) {
//         String name = key;
//         int freeCarSlots = values["car"];
//         int freBikeSlots = values["bike"];

//         for (var spot in parking_spots) {
//           if (spot.name == name) {
//             spot.freeCarSlots = freeCarSlots;
//             spot.freeBikeSlots = freBikeSlots;
//             break;
//           }
//         }
//       });
//     }
//   });
// }
