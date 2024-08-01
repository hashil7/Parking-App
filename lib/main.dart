import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:parking_app/constants.dart';
import 'package:parking_app/firebase_options.dart';
import 'package:parking_app/models/bookingspots_provider.dart';

import 'package:parking_app/models/bookingtimer_provider.dart';
import 'package:parking_app/models/location_provider.dart';

import 'package:parking_app/models/navcheck_provider.dart';
import 'package:parking_app/models/parking_spot.dart';
import 'package:parking_app/models/parkingspotsnotifier.dart';

import 'package:parking_app/models/tabindex_provider.dart';
import 'package:parking_app/models/vehicle_provider.dart';

import 'package:parking_app/screens/splash_screen.dart';
import 'package:parking_app/services/notification_service.dart';
import 'package:parking_app/services/sp_repository.dart';

import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

final databaseReference = FirebaseDatabase.instance.ref();

Future<void> fetchInitialParkingSpots(
    List<ParkingSpot> onstreetSpots, List<ParkingSpot> bookingSpots) async {
  DataSnapshot onstreetSnapshot =
      await databaseReference.child('onstreet_spots').get();
  DataSnapshot bookingSnapshot =
      await databaseReference.child('booking_spots').get();
  var onstreetvalue = onstreetSnapshot.value as Map<dynamic, dynamic>;
  var bookingvalue = bookingSnapshot.value as Map<dynamic, dynamic>;
  if (onstreetvalue != null) {
    onstreetSpots.clear();
    onstreetvalue.forEach(
      (key, values) {
        var images = List<String>.from(values['image']);
        var carSlots = values['car'] as List<dynamic>;
        var bikeSlots = values['bike'] as List<dynamic>;

        int freeCarSlots = carSlots.fold(0, (sum, item) => sum + item as int);
        int freeBikeSlots = bikeSlots.fold(0, (sum, item) => sum + item as int);
        onstreetSpots.add(
          ParkingSpot(
              name: key,
              address: values['address'],
              latitude: values['lat'],
              longitude: values['long'],
              freeCarSlots: freeCarSlots,
              freeBikeSlots: freeBikeSlots,
              locationImage: images,
              avgFillingTime: values['fillingTime'],
              type: 'onstreet'),
        );
      },
    );
  }
  print(onstreetSpots);
  if (bookingvalue != null) {
    bookingSpots.clear();
    bookingvalue.forEach(
      (key, values) {
        var images = List<String>.from(values['image']);

        bookingSpots.add(
          ParkingSpot(
            name: key,
            address: values['address'],
            latitude: values['lat'],
            longitude: values['long'],
            freeCarSlots: values['car'],
            freeBikeSlots: values['bike'],
            locationImage: images,
            type: 'booking',
            price: values['price'],
          ),
        );
      },
    );
  }
  print(bookingSpots);
}

void listenForParkingSpotChanges(ParkingSpotsNotifier notifier) {
  databaseReference.child('onstreet_spots').onChildChanged.listen((event) {
    var key = event.snapshot.key;
    var values = event.snapshot.value as Map<dynamic, dynamic>;

    if (key != null) {
      var images = List<String>.from(values['image']);
      var carSlots = values['car'] as List<dynamic>;
      var bikeSlots = values['bike'] as List<dynamic>;

      int freeCarSlots = carSlots.fold(0, (sum, item) => sum + item as int);
      int freeBikeSlots = bikeSlots.fold(0, (sum, item) => sum + item as int);
      ParkingSpot updatedSpot = ParkingSpot(
        name: key,
        address: values['address'],
        latitude: values['lat'],
        longitude: values['long'],
        freeCarSlots: freeCarSlots,
        freeBikeSlots: freeBikeSlots,
        locationImage: images,
        avgFillingTime: values['fillingTime'],
        type: 'onstreet', // Use a default image
      );
      notifier.updateSpot(updatedSpot);
    }
  });
  databaseReference.child('booking_spots').onChildChanged.listen((event) {
    var key = event.snapshot.key;
    var values = event.snapshot.value as Map<dynamic, dynamic>;

    if (key != null) {
      var images = List<String>.from(values['image']);

      ParkingSpot updatedSpot = ParkingSpot(
        name: key,
        address: values['address'],
        latitude: values['lat'],
        longitude: values['long'],
        freeCarSlots: values['car'],
        freeBikeSlots: values['bike'],
        locationImage: images,
        type: 'booking',
        price: values['price'],
      );
      notifier.updateSpot(updatedSpot);
    }
  });
  databaseReference.child('onstreet_spots').onChildAdded.listen((event) {
    var key = event.snapshot.key;
    var values = event.snapshot.value as Map<dynamic, dynamic>;
    if (key != null) {
      var images = List<String>.from(values['image']);
      var carSlots = values['car'] as List<dynamic>;
      var bikeSlots = values['bike'] as List<dynamic>;

      int freeCarSlots = carSlots.fold(0, (sum, item) => sum + item as int);
      int freeBikeSlots = bikeSlots.fold(0, (sum, item) => sum + item as int);
      ParkingSpot newSpot = ParkingSpot(
        name: key,
        address: values['address'],
        latitude: values['lat'],
        longitude: values['long'],
        freeCarSlots: freeCarSlots,
        freeBikeSlots: freeBikeSlots,
        locationImage: images,
        avgFillingTime: values['fillingTime'],
        type: 'onStreet',
        // Use a default image
      );
      notifier.addSpot(newSpot);
    }
  });
  databaseReference.child('booking_spots').onChildAdded.listen((event) {
    var key = event.snapshot.key;
    var values = event.snapshot.value as Map<dynamic, dynamic>;
    if (key != null) {
      var images = List<String>.from(values['image']);

      ParkingSpot newSpot = ParkingSpot(
        name: key,
        address: values['address'],
        latitude: values['lat'],
        longitude: values['long'],
        freeCarSlots: values['car'],
        freeBikeSlots: values['bike'],
        locationImage: images, type: 'booking',
        price: values['price'],
        // Use a default image
      );
      notifier.addSpot(newSpot);
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.init();
  var prefs = await SharedPreferences.getInstance();
  SharedPreferenceRepository.setSharedPreferences(prefs);

  List<ParkingSpot> initialonstreetSpots = [];
  List<ParkingSpot> initialbookingSpots = [];
  await fetchInitialParkingSpots(initialonstreetSpots, initialbookingSpots);
  final parkingspotsnotifier =
      ParkingSpotsNotifier(initialbookingSpots, initialonstreetSpots);
  listenForParkingSpotChanges(parkingspotsnotifier);
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then(
    (_) {
      runApp(
        MultiProvider(providers: [
          ChangeNotifierProvider(
            create: (context) => TabIndex(),
          ),
          ChangeNotifierProvider(create: (_) => parkingspotsnotifier),
          ChangeNotifierProvider(
            create: (context) => VehicleProvider(),
          ),
          ChangeNotifierProvider(
            create: (_) => LocationProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => NavcheckProvider(),
          ),
          ChangeNotifierProvider(
            create: (_) => BookingTimerProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => BookingspotsProvider(),
          )
        ], child: MyApp()),
      );
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: backgroundColor,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      home: SplashScreen(),
    );
  }
}
