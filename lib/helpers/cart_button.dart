import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CartButtonPage extends StatefulWidget {
  final String text;
  final Function() onPressed;

  const CartButtonPage(
      {super.key, required this.text, required this.onPressed});

  @override
  State<CartButtonPage> createState() => _CartButtonPageState();
}

class _CartButtonPageState extends State<CartButtonPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: SizedBox(
        height: 30,
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:  Colors.indigoAccent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
          ),
          onPressed: widget.onPressed,
          child: Text(
            widget.text,
            style: GoogleFonts.montserrat(
                color: Colors.amber[100],
                fontSize: 11,
                fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
