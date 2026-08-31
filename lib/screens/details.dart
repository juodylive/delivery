import 'package:eat_with_us/helpers/buttons.dart';
import 'package:eat_with_us/helpers/cart_button.dart';
import 'package:eat_with_us/helpers/cart_controller.dart';
import 'package:eat_with_us/helpers/text_input_decoration.dart';
import 'package:eat_with_us/screens/cart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailsPage extends StatefulWidget {
  final String imagePath;
  final String name;
  final double price;
  final CartController cartController;
  final String description;
  final List ratings;
  final VoidCallback onUpdate;

  const DetailsPage({
    super.key,
    required this.imagePath,
    required this.name,
    required this.price,
    required this.cartController,
    required this.description,
    required this.ratings,
    required this.onUpdate,
  });

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Order Cart',
            style: GoogleFonts.montserrat(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: Colors.amber[100],
            ),
          ),
          backgroundColor: AppColor.mainColor,
          actions: [
            if (widget.cartController.cartItems.isNotEmpty)
              Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CartPage(
                            cartController: widget.cartController,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.shopping_cart),
                  ),
                  Positioned(
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.amber,
                      radius: 10,
                      child: Text(
                        widget.cartController.cartItems.length.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  )
                ],
              )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.network(
                widget.imagePath,
                fit: BoxFit.cover,
                height: 350,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.name,
                  style: GoogleFonts.montserrat(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  'Price: \$${widget.price.toStringAsFixed(2)}',
                  style: GoogleFonts.montserrat(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ButtonPage(
                onPressed: () async {
                  await _showQuantityDialog(context);
                  // Call onUpdate after updating cart
                  widget.onUpdate();
                  setState(() {});
                },
                child: Text(
                  'Add to Cart',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                    color: Colors.amber[100],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Description',
                  style: GoogleFonts.montserrat(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.description,
                  style: GoogleFonts.montserrat(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showQuantityDialog(BuildContext context) async {
    int quantity = 1;

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return QuantityDialog(
          initialQuantity: quantity,
          onQuantityChanged: (newQuantity) {
            quantity = newQuantity;
          },
          onAddToCart: () {
            widget.cartController.addToCart(
              widget.name,
              widget.price,
              widget.imagePath,
              quantity: quantity,
            );
            widget.onUpdate();
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}

class QuantityDialog extends StatefulWidget {
  final int initialQuantity;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onAddToCart;

  const QuantityDialog({
    super.key,
    required this.initialQuantity,
    required this.onQuantityChanged,
    required this.onAddToCart,
  });

  @override
  State<QuantityDialog> createState() => _QuantityDialogState();
}

class _QuantityDialogState extends State<QuantityDialog> {
  late int quantity;

  @override
  void initState() {
    super.initState();
    quantity = widget.initialQuantity;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Select Quantity',
        style: GoogleFonts.montserrat(
          fontSize: 17,
          fontWeight: FontWeight.w500,
        ),
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(
              'Choose the quantity for this item:',
              style: GoogleFonts.montserrat(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () {
                    if (quantity > 1) {
                      setState(() {
                        quantity--;
                        widget.onQuantityChanged(quantity);
                      });
                    }
                  },
                ),
                Text('$quantity'),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      quantity++;
                      widget.onQuantityChanged(quantity);
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: <Widget>[
        CartButtonPage(
          text: ('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        CartButtonPage(
          text: ('Add to Cart'),
          onPressed: widget.onAddToCart,
        ),
      ],
    );
  }
}
