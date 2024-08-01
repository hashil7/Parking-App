import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gradient_circular_progress_indicator/gradient_circular_progress_indicator.dart';
import 'package:parking_app/constants.dart';
import 'package:parking_app/models/bookingtimer_provider.dart';
import 'package:parking_app/models/tabindex_provider.dart';
import 'package:parking_app/services/sp_repository.dart';
import 'package:provider/provider.dart';

class BookingTimer extends StatelessWidget {
  BookingTimer({super.key, required this.onCancel});
  VoidCallback onCancel;
  @override
  Widget build(BuildContext context) {
    return Consumer<TabIndex>(builder: (context, index, child) {
      return Consumer<BookingTimerProvider>(
        builder: (context, bookingTimerProvider, child) {
          Duration remainingTime = bookingTimerProvider.remainingTime;
          Duration bufferTime = bookingTimerProvider.bufferTime;
          double progress = remainingTime.inSeconds /
              BookingTimerProvider.totalTime.inSeconds;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Transform.scale(
                scale: 0.8,
                child: Stack(children: [
                  Image(
                    image: AssetImage('assets/images/Vector.jpg'),
                    alignment: Alignment.center,
                  ),
                  Positioned(
                    top: 68.5,
                    left: 14.5,
                    child: Container(
                      width: 167,
                      height: 164,
                      padding: EdgeInsets.only(),
                      child: GradientCircularProgressIndicator(
                        progress: progress,
                        stroke: 11,
                        backgroundColor: Color(0xFFCEE0F4),
                        gradient: LinearGradient(colors: [
                          Color(0xFF3B77DC),
                          Color(0xFF8D71FA),
                        ]),
                      ),
                    ),
                  ),
                ]),
              ),
              Text(
                'Get QR scanned within',
                style: TextStyle(
                  color: Color(0xFF8498B4),
                  fontSize: 20,
                ),
              ),
              Text(
                '${remainingTime.inMinutes}:${(remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF203D65),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    // gradient: purpleButtonColour,
                    ),
                child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all(backgroundColor)),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: Colors.white,
                            content: _addTimeDialog(context),
                          );
                        });
                  },
                  child: Text(
                    'Add Time +',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(bookingTimerProvider.parked
                      ? 'Your Parking Time has started'
                      : 'Your Parking Time starts in: '),
                  Text(
                    bookingTimerProvider.parked
                        ? ''
                        : '${bufferTime.inMinutes}:${(bufferTime.inSeconds % 60).toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF203D65),
                    ),
                  ),
                ],
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.2,
                decoration: BoxDecoration(
                    // gradient: purpleButtonColour,
                    ),
                child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(backgroundColor),
                      padding: WidgetStateProperty.all(EdgeInsets.all(8)),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      index.currentIndex = 2;
                    },
                    child: Image(
                      color: Colors.white,
                      image: AssetImage('assets/images/qr.png'),
                    )),
              ),
              SizedBox(
                height: 10,
              ),
              TextButton(
                onPressed: () {
                  bookingTimerProvider.cancel_booking();
                  onCancel();
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Color(0xFF8498B4)),
                ),
              ),
            ],
          );
        },
      );
    });
  }

  Widget _addTimeDialog(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      color: Colors.white,
      child: Column(children: [
        SizedBox(
          height: 10,
        ),
        Image(
          image: AssetImage('assets/images/car_pic.png'),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          'Addon Time',
          style: GoogleFonts.saira(
            color: Color(0xFF333E63),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          'Buy additional time to get the QR scanned',
          style: TextStyle(
            color: Color(0xFF6E819B),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 15,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Provider.of<BookingTimerProvider>(context, listen: false)
                    .addTime(Duration(minutes: 15));
              },
              child: Text(
                '+15 min\nfor 10 INR',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: backgroundColor,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {},
                child: Text(
                  '+30 min\nfor 20 INR',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ))
          ],
        )
      ]),
    );
  }
}
