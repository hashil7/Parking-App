import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import 'package:map_launcher/map_launcher.dart';
import 'package:parking_app/constants.dart';
import 'package:parking_app/models/bookingtimer_provider.dart';
import 'package:parking_app/models/location_provider.dart';
import 'package:parking_app/models/navcheck_provider.dart';
import 'package:parking_app/models/parking_spot.dart';
import 'package:parking_app/models/parkingspotsnotifier.dart';
import 'package:parking_app/models/vehicle_provider.dart';
import 'package:parking_app/services/auth_service.dart';
import 'package:parking_app/services/notification_service.dart';
import 'package:parking_app/services/sp_repository.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SpotDetails extends StatefulWidget {
  SpotDetails({super.key, required this.p_spot, required this.onTap});
  final ParkingSpot p_spot;
  final VoidCallback onTap;

  @override
  State<SpotDetails> createState() => _SpotDetailsState();
}

class _SpotDetailsState extends State<SpotDetails> with WidgetsBindingObserver {
  int _currentIndex = 0;
  Timer? _imageTimer;
  int avgFillingTime = 360;
  Razorpay razorpay = Razorpay();
  openMapsSheet() async {
    final coords = Coords(widget.p_spot.latitude, widget.p_spot.longitude);

    if (await MapLauncher.isMapAvailable(MapType.google) != null) {
      await MapLauncher.showDirections(
        // origin: origin,
        mapType: MapType.google,
        destination: coords,
      );
    }
  }

