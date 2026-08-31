import 'package:cached_network_image/cached_network_image.dart';
import 'package:eat_with_us/helpers/cart_button.dart';
import 'package:eat_with_us/helpers/cart_controller.dart';
import 'package:eat_with_us/helpers/text_input_decoration.dart';
import 'package:eat_with_us/screens/details.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FutureCarouselSlider extends StatefulWidget {
  final CollectionReference collectionReference;
  final bool includeNameAndPrice;
  final double viewportFraction;
  final double itemHeight;
  final bool clickable;
  final CartController cartController;
  final VoidCallback onUpdate;

  const FutureCarouselSlider({
    super.key,
    required this.collectionReference,
    this.includeNameAndPrice = false,
    this.viewportFraction = 1.0,
    this.itemHeight = 100.0,
    this.clickable = true,
    required this.cartController,
    required this.onUpdate,
  });

  @override
  State<FutureCarouselSlider> createState() => _FutureCarouselSliderState();
}

class _FutureCarouselSliderState extends State<FutureCarouselSlider> {
  late Future<List<QueryDocumentSnapshot>> backgroundImagesFuture;
  late Future<List<QueryDocumentSnapshot>> mealsFuture;

  @override
  void initState() {
    super.initState();
    backgroundImagesFuture =
        fetchData(FirebaseFirestore.instance.collection('backgroundImage'));
    mealsFuture = fetchData(FirebaseFirestore.instance.collection('meals'));
  }

  Future<List<QueryDocumentSnapshot>> fetchData(
      CollectionReference collectionReference) async {
    final snapshot = await collectionReference.get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs;
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<QueryDocumentSnapshot>>(
      future: widget.collectionReference ==
              FirebaseFirestore.instance.collection('backgroundImage')
          ? backgroundImagesFuture
          : mealsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(
            color: AppColor.mainColor,
          ));
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final shuffledDocs = snapshot.data!.toList()..shuffle();

        final imagePaths = shuffledDocs
            .map<String>((doc) => doc['image'] as String? ?? '')
            .toList();
        final names = widget.includeNameAndPrice
            ? shuffledDocs
                .map<String>((doc) => doc['name'] as String? ?? '')
                .toList()
            : List.filled(shuffledDocs.length, '');
        final prices = widget.includeNameAndPrice
            ? shuffledDocs
                .map<double>((doc) => (doc['price'] as num?)?.toDouble() ?? 0.0)
                .toList()
            : List.filled(shuffledDocs.length, 0.0);

        return CarouselSlider.builder(
          itemCount: imagePaths.length,
          itemBuilder: (BuildContext context, int index, int realIndex) {
            final imagePath = imagePaths[index];
            return Builder(
              builder: (BuildContext context) {
                return GestureDetector(
                  onTap: widget.clickable
                      ? () {
                          // Only navigate if clickable
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailsPage(
                                imagePath: imagePath,
                                name: names[index],
                                price: prices[index],
                                ratings: shuffledDocs[index]['ratings']
                                    as List<dynamic>,
                                description: shuffledDocs[index]['description']
                                    as String,
                                cartController: widget.cartController,
                                onUpdate: widget.onUpdate,
                              ),
                            ),
                          );
                        }
                      : null, // Set to null if not clickable
                  child: buildCarouselItem(
                    snapshot,
                    imagePath,
                    names[index],
                    prices[index],
                    index,
                    shuffledDocs,
                  ),
                );
              },
            );
          },
          options: CarouselOptions(
            height: widget.itemHeight,
            aspectRatio: 16 / 9,
            viewportFraction: widget.viewportFraction,
            initialPage: 0,
            enableInfiniteScroll: true,
            reverse: false,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            onPageChanged: (index, reason) {},
            scrollDirection: Axis.horizontal,
          ),
        );
      },
    );
  }

  Widget buildCarouselItem(
    AsyncSnapshot<List<QueryDocumentSnapshot>> snapshot,
    String imagePath,
    String name,
    double price,
    int index,
    List<QueryDocumentSnapshot> shuffledDocs,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (widget.includeNameAndPrice)
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Center(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (widget.collectionReference ==
              FirebaseFirestore.instance.collection('backgroundImage')) ...[
            SizedBox(
              width: double.infinity,
              height: 170,
              child: Stack(
                children: [
                  // Image
                  ClipRRect(
                    child: CachedNetworkImage(
                      imageUrl: imagePath,
                      width: double.infinity,
                      height: 170,
                      fit: BoxFit.fill,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                          color: AppColor.mainColor,
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                  // Overlay
                  Container(
                    color: Colors.black.withOpacity(0.1),
                  ),
                ],
              ),
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              height: 110,
              child: Stack(
                children: [
                  // Image
                  ClipRRect(
                    child: CachedNetworkImage(
                      imageUrl: imagePath,
                      fit: BoxFit.fill,
                      width: double.infinity,
                      height: 110,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                          color: AppColor.mainColor,
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                  // Overlay
                  Container(
                    color: Colors.black.withOpacity(0.1),
                  ),
                ],
              ),
            ),
          ],
          if (widget.includeNameAndPrice)
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Center(
                child: Text(
                  ' \$${price.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 13.0, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          if (widget.includeNameAndPrice)
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: RatingBar.builder(
                initialRating:
                    calculateAverageRating(shuffledDocs[index]['ratings']),
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 18,
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (newRating) {
                  updateRatingInFirebase(snapshot, index, newRating);
                },
              ),
            ),
          if (widget.clickable)
            CartButtonPage(
              onPressed: () {
                widget.cartController.addToCart(name, price, imagePath);
                Fluttertoast.showToast(
                  msg: 'Item added to cart!',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
                widget.onUpdate();
              },
              text: ('Add to Cart'),
            ),
        ],
      ),
    );
  }

  double calculateAverageRating(List<dynamic> ratings) {
    if (ratings.isEmpty) {
      return 0.0;
    }

    double sum = ratings.fold(0.0, (previous, current) => previous + current);
    return sum / ratings.length;
  }

  void updateRatingInFirebase(
      AsyncSnapshot<List<QueryDocumentSnapshot>> snapshot,
      int index,
      double newRating) {
    snapshot.data![index].reference.update({
      'ratings': FieldValue.arrayUnion([newRating]),
    });
  }
}
