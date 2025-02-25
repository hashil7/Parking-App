import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:parking_app/services/auth_service.dart';

class DataSaverResponse {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveParkingSpotResponse({
    required String response,
    required Position location,
    required DateTime entryTime,
    required String spotName, // Add entryTime as a named parameter
  }) async {
    try {
      // Store the reference returned by add() to get the document ID
      DocumentReference responseRef =
          await _firestore.collection('parking_spot_responses').add({
        'response': response,
        'latitude': location.latitude,
        'longitude': location.longitude,
        'timestamp': DateTime.now().toIso8601String(),
        'on_street_entryTime': entryTime.toIso8601String(),
      });
      String responseDocId = responseRef.id;
      print('Parking spot response saved with id: $responseDocId');

      QuerySnapshot predictionSnapshot = await FirebaseFirestore.instance
          .collection('predictions')
          .where('userId', isEqualTo: AuthService.user?.uid ?? 'guest')
          .where('spotName', isEqualTo: spotName)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (predictionSnapshot.docs.isNotEmpty) {
        DocumentReference predictionDocRef =
            predictionSnapshot.docs.first.reference;
        // Update the prediction document with the response details
        await predictionDocRef.update({
          'responseDocId': responseDocId,
          'response': response,
        });
      }
    } catch (e) {
      print('Error saving parking spot response to Firestore: $e');
    }
  }
}
