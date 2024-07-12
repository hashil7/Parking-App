import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class BookingspotsProvider extends ChangeNotifier {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref('booking_spots');
  StreamSubscription<DatabaseEvent>? _subscription;
  Map<String, int> _currentParkingSlots = {};
  String? _selectedSlot;

  Map<String, int> get currentParkingSlots => _currentParkingSlots;
  String? get selectedSlot => _selectedSlot;
  void set selectedSlot(String? slot) {
    _selectedSlot = slot;
    notifyListeners();
  }

  void listenToParkingSpace(String name) {
    _subscription?.cancel();
    _subscription = _databaseReference
        .child(name)
        .child('car slots')
        .onValue
        .listen((event) {
      if (event.snapshot != null) {
        final slots = event.snapshot.value as Map<dynamic, dynamic>;
        _currentParkingSlots =
            slots.map((key, value) => MapEntry(key.toString(), value as int));
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
