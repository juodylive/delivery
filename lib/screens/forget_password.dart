import 'package:eat_with_us/helpers/elevated_button.dart';
import 'package:eat_with_us/screens/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../helpers/text_input_decoration.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  bool isEmailSent = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        body: SafeArea(
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: GestureDetector(
                            onTap: () {
                              nextScreenReplace(context, const LoginPage());
                            },
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.grey[800],
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          'Forgot Password',
                          style: GoogleFonts.montserrat(
                              fontSize: 25,
                              fontWeight: FontWeight.w600,
                              color: AppColor.mainColor,
                              letterSpacing: 1.3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Enter the email associated with your account and will we send you a link.',
                      style: GoogleFonts.montserrat(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                          letterSpacing: 0.7),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: textInputDecoration.copyWith(
                        labelText: 'Email',
                        labelStyle: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w500, fontSize: 15),
                        prefixIcon: const Icon(
                          Icons.email,
                          color: AppColor.iconColor,
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            width: 2,
                          ),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.green, width: 3)),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email addres';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButtonPage(
                    text: 'Send Rest Link',
                    onPressed: resetPassword,
                  ),
                  if (isEmailSent)
                    Text(
                      'passsword reset link sent to ${emailController.text}',
                      style: GoogleFonts.montserrat(
                          color: const Color.fromARGB(255, 7, 125, 11),
                          fontSize: 20),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void resetPassword() async {
    if (formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: emailController.text);
        setState(() {
          isEmailSent = true;
        });
      } catch (e) {
        (e);
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Wrong Email Address',
              style: GoogleFonts.montserrat(color: Colors.red, fontSize: 20),
            ),
          ),
        );
      }
    }
  }
}
