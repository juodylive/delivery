import 'package:eat_with_us/helpers/text_input_decoration.dart';
import 'package:eat_with_us/screens/register_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  BuildContext? pageContext;

  final PageController _pageController = PageController();
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                currentPage = index;
              });
            },
            children: [
              _buildFirstPage(),
              _buildSecondPage(),
              _buildThirdPage(),
              _buildLastPage(),
            ],
          ),
          Positioned(
            bottom: 20.0,
            left: 0.0,
            right: 0.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: 4,
                effect: const ExpandingDotsEffect(
                    activeDotColor: Colors.indigoAccent,
                    dotHeight: 13,
                    dotWidth: 13,
                    expansionFactor: 2),
                onDotClicked: (index) {
                  _pageController.animateToPage(index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFirstPage() {
    return SingleChildScrollView(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 1.1,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 10,
              ),
              Center(
                child: Text(
                  'EatWithUs',
                  style: GoogleFonts.akronim(
                      fontSize: 40,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo[500]),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Welcome To The World Of Food',
                style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.indigoAccent),
              ),
              Expanded(
                child: Image.asset(
                  'assets/images/chef1.png',
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondPage() {
    return SingleChildScrollView(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 1.1,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 10,
              ),
              Center(
                child: Text(
                  'EatWithUs',
                  style: GoogleFonts.akronim(
                      fontSize: 40,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo[500]),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Easy To Order',
                style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.indigoAccent),
              ),
              Expanded(
                child: Image.asset(
                  'assets/images/orders.png',
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThirdPage() {
    return SingleChildScrollView(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 1.1,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 10,
              ),
              Center(
                child: Text(
                  'EatWithUs',
                  style: GoogleFonts.akronim(
                      fontSize: 40,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo[500]),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Fast Delivery',
                style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.indigoAccent),
              ),
              Expanded(
                child: Image.asset(
                  'assets/images/deliverys.png',
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLastPage() {
    return Stack(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 1.1,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Text(
                      'EatWithUs',
                      style: GoogleFonts.akronim(
                          fontSize: 40,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo[500]),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Request A Special Meal Of Your Choice From Our Best Chefs.',
                    style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.indigoAccent),
                    softWrap: true,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Expanded(
                    child: Image.asset(
                      'assets/images/Chef-bro.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 20.0,
          right: 16.0,
          child: SizedBox(
            child: ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.grey[100]),
              onPressed: () {
                // Capture the context before entering the asynchronous block
                pageContext = Navigator.of(context).overlay!.context;

                // Navigate to the registration page using the captured context
                Navigator.pushReplacement(
                  pageContext!,
                  MaterialPageRoute(
                      builder: (pageContext) => const RegisterPage()),
                );
              },
              child: Text(
                'Get Started',
                style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: AppColor.mainColor),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
