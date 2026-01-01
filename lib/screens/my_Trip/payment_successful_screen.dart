// screens/my_Trip/payment_successful_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'completed_trip_page.dart';

// Define custom colors for consistency with the design
const Color _primaryGreen = Color(0xFF34A853);
const Color _lightGreyBackground = Color(0xFFF5F5F5);

class PaymentSuccessfulScreen extends StatefulWidget {
  const PaymentSuccessfulScreen({super.key});

  @override
  State<PaymentSuccessfulScreen> createState() =>
      _PaymentSuccessfulScreenState();
}

class _PaymentSuccessfulScreenState extends State<PaymentSuccessfulScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CompletedTripPage(dateTime: '', passengerCount: 0, pickupLocation: '', dropLocation: '', tripData: {}, bookingId: null, fareAmount: '', paymentmethod: '', vehicleType: '', paymentMethod: '', rating: '', driverName: '', driverRating: '', driverId: '',)),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : _lightGreyBackground,
      appBar: AppBar(
        title: Text(
          'Payment',
          style: TextStyle(color: isDark ? Colors.white : null),
        ),
        backgroundColor: isDark ? Colors.black : null,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.check_circle, color: _primaryGreen, size: 100),
            const SizedBox(height: 24),
            Text(
              'Payment Successful!',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: _primaryGreen,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Your payment has been processed successfully',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: isDark ? Colors.white : null,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Redirecting to rating screen...',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge!.copyWith(color: _primaryGreen),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
