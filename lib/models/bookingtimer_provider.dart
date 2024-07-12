import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:parking_app/constants.dart';

import 'package:parking_app/services/auth_service.dart';

import 'package:parking_app/services/sp_repository.dart';

class BookingTimerProvider extends ChangeNotifier {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DatabaseReference _ref = FirebaseDatabase.instance.ref('booking_spots');
  Timer? _timer;
  Timer? _buffer;
  Timer? _parkingTimer;
  DateTime? _bookedTime;
  DateTime? _parkedTime;
  String? _space;
  String? _slot;
  bool _booked = false, _parked = false, _pendingPay = false;
  Duration _remainingTime = Duration(minutes: 60);
  Duration _bufferTime = Duration(minutes: 30);
  Duration _timeParked = Duration();
  static const Duration totalTime = Duration(minutes: 60);
  static const Duration totalBuffer = Duration(minutes: 30);

  Duration get remainingTime => _remainingTime;
  Duration get bufferTime => _bufferTime;
  bool get booked => _booked;
  bool get parked => _parked;
  bool get pendingPay => _pendingPay;
  DateTime? get parkedTime => _parkedTime;
  DateTime? get bookedTime => _bookedTime;
  Duration get timeParked => _timeParked;
  String? get space => _space;
  String? get slot => _slot;

  void set slot(String? slotKey) {
    _slot = slotKey;
  }

  set booked(bool value) {
    _booked = value;
    notifyListeners();
  }

  Future<void> loadBookingTime() async {
    _timer?.cancel();
    _initializelistener();
    // print('Called Function load bookingTime');
    // DateTime? bookingTime = await getBookingTime();
    // _parkedTime = await getParkedTime();
    // _timeParked = await getTimeParked();
    // notifyListeners();
    // if (bookingTime != null) {
    //   _booked = true;
    //   notifyListeners();
    //   Duration timePassed = DateTime.timestamp()
    //       .add(
    //         Duration(hours: 5, minutes: 30),
    //       )
    //       .difference(bookingTime);
    //   print('Time Passed: ${timePassed.toString()}');
    //   _remainingTime = totalTime - timePassed;

    //   if (_remainingTime.isNegative) {
    //     _remainingTime = Duration(seconds: 0);
    //     _booked = false;
    //     SharedPreferenceRepository.instance.removeKey(bookingTimerKey);
    //   }
    //   startTimer();
    // } else if (parkedTime != null) {
    //   _timeParked = DateTime.timestamp().difference(_parkedTime!);
    //   print('Parking Duration:${timeParked.toString()}');
    //   _startParkingTimer();
    // }
  }

