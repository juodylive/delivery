// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:eat_with_us/helpers/buttons.dart';
import 'package:eat_with_us/helpers/pageview_buttons.dart';
import 'package:eat_with_us/helpers/text_input_decoration.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'dart:math';

class RequestPage extends StatefulWidget {
  final PageController controller;
  const RequestPage({super.key, required this.controller});
  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _mealController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _imageFile;
  bool _isUploading = false;
  String? _deviceToken;
  String? _selectedCheckbox;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchDeviceToken();
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('user')
          .doc(user.email)
          .get();

      setState(() {
        _nameController.text = userData['name'];
        _emailController.text = userData['email'];
        _phoneController.text = userData['phone'] ?? '';
      });
    }
  }

  Future<void> _fetchDeviceToken() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        var userTokenData = await FirebaseFirestore.instance
            .collection('deviceTokens')
            .doc(user.email)
            .get();

        if (userTokenData.exists) {
          setState(() {
            _deviceToken = userTokenData['token'];
          });
        }
      } catch (e) {
        // print('Error fetching device token: $e');
      }
    }
  }

  String _generateUniqueId() {
    final Random random = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(10, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCheckbox == null) {
        // User hasn't selected any option, show a Snackbar
        snackBar(context, Colors.red, 'Please select Pick Up or Home Delivery');
        return;
      }

      setState(() {
        _isUploading = true;
      });

      try {
        // Upload image to Firebase Storage
        String imageUrl = await _uploadImage();

        // Generate unique ID
        String requestId = _generateUniqueId();

        // Convert budget to a numeric type
        double budget = double.parse(_budgetController.text);

        // Save request data to Firestore
        await FirebaseFirestore.instance
            .collection('specialRequest')
            .doc()
            .set({
          'id': requestId,
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'mealName': _mealController.text,
          'address': _addressController.text,
          'budget': budget,
          'description': _descriptionController.text,
          'status': 'pending',
          'image': imageUrl,
          'timestamp': FieldValue.serverTimestamp(),
          'token': _deviceToken,
          'deliveryType': _selectedCheckbox,
          'ratings': []
        });

        // Show success snackbar
        snackBar(
            context, Colors.green, 'Your Request Was Submitted Successfully');

        // Clear form fields and image
        _addressController.clear();
        _budgetController.clear();
        _descriptionController.clear();
        _mealController.clear();
        setState(() {
          _imageFile = null;
          _isUploading = false;
          _selectedCheckbox = null;
        });
      } catch (e) {
        // Show error snackbar
        snackBar(context, Colors.red,
            'Failed To Submit Your Request, Try Again Later');
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<String> _uploadImage() async {
    if (_imageFile == null) {
      return '';
    }

    final firebase_storage.Reference ref = firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child('request_images')
        .child(DateTime.now().millisecondsSinceEpoch.toString());

    final firebase_storage.UploadTask uploadTask = ref.putFile(_imageFile!);
    final firebase_storage.TaskSnapshot storageSnapshot =
        await uploadTask.whenComplete(() => null);
    final String downloadUrl = await storageSnapshot.ref.getDownloadURL();

    return downloadUrl;
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.black.withOpacity(0.1),
        ),
        Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PageviewButton(
                  text: 'Request A Meal',
                  onPressed: () {
                    widget.controller.animateToPage(0,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut);
                  },
                ),
                PageviewButton(
                  text: 'Response',
                  onPressed: () {
                    widget.controller.animateToPage(1,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut);
                  },
                )
              ],
            ),
            automaticallyImplyLeading: false,
            backgroundColor: AppColor.iconColor,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    readOnly: true,
                    decoration: textInputDecoration.copyWith(
                      labelText: 'Name',
                      labelStyle: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w500, fontSize: 15),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _emailController,
                    readOnly: true,
                    decoration: textInputDecoration.copyWith(
                      labelText: 'Email',
                      labelStyle: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w500, fontSize: 15),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Email is required';
                      }
                      return null;
                    },
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
                    textCapitalization: TextCapitalization.words,
                    controller: _mealController,
                    decoration: textInputDecoration.copyWith(
                      labelText: 'Meal Name',
                      labelStyle: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w500, fontSize: 15),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Meal Name is required';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    textCapitalization: TextCapitalization.words,
                    controller: _addressController,
                    decoration: textInputDecoration.copyWith(
                      labelText: 'Address',
                      labelStyle: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w500, fontSize: 15),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Address is required';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: _budgetController,
                    decoration: textInputDecoration.copyWith(
                      labelText: 'Budget',
                      labelStyle: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w500, fontSize: 15),
                      prefixText: '\$',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Budget is required';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: textInputDecoration.copyWith(
                      labelText: 'Description',
                      labelStyle: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w500, fontSize: 15),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Description is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Checkbox(
                        checkColor: Colors.amber[100],
                        activeColor: AppColor.iconColor,
                        value: _selectedCheckbox == 'pickup',
                        onChanged: (value) {
                          setState(() {
                            _selectedCheckbox = value! ? 'pickup' : null;
                          });
                        },
                      ),
                      Text(
                        'Pick Up',
                        style: GoogleFonts.montserrat(),
                      ),
                      Checkbox(
                        checkColor: Colors.amber[100],
                        activeColor: AppColor.iconColor,
                        value: _selectedCheckbox == 'homeDelivery',
                        onChanged: (value) {
                          setState(() {
                            _selectedCheckbox = value! ? 'homeDelivery' : null;
                          });
                        },
                      ),
                      Text(
                        'Home Delivery',
                        style: GoogleFonts.montserrat(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  ButtonPage(
                    onPressed: _showImagePickerOptions,
                    child: Text(
                      'Upload Image',
                      style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          color: Colors.amber[100]),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  if (_imageFile != null)
                    Image.file(
                      _imageFile!,
                      height: 200.0,
                      width: double.infinity,
                      fit: BoxFit.fill,
                    ),
                  const SizedBox(height: 16.0),
                  ButtonPage(
                    onPressed: _isUploading
                        ? null
                        : () async => await _submitRequest(),
                    child: _isUploading
                        ? CircularProgressIndicator(
                            color: Colors.cyan[100],
                          )
                        : Text(
                            'Submit Request',
                            style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                                color: Colors.amber[100]),
                          ),
                  ),
                ],
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
        ),
      ],
    );
  }
}
