// ignore_for_file: use_build_context_synchronously

import 'package:eat_with_us/helpers/pageview_buttons.dart';
import 'package:eat_with_us/helpers/text_input_decoration.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class FeedBack {
  // ...

  final String mealName;
  final String mealStatus;
  final double budget;
  final String description;
  final String? imageUrl;
  final String documentId;
  final List<double>? ratings; // Change type to List<double>?
  final String? feedback;
  final String id;
  final String type;

  FeedBack({
    required this.mealName,
    required this.mealStatus,
    required this.budget,
    required this.description,
    this.imageUrl,
    required this.documentId,
    this.ratings,
    this.feedback,
    required this.id,
    required this.type,
  });

  factory FeedBack.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return FeedBack(
      mealName: data['mealName'] ?? '',
      mealStatus: data['mealStatus'] ?? '',
      budget: (data['budget'] as num?)?.toDouble() ?? 0.0,
      description: data['description'] ?? '',
      imageUrl: data['image'],
      documentId: snapshot.id,
      ratings: (data['ratings'] as List<dynamic>?)?.cast<double>(),
      feedback: data['feedback'],
      id: data['id'] ?? '',
      type: data['deliveryType'] ?? '',
    );
  }
}

class SpecialOrderPage extends StatefulWidget {
  final PageController controller;

  const SpecialOrderPage({super.key, required this.controller});

  @override
  State<SpecialOrderPage> createState() => _SpecialOrderPageState();
}

class _SpecialOrderPageState extends State<SpecialOrderPage> {
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
    return Scaffold(
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
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('specialRequest')
            .where('email', isEqualTo: email)
            .where('mealStatus',
                whereIn: ['pending', 'delivered', 'rated']).snapshots(),
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

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No special orders found.',
                style: GoogleFonts.montserrat(fontSize: 18),
              ),
            );
          }

          List<FeedBack> specialOrders = snapshot.data!.docs
              .map((doc) => FeedBack.fromSnapshot(doc))
              .toList();

          return ListView.builder(
            itemCount: specialOrders.length,
            itemBuilder: (context, index) {
              FeedBack feedBack = specialOrders[index];
              return SpecialOrderCard(feedBack: feedBack);
            },
          );
        },
      ),
      backgroundColor: Colors.black.withOpacity(0.1),
    );
  }
}

class SpecialOrderCard extends StatelessWidget {
  final FeedBack feedBack;

  const SpecialOrderCard({super.key, required this.feedBack});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(
          feedBack.mealName,
          style: GoogleFonts.montserrat(fontSize: 20),
        ),
        subtitle: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Status: ${feedBack.mealStatus},',
                style: GoogleFonts.montserrat(fontSize: 18),
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                'Budget: \$${feedBack.budget} ',
                style: GoogleFonts.montserrat(fontSize: 18),
              )
            ],
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SpecialOrderDetailsPage(feedBack: feedBack),
            ),
          );
        },
      ),
    );
  }
}

class SpecialOrderDetailsPage extends StatefulWidget {
  final FeedBack feedBack;

  const SpecialOrderDetailsPage({super.key, required this.feedBack});

  @override
  State<SpecialOrderDetailsPage> createState() =>
      _SpecialOrderDetailsPageState();
}

class _SpecialOrderDetailsPageState extends State<SpecialOrderDetailsPage> {
  double initialRating = 0.0;
  late TextEditingController feedbackController;
  bool isRatingVisible = false;
  bool canSubmit = false;

  @override
  void initState() {
    super.initState();
    feedbackController = TextEditingController();
    initialRating =
        (widget.feedBack.ratings != null && widget.feedBack.ratings!.isNotEmpty)
            ? widget.feedBack.ratings![
                0] // Assuming ratings is a list and taking the first element
            : 0.0;
    feedbackController.text = widget.feedBack.feedback ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Special Meal Details',
          style: GoogleFonts.montserrat(color: Colors.amber[100]),
        ),
        backgroundColor: AppColor.iconColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(
                'Request Id: ${widget.feedBack.id}',
                style: GoogleFonts.montserrat(fontSize: 20),
              ),
              const SizedBox(height: 8),
              Text(
                'Meal: ${widget.feedBack.mealName}',
                style: GoogleFonts.montserrat(fontSize: 20),
              ),
              const SizedBox(height: 8),
              Text(
                'Status: ${widget.feedBack.mealStatus}',
                style: GoogleFonts.montserrat(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Budget: \$${widget.feedBack.budget}',
                style: GoogleFonts.montserrat(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Delivery Type: ${widget.feedBack.type}',
                style: GoogleFonts.montserrat(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Description: ${widget.feedBack.description}',
                style: GoogleFonts.montserrat(fontSize: 18),
              ),
              if (widget.feedBack.imageUrl != null &&
                  widget.feedBack.imageUrl!.isNotEmpty) ...[
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Image.network(
                    widget.feedBack.imageUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                ),
              ] else ...[
                const SizedBox(height: 20),
                Text(
                  'No image was given for this request.',
                  style: GoogleFonts.montserrat(fontSize: 14),
                ),
              ],
              if (widget.feedBack.mealStatus == 'rated') ...[
                const SizedBox(height: 16),
                Text(
                  'Ratings: ${widget.feedBack.ratings ?? 0.0}',
                  style: GoogleFonts.montserrat(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'Feedback: ${widget.feedBack.feedback ?? ''}',
                  style: GoogleFonts.montserrat(fontSize: 18),
                ),
              ],
              if (widget.feedBack.mealStatus == 'delivered') ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    backgroundColor: AppColor.iconColor,
                  ),
                  onPressed: () {
                    setState(() {
                      isRatingVisible = true;
                    });
                  },
                  child: Text(
                    'Rate Meal',
                    style: GoogleFonts.montserrat(
                      fontSize: 22,
                      color: Colors.amber[100],
                    ),
                  ),
                ),
                if (isRatingVisible) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Please select a rating or provide feedback before submitting.',
                    style: GoogleFonts.montserrat(color: Colors.red),
                  ),
                ],
                if (isRatingVisible) ...[
                  const SizedBox(height: 16),
                  RatingBar.builder(
                    initialRating: initialRating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 40,
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      setState(() {
                        initialRating = rating;
                        canSubmit = true;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: feedbackController,
                    onChanged: (value) {
                      setState(() {
                        canSubmit = value.isNotEmpty || initialRating > 0;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Feedback',
                      labelStyle: GoogleFonts.montserrat(),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 40,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        backgroundColor: AppColor.iconColor,
                      ),
                      onPressed: canSubmit
                          ? () async {
                              await _submitFeedback(context);
                            }
                          : null,
                      child: Text(
                        'Submit Feedback',
                        style: GoogleFonts.montserrat(
                          fontSize: 22,
                          color: Colors.amber[100],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitFeedback(BuildContext context) async {
    double rating = initialRating;
    String feedback = feedbackController.text;

    try {
      await FirebaseFirestore.instance
          .collection('specialRequest')
          .doc(widget.feedBack.documentId)
          .update({
        'ratings': FieldValue.arrayUnion([rating]),
        'feedback': feedback,
        'mealStatus': 'rated',
      });

      Navigator.pop(context); // Go back to the previous screen
    } catch (e) {
      // Handle error
      //    print('Error submitting feedback: $e');
    }
  }
}
