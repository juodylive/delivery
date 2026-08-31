// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eat_with_us/helpers/elevated_button.dart';
import 'package:eat_with_us/helpers/text_input_decoration.dart';
import 'package:eat_with_us/screens/button_navbar.dart';
import 'package:eat_with_us/screens/forget_password.dart';
import 'package:eat_with_us/screens/register_page.dart';
import 'package:eat_with_us/screens/verify_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  UserCredential? userCredential;
  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
  }

  @override
  void initState() {
    getPrefInstance();
    passwordVisible = true;
    super.initState();
    getEmail().then((savedEmail) {
      if (savedEmail != null) {
        emailController.text = savedEmail;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    saveEmail(emailController.text);
  }

  bool passwordVisible = false;
  final formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;
  String wrongEmail = 'Wrong email';
  String wrongPassword = 'Wrong Password';
  late SharedPreferences _pref;

  getPrefInstance() async {
    _pref = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Stack(
          children: [
            Image.asset(
              'assets/images/image15.jpg',
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
              colorBlendMode: BlendMode.darken,
              color: Colors.black.withOpacity(0.4),
            ),
            _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: Colors.cyan[100]),
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 70),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'My Resturant',
                              style: GoogleFonts.montserrat(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: AppColor.resturantColor,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Great Meals Awaits',
                              style: GoogleFonts.montserrat(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: AppColor.subResturantColor,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: textInputDecoration.copyWith(
                                labelText: 'Email',
                                labelStyle: GoogleFonts.montserrat(
                                  fontSize: 20,
                                  color: AppColor.labelTextColor,
                                ),
                                prefixIcon: const Icon(
                                  Icons.email,
                                  color: AppColor.iconColor,
                                ),
                              ),
                              style: GoogleFonts.montserrat(
                                  color: AppColor.formFieldColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17),
                              onChanged: (val) {
                                setState(() {
                                  emailController.text;
                                });
                              },
                              validator: (val) {
                                return RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                ).hasMatch(val!)
                                    ? null
                                    : 'Please enter a valid email';
                              },
                            ),
                            const SizedBox(height: 25),
                            TextFormField(
                              controller: passwordController,
                              obscureText: passwordVisible,
                              decoration: textInputDecoration.copyWith(
                                labelText: 'Password',
                                labelStyle: GoogleFonts.montserrat(
                                  fontSize: 20,
                                  color: AppColor.labelTextColor,
                                ),
                                prefixIcon: const Icon(
                                  Icons.lock,
                                  color: AppColor.iconColor,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(passwordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                  onPressed: () {
                                    setState(() {
                                      passwordVisible = !passwordVisible;
                                    });
                                  },
                                ),
                                suffixIconColor: AppColor.iconColor,
                                alignLabelWithHint: false,
                              ),
                              keyboardType: TextInputType.visiblePassword,
                              textInputAction: TextInputAction.done,
                              validator: (val) {
                                if (val!.length < 6) {
                                  return 'Password must be at least 6 characters';
                                } else {
                                  return null;
                                }
                              },
                              style: GoogleFonts.montserrat(
                                  color: AppColor.formFieldColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17),
                              onChanged: (val) {},
                            ),
                            const SizedBox(height: 30),
                            ElevatedButtonPage(
                              text: 'Login',
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  setState(() {
                                    _isLoading = true;
                                  });

                                  try {
                                    userCredential =
                                        await auth.signInWithEmailAndPassword(
                                      email: emailController.text,
                                      password: passwordController.text,
                                    );

                                    // Check if the user's email is verified
                                    if (userCredential!.user?.emailVerified ==
                                        true) {
                                      // Email is verified, proceed with login
                                      QuerySnapshot userDoc = await _firestore
                                          .collection('user')
                                          .where('email',
                                              isEqualTo:
                                                  userCredential!.user?.email)
                                          .get();
                                      if (userDoc.docs.first['blocked']) {
                                        await auth.signOut();
                                        snackBar(context, Colors.red,
                                            'User is blocked. Cannot log in.');
                                        if (userCredential!.user != null) {
                                          _pref.setString(
                                            'email',
                                            emailController.text,
                                          );
                                        }
                                      } else {
                                        // Check if userCredential and user are not null
                                        if (userCredential != null &&
                                            userCredential!.user?.email !=
                                                null) {
                                          // Fetch user data from Firestore
                                          DocumentSnapshot userDoc =
                                              await _firestore
                                                  .collection('user')
                                                  .doc(
                                                    userCredential!
                                                        .user!.email!,
                                                  )
                                                  .get();
                                          // Check if the document exists
                                          if (userDoc.exists) {
                                            // Check if 'userType' field exists
                                            if (userDoc.data() != null &&
                                                (userDoc.data()
                                                        as Map<String, dynamic>)
                                                    .containsKey('userType')) {
                                              String userType = (userDoc.data()
                                                      as Map<String, dynamic>)[
                                                  'userType'];
                                              // Check if userType is 'user'
                                              if (userType == 'user') {
                                                // User is allowed to log in
                                                nextScreen(context,
                                                    const BottomNavBar());
                                              } else {
                                                snackBar(context, Colors.red,
                                                    'Invalid user type');
                                              }
                                            } else {
                                              snackBar(context, Colors.red,
                                                  'Invalid user data');
                                            }
                                          } else {
                                            // Document does not exist, handle accordingly
                                            snackBar(context, Colors.red,
                                                'User not found');
                                          }
                                        } else {
                                          // Handle the case where userCredential or user is null
                                          snackBar(context, Colors.red,
                                              'Authentication failed');
                                        }
                                      }
                                    } else {
                                      // Email is not verified, redirect to email verification screen
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const EmailVerifyLink(),
                                        ),
                                      );
                                    }

                                    setState(() {
                                      _isLoading = false;
                                    });
                                    // ignore: unused_local_variable
                                  } catch (e) {
                                    ('Login failed: $e');

                                    setState(() {
                                      _isLoading = false;
                                    });

                                    // Handle authentication errors
                                    if (e
                                        .toString()
                                        .contains('User is blocked')) {
                                      snackBar(context, Colors.red,
                                          'User is blocked. Cannot log in.');
                                    } else if (e == wrongEmail) {
                                      snackBar(context, Colors.red,
                                          'No user found for that email.');
                                    } else if (e == wrongPassword) {
                                      snackBar(context, Colors.red,
                                          'Wrong password.');
                                    } else {
                                      snackBar(context, Colors.red, '$e');
                                    }
                                  }
                                }
                              },
                            ),
                            const SizedBox(height: 20),
                            Text.rich(
                              TextSpan(
                                text: "Don't have an account? ",
                                style: GoogleFonts.montserrat(
                                  color: AppColor.firstTextSpanColor,
                                  fontSize: 17,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: 'Register here',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 18,
                                      color: AppColor.secoundTextSpanColor,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        nextScreenReplace(
                                          context,
                                          const RegisterPage(),
                                        );
                                      },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),
                            TextButton(
                              onPressed: () {
                                nextScreenReplace(
                                  context,
                                  const ForgetPassword(),
                                );
                              },
                              child: Text(
                                'Forgot password?',
                                style: GoogleFonts.montserrat(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 1.2,
                                    color: AppColor.secoundTextSpanColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
