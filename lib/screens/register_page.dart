// ignore_for_file: use_build_context_synchronousl

import 'package:eat_with_us/helpers/elevated_button.dart';
import 'package:eat_with_us/helpers/text_input_decoration.dart';
import 'package:eat_with_us/screens/login_page.dart';
import 'package:eat_with_us/screens/verify_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool isBlocked = false;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final TextEditingController datOfBirthController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController userCityController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordMatch() {
    String password = passwordController.text;
    String confirmPassword = _confirmPasswordController.text;
    return password == confirmPassword;
  }

  bool _isLoading = false;
  bool passwordVisible = false;

  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    passwordVisible = true;

    super.initState();
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
                          horizontal: 10, vertical: 35),
                      child: Form(
                        key: formKey,
                        // ignore: prefer_const_constructors
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
                                  letterSpacing: 1.5),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Ordering A Meal Has Never Been This Easy',
                              style: GoogleFonts.montserrat(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColor.subResturantColor,
                                letterSpacing: 1,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: textInputDecoration.copyWith(
                                labelText: 'Email',
                                labelStyle: GoogleFonts.montserrat(
                                    fontSize: 18,
                                    color: AppColor.labelTextColor,
                                    fontWeight: FontWeight.bold),
                                prefixIcon: const Icon(
                                  Icons.email,
                                  color: AppColor.iconColor,
                                ),
                              ),
                              style: GoogleFonts.montserrat(
                                  color: AppColor.formFieldColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                              onChanged: (val) {
                                setState(() {});
                              },
                              validator: (val) {
                                return RegExp(
                                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                        .hasMatch(val!)
                                    ? null
                                    : "please enter a valid email";
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              controller: nameController,
                              textCapitalization: TextCapitalization.words,
                              decoration: textInputDecoration.copyWith(
                                labelText: 'Full Name',
                                labelStyle: GoogleFonts.montserrat(
                                    fontSize: 18,
                                    color: AppColor.labelTextColor,
                                    fontWeight: FontWeight.bold),
                                prefixIcon: const Icon(
                                  Icons.person,
                                  color: AppColor.iconColor,
                                ),
                              ),
                              style: GoogleFonts.montserrat(
                                  color: AppColor.formFieldColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                              onChanged: (val) {
                                setState(() {});
                              },
                              validator: (val) {
                                if (val!.isNotEmpty) {
                                  return null;
                                } else {
                                  return "Full name cannot be empty";
                                }
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              controller: passwordController,
                              obscureText: passwordVisible,
                              decoration: textInputDecoration.copyWith(
                                labelText: 'Password',
                                labelStyle: GoogleFonts.montserrat(
                                    fontSize: 18,
                                    color: AppColor.labelTextColor,
                                    fontWeight: FontWeight.bold),
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
                                  return 'password must be at least 6 characters';
                                } else {
                                  return null;
                                }
                              },
                              style: GoogleFonts.montserrat(
                                  color: AppColor.formFieldColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                              onChanged: (val) {},
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: passwordVisible,
                              decoration: textInputDecoration.copyWith(
                                labelText: 'Confirm Password',
                                labelStyle: GoogleFonts.montserrat(
                                    fontSize: 18,
                                    color: AppColor.labelTextColor,
                                    fontWeight: FontWeight.bold),
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
                                if (_isPasswordMatch()) {
                                  return null;
                                } else {
                                  return 'password mismatch';
                                }
                              },
                              style: GoogleFonts.montserrat(
                                  color: AppColor.formFieldColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                              onChanged: (val) {},
                            ),
                            const SizedBox(
                              height: 25,
                            ),
                            ElevatedButtonPage(
                                text: 'Register',
                                onPressed: () async {
                                  if (formKey.currentState!.validate()) {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    try {
                                      UserCredential userCredential = await auth
                                          .createUserWithEmailAndPassword(
                                              email: emailController.text,
                                              password:
                                                  passwordController.text);

                                      // ignore: await_only_futures

                                      user = userCredential.user;
                                      await user!.updateDisplayName(
                                          nameController.text);
                                      await user!.reload();
                                      user = auth.currentUser;

                                      await FirebaseFirestore.instance
                                          .collection('user')
                                          .doc(userCredential.user?.email)
                                          .set({
                                        'blocked': isBlocked,
                                        'userType': 'user',
                                        'name': nameController.text,
                                        'dob': datOfBirthController.text,
                                        'gender': genderController.text,
                                        'phone': phoneNumberController.text,
                                        'country': countryController.text,
                                        'state': stateController.text,
                                        'address': addressController.text,
                                        'email': emailController.text,
                                        'timestamp': DateTime.now()
                                      });

                                      if (context.mounted) {
                                        nextScreenReplace(
                                            context, const EmailVerifyLink());
                                      }

                                      setState(() {
                                        _isLoading = false;
                                      });
                                    } catch (e) {
                                      setState(() {
                                        _isLoading = false;
                                      });

                                      if (e == 'error') {}

                                      (e);
                                      // ignore: use_build_context_synchronously
                                      snackBar(context, Colors.red, e);

                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                  }
                                }),
                            const SizedBox(
                              height: 15,
                            ),
                            Text.rich(
                              TextSpan(
                                  text: "Alredy have an account? ",
                                  style: GoogleFonts.montserrat(
                                      fontSize: 20,
                                      color: AppColor.firstTextSpanColor),
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: "Login here",
                                        style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color:
                                                AppColor.secoundTextSpanColor,
                                            decoration:
                                                TextDecoration.underline),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            nextScreenReplace(
                                                context, const LoginPage());
                                          }),
                                  ]),
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
