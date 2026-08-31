import 'package:eat_with_us/helpers/carousel_slider.dart';
import 'package:eat_with_us/helpers/cart_controller.dart';
import 'package:eat_with_us/helpers/text_input_decoration.dart';
import 'package:eat_with_us/screens/cart.dart';
import 'package:eat_with_us/screens/contacts.dart';
import 'package:eat_with_us/screens/login_page.dart';
import 'package:eat_with_us/screens/notification.dart';
import 'package:eat_with_us/screens/profile.dart';
import 'package:eat_with_us/screens/settings.dart';
import 'package:eat_with_us/services/firebase_api.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.cartController});

  final CartController cartController;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  FirebaseAuth auth = FirebaseAuth.instance;
  final usersCollection = FirebaseFirestore.instance.collection('user');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ignore: unused_field

  final CollectionReference backgroundImages =
      FirebaseFirestore.instance.collection('backgroundImage');
  final CollectionReference meals =
      FirebaseFirestore.instance.collection('meals');

  String? _imageUrl;

  Future<void> _fetchUserProfile() async {
    final email = auth.currentUser!.email;
    final userDoc = await _firestore.collection('user').doc(email).get();
    final userData = userDoc.data();
    final imageUrl = userData?['image_url'];

    setState(() {
      _imageUrl = imageUrl;
    });
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _fetchUserProfile();
    await FirebaseApi().initNotification();

    loadCollection();
  }

  Future<void> loadCollection() async {
    await backgroundImages.get();
    await meals.get();
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();

      // Navigate to the login page and remove all previous routes from the stack
      // ignore: use_build_context_synchronously
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      //   print('Error signing out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Eat With Us',
          style: GoogleFonts.montserrat(fontSize: 22, color: Colors.amber[100]),
        ),
        backgroundColor: AppColor.mainColor,
        actions: [
          if (widget.cartController.cartItems.isNotEmpty)
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CartPage(cartController: widget.cartController),
                      ),
                    );
                  },
                ),
                Positioned(
                  right: 0,
                  child: CircleAvatar(
                    backgroundColor: Colors.amber,
                    radius: 10,
                    child: Text(
                      widget.cartController.cartItems.length.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: const BoxDecoration(
                      color: Colors.indigoAccent,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Stack(
                            children: [
                              if (_imageUrl != null)
                                CircleAvatar(
                                  radius: 60.0,
                                  backgroundImage: NetworkImage(_imageUrl!),
                                )
                              else
                                const CircleAvatar(
                                  radius: 60.0,
                                  backgroundImage: NetworkImage(
                                      'https://png.pngitem.com/pimgs/s/421-4212266_transparent-default-avatar-png-default-avatar-images-png.png'),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: Text(
                      '${currentUser.displayName}',
                      style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w500, fontSize: 17),
                      softWrap: true,
                    ),
                    subtitle: Text(
                      currentUser.email!,
                      softWrap: true,
                      style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                          letterSpacing: 0.1),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'Profile',
                      style: GoogleFonts.montserrat(
                          fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      nextScreen(context, const ProfilePage());
                    },
                  ),
                  ListTile(
                    title: Text('Setting',
                        style: GoogleFonts.montserrat(
                            fontSize: 20, fontWeight: FontWeight.w500)),
                    onTap: () {
                      nextScreen(context, const Setting());
                    },
                  ),
                  ListTile(
                    title: Text(
                      'Contact Us',
                      style: GoogleFonts.montserrat(
                          fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      nextScreen(context, const ContactPage());
                    },
                  ),
                  ListTile(
                    title: Text(
                      'Notifications',
                      style: GoogleFonts.montserrat(
                          fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      nextScreen(context, const NotificationsPage());
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text('Log Out',
                  style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w700, fontSize: 20)),
              onTap: _signOut,
              trailing: IconButton(
                onPressed: _signOut,
                icon: const Icon(
                  Icons.logout,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.black.withOpacity(0.1),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                FutureCarouselSlider(
                  collectionReference: backgroundImages,
                  itemHeight: 180.0,
                  clickable: false,
                  cartController: widget.cartController,
                  onUpdate: () {},
                ),
                // const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FutureCarouselSlider(
                    collectionReference: meals,
                    includeNameAndPrice: true,
                    viewportFraction: 0.5,
                    itemHeight: 280.0,
                    cartController: widget.cartController,
                    onUpdate: () {
                      setState(() {});
                    },
                  ),
                ),
                // const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FutureCarouselSlider(
                    collectionReference: meals,
                    includeNameAndPrice: true,
                    viewportFraction: 0.5,
                    itemHeight: 280.0,
                    cartController: widget.cartController,
                    onUpdate: () {
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
    );
  }
}
