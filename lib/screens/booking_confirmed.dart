// screens/booking_confirmed.dart
import 'package:flutter/material.dart';

class BookingDetails {
  final String bookingId;
  final String serviceType;
  final String dateTime;
  final String paymentStatus;
  final double totalAmount;
  final String? paymentMethod;
  final double? advanceAmount;
  final double? remainingAmount;

  const BookingDetails({
    required this.bookingId,
    required this.serviceType,
    required this.dateTime,
    required this.paymentStatus,
    required this.totalAmount,
    this.paymentMethod,
    this.advanceAmount,
    this.remainingAmount,
  });
}

class BookingConfirmedPage extends StatelessWidget {
  final BookingDetails bookingDetails;

  const BookingConfirmedPage({super.key, required this.bookingDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Confirmed'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 80,
              ),
              const SizedBox(height: 24),
              const Text(
                'Your Booking is Confirmed!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Thank you for using our service. your driver will be assigned shortly.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: <Widget>[
                      _buildInfoRow('Booking ID', bookingDetails.bookingId),
                      const Divider(height: 24),
                      _buildInfoRow('Service Type', bookingDetails.serviceType),
                      const Divider(height: 24),
                      _buildInfoRow('Date & Time', bookingDetails.dateTime),
                      const Divider(height: 24),
                      _buildInfoRow(
                        'Payment Status',
                        bookingDetails.paymentStatus,
                        valueColor: Colors.green,
                      ),
                      if (bookingDetails.paymentMethod != null) ...[
                        const Divider(height: 24),
                        _buildInfoRow(
                          'Payment Method',
                          bookingDetails.paymentMethod!,
                        ),
                      ],
                      if (bookingDetails.advanceAmount != null) ...[
                        const Divider(height: 24),
                        _buildInfoRow(
                          'Advance Paid',
                          '₹${bookingDetails.advanceAmount!.toStringAsFixed(2)}',
                        ),
                      ],
                      if (bookingDetails.remainingAmount != null &&
                          bookingDetails.remainingAmount! > 0) ...[
                        const Divider(height: 24),
                        _buildInfoRow(
                          'Remaining Amount',
                          '₹${bookingDetails.remainingAmount!.toStringAsFixed(2)}',
                        ),
                      ],
                      const Divider(height: 24),
                      _buildInfoRow(
                        'Total Amount',
                        '₹${bookingDetails.totalAmount.toStringAsFixed(2)}',
                        valueColor: Colors.green,
                        isBold: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    //
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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

  Widget _buildInfoRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: valueColor ?? Colors.black,
          ),
        ),
      ],
    );
  }
}
