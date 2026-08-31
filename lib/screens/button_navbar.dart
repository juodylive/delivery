import 'package:eat_with_us/helpers/cart_controller.dart';
import 'package:eat_with_us/helpers/page_controller.dart';
import 'package:eat_with_us/helpers/page_controller2.dart';
import 'package:eat_with_us/screens/homepage.dart';
import 'package:eat_with_us/screens/menu.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});
  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int currentIndex = 0;
  late final CartController cartController;

  @override
  void initState() {
    super.initState();
    cartController = CartController();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget Function()> pages = [
      () => HomePage(cartController: cartController),
      () => MenuPage(cartController: cartController),
      () => const PageSlider(),
      () => const PageSlide(),
    ];

    return Scaffold(
      body: pages[currentIndex](),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Menu'),
          BottomNavigationBarItem(
              icon: Icon(Icons.request_page), label: 'Special Request'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_business), label: 'Order'),
        ],
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        selectedItemColor: Colors.indigoAccent,
        unselectedItemColor: Colors.indigoAccent[100],
        type: BottomNavigationBarType.shifting,
      ),
    );
  }
}
