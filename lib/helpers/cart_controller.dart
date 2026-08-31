import 'package:flutter/material.dart';

class CartController {
  List<CartItem> cartItems = [];
  ValueNotifier<int> cartItemsCount = ValueNotifier<int>(0);

  void addToCart(String name, double price, String imagePath,
      {int quantity = 1}) {
    // Check if the item is already in the cart
    bool itemExists = cartItems.any((item) => item.name == name);
    if (itemExists) {
      // If the item already exists, update the quantity
      CartItem existingItem = cartItems.firstWhere((item) => item.name == name);
      existingItem.quantity += quantity;
    } else {
      // If the item does not exist, add it to the cart
      cartItems.add(
        CartItem(
          name: name,
          price: price,
          imagePath: imagePath,
          quantity: quantity,
          timestamp: DateTime.now(),
        ),
      );
    }
    cartItemsCount.value = cartItems.length;
  }

  void removeFromCart(CartItem item) {
    cartItems.remove(item);
    cartItemsCount.value = cartItems.length;
  }

  void increaseQuantity(CartItem item) {
    item.quantity++;
    cartItemsCount.value = cartItems.length;
  }

  void decreaseQuantity(CartItem item) {
    if (item.quantity > 1) {
      item.quantity--;
      cartItemsCount.value = cartItems.length;
    }
  }

  double calculateTotalPrice() {
    double totalPrice = 0;
    for (var item in cartItems) {
      try {
        // Attempt to parse the price as a double
        double itemPrice = item.price;
        totalPrice += itemPrice * item.quantity;
      } catch (e) {
        //      print('Error parsing price for item ${item.name}: ${item.price}');
      }
    }
    return totalPrice;
  }

  void clearCart() {
    cartItems.clear();
  }
}

class CartItem {
  final String name;
  final double price;
  final String imagePath;
  int quantity;
  final DateTime timestamp;

  CartItem({
    required this.name,
    required this.price,
    required this.imagePath,
    required this.quantity,
    required this.timestamp,
  });
}
