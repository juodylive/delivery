// ignore_for_file: use_build_context_synchronously

import 'package:eat_with_us/helpers/elevated_button.dart';
import 'package:eat_with_us/helpers/text_input_decoration.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();

  var auth = FirebaseAuth.instance;
  var currentUser = FirebaseAuth.instance.currentUser;

  Future<void> changePassword(
      String email, String oldPassword, String newPassword) async {
    var credentials =
        EmailAuthProvider.credential(email: email, password: oldPassword);

    try {
      await currentUser!.reauthenticateWithCredential(credentials);
      await currentUser!.updatePassword(newPassword);
    } catch (error) {
      // Handle incorrect old password
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Error',
              style: GoogleFonts.montserrat(),
            ),
            content: Text('Old password is incorrect.',
                style: GoogleFonts.montserrat()),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK', style: GoogleFonts.montserrat()),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: AppColor.mainColor,
          title: Text(
            'Change Password',
            style: GoogleFonts.montserrat(color: Colors.amber[100]),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Column(
                children: [
                  MyFormField(
                    data: 'Old Password',
                    icon: Icons.visibility_off,
                    textFieldController: oldPasswordController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Field cannot be empty';
                      }
                      return null;
                    },
                    onTap: () {},
                  ),
                  const SizedBox(height: 13),
                  MyFormField(
                    data: 'New Password',
                    icon: Icons.visibility_off,
                    textFieldController: newPasswordController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Field cannot be empty';
                      }
                      return null;
                    },
                    onTap: () {},
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  ElevatedButtonPage(
                    onPressed: () async {
                      String? validationError;
                      if (oldPasswordController.text.isEmpty ||
                          newPasswordController.text.isEmpty) {
                        validationError = 'Fields cannot be empty';
                      }

                      if (validationError == null) {
                        await changePassword(
                          currentUser!.email!,
                          oldPasswordController.text,
                          newPasswordController.text,
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Error',
                                  style: GoogleFonts.montserrat()),
                              content: Text(validationError!),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('OK',
                                      style: GoogleFonts.montserrat()),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    text: 'Change Password',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
