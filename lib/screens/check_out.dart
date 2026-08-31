// ignore_for_file: use_build_context_synchronously

import 'package:eat_with_us/helpers/cart_controller.dart';
import 'package:eat_with_us/helpers/text_input_decoration.dart';
import 'package:eat_with_us/screens/button_navbar.dart';
import 'package:eat_with_us/services/stripe_payment.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:uuid/uuid.dart';

class CheckoutPage extends StatefulWidget {
  final CartController cartController;

  const CheckoutPage({super.key, required this.cartController});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool eatWithUsSelected = true; // "Eat With Us" is the default option
  bool homeDeliverySelected = false;
  bool isLoading = false;
  TextEditingController addressController = TextEditingController();

  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController tableNumberController = TextEditingController();

  String? deviceToken;
  String? userName;

  @override
  void initState() {
    super.initState();
    // Fetch user information and device token on page initialization
    fetchUserInformationAndDeviceToken();
  }

  void fetchUserInformationAndDeviceToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.email;
      if (userId != null) {
        // Fetch user document from Firestore
        var userData = await FirebaseFirestore.instance
            .collection('user')
            .doc(userId)
            .get();

        // Update controllers with user information if available
        if (userData.exists) {
          var userAddress = userData['address'];
          var userPhoneNumber = userData['phone'];
          userName = userData['name'];

          // Set the controllers only if the information is available
          if (userAddress != null) {
            addressController.text = userAddress;
          }
          if (userPhoneNumber != null) {
            phoneNumberController.text = userPhoneNumber;
          }
        }

        // Fetch device token
        var userTokenData = await FirebaseFirestore.instance
            .collection('deviceTokens')
            .doc(userId)
            .get();

        if (userTokenData.exists) {
          setState(() {
            deviceToken = userTokenData['token'];
          });
        }
      }
    } catch (e) {
      //   print('Error fetching user information: $e');
    }
  }

  Future<void> saveOrder(CartController cart, bool eatWithUs, String address,
      String phoneNumber, String tableNumber) async {
    //  print('Saving order...');
    var uuid = const Uuid();
    var orderId = uuid.v4().substring(0, 8);
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;

    try {
      // Save the order to Firebase
      await FirebaseFirestore.instance.collection('orders').doc().set({
        'email': email,
        'orderId': orderId,
        'date': DateTime.now(),
        'status': 'Pending',
        'items': cart.cartItems
            .map((item) => {
                  'name': item.name,
                  'price': item.price,
                  'quantity': item.quantity,
                  'Subtotal': (item.price * item.quantity)
                })
            .toList(),
        'totalAmount': cart.calculateTotalPrice(),
        'option': eatWithUs ? 'Eat With Us' : 'Home Delivery',
        'address': address,
        'phoneNumber': phoneNumber,
        'tableNumber': tableNumber,
        'token': deviceToken,
        'name': userName,
        'ratings': []
      });

      //   print('Order saved successfully!');
    } catch (e) {
      //   print('Error saving order: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    StripePaymentHandle paymentService = StripePaymentHandle();
    // ignore: unused_local_variable
    double totalAmount = widget.cartController.calculateTotalPrice();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Check Out',
          style: GoogleFonts.montserrat(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: Colors.amber[100],
          ),
        ),
        backgroundColor: AppColor.mainColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Items in Cart: ${widget.cartController.cartItems.length}',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Options',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              CheckboxListTile(
                title: Text(
                  'Eat With Us',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                value: eatWithUsSelected,
                onChanged: (value) {
                  setState(() {
                    eatWithUsSelected = value!;
                    if (value) {
                      homeDeliverySelected = false;
                    }
                  });
                },
              ),
              CheckboxListTile(
                title: Text(
                  'Home Delivery',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                value: homeDeliverySelected,
                onChanged: (value) {
                  setState(() {
                    homeDeliverySelected = value!;
                    if (value) {
                      eatWithUsSelected = false;
                    }
                  });
                },
              ),
              if (homeDeliverySelected)
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        'Delivery Address',
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextField(
                        controller: addressController,
                        decoration: InputDecoration(
                          labelText: 'Enter your address',
                          labelStyle: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Phone Number',
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextField(
                        controller: phoneNumberController,
                        decoration: InputDecoration(
                          labelText: 'Enter your phone number',
                          labelStyle: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (eatWithUsSelected)
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        'Table Number (Optional)',
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextField(
                        controller: tableNumberController,
                        decoration: InputDecoration(
                          labelText: 'Enter your table number (optional)',
                          labelStyle: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              SizedBox(
                height: 45,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    backgroundColor: AppColor.mainColor,
                  ),
                  onPressed: (eatWithUsSelected || homeDeliverySelected)
                      ? () async {
                          if (isLoading) return;

                          try {
                            setState(() {
                              isLoading = true;
                            });

                            if (homeDeliverySelected &&
                                addressController.text.isEmpty) {
                              snackBar(context, Colors.red,
                                  'Address is needed for home delivery');
                              return;
                            }

                            double totalAmount =
                                widget.cartController.calculateTotalPrice();

                            if (homeDeliverySelected) {
                              totalAmount += (totalAmount * 0.08);
                            }

                            // Proceed to pay logic
                            bool paymentSuccessful = await paymentService
                                .stripeMakePayment(context, totalAmount);
                            //        print('Payment successful: $paymentSuccessful');
                            if (paymentSuccessful &&
                                widget.cartController.cartItems.isNotEmpty) {
                              //  print(
                              //       'Cart is not empty: ${widget.cartController.cartItems.isNotEmpty}');
                              // Save the order to Firebase
                              try {
                                await saveOrder(
                                  widget.cartController,
                                  eatWithUsSelected,
                                  addressController.text,
                                  phoneNumberController.text,
                                  tableNumberController.text,
                                );
                                //    print('Order saved successfully!');
                              } catch (e) {
                                //     print('Error saving order: $e');
                              }

                              // Clear the cart after placing the order
                              widget.cartController.cartItems.clear();

                              // Navigate to the BottomNavBar page
                              nextScreenReplace(context, const BottomNavBar());
                            } else {
                              // Show an error snackbar and remain in the checkout page
                              snackBar(context, Colors.red,
                                  'Payment failed or cart is empty. Please try again.');
                            }
                          } finally {
                            setState(() {
                              isLoading = false;
                            });
                          }
                        }
                      : null, // Disabled button if no option selected
                  child: isLoading
                      ? CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.amber[100]!),
                        )
                      : Text(
                          'Proceed to Pay',
                          style: GoogleFonts.montserrat(
                            color: Colors.amber[100],
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),
              if (homeDeliverySelected)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    '8% delivery cost included for home delivery items.',
                    style: GoogleFonts.montserrat(
                        fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
