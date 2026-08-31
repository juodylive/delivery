import 'package:eat_with_us/helpers/text_input_decoration.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColor.mainColor,
        title: Text(
          'Contacts',
          style: GoogleFonts.montserrat(fontSize: 25, color: Colors.amber[100]),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('support').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
              color: AppColor.mainColor,
            ));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          List<DocumentSnapshot> contacts = snapshot.data!.docs;

          if (contacts.isEmpty) {
            return Center(
                child: Text(
              'No contacts available.',
              style: GoogleFonts.montserrat(),
            ));
          }

          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> contact =
                  contacts[index].data() as Map<String, dynamic>;

              return ListTile(
                title: Row(
                  children: [
                    Expanded(
                        child: Text(
                      contact['email'],
                      style: GoogleFonts.montserrat(
                          color: Colors.grey[900], fontSize: 17),
                    )),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        _copyToClipboard(contact['email'], context);
                      },
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Phone 1: ${contact['phoneNumber1']}',
                            style: GoogleFonts.montserrat(
                                color: Colors.grey[900], fontSize: 18),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            _copyToClipboard(contact['phoneNumber1'], context);
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Phone 2: ${contact['phoneNumber2']}',
                            style: GoogleFonts.montserrat(
                                color: Colors.grey[900], fontSize: 18),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            _copyToClipboard(contact['phoneNumber2'], context);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _copyToClipboard(String text, BuildContext context) {
    try {
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Copied to clipboard: $text'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error copying to clipboard.'),
        ),
      );
    }
  }
}
