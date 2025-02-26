import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import 'package:latlong2/latlong.dart';
import 'package:parking_app/constants.dart';

import 'package:parking_app/models/location_provider.dart';
import 'package:parking_app/models/parkingspotsnotifier.dart';
import 'package:parking_app/models/vehicle_provider.dart';

import 'package:parking_app/models/parking_spot.dart';
import 'package:parking_app/widgets/booking_sheet.dart';
import 'package:parking_app/widgets/marker_icon.dart';
import 'package:parking_app/widgets/spot_details.dart';
import 'package:parking_app/models/saveParkingLocation.dart';

import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:parking_app/services/notification_service.dart';
import 'dart:math'; // Add this import
import 'package:parking_app/models/polygon_helper.dart';
import 'package:parking_app/models/evparkingspots.dart';
import 'dart:async';
import 'package:parking_app/models/data_saver_response.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key, this.bookingtime, required this.currentposition});
  DateTime? bookingtime;

  Position? currentposition;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late double? latitude, longitude;
  late bool is_booked;
  late LatLng currentcentre;
  final mapController = MapController();

  Timer? _onStreetTimer;
  bool _isInOnStreetArea = false;
  DateTime? _entryTime;

  bool isFindVehicleMode = false;
  Marker? searchlocMarker;

  ParkingSpot? _current_booking;
  ParkingSpot? _nearestSpot; // New member to store the nearest parking spot
  void openBottomSheet(BuildContext context, ParkingSpot p_spot) {
    if (mounted) {
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return p_spot.type == 'booking'
              ? BookingSheet(space: p_spot)
              : SpotDetails(p_spot: p_spot, onTap: () {});
          // return Provider.of<BookingTimerProvider>(context, listen: false)
          //         .booked
          //     ? CustomSheet(
          //         onCancel: () {
          //           // setState(() {
          //           //   is_booked = false;
          //           // });
          //         },
          //         // deadline: widget.bookingtime!.add(Duration(hours: 1)),
          //         // pspot: _current_booking!,
          //       )
          //     : SpotDetails(
          //         p_spot: p_spot,
          //         onTap: () {
          //           setState(() {
          //             Navigator.pop(context);
          //             // is_booked = true;
          //             widget.bookingtime = DateTime.timestamp()
          //                 .add(Duration(hours: 5, minutes: 30));
          //             _current_booking = p_spot;
          //             openBottomSheet(context, p_spot);
          //             Navigator.pop(context);
          //           });
          //           // Open the bottom sheet again after setting is_booked to true
          //           openBottomSheet(context, p_spot);
          //         },
          //       );
        },
      );
    }
  }

  @override
  void dispose() {
    _onStreetTimer?.cancel();
    _proximityTimer?.cancel();
    super.dispose();
  }

  // Future<void> getLocation(String text) async {
  //   List<Location> locations = await locationFromAddress(text);

  //   print(locations.first.longitude);
  //   setState(() {
  //     map_controller.move(
  //         LatLng(locations.first.latitude, locations.first.longitude), 15);
  //   });
  //   setState(() {
  //     searchlocMarker = Marker(
  //       rotate: true,
  //       width: 80.0,
  //       height: 80.0,
  //       point: LatLng(locations.first.latitude, locations.first.longitude),
  //       child: Tooltip(
  //         triggerMode: TooltipTriggerMode.tap,
  //         message: text.capitalize,
  //         child: Icon(
  //           Icons.location_pin,
  //           color: backgroundColor,
  //           size: 32.0,
  //         ),
  //       ),
  //     );
  //   });
  // }

//   void _checkUserPresence() async {
//   if (_entryTime == null || !_isInOnStreetArea) return;

//   print('Entry Time: $_entryTime');
//   print('Is in On-Street Area: $_isInOnStreetArea');

//   final elapsed = DateTime.now().difference(_entryTime!);
//   if (elapsed.inMinutes >= 3) {
//     final locationProvider = Provider.of<LocationProvider>(context, listen: false);
//     final userPosition = locationProvider.currentLocation;

//     final nearbySpots = Provider.of<ParkingSpotsNotifier>(context, listen: false)
//         .parkingSpots
//         .where((spot) {
//           final distance = Geolocator.distanceBetween(
//             userPosition.latitude,
//             userPosition.longitude,
//             spot.latitude,
//             spot.longitude,
//           );
//           return distance <= 10; // 30 meters
//         }).toList();

