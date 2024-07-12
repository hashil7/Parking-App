import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';

import 'package:parking_app/constants.dart';
import 'package:parking_app/models/bookingtimer_provider.dart';
import 'package:parking_app/models/location_provider.dart';

import 'package:parking_app/screens/main_page.dart';
import 'package:parking_app/screens/signin_page.dart';
import 'package:parking_app/services/auth_service.dart';
import 'package:parking_app/widgets/type_writer.dart';
import 'package:provider/provider.dart';

// import 'package:typewritertext/typewritertext.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with WidgetsBindingObserver {
  DateTime? bookingtime;
  DateTime? reachingtime;
  Position? currentposition;

  var auth = FirebaseAuth.instance;
  Future<void> _loadBookingTime() async {
    await Provider.of<BookingTimerProvider>(context, listen: false)
        .loadBookingTime();
  }

  void initState() {
    Provider.of<LocationProvider>(context, listen: false).determinePosition();
    // _loadBookingTime();
    if (AuthService.user != null) {
      print(AuthService.user?.displayName.toString());
    }
    WidgetsBinding.instance.addObserver(this);
    Future.wait([Future.delayed(Duration(seconds: 7))]).whenComplete(() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AuthService.user != null
              ? MainPage(
                  currentposition: currentposition,
                  bookingtime: bookingtime,
                )
              : SigninPage(),
        ),
      );
    });

    super.initState();
  }

  // // @override
  // // void didChangeAppLifecycleState(AppLifecycleState state) {
  // //   if (state == AppLifecycleState.resumed) {
  // //     Provider.of<BookingTimerProvider>(context, listen: false)
  // //         .loadBookingTime();
  // //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: backgroundColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 100,
            ),
            SvgPicture.asset(
              'assets/images/Group 92.svg',
              height: MediaQuery.of(context).size.height * 0.4,
              width: MediaQuery.of(context).size.width * 0.7,
            ),
            SizedBox(
              height: 50,
            ),
            TypeWriter(
              text: 'Welcome to \nSmart Parking.',
              delay: Duration(milliseconds: 100),
            ),
          ],
        ),
      ),
    );
  }
}
