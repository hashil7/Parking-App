// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:parking_app/constants.dart';
// import 'package:parking_app/models/bookingtimer_provider.dart';
// import 'package:parking_app/screens/signin_page.dart';
// import 'package:parking_app/services/auth_service.dart';
// import 'package:provider/provider.dart';
// import 'package:parking_app/models/language_provider.dart'; // Import your language provider

// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   @override
//   Widget build(BuildContext context) {
//     final languageProvider = Provider.of<LanguageProvider>(context); // Get the language provider

//     return Scaffold(
//       appBar: AppBar(
//         title: Center(
//           child: Text(
//             'Profile'.tr, // Use GetX for translations
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         backgroundColor: backgroundColor,
//       ),
//       body: Container(
//         color: Color(0xFFF7F7FA),
//         child: Column(
//           children: [
//             _buildHeader(),
//             SizedBox(height: 20),
//             _wallet(),
//             _languageSelector(languageProvider), // Add the language selector
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Container(
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(30),
//           bottomRight: Radius.circular(30),
//         ),
//       ),
//       height: MediaQuery.of(context).size.height * 0.12,
//       width: MediaQuery.of(context).size.width,
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(width: 20),
//           Text(
//             AuthService.user != null
//                 ? 'Hi, ${AuthService.user!.displayName!.split(" ")[0].capitalizeFirst}!'
//                 : 'Hi User!',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 25,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           Spacer(),
//           IconButton(
//             onPressed: _signOut,
//             icon: Icon(Icons.logout),
//             color: Colors.white,
//             iconSize: 25,
//           ),
//           SizedBox(width: 10),
//         ],
//       ),
//     );
//   }

//   Future<void> _signOut() async {
//     await AuthService.signOut();
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => SigninPage()),
//     );
//   }

//   Widget _wallet() {
//     return Consumer<BookingTimerProvider>(
//       builder: (context, wallet, child) {
//         return Padding(
//           padding: const EdgeInsets.all(20),
//           child: Card(
//             color: Colors.white,
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Wallet'.tr, // Use GetX for translations
//                     style: GoogleFonts.saira(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Text(
//                     'Your current balance is ₹${wallet.walletBalance}',
//                     style: GoogleFonts.montserrat(fontSize: 18),
//                   ),
//                   SizedBox(height: 10),
//                   ElevatedButton(
//                     onPressed: () {},
//                     child: Text(
//                       'Recharge'.tr, // Use GetX for translations
//                       style: GoogleFonts.montserrat(
//                         color: Colors.black,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Color(0xFFEDF0F2),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _languageSelector(LanguageProvider languageProvider) {
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             'Select Language'.tr, // Use GetX for translations
//             style: GoogleFonts.montserrat(fontSize: 18),
//           ),
//           const SizedBox(width: 10),
//           DropdownButton<String>(
//             value: languageProvider.locale.languageCode, // Get the current language code
//             items: <String>['en', 'ml']
//                 .map<DropdownMenuItem<String>>((String value) {
//               return DropdownMenuItem<String>(
//                 value: value,
//                 child: Text(
//                   value == 'en' ? 'English' : 'Malayalam', // Display language names
//                 ),
//               );
//             }).toList(),
//             onChanged: (String? newValue) {
//               if (newValue != null) {
//                 Locale newLocale = Locale(newValue);
//                 languageProvider.setLocale(newLocale); // Set the new locale
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }




// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:parking_app/constants.dart';
// import 'package:parking_app/models/bookingtimer_provider.dart';
// import 'package:parking_app/screens/signin_page.dart';
// import 'package:parking_app/services/auth_service.dart';
// import 'package:provider/provider.dart';
// import 'package:parking_app/models/language_provider.dart'; // Import your language provider

// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   @override
//   Widget build(BuildContext context) {
//     final languageProvider = Provider.of<LanguageProvider>(context); // Get the language provider

