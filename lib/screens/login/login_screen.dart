import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manger/widgets/constant/app_const.dart';

import '../../widgets/constant/app_routes.dart';
import '../../widgets/custom_textfiled.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var emailController = TextEditingController();

  var passwordController = TextEditingController();

  bool isPassVisible = false;
  bool isLogin = true;
  bool isAuthenticating=false;

  GlobalKey<FormState> fromkey = GlobalKey<FormState>();

  FirebaseAuth? fireAuth;
  FirebaseFirestore? firestore;

  void initState() {
    super.initState();
    fireAuth = FirebaseAuth.instance;
    firestore = FirebaseFirestore.instance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Form(
          key: fromkey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Welcome Back ",
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text("Login to continue", style: TextStyle(fontSize: 15)),
              SizedBox(height: 15),
              Image.asset(AppConst.ic_logo, width: 70, height: 70),
              SizedBox(height: 15),
              TextFormField(
                controller: emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "please enter email";
                  } else if (!RegExp(
                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                  ).hasMatch(value)) {
                    return "Please enter a valid email";
                  }
                  return null;
                },
                decoration: AppTextFiled.mDecoration(
                  label: "Email",
                  hint: "Enter email",
                  mIcons: Icons.email_outlined,
                ),
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: passwordController,
                obscureText: !isPassVisible,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "please enter password";
                  }
                  return null;
                },
                decoration: AppTextFiled.mDecoration(
                  label: "Password",
                  hint: "Enter Password",
                  mIcons: Icons.lock_open_rounded,
                  isPass: true,
                  isPasswordVisible: isPassVisible,
                  onObscureTap: () {
                    isPassVisible = !isPassVisible;
                    setState(() {});
                  },
                ),
              ),

              SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (fromkey.currentState!.validate()) {
                      isAuthenticating=true;
                      try {
                        UserCredential userCred = await fireAuth!
                            .signInWithEmailAndPassword(
                              email: emailController.text,
                              password: passwordController.text,
                            );

                        if (userCred.user != null) {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.setString("uid", userCred.user!.uid);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Login Successfully !!"),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.pushReplacementNamed(context, AppRoutes.homescreen);

                        }else{
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Something is wrong please try again.."),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                          } on FirebaseAuthException catch (e) {
                        String errorMessage = " ";
                        if (e.code == 'invalid-credential') {
                          errorMessage = "Invalid email or password.";
                        }else if (e.code == 'user-not-found') {
                          errorMessage = "No user found with this email.";
                        } else if (e.code == 'wrong-password') {
                          errorMessage = "Incorrect password. Please try again.";
                        } else if (e.code == 'invalid-email') {
                          errorMessage = "The email is not valid.";
                        } else if (e.code == 'user-disabled') {
                          errorMessage = "This account has been disabled.";
                        } else if (e.code == 'too-many-requests') {
                          errorMessage = "Too many attempts. Please try again later.";
                        }
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(errorMessage),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Something is wrong please try again.."),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    fixedSize: Size(100, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: isAuthenticating
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(11.0),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 11),
                      Text('Authenticating...'),
                    ],
                  )
                      : Text('Login',style: TextStyle(fontSize: 16))),
                ),
              SizedBox(height: 15),

              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.signupscreen);
                },
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(color: Colors.black),
                      ),
                      TextSpan(
                        text: "Sing Up",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
