import 'package:flutter/cupertino.dart';
import 'package:task_manger/screens/add_task_screen.dart';
import 'package:task_manger/screens/update_task_screen.dart';

import '../../screens/home_screen.dart';
import '../../screens/login/login_screen.dart';
import '../../screens/singup/signup_screen.dart';
import '../../screens/splash/splash_screen.dart';

class AppRoutes {
  static const String splashscreen = "/";
  static const String loginscreen = "/loginscreen";
  static const String signupscreen = "/signupscreen";
  static const String homescreen = "/homescreen";
  static const String addTaskscreen = "/addTaskscreen";


  static Map<String, WidgetBuilder> mRoutes = {
    splashscreen: (context) => SplashScreen(),
    loginscreen: (context) => LoginScreen(),
    signupscreen: (context) => SignupScreen(),
    homescreen: (context) => HomeScreen(),
    addTaskscreen:(context) => AddTaskScreen(),

  };
}
