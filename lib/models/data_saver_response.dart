import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';



class DataSaverResponse {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


 Future<void> saveParkingSpotResponse({
  required String response,
  required Position location,
  required DateTime entryTime, 
  required List<String> nearbySpots,
}) async {
  try {
    await _firestore.collection('parking_spot_responses').add({
      'response': response,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'timestamp': DateTime.now().toIso8601String(),
      'on_street_entryTime': entryTime.toIso8601String(),
      'nearbySpots':nearbySpots // Save entryTime in Firestore
    });
    print('Parking spot response saved to Firestore');
  } catch (e) {
    print('Error saving parking spot response to Firestore: $e');
  }
}
}

