import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'dart:math';

class SpotDetails extends StatefulWidget {
  const SpotDetails({super.key, required this.p_spot, required this.onTap});
  final ParkingSpot p_spot;
  final VoidCallback onTap;

  @override
  State<SpotDetails> createState() => _SpotDetailsState();
}

class _SpotDetailsState extends State<SpotDetails> with WidgetsBindingObserver {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  int _currentIndex = 0;
  late Map<String, dynamic> jsonData;
  int occupancyPercent = 0;
  List<String> locationImages = [];
  late String previousImageUrl;

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
      print("duration: ${duration}");
      return duration;
    } else {
      throw Exception('Failed to load duration');
    }
  }

  Coords origin = Coords(0, 0);

  DateTime? deadline;
  double? probability;
  Future<Map<String, dynamic>> loadJsonData() async {
    DatabaseEvent event =
        await _database.child('onstreet_spots/${widget.p_spot.name}').once();
    DataSnapshot snapshot = event.snapshot;
    return Map<String, dynamic>.from(snapshot.value as Map);
  }

  int getOccupancyPercent(Map<String, dynamic> data, String day, int hour) {
    Map<String, dynamic> dayData =
        Map<String, dynamic>.from(data['popularTimes'][day]);
    if (dayData.containsKey(hour.toString())) {
      return dayData[hour.toString()];
    }
    return 0; // Return 0 if no data is found for the given day and hour
  }

  String getDayString(int weekday) {
    switch (weekday) {
      case DateTime.sunday:
        return 'Su';
      case DateTime.monday:
        return 'Mo';
      case DateTime.tuesday:
        return 'Tu';
      case DateTime.wednesday:
        return 'We';
      case DateTime.thursday:
        return 'Th';
      case DateTime.friday:
        return 'Fr';
      case DateTime.saturday:
        return 'Sa';
      default:
        return '';
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadJsonData().then((data) {
      setState(() {
        jsonData = data;
        DateTime now = DateTime.now();
        String currentDay = getDayString(now.weekday);
        int currentHour = now.hour;
        occupancyPercent =
            getOccupancyPercent(jsonData, currentDay, currentHour);
        print('Current Day: $currentDay');
        print('Current Hour: $currentHour');
        print('Occupancy Percent: $occupancyPercent');
      });
    });
    WidgetsBinding.instance.addObserver(this);
    _imageTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      setState(() {
        _currentIndex =
            (_currentIndex + 1) % (widget.p_spot.locationImage.length);
      });
    });
    //////////////
    if (locationImages.isNotEmpty) {
      previousImageUrl = locationImages[0];
    }
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
          '${updatedSpot.name} has run out of $selectedvehicle spots');
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
            height: MediaQuery.of(context).size.height * 0.50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.white,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            margin: const EdgeInsets.symmetric(horizontal: 15),
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
                            style: const TextStyle(color: Colors.grey),
                          ),
                          // Text(
                          //   'You should do ${updatedSpot.parkingType} Parking',
                          //   style: TextStyle(color: Color.fromARGB(255, 222, 19, 53)),
                          // ),
                          vehicleProvider.selectedVehicle == 'car'
                              ? Text(
                                  'You should do ${updatedSpot.carParkingType} Parking',
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 222, 19, 53)),
                                )
                              : Text(
                                  'You should do ${updatedSpot.bikeParkingType} Parking',
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 222, 19, 53)),
                                ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        widget.p_spot.type == 'booking'
                            ? '₹${widget.p_spot.price}/hr'
                            : '',
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
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

                  // Container(
                  //   width: MediaQuery.of(context).size.width,
                  //   height: MediaQuery.of(context).size.height * 0.23,
                  //   child: FadeInImage(
                  //     fit: BoxFit.cover,
                  //     placeholder: NetworkImage(updatedSpot.locationImage[
                  //         _currentIndex]), // Placeholder is the previous image
                  //     image: NetworkImage(updatedSpot
                  //         .locationImage[_currentIndex]), // The new image
                  //     fadeInDuration: Duration(
                  //         milliseconds: 300), // Adjust the duration as needed
                  //     placeholderErrorBuilder: (context, error, stackTrace) =>
                  //         Image.network(
                  //       previousImageUrl, // Fallback to previous image if the placeholder fails
                  //       fit: BoxFit.cover,
                  //     ),
                  //     imageErrorBuilder: (context, error, stackTrace) =>
                  //         Image.network(
                  //       previousImageUrl, // Fallback to previous image if the image loading fails
                  //       fit: BoxFit.cover,
                  //     ),
                  //   ),
                  // ),

                  Row(
                    children: [
                      vehicleProvider.selectedVehicle == 'car'
                          ? const Icon(
                              Icons.directions_car,
                              color: backgroundColor,
                              size: 25,
                            )
                          : const Icon(
                              Icons.motorcycle,
                              color: backgroundColor,
                              size: 25,
                            ),
                      const SizedBox(
                        width: 5,
                      ),
                      vehicleProvider.selectedVehicle == 'car'
                          ? Text(
                              '${updatedSpot.bigCarSpots} Big Car Spots Available \n ${updatedSpot.freeCarSlots} Small Car Spots Available',
                              style: TextStyle(fontSize: 16, color: textcolor),
                            )
                          : Text(
                              '${updatedSpot.freeBikeSlots} Bike Spots Available',
                              style: TextStyle(fontSize: 16, color: textcolor),
                            ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          Provider.of<NavcheckProvider>(context, listen: false)
                              .isNavigating = true;
                          openMapsSheet();
                        },
                        icon: const Icon(
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
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: backgroundColor,
                            ),
                            child: const Text(
                              'Book Now',
                              style: TextStyle(color: Colors.white),
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
                            print("avgFillingTime: $avgFillingTime");
                            probability =
                                (avgFillingTime * currentSpots * 100) /
                                    duration;
                            probability = probability!.clamp(0, 99);
                            try {
                              await FirebaseFirestore.instance
                                  .collection('predictions')
                                  .add({
                                'probability': probability,
                                'timestamp': FieldValue.serverTimestamp(),
                                'userLocation': {
                                  'latitude':
                                      locationProvider.currentLocation.latitude,
                                  'longitude': locationProvider
                                      .currentLocation.longitude,
                                },
                                'duration': duration,
                                'currentSpots': currentSpots,
                                'avgFillingTime': avgFillingTime,
                                'spotName': widget.p_spot.name,
                                'userId': AuthService.user?.uid,
                                'vehicleType': vehicleProvider.selectedVehicle,
                              });
                            } catch (e) {
                              print('Error saving prediction data: $e');
                            }
                            // probability = 100 - occupancyPercent.toDouble();
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    content: _probability(probability!),
                                  );
                                });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: backgroundColor,
                          ),
                          child: const Text('Predict Availability',
                              style: TextStyle(color: Colors.white)),
                        )
                ]),
          );
        });
      });
    });
  }

  Widget _probability(double probability) {
    String prob = probability.toStringAsFixed(0);
    final Random random = Random();
    final int proba = 97 + random.nextInt(100 - 97 + 1);
    late Color probColor;
    if (probability < 20) {
      probColor = Colors.redAccent;
    } else if (probability < 70) {
      probColor = Colors.orange;
    } else {
      probColor = Colors.green;
    }
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            'Availability Prediction',
            style: GoogleFonts.saira(
                color: const Color(0xFF333E63),
                fontWeight: FontWeight.bold,
                fontSize: 20),
          ),
          Text.rich(
            textAlign: TextAlign.center,
            TextSpan(
              children: [
                const TextSpan(text: 'There is '),
                TextSpan(
                  text: '$prob%',
                  style: TextStyle(color: probColor),
                ),
                const TextSpan(text: ' chance of finding a free spot'),
              ],
              style: const TextStyle(
                color: Color(0xFF6E819B),
                fontSize: 15,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'OK',
                style: TextStyle(color: Colors.white, fontSize: 18),
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
        DateTime.timestamp().add(const Duration(hours: 5, minutes: 30));

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
  return SizedBox(
    height: MediaQuery.of(context).size.height * 0.5,
    child: const Column(
      children: [
        Image(image: AssetImage('assets/images/car_pic.png')),
      ],
    ),
  );
}
