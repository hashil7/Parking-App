import 'package:flutter/material.dart';
import 'package:parking_app/models/parking_spot.dart';

class ParkingSpotsNotifier with ChangeNotifier {
  List<ParkingSpot> _bookingspots, _onstreetspots, _currentspots;

  ParkingSpotsNotifier(this._bookingspots, this._onstreetspots)
      : _currentspots = [];
  List<ParkingSpot> get parkingSpots => _currentspots;

  void setOnStreetMarkers() {
    _currentspots = _onstreetspots;
    print(_currentspots);
    notifyListeners();
  }

  void setbookingMarkers() {
    _currentspots = _bookingspots;
    print(_bookingspots.length);
    notifyListeners();
  }

  void updateSpot(ParkingSpot spot) {
    if (spot.type == 'onstreet') {
      int index = _onstreetspots.indexWhere((s) => s.name == spot.name);
      if (index != -1) {
        _onstreetspots[index] = spot;
        notifyListeners();
      }
    } else if (spot.type == 'booking') {
      int index = _bookingspots.indexWhere((s) => s.name == spot.name);
      if (index != -1) {
        _bookingspots[index] = spot;
        notifyListeners();
      }
    }
  }

  void addSpot(ParkingSpot spot) {
    if (spot.type == 'onstreet') {
      _onstreetspots.add(spot);
      notifyListeners();
    } else if (spot.type == 'booking') {
      _bookingspots.add(spot);
      notifyListeners();
    }
  }

  void setonsStreetSpots(List<ParkingSpot> spots) {
    _onstreetspots = spots;
    notifyListeners();
  }

  void setbookingSpots(List<ParkingSpot> spots) {
    _bookingspots = spots;
    notifyListeners();
  }
}
