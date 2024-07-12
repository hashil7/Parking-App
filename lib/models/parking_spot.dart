import 'package:flutter/material.dart';
import 'package:parking_app/data/parking_spots.dart';
import 'package:firebase_database/firebase_database.dart';

class ParkingSpot extends ChangeNotifier {
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  int _freeCarSlots;
  int _freeBikeSlots;
  final String locationImage;
  final String type;
  int? price;
  double get Latitude => latitude;
  double get Longitude => longitude;

  ParkingSpot({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required freeCarSlots,
    required freeBikeSlots,
    required this.locationImage,
    required this.type,
    this.price,
  })  : _freeCarSlots = freeCarSlots,
        _freeBikeSlots = freeBikeSlots;

  int get freeCarSlots => _freeCarSlots;
  int get freeBikeSlots => _freeBikeSlots;

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
}
