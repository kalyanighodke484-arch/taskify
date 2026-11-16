import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:task_manger/widgets/constant/app_routes.dart';

import '../../widgets/constant/app_const.dart';


class SplashScreen extends StatefulWidget {


  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  void initState(){
    super.initState();
    void checkUserStatus() {
      // 2. Check if a user is already signed in to Firebase
      User? user = FirebaseAuth.instance.currentUser;

      if (mounted) {
        if (user != null) {
          // 3. If user exists, go to Home Screen
          Navigator.pushReplacementNamed(context, AppRoutes.homescreen);
        } else {
          // 4. If no user, go to Login Screen
          Navigator.pushReplacementNamed(context, AppRoutes.loginscreen);
        }
      }
    }
    Timer(Duration(seconds: 2), (){
      checkUserStatus();
    });


  }
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Image.asset(AppConst.ic_logo,width: 150,height: 150)),
          SizedBox(height: 10,),
          Text("Taskify",style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade300
          ),)
        ],
      ),
    );
  }
}
