import 'package:eat_with_us/firebase_options.dart';
import 'package:eat_with_us/helpers/splash_screen.dart';
import 'package:eat_with_us/screens/button_navbar.dart';
import 'package:eat_with_us/services/api_keys.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Stripe.publishableKey = ApiKeys.publishKey;
  Stripe.instance.applySettings();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isFirebaseInitialized = false;

  @override
  void initState() {
    super.initState();
    initializeFirebase();
  }

  Future<void> initializeFirebase() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    Stripe.publishableKey = ApiKeys.publishKey;
    await Stripe.instance.applySettings();
    setState(() {
      isFirebaseInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eat With Us',
      home: isFirebaseInitialized
          ? FutureBuilder(
              future: FirebaseAuth.instance.authStateChanges().first,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  User? user = snapshot.data;
                  return determineHomeScreen(user);
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            )
          : const SplashScreen(),
    );
  }

  Widget determineHomeScreen(User? user) {
    if (user != null && user.emailVerified) {
      return const BottomNavBar();
    } else {
      return const SplashScreen();
    }
  }
}
