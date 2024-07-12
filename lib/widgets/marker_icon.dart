import 'package:flutter/material.dart';
import 'package:parking_app/models/parking_spot.dart';
import 'package:parking_app/models/parkingspotsnotifier.dart';
import 'package:parking_app/models/vehicle_provider.dart';
import 'package:provider/provider.dart';

class MarkerIcon extends StatelessWidget {
  const MarkerIcon({super.key, required this.spot});
  final ParkingSpot spot;

  @override
  Widget build(BuildContext context) {
    return Consumer<VehicleProvider>(
        builder: (context, vehicleProvider, child) {
      return Consumer<ParkingSpotsNotifier>(
          builder: (context, notifier, child) {
        var updatedSpot = notifier.parkingSpots
            .firstWhere((spot) => spot.name == spot.name, orElse: () => spot);
        Color iconColor;
        if (vehicleProvider.selectedVehicle == 'car') {
          if (updatedSpot.freeCarSlots < 6 && updatedSpot.freeCarSlots >= 3)
            iconColor = Colors.orange;
          else if (updatedSpot.freeCarSlots < 3) {
            iconColor = Colors.red;
          } else {
            iconColor = Colors.green;
          }
        } else {
          if (updatedSpot.freeBikeSlots < 6 && updatedSpot.freeBikeSlots >= 3)
            iconColor = Colors.orange;
          else if (updatedSpot.freeBikeSlots < 3) {
            iconColor = Colors.red;
          } else {
            iconColor = Colors.green;
          }
        }
        return Icon(
          Icons.local_parking_sharp,
          color: iconColor,
          size: 30,
        );
      });
    });
  }
}
