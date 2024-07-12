import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:google_fonts/google_fonts.dart';

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

class SpotDetails extends StatefulWidget {
  SpotDetails({super.key, required this.p_spot, required this.onTap});
  final ParkingSpot p_spot;
  final VoidCallback onTap;

  @override
  State<SpotDetails> createState() => _SpotDetailsState();
}

class _SpotDetailsState extends State<SpotDetails> with WidgetsBindingObserver {
  Razorpay razorpay = Razorpay();
  openMapsSheet() async {
    final coords = Coords(widget.p_spot.latitude, widget.p_spot.longitude);
    final title = widget.p_spot.name;
    if (await MapLauncher.isMapAvailable(MapType.google) != null) {
      await MapLauncher.showDirections(
        // origin: origin,
        mapType: MapType.google,
        destination: coords,
      );
    }
  }

  Coords origin = Coords(0, 0);

  DateTime? deadline;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
            height: MediaQuery.of(context).size.height * 0.45,
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
                      updatedSpot.locationImage,
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
                          // locationProvider.determinePosition();
                          // origin = Coords(
                          //   locationProvider.currentLocation.latitude,
                          //   locationProvider.currentLocation.longitude,
                          // );
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
                      : SizedBox()
                ]),
          );
        });
      });
    });
  }

  void handlePaymentSuccess() async {
    Fluttertoast.showToast(msg: 'Payment Success');
    print('Payment Success');

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DateTime bookingTime =
        DateTime.timestamp().add(Duration(hours: 5, minutes: 30));

    // Provider.of<BookingTimerProvider>(context, listen: false)
    //     .saveBookingTimetoFirebase();
    // try {
    //   await saveBookingTime(bookingTime);
    //   print('Successfully Saved');
    // } catch (e) {
    //   print('Shared Pref error: $e');
    // }

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
