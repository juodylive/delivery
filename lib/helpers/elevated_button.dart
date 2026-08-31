import 'package:eat_with_us/helpers/text_input_decoration.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ElevatedButtonPage extends StatefulWidget {
  final String text;
  final Function() onPressed;

  const ElevatedButtonPage(
      {super.key, required this.text, required this.onPressed});

  @override
  State<ElevatedButtonPage> createState() => _ElevatedButtonPageState();
}

class _ElevatedButtonPageState extends State<ElevatedButtonPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: SizedBox(
        height: 65,
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigoAccent,
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
                fontSize: 23,
                fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}

class MyFormField extends StatefulWidget {
  final String data;
  final IconData icon;
  final TextEditingController textFieldController;
  final String? Function(String?)? validator;
  final Function() onTap;

  const MyFormField({
    super.key,
    required this.data,
    required this.icon,
    required this.textFieldController,
    this.validator,
    required this.onTap,
  });

  @override
  State<MyFormField> createState() => _MyFormFieldState();
}

class _MyFormFieldState extends State<MyFormField> {
  bool obscureText = true;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTap: widget.onTap,
      controller: widget.textFieldController,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: widget.data,
        labelStyle:
            GoogleFonts.montserrat(color: Colors.grey[700], fontSize: 20),
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              obscureText = !obscureText;
            });
          },
          child: Icon(
            widget.icon,
            color: AppColor.iconColor,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            width: 2,
            color: AppColor.mainColor,
          ),
          borderRadius: BorderRadius.circular(100),
        ),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: const BorderSide(color: AppColor.mainColor, width: 2)),
      ),
      onChanged: (value) {
        setState(() {});
      },
      validator: widget.validator,
    );
  }
}
