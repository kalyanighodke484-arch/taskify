import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:task_manger/widgets/custom_textfiled.dart';

import '../../widgets/constant/app_routes.dart';

class SignupScreen extends StatefulWidget {
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  var nameController = TextEditingController();

  var emailController = TextEditingController();

  var passwordController = TextEditingController();

  var conPasswordController = TextEditingController();

  bool isPassVisible = false;

  bool isConfirmPassVisible = false;

  bool isAccCreating = false;

  GlobalKey<FormState> fromkey = GlobalKey<FormState>();

  FirebaseAuth? fireAuth;
  FirebaseFirestore? fireStore;

  void initState() {
    super.initState();
    fireAuth = FirebaseAuth.instance;
    fireStore = FirebaseFirestore.instance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              child: Form(
                key: fromkey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Create Account ",
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text("Signup to get started", style: TextStyle(fontSize: 15)),
                    SizedBox(height: 30),
                    TextFormField(
                      controller: nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "please enter name";
                        }
                        return null;
                      },
                      decoration: AppTextFiled.mDecoration(
                        label: "Name",
                        hint: "Enter name",
                        mIcons: Icons.person_2_outlined,
                      ),
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "please enter email";
                        } else if (!RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                        ).hasMatch(value)) {
                          return "Enter valid email";
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
                        } else if (!RegExp(
                          r'^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$',
                        ).hasMatch(value)) {
                          return "must have 1 upper case,1 symbol, 1number ,\nlength 8 ";
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
                          }
                      ),
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: conPasswordController,
                      obscureText: !isConfirmPassVisible,
                      validator: (value) {
                        if (passwordController.text != conPasswordController.text) {
                          return "password not match";
                        }
                        return null;
                      },
                      decoration: AppTextFiled.mDecoration(
                        label: "Confirm Password",
                        hint: "Enter confirm password",
                        mIcons: Icons.lock_open_rounded,
                        isPass: true,
                          isPasswordVisible: isConfirmPassVisible,
                          onObscureTap: () {
                            isConfirmPassVisible = !isConfirmPassVisible;
                            setState(() {});
                          }
                      ),
                    ),
                    SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (fromkey.currentState!.validate()) {
                            try {
                              UserCredential userCred = await fireAuth!
                                  .createUserWithEmailAndPassword(
                                    email: emailController.text,
                                    password: passwordController.text,
                                  );

                              if (userCred.user != null) {
                                await fireStore!
                                    .collection("users")
                                    .doc(userCred.user!.uid)
                                    .set({
                                      "name": nameController.text,
                                      "email": emailController.text,
                                      "uid": userCred.user!.uid,
                                      "password": passwordController.text,
                                      "createdAt ":
                                          DateTime.now().millisecondsSinceEpoch,
                                    });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Account created successfully"),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                Navigator.pop(context);

                              }
                            } on FirebaseAuthException catch (e) {
                              if (e.code == 'weak-password') {
                                print('The password provided is too weak.');
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("The password provided is too weak."),backgroundColor: Colors.red,));
                              } else if (e.code == 'email-already-in-use') {
                                print('The account already exists for that email.');
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("The account already exists for that email."),backgroundColor: Colors.red,));

                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Something is wrong please try again.."),backgroundColor: Colors.red,));

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
                        child: Text("Sing Up", style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    SizedBox(height: 15),

                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.loginscreen);
                      },
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Already have an account? ",
                              style: TextStyle(color: Colors.black),
                            ),
                            TextSpan(
                              text: "Login",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
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
          ),
        ),
      ),
    );
  }
}
