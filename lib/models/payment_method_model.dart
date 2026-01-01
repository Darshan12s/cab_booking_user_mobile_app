// models/payment_method_model.dart
import 'dart:ui';

import 'package:flutter/material.dart';

class PaymentMethod {
  final String id;
  final String name;
  final String description;
  final String imageAsset;
  final Color iconColor;

  const PaymentMethod({
    required this.id,
    required this.name,
    required this.description,
    required this.imageAsset,
    required this.iconColor,
  });

  static final List<PaymentMethod> availablePaymentMethods = [
    PaymentMethod(
      id: 'upi',
      name: 'UPI',
      description: 'Pay using UPI apps',
      imageAsset: 'assets/images/upi.png',
      iconColor: Colors.black87,
    ),
    PaymentMethod(
      id: 'google_pay',
      name: 'Google Pay',
      description: 'Quick & secure payment',
      imageAsset: 'assets/images/google_pay.png',
      iconColor: Colors.teal,
    ),
    PaymentMethod(
      id: 'phonepe',
      name: 'PhonePe',
      description: 'Digital wallet payment',
      imageAsset: 'assets/images/phonepe.png',
      iconColor: Colors.black87,
    ),
    PaymentMethod(
      id: 'paytm',
      name: 'Paytm',
      description: 'Paytm wallet & UPI',
      imageAsset: 'assets/images/paytm.png',
      iconColor: Colors.orange,
    ),
    PaymentMethod(
      id: 'credit_debit_card',
      name: 'Credit/Debit Card',
      description: 'Visa, Mastercard, Rupay',
      imageAsset: 'assets/images/credit_card.png',
      iconColor: Colors.indigo,
    ),
  ];

  static var allPaymentMethods;
}