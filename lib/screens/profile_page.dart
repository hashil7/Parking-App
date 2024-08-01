import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:parking_app/constants.dart';
import 'package:parking_app/models/bookingtimer_provider.dart';
import 'package:parking_app/screens/signin_page.dart';
import 'package:parking_app/services/auth_service.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text(
              'Profile',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
          backgroundColor: backgroundColor,
        ),
        body: Container(
          color: Color(0xFFF7F7FA),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                height: MediaQuery.of(context).size.height * 0.12,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      AuthService.user != null
                          ? 'Hi, ${AuthService.user!.displayName!.split((" "))[0].camelCase!.capitalizeFirst}!'
                          : 'Hi User!',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: () async {
                        await AuthService.signOut();
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SigninPage()));
                      },
                      icon: Icon(Icons.logout),
                      color: Colors.white,
                      iconSize: 25,
                    ),
                    SizedBox(
                      width: 10,
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),

              _wallet(),
              // Container(
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(60),
              //     color: Color.fromARGB(106, 233, 177, 10),
              //   ),
              //   width: 320,
              //   height: 450,
              //   margin: EdgeInsets.all(30),
              //   child: Column(
              //     children: [
              //       SizedBox(height: 20),
              //       Text(
              //         'Booking History',
              //         style: TextStyle(fontSize: 20),
              //       ),
              //       Container(
              //         color: Colors.black,
              //         height: 3,
              //         width: 250,
              //       )
              //     ],
              //   ),
              // )
            ],
          ),
        ));
  }

  Widget _wallet() {
    return Consumer<BookingTimerProvider>(
      builder: (context, wallet, child) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Wallet',
                        style: GoogleFonts.saira(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Your current balance is ₹${wallet.walletBalance}',
                        style: GoogleFonts.montserrat(fontSize: 18),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        child: Text(
                          'Recharge',
                          style: GoogleFonts.montserrat(
                              color: Colors.black, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFEDF0F2)),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
