// screens/my_Trip/payment_25_percent_success_page.dart
import 'package:flutter/material.dart';

class Payment25PercentSuccessPage extends StatelessWidget {
  final String orderId;
  final double amount;
  final String bookingId;
  final String serviceType;

  const Payment25PercentSuccessPage({
    Key? key,
    required this.orderId,
    required this.amount,
    required this.bookingId,
    required this.serviceType, required double remainingAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advance Payment Success'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 24),
              Text(
                '25% Advance Paid!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text('Order ID: $orderId'),
              Text('Booking ID: $bookingId'),
              Text('Service: $serviceType'),
              Text('Amount Paid: ₹${amount.toStringAsFixed(2)}'),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
