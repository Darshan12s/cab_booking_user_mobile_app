// screens/my_Trip/cancelled_trip_page.dart
// ignore_for_file: duplicate_import

import 'package:cab_booking_user_mobile_app/widgets/my_Trip/driver_card_widget.dart';
import 'package:cab_booking_user_mobile_app/widgets/my_Trip/trip_details_section.dart';
import 'package:cab_booking_user_mobile_app/widgets/my_Trip/vehicle_and_bill_details_widget.dart';
import 'package:flutter/material.dart';
import '../../widgets/my_Trip/trip_details_section.dart';
import '../../widgets/my_Trip/driver_card_widget.dart';
import '../../widgets/my_Trip/vehicle_and_bill_details_widget.dart';

class CancelledTripPage extends StatelessWidget {
  final String status;
  final String dateTime;
  final int passengerCount;
  final String pickupLocation;
  final String dropLocation;

  const CancelledTripPage({
    super.key,
    this.status = 'Cancelled',
    required this.dateTime,
    required this.passengerCount,
    required this.pickupLocation,
    required this.dropLocation, required bookingId, required Map<String, dynamic> tripData, required String fareAmount, required String paymentmethod, required String vehicleType, required String paymentMethod, required String rating, required String driverName, required String driverRating, required String driverId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Trip Details - Cancelled')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            TripDetailsSection(
              status,
              dateTime: dateTime,
              passengerCount: passengerCount,
              pickupLocation: pickupLocation,
              dropLocation: dropLocation, status: '',
            ),
            const SizedBox(height: 16),
            const DriverCardWidget(showContact: false),
            const SizedBox(height: 16),
            const VehicleAndBillDetailsWidget(),
            const SizedBox(height: 10),
            Text(
              "Worry Not! Refund will be processed shortly according to T&C, Our Team is working on it.",
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ),
      ),
    );
  }
}
