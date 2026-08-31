// Import necessary packages
// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:eat_with_us/helpers/buttons.dart';
import 'package:eat_with_us/helpers/text_input_decoration.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();

  late String _imageUrl;
  late String _defaultImageUrl;

  bool _isLoading = false;
  File? _imageFile;

  @override
  void initState() {
    super.initState();

    _defaultImageUrl =
        'https://png.pngitem.com/pimgs/s/421-4212266_transparent-default-avatar-png-default-avatar-images-png.png';
    _imageUrl = _defaultImageUrl;
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('user')
            .doc(user.email)
            .get();

        setState(() {
          _nameController.text = userData['name'];
          _emailController.text = userData['email'];
          _phoneController.text = userData['phone'] ?? '';
          _countryController.text = userData['country'] ?? '';
          _stateController.text = userData['state'] ?? '';
          _addressController.text = userData['address'] ?? '';
          _dobController.text = userData['dateOfBirth'] ?? '';
          _genderController.text = userData['gender'] ?? '';
        });
      } catch (e) {
        // Handle error, e.g., show a snackbar
        //   print('Error fetching user data: $e');
      }

      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    try {
      final firebase_storage.Reference ref = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('user_image')
          .child('${_emailController.text}.jpg');

      final String downloadUrl = await ref.getDownloadURL();
      setState(() {
        _imageUrl = downloadUrl;
      });
    } catch (e) {
      // If there's no image, use the default URL
      setState(() {
        _imageUrl = _defaultImageUrl;
      });
    }
  }

  Future<void> _uploadImage() async {
    try {
      if (_imageFile != null) {
        final firebase_storage.Reference ref = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child('user_image')
            .child('${_emailController.text}.jpg');

        await ref.putFile(_imageFile!);
        final String downloadUrl = await ref.getDownloadURL();

        setState(() {
          _imageUrl = downloadUrl;
        });
      }
    } catch (e) {
      // print('Error uploading image: $e');
      // Handle the error as needed
    }
  }

  Future<void> _saveUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _uploadImage(); // Call the image upload function

      await FirebaseFirestore.instance
          .collection('user')
          .doc(_emailController.text)
          .update({
        'phone': _phoneController.text,
        'country': _countryController.text,
        'state': _stateController.text,
        'address': _addressController.text,
        'dob': _dobController.text,
        'gender': _genderController.text,
        'image_url': _imageUrl, // Update user's image URL in Firestore
      });

      // Show success snackbar
      snackBar(context, Colors.green, 'User details updated successfully');
    } catch (e) {
      // Handle error, e.g., show a snackbar
      //   print('Error updating user data: $e');
      snackBar(context, Colors.red, 'Error updating user details');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _imageUrl = pickedFile.path;
      });
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
                    fontWeight: FontWeight.w500, fontSize: 15),
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
                    fontWeight: FontWeight.w500, fontSize: 15),
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _dobController.text = picked.toLocal().toString().split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Profile',
          style: GoogleFonts.montserrat(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: Colors.amber[100]),
        ),
        backgroundColor: AppColor.mainColor,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _showImagePickerOptions,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 60.0,
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!)
                              : NetworkImage(_imageUrl)
                                  as ImageProvider<Object>?,
                        ),
                        Positioned(
                          bottom: -12,
                          right: -6,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt),
                            onPressed: _showImagePickerOptions,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _nameController,
                    decoration: textInputDecoration.copyWith(
                      labelText: 'Name',
                      labelStyle: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w500, fontSize: 15),
                    ),
                  ),
                  TextFormField(
                    controller: _emailController,
                    readOnly: true,
                    decoration: textInputDecoration.copyWith(
                      labelText: 'Email',
                      labelStyle: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w500, fontSize: 15),
                    ),
                  ),
                  TextFormField(
                    controller: _phoneController,
                    decoration: textInputDecoration.copyWith(
                      labelText: 'Phone Number',
                      labelStyle: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w500, fontSize: 15),
                    ),
                  ),
                  TextFormField(
                    controller: _countryController,
                    decoration: textInputDecoration.copyWith(
                      labelText: 'Country',
                      labelStyle: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w500, fontSize: 15),
                    ),
                  ),
                  TextFormField(
                    controller: _stateController,
                    decoration: textInputDecoration.copyWith(
                      labelText: 'State',
                      labelStyle: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w500, fontSize: 15),
                    ),
                  ),
                  TextFormField(
                    controller: _addressController,
                    decoration: textInputDecoration.copyWith(
                      labelText: 'Address',
                      labelStyle: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w500, fontSize: 15),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _dobController,
                        decoration: textInputDecoration.copyWith(
                          labelText: 'Date of Birth',
                          labelStyle: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w500, fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                  TextFormField(
                    controller: _genderController,
                    decoration: textInputDecoration.copyWith(
                      labelText: 'Gender',
                      labelStyle: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w500, fontSize: 15),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  ButtonPage(
                    onPressed: _saveUserData,
                    child: Text(
                      'Save',
                      style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w500,
                          fontSize: 22,
                          color: Colors.amber[100]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
