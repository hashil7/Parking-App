import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:parking_app/services/notification_service.dart';
import 'package:location/location.dart';
import 'package:flutter_map/flutter_map.dart'; // Ensure Polygon is imported from here
import 'polygon_helper.dart';
import 'dart:async';
import 'data_saver.dart';
import 'parkingspotsnotifier.dart';
import 'package:provider/provider.dart';
import 'dart:math'; // Add this import
import 'parking_spot.dart'; // Replace with the correct path
import 'package:parking_app/widgets/booking_sheet.dart';
import 'package:parking_app/widgets/spot_details.dart';






class LocationProvider extends ChangeNotifier {
  Position _currentLocation = Position(
    longitude: 75.780411,
    latitude: 11.258753,
    timestamp: DateTime.now(),
    accuracy: 0,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );
  final bool _serviceEnabled = true;
  Location location = Location();
  List<Polygon> polygons = PolygonHelper.createPolygons();

  DateTime? _stopTime;
  Timer? _stopTimer;
  bool _isInsidePolygon = false;
  bool _notificationShown = false; // Flag to track if notification has been shown
  final GlobalKey<NavigatorState> navigatorKey;
    final DataSaver _dataSaver = DataSaver(); // Initialize your DataSaver instance
    final bool _insidePolygonConfirmed = false; // Declare and initialize the flag



  LocationProvider(this.navigatorKey) {
    _startLocationUpdates();
  }

  bool get serviceEnabled => _serviceEnabled;

  Future<void> determinePosition() async {
    // Your existing code
  }

  void _startLocationUpdates() {
    location.onLocationChanged.listen((LocationData locationData) {
      _currentLocation = Position(
        longitude: locationData.longitude!,
        latitude: locationData.latitude!,
        timestamp: DateTime.now(),
        accuracy: locationData.accuracy ?? 5,
        altitude: locationData.altitude ?? 0,
        altitudeAccuracy: 0,
        heading: locationData.heading ?? 0,
        headingAccuracy: 0,
        speed: locationData.speed ?? 0,
        speedAccuracy: locationData.speedAccuracy ?? 1,
      );
      _checkIfInsidePolygons();
      _monitorSpeedAndStop();
      notifyListeners();
    });
  }

