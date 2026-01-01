// widgets/my_Trip/vehicle_type_card.dart
import 'package:cab_booking_user_mobile_app/models/ride_option_model.dart';
import 'package:flutter/material.dart';

class VehicleTypeCard extends StatelessWidget {
  final String vehicleType;
  final double perKmRate;
  final int seats;

  const VehicleTypeCard({
    super.key,
    required this.vehicleType,
    required this.perKmRate,
    required this.seats, required Future<void> Function() onBookNow, required bool isLoading, required VehicleType vehicleOption,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: <Widget>[
            const Icon(Icons.directions_car, color: Colors.red, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    vehicleType,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${perKmRate.toStringAsFixed(0)}/km • $seats seats',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_outlined,
              color: Theme.of(context).textTheme.bodyMedium!.color,
            ),
          ],
        ),
      ),
    );
  }
}