//     return Scaffold(
//       appBar: AppBar(
//         title: Center(
//           child: Text(
//             'Profile'.tr, // Use GetX for translations
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         backgroundColor: backgroundColor,
//       ),
//       body: Container(
//         color: Color(0xFFF7F7FA),
//         child: Column(
//           children: [
//             _buildHeader(),
//             SizedBox(height: 20),
//             _wallet(),
//             _languageSelector(languageProvider), // Add the language selector
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Container(
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(30),
//           bottomRight: Radius.circular(30),
//         ),
//       ),
//       height: MediaQuery.of(context).size.height * 0.12,
//       width: MediaQuery.of(context).size.width,
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(width: 20),
//           Text(
//             AuthService.user != null
//                 ? 'Hi, ${AuthService.user!.displayName!.split(" ")[0].capitalizeFirst}!'
//                 : 'Hi User!',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 25,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           Spacer(),
//           IconButton(
//             onPressed: _signOut,
//             icon: Icon(Icons.logout),
//             color: Colors.white,
//             iconSize: 25,
//           ),
//           SizedBox(width: 10),
//         ],
//       ),
//     );
//   }

//   Future<void> _signOut() async {
//     await AuthService.signOut();
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => SigninPage()),
//     );
//   }

//   Widget _wallet() {
//     return Consumer<BookingTimerProvider>(
//       builder: (context, wallet, child) {
//         return Padding(
//           padding: const EdgeInsets.all(20),
//           child: Card(
//             color: Colors.white,
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Wallet'.tr, // Use GetX for translations
//                     style: GoogleFonts.saira(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Text(
//                     'Your current balance is ₹${wallet.walletBalance}',
//                     style: GoogleFonts.montserrat(fontSize: 18),
//                   ),
//                   SizedBox(height: 10),
//                   ElevatedButton(
//                     onPressed: () {},
//                     child: Text(
//                       'Recharge'.tr, // Use GetX for translations
//                       style: GoogleFonts.montserrat(
//                         color: Colors.black,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Color(0xFFEDF0F2),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _languageSelector(LanguageProvider languageProvider) {
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             'Select Language'.tr, // Use GetX for translations
//             style: GoogleFonts.montserrat(fontSize: 18),
//           ),
//           const SizedBox(width: 10),
//           DropdownButton<String>(
//             value: languageProvider.locale.languageCode, // Get the current language code
//             items: <String>['en', 'ml']
//                 .map<DropdownMenuItem<String>>((String value) {
//               return DropdownMenuItem<String>(
//                 value: value,
//                 child: Text(
//                   value == 'en' ? 'English' : 'Malayalam', // Display language names
//                 ),
//               );
//             }).toList(),
//             onChanged: (String? newValue) {
//               if (newValue != null) {
//                 Locale newLocale = Locale(newValue);
//                 languageProvider.setLocale(newLocale); // Set the new locale
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:parking_app/constants.dart';
import 'package:parking_app/models/bookingtimer_provider.dart';
import 'package:parking_app/screens/signin_page.dart';
import 'package:parking_app/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:parking_app/models/language_provider.dart'; // Import your language provider

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context); // Get the language provider

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Profile'.tr, // Use GetX for translations
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: backgroundColor,
      ),
      body: Container(
        color: const Color(0xFFF7F7FA),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _wallet(),
            _languageSelector(languageProvider), // Add the language selector
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
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
          const SizedBox(width: 20),
          Text(
            AuthService.user != null
                ? 'Hi, ${AuthService.user!.displayName!.split(" ")[0].capitalizeFirst}!'
                : 'Hi User!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
            color: Colors.white,
            iconSize: 25,
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    await AuthService.signOut();
    Get.offAll(() =>  const SigninPage()); // Use GetX for navigation
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wallet'.tr, // Use GetX for translations
                    style: GoogleFonts.saira(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Your current balance is ₹${wallet.walletBalance}',
                    style: GoogleFonts.montserrat(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEDF0F2),
                    ),
                    child: Text(
                      'Recharge'.tr, // Use GetX for translations
                      style: GoogleFonts.montserrat(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _languageSelector(LanguageProvider languageProvider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Select Language'.tr, // Use GetX for translations
            style: GoogleFonts.montserrat(fontSize: 18),
          ),
          const SizedBox(width: 10),
          DropdownButton<String>(
            value: languageProvider.locale.languageCode, // Get the current language code
            items: <String>['en', 'ml']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value == 'en' ? 'English' : 'Malayalam', // Display language names
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                Locale newLocale = Locale(newValue);
                languageProvider.setLocale(newLocale); // Set the new locale
              }
            },
          ),
        ],
      ),
    );
  }
}








