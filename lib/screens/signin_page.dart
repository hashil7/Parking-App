import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parking_app/constants.dart';

import 'package:parking_app/screens/main_page.dart';
import 'package:parking_app/services/auth_service.dart';

class SigninPage extends StatefulWidget {
  SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final _auth = AuthService();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (AuthService.user != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) {
        return MainPage();
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        color: backgroundColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () async {
                  final user = await _auth.loginWithGoogle();
                  if (user != null) {
                    AuthService.user = FirebaseAuth.instance.currentUser;
                    FirebaseFirestore firestore = FirebaseFirestore.instance;
                    DocumentSnapshot userDoc = await firestore
                        .collection('users')
                        .doc(AuthService.user!.uid)
                        .get();
                    if (!userDoc.exists) {
                      await firestore
                          .collection('users')
                          .doc(AuthService.user!.uid)
                          .set({});
                    }
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainPage(),
                      ),
                    );
                  }
                },
                child: Text('Sign in with Google'))
          ],
        ),
      ),
    );
  }
}
