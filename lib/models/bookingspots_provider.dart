import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class BookingspotsProvider extends ChangeNotifier {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref('booking_spots');
  StreamSubscription<DatabaseEvent>? _carSubscription;
  StreamSubscription<DatabaseEvent>? _bikeSubscription;

  Map<String, int> _currentCarSlots = {};
  Map<String, int> _currentBikeSlots = {};

  String? _selectedSlot;

  Map<String, int> get currentCarSlots => _currentCarSlots;
  Map<String, int> get currentBikeSlots => _currentBikeSlots;

  String? get selectedSlot => _selectedSlot;
  set selectedSlot(String? slot) {
    _selectedSlot = slot;
    notifyListeners();
  }

  void listenToParkingSpace(String name) {
    _carSubscription?.cancel();
    _bikeSubscription?.cancel();
    _carSubscription = _databaseReference
        .child(name)
        .child('car slots')
        .onValue
        .listen((event) {
      final slots = event.snapshot.value as Map<dynamic, dynamic>;
      _currentCarSlots =
          slots.map((key, value) => MapEntry(key.toString(), value as int));

      notifyListeners();
        });
    _bikeSubscription = _databaseReference
        .child(name)
        .child('bike slots')
        .onValue
        .listen((event) {
      final slots = event.snapshot.value as Map<dynamic, dynamic>;
      _currentBikeSlots =
          slots.map((key, value) => MapEntry(key.toString(), value as int));

      notifyListeners();
        });
  }

  @override
  void dispose() {
    _carSubscription?.cancel();
    _bikeSubscription?.cancel();
    super.dispose();
  }
}
  