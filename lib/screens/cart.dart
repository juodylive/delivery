import 'package:eat_with_us/helpers/cart_button.dart';
import 'package:eat_with_us/helpers/cart_controller.dart';
import 'package:eat_with_us/helpers/text_input_decoration.dart';
import 'package:eat_with_us/screens/button_navbar.dart';
import 'package:eat_with_us/screens/check_out.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class CartPage extends StatefulWidget {
  final CartController cartController;

  const CartPage({super.key, required this.cartController});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Order Cart',
          style: GoogleFonts.montserrat(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: Colors.amber[100]),
        ),
        backgroundColor: AppColor.mainColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            color: Colors.white,
            onPressed: () {
              // Remove all items from the cart
              widget.cartController.clearCart();
              Fluttertoast.showToast(msg: 'Cart is now empty');
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const BottomNavBar(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Display the items in the cart
              SizedBox(
                height: MediaQuery.of(context).size.height - 200,
                child: ListView.builder(
                  itemCount: widget.cartController.cartItems.length,
                  itemBuilder: (context, index) {
                    CartItem item = widget.cartController.cartItems[index];
                    return Column(
                      children: [
                        CartItemWidget(
                          item: item,
                          onRemove: () {
                            // Remove the item from the cart when "Remove" is clicked
                            setState(() {
                              widget.cartController.removeFromCart(item);

                              // If the cart is empty, navigate to the BottomNavrpage
                              if (widget.cartController.cartItems.isEmpty) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => const BottomNavBar(),
                                  ),
                                );
                              }
                            });
                          },
                          onIncrease: () {
                            // Increase the quantity of the item in the cart
                            setState(() {
                              widget.cartController.increaseQuantity(item);
                            });
                          },
                          onDecrease: () {
                            // Decrease the quantity of the item in the cart
                            setState(() {
                              widget.cartController.decreaseQuantity(item);

                              // If the cart is empty, navigate to the BottomNavrpage
                              if (widget.cartController.cartItems.isEmpty) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => const BottomNavBar(),
                                  ),
                                );
                              }
                            });
                          },
                        ),
                        const Divider(),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Total Price: \$${widget.cartController.calculateTotalPrice().toStringAsFixed(2)}',
                style: GoogleFonts.montserrat(
                    fontSize: 15, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(
                    bottom: 15, left: 10, right: 10, top: 10),
                child: SizedBox(
                  height: 40,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40)),
                        backgroundColor: AppColor.mainColor),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckoutPage(
                            cartController: widget.cartController,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Check Out',
                      style: GoogleFonts.montserrat(
                          color: Colors.amber[100],
                          fontSize: 20,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CartItemWidget extends StatefulWidget {
  final CartItem item;
  final VoidCallback onRemove;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const CartItemWidget({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  State<CartItemWidget> createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<CartItemWidget> {
  TextEditingController quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    quantityController.text = widget.item.quantity.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.item.name,
              style: GoogleFonts.montserrat(
                  fontSize: 17, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 6),
            Image.network(
              widget.item.imagePath,
              fit: BoxFit.cover,
              height: 50,
              width: 100,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${widget.item.price.toStringAsFixed(2)}',
                  style: GoogleFonts.montserrat(
                      fontSize: 13, fontWeight: FontWeight.w500),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: widget.onDecrease,
                    ),
                    InkWell(
                      onTap: () {
                        // Make the quantity clickable
                        _showQuantityDialog();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          widget.item.quantity.toString(),
                          style: GoogleFonts.montaga(fontSize: 10),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: widget.onIncrease,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Subtotal: \$${(widget.item.price * widget.item.quantity).toStringAsFixed(2)}',
              style: GoogleFonts.montserrat(
                  fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(
              height: 6,
            ),
            Center(
              child: SizedBox(
                height: 40,
                width: 120,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40)),
                      backgroundColor: AppColor.mainColor),
                  onPressed: widget.onRemove,
                  child: Text(
                    'Remove',
                    style: GoogleFonts.montserrat(
                        color: Colors.amber[100],
                        fontSize: 15,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _showQuantityDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Set Quantity',
            style: GoogleFonts.montserrat(
                fontSize: 17, fontWeight: FontWeight.w500),
          ),
          content: TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Quantity',
              labelStyle: GoogleFonts.montserrat(
                  fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          actions: [
            CartButtonPage(
              onPressed: () {
                Navigator.of(context).pop();
              },
              text: ('Cancel'),
            ),
            CartButtonPage(
              onPressed: () {
                int newQuantity = int.tryParse(quantityController.text) ?? 1;
                if (newQuantity > 0) {
                  setState(() {
                    widget.item.quantity = newQuantity;
                  });
                  Navigator.of(context).pop();
                } else {
                  // Show an error message or handle the case of invalid input
                }
              },
              text: ('OK'),
            ),
          ],
        );
      },
    );
  }
}
