import 'package:eat_with_us/helpers/text_input_decoration.dart';
import 'package:eat_with_us/screens/change_password.dart';
import 'package:eat_with_us/screens/complain.dart';
import 'package:eat_with_us/screens/complain_history.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
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
            'Settings',
            style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: Colors.amber[100]),
          ),
          backgroundColor: AppColor.mainColor,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                const SizedBox(
                  height: 15,
                ),
                TextButton(
                  onPressed: () {
                    nextScreen(context, const ChangePassword());
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Change Password',
                        style: GoogleFonts.montserrat(
                            fontSize: 20,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w400),
                      ),
                      const Icon(
                        Icons.password,
                        color: AppColor.iconColor,
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextButton(
                  onPressed: () {
                    nextScreen(context, const ComplaintFormPage());
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Make A Complaint',
                        style: GoogleFonts.montserrat(
                            color: Colors.grey[700],
                            fontSize: 22,
                            fontWeight: FontWeight.w400),
                      ),
                      const Icon(
                        Icons.report_problem,
                        color: AppColor.iconColor,
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextButton(
                  onPressed: () {
                    nextScreen(context, const TreatedComplaintPage());
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Complaint History',
                        style: GoogleFonts.montserrat(
                            color: Colors.grey[700],
                            fontSize: 22,
                            fontWeight: FontWeight.w400),
                      ),
                      const Icon(
                        Icons.history,
                        color: AppColor.iconColor,
                      )
                    ],
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
