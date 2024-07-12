import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:parking_app/constants.dart';
import 'package:parking_app/models/bookingtimer_provider.dart';
import 'package:parking_app/models/tabindex_provider.dart';
import 'package:parking_app/screens/home_page.dart';
import 'package:parking_app/screens/payment_page.dart';
import 'package:parking_app/screens/profile_page.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  MainPage({super.key, this.currentposition, this.bookingtime});
  Position? currentposition;
  DateTime? bookingtime;
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Position currentposition = Position(
      longitude: 78.9629,
      latitude: 20.5937,
      timestamp: DateTime.timestamp().add(Duration(
        hours: 5,
        minutes: 30,
      )),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0);

  late List<Widget> _children;

  @override
  void initState() {
    if (widget.currentposition == null) {
      print('Not getting current position');
      widget.currentposition = Position(
          longitude: 78.9629,
          latitude: 20.5937,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0);
    }

    currentposition = widget.currentposition!;
    print(currentposition);

    _children = [
      ProfilePage(),
      HomePage(
        currentposition: currentposition,
        bookingtime: widget.bookingtime,
      ),
      PaymentPage(),
    ];

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingTimerProvider>(context, listen: false)
          .loadBookingTime();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TabIndex>(builder: (context, tabIndex, child) {
      return Scaffold(
        body: IndexedStack(
          index: tabIndex.currentIndex,
          children: _children,
        ),
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedItemColor: backgroundColor,
          selectedIconTheme: IconThemeData(
            color: backgroundColor,
          ),
          backgroundColor: const Color.fromARGB(225, 24, 26, 32),
          items: _bottomnavbaritems,
          onTap: (index) {
            tabIndex.currentIndex = index;
          },
          currentIndex: tabIndex.currentIndex,
        ),
      );
    });
  }
}

List<BottomNavigationBarItem> _bottomnavbaritems = [
  BottomNavigationBarItem(
      icon: Icon(
        Icons.person,
        color: Color.fromARGB(255, 255, 255, 255),
      ),
      label: "Profile"),
  BottomNavigationBarItem(
      icon: Icon(
        Icons.home,
        color: Colors.white,
      ),
      label: "Home"),
  BottomNavigationBarItem(
      icon: Icon(
        Icons.qr_code,
        color: Colors.white,
      ),
      label: "QR")
];
