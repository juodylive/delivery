import 'package:eat_with_us/screens/order.dart';
import 'package:eat_with_us/screens/special_order.dart';
import 'package:flutter/material.dart';

class PageSlide extends StatefulWidget {
  const PageSlide({super.key});

  @override
  State<PageSlide> createState() => _PageSlideState();
}

class _PageSlideState extends State<PageSlide> {
  final PageController _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: [
          OrderPage(controller: _pageController),
          SpecialOrderPage(
            controller: _pageController,
          ),
        ],
      ),
    );
  }
}
