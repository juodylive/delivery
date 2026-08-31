import 'package:eat_with_us/services/api_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StripePaymentHandle {
  Map<String, dynamic>? paymentIntent;

  Future<bool> stripeMakePayment(BuildContext context, double amount) async {
    try {
      // Step 1: Initialize payment sheet
      await initPaymentSheet(amount);

      // Step 2: Display Payment sheet
      return await displayPaymentSheet();
    } catch (e) {
      //   print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
      return false;
    }
  }

  Future<void> initPaymentSheet(double amount) async {
    // Initialize payment sheet parameters
    paymentIntent = await createPaymentIntent(amount.toString(), 'USD');

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        billingDetails: const BillingDetails(
          name: 'YOUR NAME',
          email: 'YOUREMAIL@gmail.com',
          phone: 'YOUR NUMBER',
          address: Address(
            city: 'YOUR CITY',
            country: 'YOUR COUNTRY',
            line1: 'YOUR ADDRESS 1',
            line2: 'YOUR ADDRESS 2',
            postalCode: 'YOUR POSTALCODE',
            state: 'YOUR STATE',
          ),
        ),
        paymentIntentClientSecret:
            paymentIntent!['client_secret'], // Gotten from payment intent
        style: ThemeMode.dark,
        merchantDisplayName: 'My Restaurant',
      ),
    );
  }

  Future<bool> displayPaymentSheet() async {
    try {
      // Step 3: Display the payment sheet
      await Stripe.instance.presentPaymentSheet();

      Fluttertoast.showToast(
        backgroundColor: Colors.green,
        timeInSecForIosWeb: 2,
        msg:
            'Payment successfully completed, and order was placed, check the order page to see your order.',
      );
      return true;
    } on Exception catch (e) {
      if (e is StripeException) {
        Fluttertoast.showToast(
            msg: 'Error from Stripe: ${e.error.localizedMessage}');
        //   print(e.error.localizedMessage);
      } else {
        Fluttertoast.showToast(msg: 'Unforeseen error: $e');
      }
      return false;
    }
  }

  // create Payment
  Future<Map<String, dynamic>> createPaymentIntent(
      String amount, String currency) async {
    try {
      // Request body
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
      };

      // Make post request to Stripe
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${ApiKeys.secretKey}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );
      return paymentIntent = json.decode(response.body);
    } catch (err) {
      //   print(err);
      throw Exception(err.toString());
    }
  }

  // calculate Amount
  String calculateAmount(String amount) {
    final calculatedAmount = (double.parse(amount) * 100).toInt();
    return calculatedAmount.toString();
  }
}
