import 'package:eat_with_us/helpers/cart_controller.dart';
import 'package:eat_with_us/helpers/text_input_decoration.dart';
import 'package:eat_with_us/screens/cart.dart';
import 'package:eat_with_us/screens/details.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key, required this.cartController});

  final CartController cartController;

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final CollectionReference meals =
      FirebaseFirestore.instance.collection('meals');

  List<MenuItem> allMenuItems = [];
  List<MenuItem> filteredMenuItems = [];

  String selectedCategory = 'All';
  String searchString = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Menu',
          style: GoogleFonts.montserrat(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: Colors.amber[100],
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: AppColor.mainColor,
        actions: [
          if (widget.cartController.cartItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
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
                  ),
                  Positioned(
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.amber,
                      radius: 10,
                      child: Text(
                        widget.cartController.cartItems.length.toString(),
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          Container(color: Colors.black.withOpacity(0.1)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                _buildSearchBar(),
                _buildSortBar(),
                Expanded(
                  child: _buildMenuList(),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchString = value.toLowerCase();
            _filterMenuItems();
          });
        },
        decoration: InputDecoration(
          hintText: 'Search for food...',
          hintStyle: GoogleFonts.montserrat(),
          prefixIcon: const Icon(Icons.search),
        ),
      ),
    );
  }

  Widget _buildSortBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSortButton('All'),
          _buildSortButton('Breakfast'),
          _buildSortButton('Lunch'),
          _buildSortButton('Dinner'),
          _buildSortButton('Dessert'),
        ],
      ),
    );
  }

  Widget _buildSortButton(String category) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedCategory = category;
            _filterMenuItems();
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigoAccent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
        ),
        child: Text(
          category,
          style: GoogleFonts.montserrat(
            color: Colors.amber[100],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuList() {
    return FutureBuilder(
      future: meals.get(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(
            color: AppColor.mainColor,
          ));
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData ||
            snapshot.data == null ||
            snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No data available',
              style: GoogleFonts.montserrat(fontSize: 20),
            ),
          );
        }

        final mealData =
            snapshot.data!.docs.map((doc) => MenuItem.fromDocument(doc));
        allMenuItems = [...mealData];
        _filterMenuItems();

        return ListView.builder(
          itemCount: filteredMenuItems.length,
          itemBuilder: (context, index) {
            return MenuItemTile(
              menuItem: filteredMenuItems[index],
              cartController: widget.cartController,
              onUpdate: () {
                // Trigger a rebuild to update the cart count
                setState(() {});
              },
            );
          },
        );
      },
    );
  }

  void _filterMenuItems() {
    filteredMenuItems = allMenuItems
        .where((menuItem) =>
            (selectedCategory == 'All' ||
                menuItem.category.toLowerCase() ==
                    selectedCategory.toLowerCase()) &&
            (searchString.isEmpty ||
                menuItem.name.toLowerCase().contains(searchString) ||
                menuItem.description.toLowerCase().contains(searchString)))
        .toList();

    // Sort the filteredMenuItems alphabetically
    filteredMenuItems.sort((a, b) => a.name.compareTo(b.name));
  }
}

class MenuItem {
  final String id;
  final String name;
  final double price;
  final String imagePath;
  final String description;
  final String category;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imagePath,
    required this.description,
    required this.category,
  });

  factory MenuItem.fromDocument(QueryDocumentSnapshot document) {
    return MenuItem(
      id: document.id,
      name: document['name'] as String,
      price: (document['price'] as num).toDouble(),
      imagePath: document['image'] as String,
      description: document['description'] as String,
      category: document['category'] as String,
    );
  }
}

class MenuItemTile extends StatefulWidget {
  final MenuItem menuItem;
  final CartController cartController;
  final VoidCallback onUpdate;

  const MenuItemTile({
    super.key,
    required this.menuItem,
    required this.cartController,
    required this.onUpdate,
  });

  @override
  State<MenuItemTile> createState() => _MenuItemTileState();
}

class _MenuItemTileState extends State<MenuItemTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.menuItem.name),
      subtitle: Text('\$${widget.menuItem.price.toStringAsFixed(2)}'),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(widget.menuItem.imagePath),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.add),
        onPressed: () {
          widget.cartController.addToCart(
            widget.menuItem.name,
            widget.menuItem.price,
            widget.menuItem.imagePath,
          );
          Fluttertoast.showToast(
            msg: 'Item added to cart!',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          // Trigger a rebuild to update the cart count
          widget.onUpdate();
        },
      ),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsPage(
              imagePath: widget.menuItem.imagePath,
              name: widget.menuItem.name,
              price: widget.menuItem.price,
              description: widget.menuItem.description,
              cartController: widget.cartController,
              ratings: const [],
              onUpdate: widget.onUpdate,
            ),
          ),
        );
      },
    );
  }
}