//         print('Number of nearby spots found: ${nearbySpots.length}');

//     if (nearbySpots.isNotEmpty) {
//       // Show notification
//       print('Nearby parking spot(s) found. Showing notification.');
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text('Parking Spot Nearby'),
//             content: Text('Did you get a parking spot?'),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () {
//                   // Handle 'Yes' response
//                   Navigator.of(context).pop();
//                   // Save data to Firestore or handle as needed
//                 },
//                 child: Text('Yes'),
//               ),
//               TextButton(
//                 onPressed: () {
//                   // Handle 'No' response
//                   Navigator.of(context).pop();
//                   // Save data to Firestore or handle as needed
//                 },
//                 child: Text('No'),
//               ),
//             ],
//           );
//         },
//       );
//       // Stop checking after showing the notification
//       _onStreetTimer?.cancel();
//     }
//   }
// }

  Timer? _proximityTimer; // Timer to track proximity
  bool _alertShown = false; // To track if the alert is already shown

  void _checkUserPresence() async {
    if (_entryTime == null || !_isInOnStreetArea || _alertShown) return;

    print('Entry Time: $_entryTime');
    print('Is in On-Street Area: $_isInOnStreetArea');

    final elapsed = DateTime.now().difference(_entryTime!);
    if (elapsed.inMinutes >= 1) {
      final locationProvider =
          Provider.of<LocationProvider>(context, listen: false);
      final userPosition = locationProvider.currentLocation;

      final nearbySpots =
          Provider.of<ParkingSpotsNotifier>(context, listen: false)
              .parkingSpots
              .where((spot) {
        final distance = Geolocator.distanceBetween(
          userPosition.latitude,
          userPosition.longitude,
          spot.latitude,
          spot.longitude,
        );
        return distance <= 30; // 10 meters
      }).toList();

      print('Number of nearby spots found: ${nearbySpots.length}');

      if (nearbySpots.isNotEmpty) {
        double minDistance = double.infinity;
        ParkingSpot nearestSpot = nearbySpots.first;
        for (ParkingSpot spot in nearbySpots) {
          double d = Geolocator.distanceBetween(
            userPosition.latitude,
            userPosition.longitude,
            spot.latitude,
            spot.longitude,
          );
          if (d < minDistance) {
            minDistance = d;
            nearestSpot = spot;
          }
        }
        _nearestSpot = nearestSpot;
        
        if (_proximityTimer == null) {
          _proximityTimer = Timer(Duration(seconds: 20), () {
            _showParkingAlert(userPosition); // Pass user position to the alert
            _proximityTimer = null;
            // Reset timer after showing alert
          });
        }
      } else {
        _proximityTimer?.cancel();
        _proximityTimer = null;
        _alertShown = false;
      }
    }
  }

  Timer? _stopDurationTimer;
// Assume you have an instance of DataSaver class
  final DataSaverResponse _dataSaver = DataSaverResponse();

