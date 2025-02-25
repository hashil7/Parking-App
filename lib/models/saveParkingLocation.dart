// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:geolocator/geolocator.dart';

// void saveCurrentLocationToFirestore(Position position) async {
//     final firestore = FirebaseFirestore.instance;

//     try {
//       await firestore.collection('saved_parking_locations').add({
//         'latitude': position.latitude,
//         'longitude': position.longitude,
//         'timestamp': FieldValue.serverTimestamp(),
//       });

//       print('Saved current location: ${position.latitude}, ${position.longitude}');
//     } catch (e) {
//       print('Error saving location: $e');
//     }
//   }


// TileLayer get openStreetMapTileLayer {
//   return TileLayer(
//     urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
//     userAgentPackageName: 'dev.fleaflet.flutter_map.example',
//   );
// }

// import 'package:shared_preferences/shared_preferences.dart';

// Future<void> saveCurrentLocationToLocal(Position position) async {
//   final prefs = await SharedPreferences.getInstance();

//   await prefs.setDouble('latitude', position.latitude);
//   await prefs.setDouble('longitude', position.longitude);

//   print('Saved current location to local storage: ${position.latitude}, ${position.longitude}');
// }


import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'location_provider.dart'; // Assuming you have a LocationProvider file

class LocationService {
  static const String _latitudeKey = 'latitude';
  static const String _longitudeKey = 'longitude';

  Future<void> saveLocation(double latitude, double longitude) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_latitudeKey, latitude);
    await prefs.setDouble(_longitudeKey, longitude);
  }

  Future<Map<String, double>?> getLocation() async {
    final prefs = await SharedPreferences.getInstance();
    double? latitude = prefs.getDouble(_latitudeKey);
    double? longitude = prefs.getDouble(_longitudeKey);

    if (latitude != null && longitude != null) {
      return {'latitude': latitude, 'longitude': longitude};
    }
    return null;
  }

  Future<void> clearLocation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_latitudeKey);
    await prefs.remove(_longitudeKey);
  }
}

class SaveParkingLocation {
  final BuildContext context;
  final LocationProvider locationProvider;

  SaveParkingLocation(this.context, this.locationProvider);

  Future<void> saveCurrentLocation() async {
    LocationService locationService = LocationService();
    final position = locationProvider.currentLocation;
    await locationService.saveLocation(position.latitude, position.longitude);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location saved')),
    );

  }

  Future<void> navigateToSavedLocation() async {
    LocationService locationService = LocationService();
    final savedLocation = await locationService.getLocation();

    if (savedLocation != null) {
      final Uri url = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=${savedLocation['latitude']},${savedLocation['longitude']}&travelmode=driving');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch Google Maps')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No saved location found')),
      );
    }
  }
}


