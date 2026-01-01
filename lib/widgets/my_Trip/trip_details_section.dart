// widgets/my_Trip/trip_details_section.dart
import 'package:flutter/material.dart';

class TripDetailsSection extends StatelessWidget {
  final String status;
  final String dateTime;
  final int passengerCount;
  final String pickupLocation;
  final String dropLocation;

  const TripDetailsSection(String s, {
    super.key,
    required this.status,
    required this.dateTime,
    required this.passengerCount,
    required this.pickupLocation,
    required this.dropLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          "Trip Scheduled Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(dateTime),
            Row(
              children: <Widget>[
                const Icon(Icons.person),
                Text(passengerCount.toString()),
              ],
            ),
          ],
        ),
        Text(pickupLocation),
        if (dropLocation.isNotEmpty) Text(dropLocation),
      ],
    );
  }
}