// Method to show the parking alert
  void _resetAllTimers() {
    _proximityTimer?.cancel();
    _proximityTimer = null;

    _stopDurationTimer?.cancel();
    _stopDurationTimer = null;

    _alertShown = false;
    _entryTime = null;
    print("All timers and states reset.");
  }

  void _showParkingAlert(Position userPosition) {
    if (_alertShown) return; // Prevent showing the alert again if already shown
    if (_nearestSpot == null) return; // Ensure nearest spot is set

    _alertShown = true;
    print('Nearby parking spot(s) found. Showing notification.');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Parking Spot Nearby'),
          content: Text('Did you get a parking spot?'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _dataSaver.saveParkingSpotResponse(
                  response: 'Yes',
                  location: userPosition,
                  entryTime: _entryTime!,
                  spotName: _nearestSpot!.name, // Using _nearestSpot
                );
                _resetAllTimers(); // Reset all timers after the response
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _dataSaver.saveParkingSpotResponse(
                    response: 'No',
                    location: userPosition,
                    entryTime: _entryTime!,
                    spotName: _nearestSpot!.name // Pass entry time when saving
                    );
                _resetAllTimers(); // Reset all timers after the response
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  void _resetProximityState() {
    // Reset the alertShown flag and any other relevant state
    _alertShown = false;
    _proximityTimer?.cancel();
    _proximityTimer = null;
  }

  void showNearbyParkingSpots(List<ParkingSpot> nearbynSpots) {
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
            ListTile(
              title: Text('Find Nearby EV Charging Spots'),
              tileColor: Color.fromARGB(255, 106, 233, 111),
              leading: Icon(
                Icons.bolt,
                color: Colors.yellow, // Yellow color for the symbol
              ),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: Text('TATA'),
                          subtitle: Text('2 charging points are free'),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          title: Text('Aether'),
                          subtitle: Text(
                              'No charging point available for the time being'),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                        // Add more items as needed
                      ],
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    const c = cos;
    final a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // Distance in kilometers
  }

  Future<void> getLocation(String text) async {
    try {
      // Geocode the location text to get latitude and longitude
      List<Location> locations = await locationFromAddress(text);
      final searchedLocation =
          LatLng(locations.first.latitude, locations.first.longitude);

      print(
          'Searched location: ${searchedLocation.latitude}, ${searchedLocation.longitude}');

      // Move the map to the searched location
      setState(() {
        map_controller.move(searchedLocation, 15);
      });

      // Create a marker for the searched location
      setState(() {
        searchlocMarker = Marker(
          rotate: true,
          width: 80.0,
          height: 80.0,
          point: searchedLocation,
          child: Tooltip(
            triggerMode: TooltipTriggerMode.tap,
            message: text.capitalize,
            child: Icon(
              Icons.location_pin,
              color: backgroundColor,
              size: 32.0,
            ),
          ),
        );
      });

      // Filter nearby parking spots
      final nearbySpots =
          Provider.of<ParkingSpotsNotifier>(context, listen: false)
              .parkingSpots
              .where((spot) {
        final distance = calculateDistance(searchedLocation.latitude,
            searchedLocation.longitude, spot.latitude, spot.longitude);
        return distance <= 5.0; // 5 km radius
      }).toList();

      // _nearbyNewSpots = Provider.of<ParkingSpotsNotifier>(context, listen: false)
      //   .parkingSpots
      //   .where((spot) {
      //     final distance = calculateDistance(
      //         currentcentre.latitude, currentcentre.longitude, spot.latitude, spot.longitude);
      //     return distance <= 1.0;
      //   }).toList();

      // Display the nearby parking spots in a modal
      showNearbyParkingSpots(nearbySpots);
    } catch (e) {
      // Handle error, possibly showing a snackbar or dialog
      print('Error finding location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not find location. Please try again.')),
      );
    }
  }

  final map_controller = MapController();
  final text_controller = TextEditingController();

  @override
  void initState() {
    is_booked = widget.bookingtime != null;
    print(widget.currentposition);
    setState(() {
      print('latitude is null');
      latitude = widget.currentposition != null
          ? widget.currentposition!.latitude
          : 20.5937;
      longitude = widget.currentposition != null
          ? widget.currentposition!.longitude
          : 78.9629;
    });

    super.initState();
    Provider.of<ParkingSpotsNotifier>(context, listen: false)
        .setbookingMarkers();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, child) {
        return Consumer<ParkingSpotsNotifier>(
          builder: (context, notifier, child) {
            return Scaffold(
              floatingActionButton: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    onPressed: () {
                      locationProvider.determinePosition();
                      map_controller.move(
                        LatLng(locationProvider.currentLocation.latitude,
                            locationProvider.currentLocation.longitude),
                        13,
                      );
                    },
                    child: Icon(
                      Icons.my_location,
                      size: 25,
                    ),
                    elevation: 4,
                    backgroundColor: backgroundColor,
                  ),
                  SizedBox(width: 16),
                  FloatingActionButton(
                    onPressed: () async {
                      await locationProvider
                          .determinePosition(); // Check and request location services
                      if (!locationProvider.serviceEnabled) {
                        // Show notification if location services are not enabled
                        NotificationService.showInstantNotification(
                            "Location Not Enabled",
                            "Please enable location services to save or find your vehicle.");
                        return;
                      }
                      if (isFindVehicleMode) {
                        await SaveParkingLocation(context, locationProvider)
                            .navigateToSavedLocation();
                        setState(() {
                          isFindVehicleMode = false;
                        });
                      } else {
                        await SaveParkingLocation(context, locationProvider)
                            .saveCurrentLocation();
                        NotificationService.showInstantNotification(
                            "Location Saved",
                            "You can use the directions to get back to your vehicle.");
                        setState(() {
                          isFindVehicleMode = true;
                        });
                      }
                    },
                    child: Icon(
                      isFindVehicleMode ? Icons.directions : Icons.bookmark,
                      size: 25,
                    ),
                    elevation: 4,
                    backgroundColor: backgroundColor,
                    tooltip: isFindVehicleMode
                        ? 'Find My Vehicle'
                        : 'Remember this Spot',
                  ),
                ],
              ),
              body: Stack(
                children: [
                  FlutterMap(
                    mapController: map_controller,
                    options: MapOptions(
                      initialCenter: LatLng(11.2588, 75.7804),
                      initialZoom: 13.0,
                    ),
                    children: [
                      openStreetMapTileLayer,
                      CurrentLocationLayer(
                        alignPositionOnUpdate: AlignOnUpdate.once,
                        alignDirectionOnUpdate: AlignOnUpdate.never,
                      ),
                      MarkerLayer(markers: [
                        if (searchlocMarker != null) searchlocMarker!,
                        ...notifier.parkingSpots.map((spot) {
                          return Marker(
                            rotate: true,
                            point: LatLng(spot.latitude, spot.longitude),
                            child: InkWell(
                              child: MarkerIcon(
                                spot: spot,
                              ),
                              onTap: () => openBottomSheet(context, spot),
                            ),
                          );
                        }),
                      ]),
                      PolygonLayer(
                        polygons: PolygonHelper.createPolygons(),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.25,
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(height: 10),
                              _searchbar(),
                              Row(
                                children: [
                                  SizedBox(width: 10),
                                  _modeButton('Pay Parking'),
                                  SizedBox(width: 10),
                                  _modeButton('On-Street'),
                                  Spacer(),
                                  _vehicleButton('car'),
                                  _vehicleButton('bike'),
                                  SizedBox(width: 20),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _selectedMode = 'Pay Parking';

  Widget _vehicleButton(String vehicle) {
    return Consumer<VehicleProvider>(
        builder: (context, vehicleProvider, child) {
      bool isSelected = vehicleProvider.selectedVehicle == vehicle;
      return IconButton(
        onPressed: () {
          vehicleProvider.selectVehicle(vehicle);
        },
        icon: vehicle == 'car'
            ? Icon(Icons.directions_car)
            : Icon(Icons.motorcycle_sharp),
        style: IconButton.styleFrom(
          foregroundColor: isSelected ? backgroundColor : Colors.black,
          backgroundColor: isSelected ? Colors.white : backgroundColor,
        ),
      );
    });
  }

  Widget _modeButton(String text) {
    bool isSelected = _selectedMode == text;

    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedMode = text;
        });
        if (text == 'On-Street') {
          // Start timer
          _isInOnStreetArea = true;
          _entryTime = DateTime.now();
          _onStreetTimer?.cancel();
          _onStreetTimer = Timer.periodic(Duration(seconds: 10), (timer) {
            _checkUserPresence();
          });
        } else {
          _isInOnStreetArea = false;
          _entryTime = null;
          _onStreetTimer?.cancel();
        }
        if (text == 'Pay Parking') {
          Provider.of<ParkingSpotsNotifier>(context, listen: false)
              .setbookingMarkers();
        } else if (text == 'On-Street') {
          Provider.of<ParkingSpotsNotifier>(context, listen: false)
              .setOnStreetMarkers();
        }
      },
      child: Text(text),
      style: ElevatedButton.styleFrom(
        elevation: 0,
        foregroundColor: isSelected ? backgroundColor : Colors.black,
        backgroundColor: isSelected ? Colors.white : backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
      ),
    );
  }

  Widget _searchbar() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(0),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5),
            )
          ]),
      margin: EdgeInsets.symmetric(
        horizontal: 10,
      ),
      child: TextField(
        onSubmitted: (String value) {
          getLocation(value);
          FocusManager.instance.primaryFocus?.unfocus();
        },
        controller: text_controller,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          hintText: 'Where are you heading to?',
          suffixIcon: IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                getLocation(text_controller.text);
                FocusManager.instance.primaryFocus?.unfocus();
              }),
        ),
      ),
    );
  }
}

TileLayer get openStreetMapTileLayer {
  return TileLayer(
    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
    userAgentPackageName: 'dev.fleaflet.flutter_map.example',
  );
}
