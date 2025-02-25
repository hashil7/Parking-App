import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:parking_app/constants.dart';
import 'package:parking_app/firebase_options.dart';
import 'package:parking_app/models/bookingspots_provider.dart';

import 'package:parking_app/models/bookingtimer_provider.dart';
import 'package:parking_app/models/location_provider.dart'as loc_provider;

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
//import 'package:parking_app/models/on_street_exit_handler.dart' as exit_handler;
import 'package:parking_app/models/language_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:parking_app/models/app_translations.dart'; // Import translations file
import 'package:get/get.dart';





final databaseReference = FirebaseDatabase.instance.ref();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();




Future<void> fetchInitialParkingSpots(
    List<ParkingSpot> onstreetSpots, List<ParkingSpot> bookingSpots) async {
  DataSnapshot onstreetSnapshot =
      await databaseReference.child('onstreet_spots').get();
  DataSnapshot bookingSnapshot =
      await databaseReference.child('booking_spots').get();
  var onstreetvalue = onstreetSnapshot.value as Map<dynamic, dynamic>;
  var bookingvalue = bookingSnapshot.value as Map<dynamic, dynamic>;
  onstreetSpots.clear();
  onstreetvalue.forEach(
    (key, values) {
      var images = List<String>.from(values['image']);
      var carSlots = values['car'] as List<dynamic>;
      var bikeSlots = values['bike'] as List<dynamic>;
      var bigCarSlots = values['bigCarSpots'] as List<dynamic>;

      int freeCarSlots = carSlots.fold(0, (sum, item) => sum + item as int);
      int freeBikeSlots = bikeSlots.fold(0, (sum, item) => sum + item as int);
      int freeBigCarSlots = bigCarSlots.fold(0, (sum, item) => sum + item as int);
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
            carParkingType: values['carParkingType'],
            bikeParkingType: values['bikeParkingType'],
            bigCarSpots: freeBigCarSlots,
            type: 'onstreet'),
      );
    },
  );
  print(onstreetSpots);
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
          //parkingType: values['parkingType'],
          locationImage: images,
          type: 'booking',
          
          price: values['price'],
        ),
      );
    },
  );
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
      var bigCarSlots = values['bigCarSpots'] as List<dynamic>;
      int freeCarSlots = carSlots.fold(0, (sum, item) => sum + item as int);
      int freeBikeSlots = bikeSlots.fold(0, (sum, item) => sum + item as int);
      int freeBigCarSlots = bigCarSlots.fold(0, (sum, item) => sum + item as int);
      ParkingSpot updatedSpot = ParkingSpot(
        name: key,
        address: values['address'],
        latitude: values['lat'],
        longitude: values['long'],
        freeCarSlots: freeCarSlots,
        freeBikeSlots: freeBikeSlots,
        locationImage: images,
        avgFillingTime: values['fillingTime'],
        carParkingType: values['carParkingType'],
        bikeParkingType: values['bikeParkingType'],
        bigCarSpots: freeBigCarSlots,
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
        //parkingType: values['parkingType'],
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
      var bigCarSlots = values['bigCarSpots'] as List<dynamic>;

      int freeCarSlots = carSlots.fold(0, (sum, item) => sum + item as int);
      int freeBikeSlots = bikeSlots.fold(0, (sum, item) => sum + item as int);
      int freeBigCarSlots = bigCarSlots.fold(0, (sum, item) => sum + item as int);

      ParkingSpot newSpot = ParkingSpot(
        name: key,
        address: values['address'],
        latitude: values['lat'],
        longitude: values['long'],
        freeCarSlots: freeCarSlots,
        freeBikeSlots: freeBikeSlots,
        locationImage: images,
        avgFillingTime: values['fillingTime'],
        carParkingType: values['carParkingType'],
        bikeParkingType: values['bikeParkingType'],
        bigCarSpots: freeBigCarSlots,
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
        locationImage: images, 
        //parkingType: values['parkingType'],
        type: 'booking',
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
           create: (context) => loc_provider.LocationProvider(navigatorKey),
          ),
          ChangeNotifierProvider(
            create: (context) => NavcheckProvider(),
          ),
          ChangeNotifierProvider(
            create: (_) => BookingTimerProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => BookingspotsProvider(),
          ),
          // ChangeNotifierProvider(
          //   create: (context) => exit_handler.OnStreetTabNotifier(), // Add the OnStreetTabNotifier here
          // ),
          ChangeNotifierProvider(create: (_) => LanguageProvider()), // Register LanguageProvider
        ], child: const MyApp()),
      );
    },
  );
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return GetMaterialApp(
      navigatorKey: navigatorKey,
      theme: ThemeData(
        primaryColor: backgroundColor,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      locale: languageProvider.locale, // Use locale from LanguageProvider
      translations: AppTranslations(), // Your translations class
      fallbackLocale: const Locale('en', ''), // Fallback locale
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('ml', ''), // Malayalam
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        DefaultMaterialLocalizations.delegate,
      ],
      home: const SplashScreen(), // Your splash screen or initial route
    );
  }
}