  Future<int> fetchDuration(LatLng origin, LatLng desti) async {
    final url = Uri.parse(
        'https://api.olamaps.io/routing/v1/directions?origin=${origin.latitude}%2C${origin.longitude}&destination=${desti.latitude}%2C${desti.longitude}&alternatives=false&steps=true&overview=full&language=en&traffic_metadata=false&api_key=tD8OsZ5JZnBryze66bMaJ8hmF63W5YHzbWR3Yd4k');

    final response = await http.post(
      url,
      headers: {
        'accept': 'application/json',
        'Authorization':
            'Bearer eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJMRndtX0U2akoyWG5yYkpkS1d1VXl2UllUN25lZ0FibDhWLXVSTno3UzZVIn0.eyJleHAiOjE3MjA5NTU4NTksImlhdCI6MTcyMDk1MjI1OSwianRpIjoiMmNlMzJhOWEtYjFmOC00OGYwLWI3NTYtNDM1NjFmYWNiMzUyIiwiaXNzIjoiaHR0cHM6Ly9hY2NvdW50Lm9sYW1hcHMuaW8vcmVhbG1zL29sYW1hcHMiLCJzdWIiOiJjM2E4MzkxOC00Y2RmLTRkYWUtYWQ3ZC1jN2Q4ZTNiNjQwNjMiLCJ0eXAiOiJCZWFyZXIiLCJhenAiOiI4YWM1NzlhMS0yNWQ3LTRiMzktOTU0YS1iNDQxNTg4YWE0ZWUiLCJhY3IiOiIxIiwiYWxsb3dlZC1vcmlnaW5zIjpbIioiXSwicmVhbG1fYWNjZXNzIjp7InJvbGVzIjpbIlNCTi0wMmRmZjM1OC1kOGNiLTQ2NDgtYjgxZi1jY2NhNTQzNjkyYTUiLCJkZWZhdWx0LXJvbGVzLW9sYW1hcHMiLCJPUkctRHNocmJCVUZtcyJdfSwic2NvcGUiOiJvcGVuaWQgcHJvZmlsZSBlbWFpbCIsImVtYWlsX3ZlcmlmaWVkIjpmYWxzZSwiY2xpZW50SG9zdCI6IjEwLjM3LjkuNzciLCJvcmciOiJPUkctRHNocmJCVUZtcyIsIm9yZzEiOnt9LCJyZWFsbSI6Im9sYW1hcHMiLCJwcmVmZXJyZWRfdXNlcm5hbWUiOiJzZXJ2aWNlLWFjY291bnQtOGFjNTc5YTEtMjVkNy00YjM5LTk1NGEtYjQ0MTU4OGFhNGVlIiwiY2xpZW50QWRkcmVzcyI6IjEwLjM3LjkuNzciLCJjbGllbnRfaWQiOiI4YWM1NzlhMS0yNWQ3LTRiMzktOTU0YS1iNDQxNTg4YWE0ZWUiLCJzYm4iOiJTQk4tMDJkZmYzNTgtZDhjYi00NjQ4LWI4MWYtY2NjYTU0MzY5MmE1In0.gHhio3FjWnL0xLUd9OhgsMDIfe3qj0ujloVTPDvIuwG6BRFx8wllKRFxJ-UNxfoDZ01dTkLkAsWaZEfb0gxWckBZO41yYv62fSi8THjmLpKzku8r1Lpc8trWJHT-ca0Opl9VnGmjADTMw95pNGNTPLRZ_pNt4PPnmTwLtwq_t6EsDt16liEX3dANIDCtvv7EkFAxyogDHNvvsgnNEe_SlKggUEnyFs8kYafSrc_mYdcB5rUFAFXPrnQ7RRpnTYPT1GXhC1uSQV8QL2o4yzZG7SFI7HH-Azs37ytTwnyDfeT7N6unegvYjJ---vdtQXJWQ3gxq0eW0tj-iBS0h5dxnA',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final duration = json['routes'][0]['legs'][0]['duration'];
      print(duration);
      return duration;
    } else {
      throw Exception('Failed to load duration');
    }
  }

  Coords origin = Coords(0, 0);

  DateTime? deadline;
  double? probability;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _imageTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      setState(() {
        _currentIndex =
            (_currentIndex + 1) % (widget.p_spot.locationImage.length);
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
    try {
      razorpay.clear();
    } catch (e) {
      print(e);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused &&
        Provider.of<NavcheckProvider>(context, listen: false).isNavigating ==
            true) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          Provider.of<ParkingSpotsNotifier>(context, listen: false)
              .addListener(_checkSlots);
        },
      );
    } else if (state == AppLifecycleState.resumed) {
      Provider.of<ParkingSpotsNotifier>(context, listen: false)
          .removeListener(_checkSlots);
      NotificationService.cancelAllNotifications();
      Provider.of<NavcheckProvider>(context, listen: false).isNavigating =
          false;
    }
  }

  void _checkSlots() {
    var updatedSpot = Provider.of<ParkingSpotsNotifier>(context, listen: false)
        .parkingSpots
        .firstWhere((spot) => spot.name == widget.p_spot.name,
            orElse: () => widget.p_spot);
    String selectedvehicle =
        Provider.of<VehicleProvider>(context, listen: false).selectedVehicle;
    if (selectedvehicle == 'car' && updatedSpot.freeCarSlots == 0 ||
        selectedvehicle == 'bike' && updatedSpot.freeBikeSlots == 0) {
      NotificationService.showInstantNotification('Oh No!',
          '${updatedSpot.name} has run out of ${selectedvehicle} spots');
    }
  }

  Future<void> saveBookingTime(DateTime bookingTime) async {
    SharedPreferenceRepository.instance
        .setKeyValue(bookingTimerKey, bookingTime.toIso8601String());
  }

  @override
  Widget build(BuildContext context) {
    // razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentFailure);

    return Consumer<LocationProvider>(
        builder: (context, locationProvider, child) {
      return Consumer<VehicleProvider>(
          builder: (context, vehicleProvider, child) {
        return Consumer<ParkingSpotsNotifier>(
            builder: (context, notifier, child) {
          var updatedSpot = notifier.parkingSpots.firstWhere(
              (spot) => spot.name == widget.p_spot.name,
              orElse: () => widget.p_spot);
          Color textcolor;
          if (vehicleProvider.selectedVehicle == 'car') {
            if (updatedSpot.freeCarSlots < 6 && updatedSpot.freeCarSlots >= 3) {
              textcolor = Colors.orange;
            } else if (updatedSpot.freeCarSlots < 3) {
              textcolor = Colors.red;
            } else {
              textcolor = Colors.green;
            }
          } else {
            if (updatedSpot.freeBikeSlots < 6 &&
                updatedSpot.freeBikeSlots >= 3) {
              textcolor = Colors.orange;
            } else if (updatedSpot.freeBikeSlots < 3) {
              textcolor = Colors.red;
            } else {
              textcolor = Colors.green;
            }
          }
          return Container(
            width: MediaQuery.of(context).size.width * 1,
            height: MediaQuery.of(context).size.height * 0.47,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.white,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            margin: EdgeInsets.symmetric(horizontal: 15),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            updatedSpot.name,
                            style: GoogleFonts.lato(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            updatedSpot.address,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      Spacer(),
                      Text(
                        widget.p_spot.type == 'booking'
                            ? '₹${widget.p_spot.price}/hr'
                            : '',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(width: 10),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.23,
                    child: Image.network(
                      updatedSpot.locationImage[_currentIndex],
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded
                                        .toDouble() /
                                    loadingProgress.expectedTotalBytes!
                                        .toDouble()
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                  Row(
                    children: [
                      vehicleProvider.selectedVehicle == 'car'
                          ? Icon(
                              Icons.directions_car,
                              color: backgroundColor,
                              size: 25,
                            )
                          : Icon(
                              Icons.motorcycle,
                              color: backgroundColor,
                              size: 25,
                            ),
                      SizedBox(
                        width: 5,
                      ),
                      vehicleProvider.selectedVehicle == 'car'
                          ? Text(
                              '${updatedSpot.freeCarSlots} Car Spots Available',
                              style: TextStyle(fontSize: 16, color: textcolor),
                            )
                          : Text(
                              '${updatedSpot.freeBikeSlots} Bike Spots Available',
                              style: TextStyle(fontSize: 16, color: textcolor),
                            ),
                      Spacer(),
                      IconButton(
                        onPressed: () {
                          Provider.of<NavcheckProvider>(context, listen: false)
                              .isNavigating = true;
                          openMapsSheet();
                        },
                        icon: Icon(
                          Icons.directions,
                          size: 40,
                          color: backgroundColor,
                        ),
                      ),
                    ],
                  ),
                  widget.p_spot.type == 'booking'
                      ? Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (AuthService.user == null) {
                                Fluttertoast.showToast(
                                    msg:
                                        'Please sign in to reserve parking spaces');
                                return;
                              }
                              var options = {
                                'key': 'rzp_test_GcZZFDPP0jHtC4',
                                'amount': 2000,
                                'name': 'Hashil',
                                'description': 'Pay Parking',
                                'prefill': {
                                  'contact': '8848577368',
                                  'email': 'hashilmuhammed7@gmail.com'
                                }
                              };

                              // razorpay.open(options);
                              // showDialog(
                              //     context: context,
                              //     builder: (BuildContext context) {
                              //       return AlertDialog(
                              //         content: _timerDisclaimer(context),
                              //       );
                              //     });
                              handlePaymentSuccess();
                            },
                            child: Text(
                              'Book Now',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: backgroundColor,
                            ),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () async {
                            locationProvider.determinePosition();
                            if (locationProvider.serviceEnabled == false) {
                              Fluttertoast.showToast(
                                msg: 'Please Enable Location Services',
                                gravity: ToastGravity.TOP,
                                backgroundColor: backgroundColor,
                                textColor: Colors.white,
                              );

                              return;
                            }
                            int duration = await fetchDuration(
                                LatLng(
                                    locationProvider.currentLocation.latitude,
                                    locationProvider.currentLocation.longitude),
                                LatLng(widget.p_spot.latitude,
                                    widget.p_spot.longitude));

                            int currentSpots =
                                vehicleProvider.selectedVehicle == 'car'
                                    ? updatedSpot.freeCarSlots
                                    : updatedSpot.freeBikeSlots;
                            avgFillingTime =
                                widget.p_spot.avgFillingTime ?? 360;
                            probability =
                                (avgFillingTime * currentSpots * 100) /
                                    duration;

                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    content: _probability(probability!),
                                  );
                                });
                          },
                          child: Text('Predict Availability',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: backgroundColor,
                          ),
                        )
                ]),
          );
        });
      });
    });
  }

  Widget _probability(double probability) {
    probability = probability.clamp(0, 99);
    String prob = probability.toStringAsFixed(0);
    late Color probColor;
    if (probability < 20) {
      probColor = Colors.redAccent;
    } else if (probability < 70) {
      probColor = Colors.orange;
    } else {
      probColor = Colors.green;
    }
    return Container(
      height: MediaQuery.of(context).size.height * 0.2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            'Availability Prediction',
            style: GoogleFonts.saira(
                color: Color(0xFF333E63),
                fontWeight: FontWeight.bold,
                fontSize: 20),
          ),
          Text.rich(
            textAlign: TextAlign.center,
            TextSpan(
              children: [
                TextSpan(text: 'There is '),
                TextSpan(
                  text: '${prob}%',
                  style: TextStyle(color: probColor),
                ),
                TextSpan(text: ' chance of finding a free spot'),
              ],
              style: TextStyle(
                color: Color(0xFF6E819B),
                fontSize: 15,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'OK',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          )
        ],
      ),
    );
  }

  void handlePaymentSuccess() async {
    Fluttertoast.showToast(msg: 'Payment Success');
    print('Payment Success');

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DateTime bookingTime =
        DateTime.timestamp().add(Duration(hours: 5, minutes: 30));

    try {
      print('Saving to firebase');
      await firestore.collection('users').doc(AuthService.user!.uid).update({
        'bookingTime': FieldValue.serverTimestamp(),
        'spot': widget.p_spot.name,
      });
      // Provider.of<BookingTimerProvider>(context, listen: false)
      //     .saveBookingTime(bookingTime);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Booking Error: $e',
      );
      print(e);
    }
  }

  void handlePaymentFailure(PaymentFailureResponse response) {
    Fluttertoast.showToast(msg: 'Payment Failed');
    print('Payment Failed');
  }

  void handlePaymentError() {
    Fluttertoast.showToast(msg: 'Some error');
    print('Some Error');
  }
}

Widget _timerDisclaimer(BuildContext context) {
  return Container(
    height: MediaQuery.of(context).size.height * 0.5,
    child: Column(
      children: [
        Image(image: AssetImage('assets/images/car_pic.png')),
      ],
    ),
  );
}
