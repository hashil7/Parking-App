import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:parking_app/models/bookingtimer_provider.dart';

import 'package:parking_app/services/auth_service.dart';
import 'package:provider/provider.dart';

import 'package:qr_flutter/qr_flutter.dart';

class PaymentPage extends StatefulWidget {
  PaymentPage({
    super.key,
    this.reachingtime,
    this.secondscan = false,
  });
  bool secondscan;
  DateTime? reachingtime;
  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final database = FirebaseDatabase.instance.ref();
  DateTime? parkedtime;
  Duration parkingduration = Duration();

  double amount = 0;
  void get_parkingtime() {
    if (parkedtime == null) return;
    setState(() {
      parkingduration = DateTime.timestamp().difference(parkedtime!);
      print(parkingduration);
      amount = (parkingduration.inMinutes * 0.333).toInt().toDouble();
    });
  }

  @override
  void initState() {
    parkedtime = widget.reachingtime;
    parkedtime = DateTime.now();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingTimerProvider>(builder: (context, notifier, child) {
      amount = notifier.timeParked.inSeconds * 0.01111;
      return Scaffold(
          body: Container(
        color: Colors.amber[20],
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height: 60),
            Text(
              'Get QR scanned after Parking',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            QrImageView(
              data: AuthService.user != null ? AuthService.user!.uid : ' ',
              version: QrVersions.auto,
              size: 320,
              gapless: false,
            ),
            Text(
              notifier.parkedTime == null
                  ? ' '
                  : "Vehicle Parked at ${(notifier.parkedTime!.hour).toString().padLeft(2, "0")}:${(notifier.parkedTime!.minute).toString().padLeft(2, "0")}",
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            ParkedTime(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Total Amount: ₹ ${amount}',
                    style: TextStyle(fontSize: 20)),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {},
              child: Text(
                'Pay',
                style: TextStyle(fontSize: 20),
              ),
            )
          ],
        ),
      ));
    });
  }
}

void onPaymentSuccessful() {
  FirebaseFirestore.instance
      .collection('users')
      .doc(AuthService.user!.uid)
      .update({
    'spot': FieldValue.delete(),
  });
}

Widget _parkingtime(Duration time) {
  return Container(
    height: 50,
    width: 100,
    child: Text(
      '${time.inHours.toString().padLeft(2, '0')}:${(time.inMinutes % 60).toString().padLeft(2, '0')}',
      style: TextStyle(
        fontSize: 30,
        color: Colors.black,
      ),
    ),
  );
}

class ParkedTime extends StatelessWidget {
  const ParkedTime({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingTimerProvider>(
        builder: (context, ptimeprovider, child) {
      Duration timeParked = ptimeprovider.timeParked;
      return Container(
        height: 50,
        width: 150,
        child: Text(
          '${timeParked.inHours.toString().padLeft(2, '0')}:${(timeParked.inMinutes % 60).toString().padLeft(2, '0')}:${(timeParked.inSeconds % 60).toString().padLeft(2, '0')}',
          style: TextStyle(
            fontSize: 30,
            color: Colors.black,
          ),
        ),
      );
    });
  }
}
