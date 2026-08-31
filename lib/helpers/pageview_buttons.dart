import 'package:eat_with_us/helpers/text_input_decoration.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PageviewButton extends StatelessWidget {
  const PageviewButton(
      {super.key, required this.onPressed, required this.text});

  final Function() onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              backgroundColor: AppColor.iconColor),
          onPressed: onPressed,
          child: Text(
            text,
            style:
                GoogleFonts.montserrat(fontSize: 15, color: Colors.amber[100]),
          )),
    );
  }
}
