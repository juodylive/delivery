import 'package:flutter/material.dart';

const textInputDecoration = InputDecoration(
  labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
  focusedBorder: UnderlineInputBorder(
    borderSide: BorderSide(color: Colors.blue, width: 2),
  ),
  enabledBorder: UnderlineInputBorder(),
  errorBorder: UnderlineInputBorder(
    borderSide: BorderSide(color: Colors.red, width: 2),
  ),
);

void nextScreen(context, page) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => page));
}

void nextScreenReplace(context, page) {
  Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => page));
}

void snackBar(context, color, message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(
      '$message',
      style: const TextStyle(
          fontFamily: 'poppins', fontSize: 15, fontWeight: FontWeight.w200),
    ),
    backgroundColor: color,
    duration: const Duration(seconds: 2),
    action: SnackBarAction(
      label: 'OK',
      onPressed: () {},
      textColor: Colors.white,
    ),
  ));
}

class AppColor {
  static const resturantColor = Color.fromARGB(255, 255, 255, 255);
  static const subResturantColor = Color.fromARGB(255, 238, 235, 232);
  static const iconColor = Colors.indigoAccent;
  static const labelTextColor = Colors.white;
  static const firstTextSpanColor = Color.fromARGB(223, 255, 255, 255);
  static const secoundTextSpanColor = Color.fromARGB(223, 250, 250, 250);
  static const formFieldColor = Colors.white;
  static const mainColor = Colors.indigoAccent;
}