  void _checkIfInsidePolygons() {
    LatLng currentLatLng = LatLng(_currentLocation.latitude, _currentLocation.longitude);
    _isInsidePolygon = false;

    for (Polygon polygon in polygons) {
      if (PolygonHelper.isPointInPolygon(currentLatLng, polygon.points)) {
        _isInsidePolygon = true;
        break;
      }
    }
    print(_isInsidePolygon ? 'Inside a polygon' : 'Outside all polygons');
    if (!_isInsidePolygon) {
      _notificationShown = false; // Reset notification flag when outside all polygons
    }
  }

  
  


void _monitorSpeedAndStop() {
  double speed = _currentLocation.speed;
  //print('Current speed: $speed');

  const double speedThreshold = 1.0; // Speed threshold in m/s
  const Duration stopDuration = Duration(seconds: 10); // Stop duration before showing notification

  if (speed > speedThreshold) {
    //print('Speed above threshold, resetting stop timer.');
    _stopTime = null;
    _stopTimer?.cancel();
    _stopTimer = null;
    _notificationShown = false; // Reset notification flag when the user moves
  } else if (_isInsidePolygon && !_notificationShown) {
    _stopTime ??= DateTime.now();

    _stopTimer?.cancel();

    _stopTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_stopTime != null) {
        final elapsedTime = DateTime.now().difference(_stopTime!);
        //print('Elapsed time: $elapsedTime');

        if (elapsedTime >= stopDuration) {
          //print('User has been stationary inside a polygon for more than $stopDuration');

          // Set notificationShown to true to avoid multiple triggers
          _notificationShown = true;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (navigatorKey.currentState?.overlay != null) {
              // Convert Position to LatLng
              LatLng currentLatLng = LatLng(_currentLocation.latitude, _currentLocation.longitude);

              // Get the current polygon name
              String? currentPolygonName = PolygonHelper.getPolygonName(currentLatLng);

              NotificationService.showPolygonNotification(
                navigatorKey.currentState!.context,
                onYesPressed: () {
                  //print('User confirmed they are inside the polygon.');

                  // Save the user's response, location, speed, stop duration, and polygon name
                  showinsidePolygonNotification(navigatorKey.currentState!.context,);
                  NotificationService.showInstantNotification("This is a no parking zone!", "Please move your vehicle immediatly ");
                  _dataSaver.saveData(
                    response: 'Yes',
                    location: _currentLocation,
                    speed: speed,
                    stopDuration: elapsedTime,
                    polygonName: currentPolygonName, // Include the current polygon name
                  );
                },
                onNoPressed: () {
                  //print('User confirmed they are not inside the polygon.');

                  // Save the user's response, location, speed, and polygon name
                  _dataSaver.saveData(
                    response: 'No',
                    location: _currentLocation,
                    speed: speed,
                    polygonName: currentPolygonName, // Include the current polygon name
                  );
                },
              );
            }
          });

          timer.cancel(); // Stop the periodic timer after sending the notification
          _stopTime = null; // Reset stop time to avoid multiple notifications
        }
      } else {
        timer.cancel(); // Cancel timer if stopTime is null
      }
    });
  } else {
    //print('Outside polygon or moving, stop timer not started.');
    _stopTime = null;
    _stopTimer?.cancel();
    _stopTimer = null;
  }
}

 Future<void> showinsidePolygonNotification(
  BuildContext context,
) async {
  if (context.mounted) {
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
              child: const Text("Find Nearby Parking Spots"),
              onPressed: () {
                Navigator.of(context).pop();
                findNearbyNewSpots(context);

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



Future<void> findNearbyNewSpots(BuildContext context) async {
  final currentLat = _currentLocation.latitude; // Remove null-safety operator
  final currentLng = _currentLocation.longitude; // Remove null-safety operator

  final nearbyNewSpots = Provider.of<ParkingSpotsNotifier>(context, listen: false)
      .parkingSpots
      .where((spot) {
        final distance = calculateDistance(
            currentLat, currentLng, spot.latitude, spot.longitude);
        return distance <= 1.0; // 1 km radius
      }).toList();

  showNearbyParkingSpots(context, nearbyNewSpots);
}

void showNearbyParkingSpots(BuildContext context, List<ParkingSpot> nearbynSpots) {
  // Show a dialog or bottom sheet with the list of nearby spots
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: nearbynSpots.length,
              itemBuilder: (context, index) {
                final spot = nearbynSpots[index];
                return ListTile(
                  title: Text(spot.name),
                  subtitle: Text(spot.address),
                  onTap: () {
                    // Handle parking spot selection
                    openBottomSheet(context, spot);
                  },
                );
              },
            ),
          ),
        ],
      );
    },
  );
}


void openBottomSheet(BuildContext context, ParkingSpot pSpot) {
  // No need for 'mounted' check, we check if 'context' is valid instead.
  if (context.mounted) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return pSpot.type == 'booking'
            ? BookingSheet(space: pSpot)
            : SpotDetails(p_spot: pSpot, onTap: () {});
      },
    );
  } else {
    print('Context is not valid. Cannot show bottom sheet.');
  }
}


double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const p = 0.017453292519943295;
  const c = cos;
  final a = 0.5 - c((lat2 - lat1) * p) / 2 +
      c(lat1 * p) * c(lat2 * p) *
          (1 - c((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a)); // Distance in kilometers
}








  Position get currentLocation => _currentLocation;

  @override
  void dispose() {
    _stopTimer?.cancel();
    super.dispose();
  }
}

