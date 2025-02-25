// import 'package:flutter/material.dart';

// class ParkingSpot extends ChangeNotifier {
//   final String name;
//   final String address;
//   final double latitude;
//   final double longitude;
//   int _freeCarSlots;
//   int _freeBikeSlots;
//   final List<String> locationImage;
//   final String type;
//   final String parkingType;
//   int _bigCarSpots; // Add this line
//   int? price;
//   int? avgFillingTime;
//   double get Latitude => latitude;
//   double get Longitude => longitude;

//   ParkingSpot(
//       {required this.name,
//       required this.address,
//       required this.latitude,
//       required this.longitude,
//       required freeCarSlots,
//       required freeBikeSlots,
//       required this.locationImage,
//       required this.type,
//       required this.parkingType,
//       required  bigCarSpots, // Add this line
//       this.price,
//       this.avgFillingTime})
//       : _freeCarSlots = freeCarSlots,
//         _freeBikeSlots = freeBikeSlots,
//         _bigCarSpots = bigCarSpots; // Add this line

//   int get freeCarSlots => _freeCarSlots;
//   int get freeBikeSlots => _freeBikeSlots;
//   int get bigCarSpots => _bigCarSpots;

//   set freeCarSlots(int value) {
//     if (_freeCarSlots != value) {
//       _freeCarSlots = value;
//       notifyListeners();
//     }
//   }

//   set freeBikeSlots(int value) {
//     if (_freeBikeSlots != value) {
//       _freeBikeSlots = value;
//       notifyListeners();
//     }
//   }
// }

// set bigCarSpots(int value) { // Add this method
//     if (_bigCarSpots != value) {
//       _bigCarSpots = value;
//       notifyListeners();
//     }
//   }

import 'package:flutter/material.dart';

class ParkingSpot extends ChangeNotifier {
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  int _freeCarSlots;
  int _freeBikeSlots;
  int? _bigCarSpots; // Ensure this line is present
  final List<String> locationImage;
  final String type;
  String? carParkingType;
  String? bikeParkingType;
  int? price;
  int? avgFillingTime;

  double get Latitude => latitude;
  double get Longitude => longitude;

  ParkingSpot({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required int freeCarSlots,
    required int freeBikeSlots,
    int? bigCarSpots, // Ensure this line is present
    required this.locationImage,
    required this.type,
    this.carParkingType,
    this.bikeParkingType,
    this.price,
    this.avgFillingTime,
  })  : _freeCarSlots = freeCarSlots,
        _freeBikeSlots = freeBikeSlots,
        _bigCarSpots = bigCarSpots; // Ensure this line is present

  int get freeCarSlots => _freeCarSlots;
  int get freeBikeSlots => _freeBikeSlots;
  int get bigCarSpots => 3; // Ensure this line is present

  set freeCarSlots(int value) {
    if (_freeCarSlots != value) {
      _freeCarSlots = value;
      notifyListeners();
    }
  }

  set freeBikeSlots(int value) {
    if (_freeBikeSlots != value) {
      _freeBikeSlots = value;
      notifyListeners();
    }
  }

  set bigCarSpots(int value) {
    // Ensure this method is present
    if (_bigCarSpots != value) {
      _bigCarSpots = value;
      notifyListeners();
    }
  }
}
