import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:parking_app/constants.dart';
import 'package:parking_app/models/bookingspots_provider.dart';
import 'package:parking_app/models/bookingtimer_provider.dart';

import 'package:parking_app/models/parking_spot.dart';

import 'package:parking_app/models/parkingspotsnotifier.dart';
import 'package:parking_app/models/vehicle_provider.dart';

import 'package:parking_app/widgets/booking_timer.dart';
import 'package:provider/provider.dart';

class BookingSheet extends StatefulWidget {
  BookingSheet({super.key, required this.space});
  final ParkingSpot space;

  @override
  State<BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<BookingSheet> {
  final PageController _scrollController = PageController();
  bool _userScroll = false;
  bool _first = true;
  void scroll() {
    if (!_userScroll || _first) {
      _scrollController.animateTo(MediaQuery.of(context).size.width,
          duration: Duration(seconds: 1), curve: Curves.easeInOut);
      _first = false;
    }
  }

  void scrollAnyway() {
    _scrollController.animateTo(MediaQuery.of(context).size.width,
        duration: Duration(seconds: 1), curve: Curves.easeInOut);
  }

  void scrollBack() async {
    await Future.delayed(Duration(seconds: 1));
    _scrollController.animateTo(0,
        duration: Duration(seconds: 1), curve: Curves.easeInOut);
  }

  openMapsSheet() async {
    final coords = Coords(widget.space.latitude, widget.space.longitude);

    if (await MapLauncher.isMapAvailable(MapType.google) != null) {
      await MapLauncher.showDirections(
        // origin: origin,
        mapType: MapType.google,
        destination: coords,
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Provider.of<BookingspotsProvider>(context, listen: false)
        .listenToParkingSpace(
      widget.space.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingTimerProvider>(
      builder: (context, status, child) {
        if (status.booked) {
          scroll();
        }
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            color: Colors.white,
          ),
          height: MediaQuery.of(context).size.height * 0.85,
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.space.name,
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.close))
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          widget.space.address,
                          textAlign: TextAlign.left,
                          style: GoogleFonts.montserrat(
                              fontSize: 14,
                              color: Color(0xFFA5AAB7),
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
              IntrinsicHeight(
                child: Container(
                  color: Color(0xFFE8E8E8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                          onPressed: () {},
                          child: Row(
                            children: [
                              Icon(
                                Icons.call,
                                color: Color(0xFFA5AAB7),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                'Call',
                                style: GoogleFonts.montserrat(
                                  color: Color(0xFFA5AAB7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )),
                      VerticalDivider(
                        color: Color.fromARGB(255, 200, 200, 200),
                        width: 5,
                      ),
                      TextButton(
                          onPressed: openMapsSheet,
                          child: Row(
                            children: [
                              Icon(
                                Icons.directions,
                                color: Color(0xFFA5AAB7),
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Directions',
                                style: GoogleFonts.montserrat(
                                  color: Color(0xFFA5AAB7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )),
                      VerticalDivider(
                        color: Color.fromARGB(255, 200, 200, 200),
                        width: 5,
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Row(
                          children: [
                            Icon(
                              Icons.share,
                              color: Color(0xFFA5AAB7),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              'Share',
                              style: GoogleFonts.montserrat(
                                color: Color(0xFFA5AAB7),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onPanDown: (_) {
                  setState(() {
                    _userScroll = true;
                  });
                },
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.70,
                  child: PageView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    children: [
                      Container(
                        child: _slots(context),
                        width: MediaQuery.of(context).size.width,
                      ),
                      Container(
                        color: Colors.white,
                        width: MediaQuery.of(context).size.width,
                        child: _timerSheet(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _slots(BuildContext context) {
    return Consumer<VehicleProvider>(
      builder: (context, vehicle, child) {
        return Consumer<BookingTimerProvider>(
          builder: (context, status, child) {
            return Consumer<BookingspotsProvider>(
                builder: (context, notifier, child) {
              final carSlots = vehicle.isCar
                  ? notifier.currentCarSlots
                  : notifier.currentBikeSlots;
              final sortedKeys = carSlots.keys.toList()
                ..sort((a, b) => int.parse(a.substring(1))
                    .compareTo(int.parse(b.substring(1))));
              return Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.25,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        widget.space.locationImage[0],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Card(
                          color: Color.fromARGB(255, 217, 217, 217),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              margin: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.02,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pricing',
                                    textAlign: TextAlign.start,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text('<8 hours'),
                                      Spacer(),
                                      Text('₹ 40/hour'),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text('>8 hours'),
                                      Spacer(),
                                      Text('₹ 60/hour'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.15,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        right: 10,
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: carSlots.length,
                        itemBuilder: (context, index) {
                          String slotKey = sortedKeys[index];
                          int slotStatus = carSlots[slotKey]!;
                          if (!status.booked && carSlots.containsValue(0)) {
                            status.slot =
                                sortedKeys.firstWhere((k) => carSlots[k] == 0);
                          }
                          bool isSelected = status.slot == slotKey;

                          return Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey,
                                width: 0.5,
                              ),
                            ),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.12,
                              margin: EdgeInsets.all(10),
                              decoration: isSelected
                                  ? BoxDecoration(
                                      border:
                                          Border.all(color: backgroundColor),
                                      borderRadius: BorderRadius.circular(10),
                                      color: backgroundColor.withOpacity(0.4))
                                  : null,
                              child: Center(
                                child: slotStatus == 1 || slotStatus == 2
                                    ? isSelected && status.booked
                                        ? Text('Booked\n $slotKey')
                                        : Transform.scale(
                                            scale: 1,
                                            child: Image(
                                              image: AssetImage(vehicle.isCar
                                                  ? 'assets/images/car_icon.png'
                                                  : 'assets/images/bike.png'),
                                              opacity: slotStatus == 1
                                                  ? AlwaysStoppedAnimation(0.4)
                                                  : null,
                                            ),
                                          )
                                    : Text('$slotKey'),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 50),
                  _bottomRow(context),
                ],
              );
            });
          },
        );
      },
    );
  }

  Widget _bottomRow(BuildContext context) {
    return Consumer<ParkingSpotsNotifier>(builder: (context, notifier, child) {
      var updatedSpot = notifier.parkingSpots.firstWhere(
          (spot) => spot.name == widget.space.name,
          orElse: () => widget.space);
      Color? textcolor;
      if (Provider.of<VehicleProvider>(context, listen: false)
              .selectedVehicle ==
          'car') {
        if (updatedSpot.freeCarSlots < 6 && updatedSpot.freeCarSlots >= 3) {
          textcolor = Colors.orange;
        } else if (updatedSpot.freeCarSlots < 3) {
          textcolor = Colors.red;
        } else {
          textcolor = Colors.green;
        }
      } else {
        if (updatedSpot.freeBikeSlots < 6 && updatedSpot.freeBikeSlots >= 3) {
          textcolor = Colors.orange;
        } else if (updatedSpot.freeBikeSlots < 3) {
          textcolor = Colors.red;
        } else {
          textcolor = Colors.green;
        }
      }
      return Consumer<BookingTimerProvider>(
        builder: (context, status, child) {
          return Consumer<BookingspotsProvider>(
            builder: (context, spots, child) {
              bool car = Provider.of<VehicleProvider>(context, listen: false)
                      .selectedVehicle ==
                  'car';
              return Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF3F4FF),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            car
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
                              width: 8,
                            ),
                            car
                                ? Text(
                                    '${updatedSpot.freeCarSlots} Car Spots\n Available',
                                    style: TextStyle(
                                        fontSize: 16, color: textcolor),
                                  )
                                : Text(
                                    '${updatedSpot.freeBikeSlots} Bike Spots\n Available',
                                    style: TextStyle(
                                        fontSize: 16, color: textcolor),
                                  ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: (car && updatedSpot.freeCarSlots > 0 ||
                                !car && updatedSpot.freeBikeSlots > 0)
                            ? Container(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: backgroundColor,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                  onPressed: () async {
                                    if (status.slot == null) {
                                      Fluttertoast.showToast(
                                          msg: 'Pick a slot');
                                    } else if (status.booked == false) {
                                      status.booked = true;
                                      status.saveBookingTimetoFirebase(
                                          widget.space.name,
                                          status.slot!,
                                          car ? 'car' : 'bike');
                                      await Future.delayed(
                                          Duration(seconds: 2));
                                      scrollAnyway();
                                    } else {
                                      status.cancel_booking();
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      status.slot == null
                                          ? 'Parking fee: 40 INR per hr'
                                          : !status.booked
                                              ? 'Reserve ${status.slot} for 20 INR'
                                              : 'Cancel Reservation',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    });
  }

  Widget _timerSheet(BuildContext context) {
    return Column(
      children: [
        BookingTimer(
          onCancel: scrollBack,
        ),
      ],
    );
  }
}
