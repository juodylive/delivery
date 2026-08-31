// ignore_for_file: use_build_context_synchronously

import 'package:eat_with_us/helpers/cart_button.dart';
import 'package:eat_with_us/helpers/pageview_buttons.dart';
import 'package:eat_with_us/helpers/text_input_decoration.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class OrderPage extends StatefulWidget {
  final PageController controller;
  const OrderPage({super.key, required this.controller});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  late User? user;
  late String? email;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    email = user?.email;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.black.withOpacity(0.1),
        ),
        Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PageviewButton(
                  onPressed: () {
                    widget.controller.animateToPage(0,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut);
                  },
                  text: 'Orders',
                ),
                PageviewButton(
                  onPressed: () {
                    widget.controller.animateToPage(1,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut);
                  },
                  text: 'Special Orders',
                ),
              ],
            ),
            backgroundColor: AppColor.iconColor,
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .where('email', isEqualTo: email)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(
                  color: AppColor.mainColor,
                ));
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              final orders = snapshot.data?.docs ?? [];
              // Sort orders by date in descending order
              orders.sort((a, b) =>
                  (b['date'] as Timestamp).compareTo(a['date'] as Timestamp));
              if (orders.isEmpty) {
                return Center(
                  child: Text(
                    'No order yet, please make a purchase to see your orders here.',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index].data() as Map<String, dynamic>;
                  // Check if the order is delivered
                  final bool isDelivered = order['status'] == 'delivered';
                  return GestureDetector(
                    onTap: () {
                      _showOrderDetails(order);
                    },
                    child: Card(
                      margin: const EdgeInsets.all(8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order ID: ${order['orderId']}',
                              style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[900],
                                  letterSpacing: 0.4,
                                  fontSize: 15),
                            ),
                            const SizedBox(
                              height: 3,
                            ),
                            Text(
                              'Date: ${_formatDate(order['date'])}',
                              style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[900],
                                  letterSpacing: 0.4,
                                  fontSize: 15),
                            ),
                            const SizedBox(
                              height: 3,
                            ),
                            Text(
                              'Total Amount: \$${order['totalAmount']}',
                              style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[900],
                                  letterSpacing: 0.4,
                                  fontSize: 15),
                            ),
                            const SizedBox(
                              height: 3,
                            ),
                            Text(
                              'Option: ${order['option']}',
                              style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[900],
                                  letterSpacing: 0.4,
                                  fontSize: 15),
                            ),
                            const SizedBox(
                              height: 3,
                            ),
                            Text(
                              'Status: ${order['status']}',
                              style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[900],
                                  letterSpacing: 0.4,
                                  fontSize: 15),
                            ),
                            if (isDelivered)
                              CartButtonPage(
                                onPressed: () {
                                  _showRatingDialog(order, index);
                                },
                                text: ('Rate Items'),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          backgroundColor: Colors.transparent,
        ),
      ],
    );
  }

  String _formatDate(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    return "${dateTime.day}-${dateTime.month}-${dateTime.year}";
  }

  void _showRatingDialog(Map<String, dynamic> order, int orderIndex) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Rate Items',
            style: GoogleFonts.montserrat(fontSize: 22),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var item in order['items'])
                _buildRatingItem(item, order, orderIndex),
              const SizedBox(height: 20),
              CartButtonPage(
                onPressed: () {
                  _closeRatingDialog(order['orderId'], order);
                },
                text: ('Rate The Items'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRatingItem(
      Map<String, dynamic> item, Map<String, dynamic> order, int orderIndex) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 2),
            child: Text(
              'Item: ${item['name']}',
              style: GoogleFonts.montserrat(),
            ),
          ),
          RatingBar.builder(
            initialRating: (item['ratings'] ?? 0.0).toDouble(),
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: false,
            itemCount: 5,
            itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) async {
              await _updateItemRating(item, rating, order, orderIndex);
            },
          ),
        ],
      ),
    );
  }

  _updateItemRating(Map<String, dynamic> item, double rating,
      Map<String, dynamic> order, int orderIndex) {
    var itemName = item['name'];

    // Update the 'ratings' field for the specific item in the 'meals' collection
    FirebaseFirestore.instance
        .collection('meals')
        .where('name', isEqualTo: itemName)
        .get()
        .then((querySnapshot) {
      var updateOperations = <Future>[];
      for (var doc in querySnapshot.docs) {
        updateOperations.add(doc.reference.update({
          'ratings': FieldValue.arrayUnion([rating])
        }));
      }
      return Future.wait(updateOperations);
    }).then((_) {
      // Update the item's rating in the order
      order['items'][orderIndex]['ratings'] = rating;

      // Update the 'ratings' field for the specific item in the 'orders' collection
      var orderId = order['orderId'];
      FirebaseFirestore.instance
          .collection('orders')
          .where('orderId', isEqualTo: orderId)
          .get()
          .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          var docId = querySnapshot.docs.first.id;
          FirebaseFirestore.instance.collection('orders').doc(docId).update({
            'ratings': FieldValue.arrayUnion([rating])
          });
        }
      });
    }).catchError((error) {
      Fluttertoast.showToast(
        msg: 'Failed to update item rating: $error',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    });
  }

  void _closeRatingDialog(String orderId, Map<String, dynamic> order) {
    // Find the document with the specified orderId and update its status to Closed
    FirebaseFirestore.instance
        .collection('orders')
        .where('orderId', isEqualTo: orderId)
        .get()
        .then((querySnapshot) async {
      if (querySnapshot.docs.isNotEmpty) {
        var docId = querySnapshot.docs.first.id;

        // Get the order data
        var orderData = querySnapshot.docs.first.data();

        // Update the status to Closed
        await FirebaseFirestore.instance
            .collection('orders')
            .doc(docId)
            .update({
          'status': 'Closed',
        });

        // Update the ratings for each item in the order
        var updateRatings = <Future>[];
        for (int i = 0; i < orderData['items'].length; i++) {
          var item = orderData['items'][i];
          var rating = item['ratings'];

          // Check if rating is not null before updating
          if (rating != null) {
            // Update the rating for the item in the meals collection
            await _updateItemRating(item, rating, order, i);

            // Add the rating to the 'ratings' field in the order
            updateRatings.add(FirebaseFirestore.instance
                .collection('orders')
                .doc(docId)
                .update({
              'ratings': FieldValue.arrayUnion([rating])
            }));
          }
        }

        // Wait for all rating updates to complete
        await Future.wait(updateRatings);

        Fluttertoast.showToast(
          msg: 'Thank You For Rating The Items',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        Navigator.of(context).pop(); // Close the rating dialog
      }
    }).catchError((error) {
      Fluttertoast.showToast(
        msg: 'Failed To Rate The Items: $error',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    });
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailsScreen(order: order),
      ),
    );
  }
}

class OrderDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Orders Details',
          style: GoogleFonts.montserrat(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: Colors.amber[100]),
        ),
        backgroundColor: AppColor.mainColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order ID: ${order['orderId']}',
                style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[900],
                    letterSpacing: 0.4,
                    fontSize: 15),
              ),
              const SizedBox(
                height: 2,
              ),
              Text(
                'Date/Time of Placing Order: ${formatDateTime(order['date'])}',
                style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[900],
                    letterSpacing: 0.4,
                    fontSize: 15),
              ),
              const SizedBox(
                height: 2,
              ),
              Text(
                'Total Amount: \$${order['totalAmount']}',
                style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[900],
                    letterSpacing: 0.4,
                    fontSize: 15),
              ),
              const SizedBox(
                height: 2,
              ),
              Text(
                'Option: ${order['option']}',
                style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[900],
                    letterSpacing: 0.4,
                    fontSize: 15),
              ),
              const SizedBox(
                height: 2,
              ),
              Text(
                'Phone Number: ${order['phoneNumber']}',
                style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[900],
                    letterSpacing: 0.4,
                    fontSize: 15),
              ),
              const SizedBox(
                height: 2,
              ),
              Text(
                'Address: ${order['address']}',
                style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[900],
                    letterSpacing: 0.4,
                    fontSize: 15),
              ),
              const SizedBox(
                height: 2,
              ),
              const SizedBox(height: 10),
              Text(
                'Items:',
                style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[900],
                    letterSpacing: 0.4,
                    fontSize: 18),
              ),
              for (var item in order['items']) _buildOrderItemDetails(item),
              const SizedBox(height: 10),
              Text(
                'Total Price: \$${order['totalAmount']}',
                style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[900],
                    letterSpacing: 0.4,
                    fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String formatDateTime(Timestamp dateTime) {
    // Format the timestamp to show date and time without milliseconds
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime.toDate());
  }

  Widget _buildOrderItemDetails(Map<String, dynamic> item) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Item: ${item['name']}',
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w500,
                color: Colors.grey[900],
                letterSpacing: 0.4,
                fontSize: 16),
          ),
          const SizedBox(
            height: 2,
          ),
          Text(
            'Quantity: ${item['quantity']}',
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w500,
                color: Colors.grey[900],
                letterSpacing: 0.4,
                fontSize: 15),
          ),
          const SizedBox(
            height: 2,
          ),
          Text(
            'Price per Item: \$${item['price']}',
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w500,
                color: Colors.grey[900],
                letterSpacing: 0.4,
                fontSize: 15),
          ),
          const SizedBox(
            height: 2,
          ),
          Text(
            'Subtotal: \$${item['quantity'] * item['price']}',
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w500,
                color: Colors.grey[900],
                letterSpacing: 0.4,
                fontSize: 15),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
