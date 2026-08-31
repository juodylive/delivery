import 'package:eat_with_us/helpers/elevated_button.dart';
import 'package:eat_with_us/helpers/text_input_decoration.dart';
import 'package:eat_with_us/screens/button_navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmailVerifyLink extends StatefulWidget {
  const EmailVerifyLink({super.key});

  @override
  State<EmailVerifyLink> createState() => _EmailVerifyLinkState();
}

class _EmailVerifyLinkState extends State<EmailVerifyLink> {
  final auth = FirebaseAuth.instance;
  late User user;

  @override
  void initState() {
    user = auth.currentUser!;
    user.sendEmailVerification();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 40,
            ),
            Text(
              'Welcome toEat With Us',
              style:
                  GoogleFonts.montserrat(fontSize: 20, color: Colors.grey[800]),
            ),
            const SizedBox(
              height: 30,
            ),
            SizedBox(
              height: 300,
              width: double.infinity,
              child: Image.asset(
                'assets/images/image4.jpg',
                fit: BoxFit.fill,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                'An email has been sent to ${user.email} please verify your email to continue.',
                style: GoogleFonts.montserrat(
                    fontSize: 18, color: Colors.grey[800]),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ElevatedButtonPage(
                onPressed: () async {
                  await auth.currentUser!.reload();
                  if (auth.currentUser!.emailVerified) {
                    //   ignore: use_build_context_synchronously
                    nextScreenReplace(context, const BottomNavBar());
                  } else {
                    // ignore: use_build_context_synchronously
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(
                            'Email Not Verified',
                            style: GoogleFonts.montserrat(),
                          ),
                          content: Text('Please verify your email to continue.',
                              style: GoogleFonts.montserrat()),
                          actions: [
                            ElevatedButton(
                              child:
                                  Text('OK', style: GoogleFonts.montserrat()),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                text: 'Continue',
              ),
            ),
            const SizedBox(width: 15.0),
            TextButton(
              onPressed: () async {
                // Resend the verification link to the user's email
                try {
                  await auth.currentUser?.sendEmailVerification();
                  // ignore: use_build_context_synchronously
                  snackBar(context, Colors.green, 'Verification email resent');
                } catch (e) {
                  // ignore: use_build_context_synchronously
                  snackBar(context, Colors.red,
                      'Error resending verification email: $e');
                }
              },
              child: Text(
                'Resend Verification Email',
                style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
