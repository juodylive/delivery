import 'package:eat_with_us/helpers/pageview_buttons.dart';
import 'package:eat_with_us/helpers/text_input_decoration.dart';
import 'package:eat_with_us/screens/meals_details.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class Respons extends StatefulWidget {
  final PageController controller;

  const Respons({super.key, required this.controller});

  @override
  State<Respons> createState() => _ResponsState();
}

class _ResponsState extends State<Respons> {
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
              text: 'Requeast A Meal',
            ),
            PageviewButton(
              onPressed: () {
                widget.controller.animateToPage(1,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut);
              },
              text: 'Response',
            ),
          ],
        ),
        backgroundColor: AppColor.iconColor,
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.black.withOpacity(0.1),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [Expanded(child: ResponseHistoryList())],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
    );
  }
}

class ResponseHistoryList extends StatelessWidget {
  const ResponseHistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FeedBack>>(
      stream: _fetchResponse(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'No Response For Any Requested Meal Yet.',
              style: GoogleFonts.montserrat(fontSize: 18),
            ),
          );
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              FeedBack feedBack = snapshot.data![index];
              return ResponseCard(feedBack: feedBack, context: context);
            },
          );
        }
      },
    );
  }

  Stream<List<FeedBack>> _fetchResponse() {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;

    if (email != null) {
      try {
        return FirebaseFirestore.instance
            .collection('specialRequest')
            .where('email', isEqualTo: email)
            .snapshots()
            .map((snapshot) => snapshot.docs
                .map((doc) => FeedBack.fromSnapshot(doc))
                .toList());
      } catch (error) {
        throw ('Error fetching Response: $error');
      }
    } else {
      throw ('User is not authenticated');
    }
  }
}

class ResponseCard extends StatelessWidget {
  final FeedBack feedBack;
  final BuildContext context;

  const ResponseCard({
    super.key,
    required this.feedBack,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MealsDetailsPage(feedBack: feedBack),
            ),
          );
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(
                  'Meal: ${feedBack.mealName}',
                  style: GoogleFonts.montserrat(fontSize: 18),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    feedBack.status,
                    style: GoogleFonts.montserrat(fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeedBack {
  final String mealName;
  final String status;
  final double budget;
  final String documentId;
  final String reason;
  final DateTime dateTime;
  final String expectedTime;
  final String id;

  FeedBack(
      {required this.mealName,
      required this.status,
      required this.budget,
      required this.documentId,
      required this.reason,
      required this.dateTime,
      required this.expectedTime,
      required this.id});

  // Construct a Special Request from a Firestore document snapshot
  factory FeedBack.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;

    // Check for null values before casting
    final timestamp = data['timeStamp'] as Timestamp?;

    return FeedBack(
      mealName: data['mealName'] ?? '',
      status: data['status'] ?? '',
      budget: (data['budget'] ?? 0.0).toDouble(),
      reason: data['reason'] ?? '',
      expectedTime: data['expectedtime'] ?? '',
      dateTime: timestamp != null ? timestamp.toDate() : DateTime.now(),
      documentId: snapshot.id,
      id: data['id'] ?? '',
    );
  }
}
