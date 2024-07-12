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

import 'package:parking_app/widgets/booking_sheet.dart';

import 'package:parking_app/models/parking_spot.dart';
import 'package:parking_app/widgets/marker_icon.dart';

import 'package:provider/provider.dart';

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
  Marker? searchlocMarker;
  ParkingSpot? _current_booking;
  void openBottomSheet(BuildContext context, ParkingSpot p_spot) {
    if (mounted) {
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return BookingSheet(
            space: p_spot,
          );
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

  Future<void> getLocation(String text) async {
    List<Location> locations = await locationFromAddress(text);

    print(locations.first.longitude);
    setState(() {
      map_controller.move(
          LatLng(locations.first.latitude, locations.first.longitude), 15);
    });
    setState(() {
      searchlocMarker = Marker(
        rotate: true,
        width: 80.0,
        height: 80.0,
        point: LatLng(locations.first.latitude, locations.first.longitude),
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
              floatingActionButton: FloatingActionButton(
                  child: Icon(
                    Icons.my_location,
                    size: 25,
                  ),
                  elevation: 4,
                  backgroundColor: backgroundColor,
                  onPressed: () {
                    locationProvider.determinePosition();
                    map_controller.move(
                        LatLng(locationProvider.currentLocation.latitude,
                            locationProvider.currentLocation.longitude),
                        13);
                  }),
              body: Stack(
                children: [
                  FlutterMap(
                    mapController: map_controller,
                    options: MapOptions(
                      initialCenter: LatLng(11.2588, 75.7804),
                      initialZoom: 13.0,
                      interactionOptions: InteractionOptions(
                          flags: ~InteractiveFlag.doubleTapZoom),
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
                              SizedBox(
                                height: 10,
                              ),
                              _searchbar(),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 10,
                                  ),
                                  _modeButton('Pay Parking'),
                                  SizedBox(
                                    width: 10,
                                  ),
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
                      SizedBox(
                        height: 20,
                      ),
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
