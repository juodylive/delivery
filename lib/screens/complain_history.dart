import 'package:eat_with_us/helpers/text_input_decoration.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:google_fonts/google_fonts.dart';

class TreatedComplaintPage extends StatelessWidget {
  const TreatedComplaintPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Treated Complaints',
          style: GoogleFonts.montserrat(color: Colors.amber[100]),
        ),
        backgroundColor: AppColor.mainColor,
      ),
      body: const ComplaintList(),
    );
  }
}

class ComplaintList extends StatefulWidget {
  const ComplaintList({super.key});

  @override
  State<ComplaintList> createState() => _ComplaintListState();
}

class _ComplaintListState extends State<ComplaintList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('complaints')
          .where('email', isEqualTo: 'email')
          .where('status', isEqualTo: 'treated')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColor.mainColor,
            ),
          );
        }

        var complaints = snapshot.data!.docs;

        if (complaints.isEmpty) {
          return Center(
            child: Text('No treated complaints yet.',
                style: GoogleFonts.montserrat(fontSize: 17)),
          );
        }

        return ListView.builder(
          itemCount: complaints.length,
          itemBuilder: (context, index) {
            var complaint = complaints[index].data();
            var complaintId = complaints[index].id;

            return ListTile(
              title: Padding(
                padding: const EdgeInsets.all(3.0),
                child:
                    Text(complaint['title'], style: GoogleFonts.montserrat()),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Text(complaint['email'],
                        style: GoogleFonts.montserrat(
                            fontSize: 16, color: Colors.grey[800])),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: SelectableText(complaint['complaintId'],
                        style: GoogleFonts.montserrat(
                            fontSize: 16, color: Colors.grey[800])),
                  )
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ComplaintDetailsPage(
                      complaintId: complaintId,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class ComplaintDetailsPage extends StatelessWidget {
  final String complaintId;

  const ComplaintDetailsPage({super.key, required this.complaintId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Complaint Details',
            style: GoogleFonts.montserrat(color: Colors.amber[100])),
        backgroundColor: AppColor.mainColor,
      ),
      body: FutureBuilder(
        future: fetchComplaintDetails(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColor.mainColor,
              ),
            );
          }

          var complaintDetails = snapshot.data;

          // Convert Firestore timestamp to DateTime
          DateTime timestamp =
              (complaintDetails!['timestamp'] as Timestamp).toDate();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Title: ${complaintDetails['title']}',
                      style: GoogleFonts.montserrat(fontSize: 15)),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Email: ${complaintDetails['email']}',
                      style: GoogleFonts.montserrat(fontSize: 15)),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                      'Complaint ID: ${complaintDetails['complaintId']}',
                      style: GoogleFonts.montserrat(fontSize: 15)),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Body: ${complaintDetails['body'] ?? 'N/A'}',
                      style: GoogleFonts.montserrat()),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Reply: ${complaintDetails['reply'] ?? 'N/A'}',
                      style: GoogleFonts.montserrat(fontSize: 15)),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Date And Time: ${_formatDateTime(timestamp)}',
                      style: GoogleFonts.montserrat(fontSize: 15)),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                      'Admin Email: ${complaintDetails['adminEmail'] ?? 'N/A'}',
                      style: GoogleFonts.montserrat(fontSize: 15)),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                        complaintDetails['image'] ??
                            'https://png.pngitem.com/pimgs/s/421-4212266_transparent-default-avatar-png-default-avatar-images-png.png',
                      ),
                      radius: 50.0,
                    ),
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                        complaintDetails['images'] ??
                            'https://png.pngitem.com/pimgs/s/421-4212266_transparent-default-avatar-png-default-avatar-images-png.png',
                      ),
                      radius: 50.0,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('Image from User', style: GoogleFonts.montserrat()),
                    Text('Image from Admin', style: GoogleFonts.montserrat()),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }

  Future<Map<String, dynamic>> fetchComplaintDetails() async {
    try {
      var documentSnapshot = await FirebaseFirestore.instance
          .collection('complaints')
          .doc(complaintId)
          .get();

      var complaintDetails = documentSnapshot.data();
      return complaintDetails ?? {};
    } catch (e) {
      //  print('Error fetching complaint details: $e');
      return {};
    }
  }
}