  Future<void> _initializelistener() async {
    print('Initialize listener Called');
    if (AuthService.user == null) return;
    String uid = AuthService.user!.uid;
    _firestore.collection('users').doc(uid).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        var data = snapshot.data();
        if (data != null) {
          _timer?.cancel();
          _parkingTimer?.cancel();
          if (data.containsKey('parkingTime')) {
            Timestamp parkedTimestamp = data['parkingTime'];
            _parkedTime = parkedTimestamp.toDate();
            _calcTimeParked();
            if (_timeParked.isNegative) {
              _timeParked = Duration(seconds: 0);
            } else {
              _startParkingTimer();
            }
          }
          if (data.containsKey('bookingTime')) {
            print('Detected booking Time from fb');
            Timestamp bookedTimeStamp = data['bookingTime'];
            _bookedTime = bookedTimeStamp.toDate();
            _space = data['spot'];
            _slot = data['slot'];
            _calcRemainingSeconds();
            startTimer();
            _startBuffer();
            _booked = true;

            notifyListeners();
          } else if (data.containsKey('timeParked')) {
            _parkingTimer?.cancel();
            _timeParked = Duration(seconds: data['timeParked']);
            _pendingPay = true;
            notifyListeners();
          } else {
            _resetLocalValues();
          }
        }
      }
    });
  }

  void _calcRemainingSeconds() {
    Duration timePassed = DateTime.timestamp().difference(_bookedTime!);
    print('Time Passed: ${timePassed.toString()}');
    _remainingTime = totalTime - timePassed;
    _bufferTime = totalBuffer - timePassed;

    if (_remainingTime.isNegative) {
      _remainingTime = Duration(seconds: 0);
      _booked = false;
      _stopParkingTimer();
      cancel_booking();
      clear();
    }
  }

  void _calcTimeParked() {
    _timeParked = DateTime.timestamp().difference(_parkedTime!);
    print('Parking Duration:${timeParked.toString()}');
  }

  void _stopParkingTimer() {
    _parkingTimer?.cancel();
    _parked = false;
    SharedPreferenceRepository.instance.removeKey(parkingTimerKey);
    SharedPreferenceRepository.instance
        .setKeyValue(timeParkedKey, _timeParked.inMilliseconds);
    SharedPreferenceRepository.instance.removeKey(bookingTimerKey);
    SharedPreferenceRepository.instance.removeKey(parkingTimerKey);
  }

  void _resetLocalValues() {
    _booked = false;
    _parked = false;
    _pendingPay = false;
    _bookedTime = null;
    _parkedTime = null;
    _space = null;
    _slot = null;
    _timer?.cancel();
    _parkingTimer?.cancel();
    _buffer?.cancel();
    _remainingTime = totalTime;
    _bufferTime = totalBuffer;
    _timeParked = Duration(seconds: 0);
    notifyListeners();
  }

  void _startParkingTimer() {
    _parked = true;
    _parkingTimer?.cancel();
    _parkingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _timeParked += Duration(seconds: 1);
      notifyListeners();
    });
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        _remainingTime -= Duration(seconds: 1);
        notifyListeners();
      } else {
        _timer?.cancel();
      }
    });
  }

  void _startBuffer() {
    _buffer?.cancel();
    _buffer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_bufferTime.inSeconds > 0 && _booked) {
        _bufferTime -= Duration(seconds: 1);
        if (_bufferTime == Duration(seconds: 0)) {
          _startParkingTimer();
        }
        notifyListeners();
      } else {
        _bufferTime = Duration(minutes: 30);
        _buffer?.cancel();
      }
    });
  }

  Future<DateTime?> getBookingTime() async {
    String? bookingTimeString =
        await SharedPreferenceRepository.instance.getValue(bookingTimerKey);
    if (bookingTimeString != null) {
      print('Booking Time got from shared Pref');
      print('Saved Time: $bookingTimeString');
      print('Length of string: ${bookingTimeString.length}');
      return DateTime.parse(bookingTimeString);
    } else {
      print('No value for booking TIme found in Shared Pref');
      return null;
    }
  }

  Future<DateTime?> getParkedTime() async {
    String? parkedTimeString =
        await SharedPreferenceRepository.instance.getValue(parkingTimerKey);
    if (parkedTimeString != null) {
      print('Got Parked Time from SharedPred');
      print('Parked Time: $parkedTimeString');
      return DateTime.parse(parkedTimeString);
    } else {
      print('didnt fetch parked time from shared pref');
      return null;
    }
  }

  Future<Duration> getTimeParked() async {
    int? timeParkedinms =
        await SharedPreferenceRepository.instance.getValue(timeParkedKey);
    if (timeParkedinms != null) {
      _timeParked = Duration(milliseconds: timeParkedinms);
      return _timeParked;
    }
    return Duration(seconds: 0);
  }

  void saveBookingTimetoFirebase(String space, String slotkey) async {
    _space = space;
    _slot = slotkey;

    try {
      await _firestore.collection('users').doc(AuthService.user!.uid).update({
        'bookingTime': FieldValue.serverTimestamp(),
        'parkingTime': DateTime.timestamp().add(Duration(minutes: 30)),
        'spot': space,
        'slot': slotkey,
      });
      await _ref.child(space).child('car slots').update({
        '$slotkey': 1,
      });
      DatabaseReference _spaceRef = _ref.child(space!);
      final snapshot = await _spaceRef.child('car').once();
      final currentValue = snapshot.snapshot.value != null
          ? int.parse(snapshot.snapshot.value.toString())
          : 0;
      await _spaceRef.update({'car': currentValue - 1});
      // Provider.of<BookingTimerProvider>(context, listen: false)
      //     .saveBookingTime(bookingTime);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Booking Error: $e',
      );
      print(e);
    }
  }

  void cancel_booking() async {
    _remainingTime = totalTime;
    _timer?.cancel();

    DatabaseReference _spaceRef = _ref.child(_space!);
    await _spaceRef.child('car slots').update({'$_slot': 0});
    final snapshot = await _spaceRef.child('car').once();
    final currentValue = snapshot.snapshot.value != null
        ? int.parse(snapshot.snapshot.value.toString())
        : 0;
    await _spaceRef.update({'car': currentValue + 1});
    clear();
    _resetLocalValues();
  }

  void addTime(Duration addonTime) async {
    if (_bookedTime == null) {
      Fluttertoast.showToast(msg: 'Please book a slot');
      return;
    } else if (bufferTime.inSeconds > 0) {
      Fluttertoast.showToast(
          msg: 'You may add time once the Parking Time has started');
      return;
    }
    try {
      DateTime newbookedTime = _bookedTime!.add(addonTime);
      await _firestore.collection('users').doc(AuthService.user!.uid).update({
        'bookingTime': Timestamp.fromDate(newbookedTime),
      });
      _bookedTime = newbookedTime;
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error Adding Time: $e');
    }
  }

  void resetTimer() {
    _timer?.cancel();
    _remainingTime = totalTime;
    startTimer();
  }

  void clear() async {
    await _firestore.collection('users').doc(AuthService.user!.uid).set({});
  }

  @override
  void dispose() {
    _timer?.cancel();
    _parkingTimer?.cancel();
    _buffer?.cancel();
    super.dispose();
  }
}
