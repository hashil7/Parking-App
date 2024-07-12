import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:parking_app/constants.dart';
import 'package:parking_app/models/bookingspots_provider.dart';
import 'package:parking_app/models/bookingtimer_provider.dart';

import 'package:parking_app/models/parking_spot.dart';
import 'dart:math' as math;

import 'package:parking_app/models/parkingspotsnotifier.dart';

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Provider.of<BookingspotsProvider>(context, listen: false)
        .listenToParkingSpace(widget.space.name);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingTimerProvider>(
      builder: (context, status, child) {
        if (status.booked) {
          scroll();
        }
        return Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height * 0.85,
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.space.name),
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.close))
                ],
              ),
              Text(
                widget.space.address,
                textAlign: TextAlign.left,
              ),
              IntrinsicHeight(
                child: Container(
                  color: Color.fromARGB(39, 158, 158, 158),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(onPressed: () {}, child: Text('Call')),
                      VerticalDivider(
                        color: Colors.grey,
                        width: 10,
                      ),
                      TextButton(onPressed: () {}, child: Text('Directions')),
                      VerticalDivider(
                        color: Colors.grey,
                        width: 10,
                      ),
                      TextButton(onPressed: () {}, child: Text('StreetView')),
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
                  height: MediaQuery.of(context).size.height * 0.71,
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
    return Consumer<BookingTimerProvider>(
      builder: (context, status, child) {
        return Consumer<BookingspotsProvider>(
            builder: (context, notifier, child) {
          final carSlots = notifier.currentParkingSlots;
          final sortedKeys = carSlots.keys.toList()
            ..sort((a, b) =>
                int.parse(a.substring(1)).compareTo(int.parse(b.substring(1))));
          return Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: 5,
                  ),
                  child: GridView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Display in a single row
                      childAspectRatio: 2.5,
                      mainAxisSpacing: 0,
                      crossAxisSpacing: 0,
                    ),
                    itemCount: carSlots.length,
                    itemBuilder: (context, index) {
                      String slotKey = sortedKeys[index];
                      int slotStatus = carSlots[slotKey]!;
                      bool isSelected = status.slot == slotKey;

                      return GestureDetector(
                        onTap: () {
                          if (slotStatus == 1 || slotStatus == 2) {
                            Fluttertoast.showToast(msg: 'Pick a free slot');
                            return;
                          }
                          if (!status.booked) {
                            setState(() {
                              status.slot = isSelected ? null : slotKey;
                            });

                            print(status.slot);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                              width: 0.5,
                            ),
                          ),
                          child: Container(
                            margin: EdgeInsets.all(10),
                            decoration: isSelected && status.slot == slotKey
                                ? BoxDecoration(
                                    border: Border.all(color: backgroundColor),
                                    borderRadius: BorderRadius.circular(10),
                                    color: backgroundColor.withOpacity(0.4))
                                : null,
                            child: Center(
                              child: slotStatus == 1 || slotStatus == 2
                                  ? status.slot != null && isSelected
                                      ? Text('Booked\n $slotKey')
                                      : Transform.scale(
                                          scale: 2.5,
                                          child: Transform.rotate(
                                            angle: index % 2 == 0
                                                ? math.pi / 2
                                                : -math.pi / 2,
                                            child: Image(
                                              image: AssetImage(
                                                  'assets/images/car_icon.png'),
                                              opacity: slotStatus == 1
                                                  ? AlwaysStoppedAnimation(0.6)
                                                  : null,
                                            ),
                                          ),
                                        )
                                  : Text('$slotKey'),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              _bottomRow(context),
            ],
          );
        });
      },
    );
  }

  Widget _bottomRow(BuildContext context) {
    return Consumer<ParkingSpotsNotifier>(builder: (context, notifier, child) {
      var updatedSpot = notifier.parkingSpots.firstWhere(
          (spot) => spot.name == widget.space.name,
          orElse: () => widget.space);
      return Consumer<BookingTimerProvider>(
        builder: (context, status, child) {
          return Consumer<BookingspotsProvider>(
            builder: (context, spots, child) {
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
                            Image(
                                image: AssetImage('assets/images/spot 1.png')),
                            Text('${updatedSpot.freeCarSlots} Spots Available'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                            child: ElevatedButton(
                                onPressed: () async {
                                  if (status.slot == null) {
                                    Fluttertoast.showToast(msg: 'Pick a slot');
                                  } else {
                                    status.saveBookingTimetoFirebase(
                                        widget.space.name, status.slot!);
                                    await Future.delayed(Duration(seconds: 2));
                                    scrollAnyway();
                                  }
                                },
                                child: Text(status.slot == null
                                    ? 'Parking fee: 40 INR per hr'
                                    : !status.booked
                                        ? 'Reserve ${status.slot} for 20 INR'
                                        : 'Cancel Reservation'))),
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
