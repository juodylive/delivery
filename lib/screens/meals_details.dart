// ignore_for_file: unused_local_variable, unnecessary_null_comparison

import 'dart:async';
import 'package:eat_with_us/helpers/text_input_decoration.dart';
import 'package:eat_with_us/screens/reponse.dart';
import 'package:eat_with_us/services/stripe_payment.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:google_fonts/google_fonts.dart';

class MealsDetailsPage extends StatefulWidget {
  final FeedBack feedBack;
  const MealsDetailsPage({super.key, required this.feedBack});

  @override
  State<MealsDetailsPage> createState() => _MealsDetailsPageState();
}

class _MealsDetailsPageState extends State<MealsDetailsPage> {
  late User? user;
  late String? email;
  late StreamController<DocumentSnapshot<Map<String, dynamic>>>
      _detailsController;
  late Timer _statusUpdateTimer;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    email = user?.email;

    // Set up the stream for the specific document
    _detailsController =
        StreamController<DocumentSnapshot<Map<String, dynamic>>>();

    // Listen to changes in the specialRequest collection for the specific document
    FirebaseFirestore.instance
        .collection('specialRequest')
        .doc(widget.feedBack.documentId)
        .snapshots()
        .listen((snapshot) {
      // Add the updated snapshot to the stream controller
      _detailsController.add(snapshot);
    });

    // Set up the timer for status updates
    _statusUpdateTimer = Timer.periodic(const Duration(hours: 3), (timer) {
      if (widget.feedBack.status == 'can_work') {
        _updateStatus('decline');
        _statusUpdateTimer.cancel();
      }
    });
  }

  // Set up the stream for the specific document

  @override
  void dispose() {
    _detailsController.close();
    _statusUpdateTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _detailsController.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColor.iconColor,
              title: Text(
                'Loading...',
                style: GoogleFonts.montserrat(color: Colors.amber[100]),
              ),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColor.iconColor,
              title: Text('Error',
                  style: GoogleFonts.montserrat(color: Colors.amber[100])),
            ),
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.data() == null) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColor.iconColor,
              title: Text('Error',
                  style: GoogleFonts.montserrat(color: Colors.amber[100])),
            ),
            body: Center(
              child: Text('No data found', style: GoogleFonts.montserrat()),
            ),
          );
        } else {
          FeedBack updatedFeedBack = FeedBack.fromSnapshot(snapshot.data!);

          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text('Request Details',
                  style: GoogleFonts.montserrat(
                      fontSize: 22, color: Colors.amber[100])),
              backgroundColor: AppColor.iconColor,
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      'Request Id: ${updatedFeedBack.id}',
                      style: GoogleFonts.montserrat(fontSize: 20),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Meal: ${updatedFeedBack.mealName}',
                      style: GoogleFonts.montserrat(fontSize: 20),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Date and Time: ${updatedFeedBack.dateTime}',
                      style: GoogleFonts.montserrat(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Status: ${updatedFeedBack.status}',
                      style: GoogleFonts.montserrat(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Budget: ${updatedFeedBack.budget}',
                      style: GoogleFonts.montserrat(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    if ((updatedFeedBack.status == 'can_work' ||
                            updatedFeedBack.status == 'decline' ||
                            updatedFeedBack.status == 'approved') &&
                        updatedFeedBack.reason != null)
                      Text(
                        'Reason: ${updatedFeedBack.reason}',
                        style: GoogleFonts.montserrat(fontSize: 18),
                      ),
                    if ((updatedFeedBack.status == 'can_work' ||
                            updatedFeedBack.status == 'approved') &&
                        updatedFeedBack.expectedTime != null &&
                        updatedFeedBack.expectedTime.isNotEmpty)
                      Text(
                        'Expected Time For Preparing Meal  ${updatedFeedBack.expectedTime}',
                        style: GoogleFonts.montserrat(fontSize: 18),
                      ),
                    const SizedBox(
                      height: 12,
                    ),
                    _buildTrailingButtons(updatedFeedBack, context),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildTrailingButtons(FeedBack updatedFeedBack, BuildContext context) {
    if (updatedFeedBack.status == 'can_work') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.cyan,
              ),
              onPressed: () => _handleAcceptButton(context),
              child: Text(
                'Accept',
                style: GoogleFonts.montserrat(fontSize: 15),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.cyan,
              ),
              onPressed: () => _handleDeclineButton(context),
              child: Text(
                'Decline',
                style: GoogleFonts.montserrat(fontSize: 15),
              ),
            ),
          ),
        ],
      );
    } else if (updatedFeedBack.status == 'approved') {
      return SizedBox(
        height: 40,
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.indigoAccent,
          ),
          onPressed: () => _handlePayButton(context),
          child: Text(
            'Pay: ${updatedFeedBack.budget}',
            style: GoogleFonts.montserrat(
                fontSize: 20, letterSpacing: 0.6, color: Colors.amber[100]),
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  void _handleAcceptButton(BuildContext context) async {
    StripePaymentHandle paymentService = StripePaymentHandle();
    double totalAmount = widget.feedBack.budget;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Accept Request?', style: GoogleFonts.montserrat()),
          content: Text('Are you sure you want to accept this request?',
              style: GoogleFonts.montserrat()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('No', style: GoogleFonts.montserrat()),
            ),
            TextButton(
              onPressed: () async {
                // print('Before paymentService.stripeMakePayment');
                bool paymentSuccessful = await paymentService.stripeMakePayment(
                    context, totalAmount);
                // print('After paymentService.stripeMakePayment');

                if (paymentSuccessful) {
                  // print('Before _updateStatusAndMealStatus');
                  await _updateStatusAndMealStatus('paid');
                  // print('After _updateStatusAndMealStatus');

                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                }
              },
              child: Text('Yes', style: GoogleFonts.montserrat()),
            ),
          ],
        );
      },
    );
  }

  void _handleDeclineButton(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Decline Request?', style: GoogleFonts.montserrat()),
          content: Text('Are you sure you want to decline this request?',
              style: GoogleFonts.montserrat()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('No', style: GoogleFonts.montserrat()),
            ),
            TextButton(
              onPressed: () {
                _updateStatus('decline');
                Navigator.pop(context);
              },
              child: Text('Yes', style: GoogleFonts.montserrat()),
            ),
          ],
        );
      },
    );
  }

  void _handlePayButton(BuildContext context) {
    StripePaymentHandle paymentService = StripePaymentHandle();
    double totalAmount = widget.feedBack.budget;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Pay Request?', style: GoogleFonts.montserrat()),
          content: Text('Are you sure you want to pay for this request?',
              style: GoogleFonts.montserrat()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('No', style: GoogleFonts.montserrat()),
            ),
            TextButton(
              onPressed: () async {
                // print('Before payment service call');
                bool paymentSuccessful = await paymentService.stripeMakePayment(
                    context, totalAmount);
                // print('After payment service call');
                if (paymentSuccessful == true) {
                  await _updateStatusAndMealStatus('paid');
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                }
              },
              child: Text('Yes', style: GoogleFonts.montserrat()),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateStatus(String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('specialRequest')
          .doc(widget.feedBack.documentId)
          .update({'status': newStatus});
    } catch (e) {
      ('Error updating status: $e');
    }
  }

  Future<void> _updateStatusAndMealStatus(String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('specialRequest')
          .doc(widget.feedBack.documentId)
          .update({
        'status': newStatus,
        'mealStatus': 'pending',
        'paidTime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Handle error
      //
      ('Error updating status and mealStatus: $e');
    }
  }
}
