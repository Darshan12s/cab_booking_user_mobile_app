// widgets/my_Trip/fare_details_card.dart
import 'package:flutter/material.dart';
import 'price_row_widget.dart';

// Define custom colors for consistency with the design
const Color _cardBorderColor = Color(0xFFE0E0E0);

class FareDetailsCard extends StatelessWidget {
  final double baseFare;
  final int distanceKm;
  final double perKmRate;
  final double distanceCharge;
  final double totalFare;

  const FareDetailsCard({
    super.key,
    required this.baseFare,
    required this.distanceKm,
    required this.perKmRate,
    required this.distanceCharge,
    required this.totalFare,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: _cardBorderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Fare Details',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            PriceRowWidget(
              'Base Fare',
              '₹${baseFare.toStringAsFixed(2)}',
            ),
            PriceRowWidget(
              'Distance ($distanceKm km)',
              '₹${distanceCharge.toStringAsFixed(2)}',
            ),
            const Divider(),
            PriceRowWidget(
              'Total Fare',
              '₹${totalFare.toStringAsFixed(2)}',
              bold: true,
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}