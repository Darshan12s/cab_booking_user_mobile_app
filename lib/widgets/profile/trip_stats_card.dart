// widgets/profile/trip_stats_card.dart
import 'package:flutter/material.dart';
import 'stat_column.dart';

class TripStatisticsCard extends StatelessWidget {
  final int totalTrips;
  final double rating;
  final double totalSpent;

  const TripStatisticsCard({
    required this.totalTrips,
    required this.rating,
    required this.totalSpent,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Trip Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                StatColumn(value: '$totalTrips', label: 'Total Trips'),
                StatColumn(value: '$rating', label: 'Rating'),
                StatColumn(
                  value: '\$${totalSpent.toStringAsFixed(0)}',
                  label: 'Total Spent',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}