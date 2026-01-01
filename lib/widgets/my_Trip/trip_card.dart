// widgets/my_Trip/trip_card.dart
import 'package:flutter/material.dart';

// Define custom colors for consistency with the design

class TripCard extends StatelessWidget {
  final String status;
  final String date;
  final String time;
  final String pickup;
  final String drop;
  final String? rating;
  final VoidCallback onTap;

  // Add more fields if needed for dynamic data

  const TripCard({
    super.key,
    required this.status,
    required this.date,
    required this.time,
    required this.pickup,
    required this.drop,
    this.rating,
    required this.onTap, required passengerCount,
  });

  static Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(time, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  if (rating != null)
                    Text(
                      rating!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  const Icon(Icons.location_on, color: Colors.red),
                  const SizedBox(width: 10),
                  Expanded(child: Text(pickup)),
                ],
              ),
              Row(
                children: <Widget>[
                  const Icon(Icons.flag, color: Colors.blue),
                  const SizedBox(width: 10),
                  Expanded(child: Text(drop)),
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
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
}
