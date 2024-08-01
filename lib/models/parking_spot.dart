import 'package:flutter/material.dart';

class ParkingSpot extends ChangeNotifier {
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  int _freeCarSlots;
  int _freeBikeSlots;
  final List<String> locationImage;
  final String type;
  int? price;
  int? avgFillingTime;
  double get Latitude => latitude;
  double get Longitude => longitude;

  ParkingSpot(
      {required this.name,
      required this.address,
      required this.latitude,
      required this.longitude,
      required freeCarSlots,
      required freeBikeSlots,
      required this.locationImage,
      required this.type,
      this.price,
      this.avgFillingTime})
      : _freeCarSlots = freeCarSlots,
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
