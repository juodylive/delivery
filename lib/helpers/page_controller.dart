import 'package:eat_with_us/screens/reponse.dart';
import 'package:eat_with_us/screens/special_request.dart';
import 'package:flutter/material.dart';

class PageSlider extends StatefulWidget {
  const PageSlider({super.key});

  @override
  State<PageSlider> createState() => _PageSliderState();
}

class _PageSliderState extends State<PageSlider> {
  final PageController _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: [
          RequestPage(controller: _pageController),
          Respons(controller: _pageController),
        ],
      ),
    );
  }
}
