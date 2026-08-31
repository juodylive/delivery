// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:eat_with_us/helpers/buttons.dart';
import 'package:eat_with_us/helpers/text_input_decoration.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:uuid/uuid.dart'; // Import the uuid package

class ComplaintFormPage extends StatefulWidget {
  const ComplaintFormPage({super.key});

  @override
  State<ComplaintFormPage> createState() => _ComplaintFormPageState();
}

class _ComplaintFormPageState extends State<ComplaintFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  File? _image;
  String? _imageUrl;
  String? _userEmail;
  String? _deviceToken;
  bool _isSubmitting = false;
  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _fetchUserEmailAndDeviceToken();
  }

  Future<void> _fetchUserEmailAndDeviceToken() async {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _userEmail = user?.email;
    });

    try {
      var userTokenData = await FirebaseFirestore.instance
          .collection('deviceTokens')
          .doc(_userEmail)
          .get();

      if (userTokenData.exists) {
        setState(() {
          _deviceToken = userTokenData['token'];
        });
      }
    } catch (e) {
      //  print('Error fetching device token: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await _picker.pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });

      // Close the modal bottom sheet after a short delay
      Future.delayed(const Duration(milliseconds: 1000), () {});
    }
  }

  Future<void> _uploadImage() async {
    if (_image != null) {
      final storageRef = FirebaseStorage.instance.ref().child(
          'complaint_images/${_uuid.v4()}'); // Use the uuid to generate a unique name
      final uploadTask = storageRef.putFile(_image!);
      final snapshot = await uploadTask.whenComplete(() {});
      final imageUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        _imageUrl = imageUrl;
      });
    }
  }

  Future<void> _submitComplaint() async {
    if (_formKey.currentState!.validate()) {
      if (_image != null) {
        await _uploadImage();
      }

      // Generate a unique complaint ID using Uuid
      String complaintId = _uuid.v4().substring(0, 10);

      final complaint = {
        'complaintId': complaintId, // Add the unique complaint ID
        'title': _titleController.text.trim(),
        'body': _bodyController.text.trim(),
        'email': _userEmail,
        'image': _imageUrl,
        'timestamp': DateTime.now(),
        'token': _deviceToken,
        'status': 'pending'
      };

      if (_userEmail != null) {
        try {
          setState(() {
            _isSubmitting = true;
          });

          await FirebaseFirestore.instance
              .collection('complaints')
              .doc()
              .set(complaint);

          snackBar(context, Colors.green, 'Complaint submitted successfully!');

          _formKey.currentState?.reset();
          _titleController.clear();
          _bodyController.clear();
          setState(() {
            _image = null;
            _imageUrl = null;
            _isSubmitting = false;
          });
        } catch (error) {
          snackBar(context, Colors.red, 'An error occurred. Please try again.');
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  Future<void> _showImagePickerOptions() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: Text(
                'Open Camera',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              onTap: () {
                _pickImage(ImageSource.camera);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: Text(
                'Pick from Gallery',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Complaint Form',
            style: GoogleFonts.montserrat(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: Colors.amber[100],
            ),
          ),
          backgroundColor: AppColor.mainColor,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: textInputDecoration.copyWith(
                    labelText: 'Title',
                    labelStyle: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w500, fontSize: 15),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _bodyController,
                  decoration: textInputDecoration.copyWith(
                    labelText: 'Body',
                    labelStyle: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w500, fontSize: 15),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter the complaint details';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  readOnly: true,
                  initialValue: _userEmail ?? '',
                  decoration: textInputDecoration.copyWith(
                    labelText: 'Email',
                    labelStyle: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w500, fontSize: 15),
                  ),
                ),
                const SizedBox(height: 16.0),
                _image != null
                    ? Container(
                        height: 200,
                        width: 200,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(_image!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : Container(),
                const SizedBox(height: 16.0),
                ButtonPage(
                  onPressed: _isSubmitting ? null : _showImagePickerOptions,
                  child: Text(
                    'Upload a Picture',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      color: Colors.amber[100],
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                ButtonPage(
                  onPressed: _isSubmitting ? null : _submitComplaint,
                  child: _isSubmitting
                      ? const CircularProgressIndicator(
                          color: AppColor.mainColor,
                        )
                      : Text(
                          'Submit Complaint',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: Colors.amber[100],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
