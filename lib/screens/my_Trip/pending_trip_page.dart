// screens/my_Trip/pending_trip_page.dart
// ignore_for_file: duplicate_import, duplicate_ignore

import 'package:cab_booking_user_mobile_app/widgets/my_Trip/driver_card_widget.dart';
import 'package:cab_booking_user_mobile_app/widgets/my_Trip/trip_details_section.dart';
import 'package:cab_booking_user_mobile_app/widgets/my_Trip/vehicle_and_bill_details_widget.dart';
import 'package:flutter/material.dart';
// ignore: duplicate_ignore
// ignore: duplicate_import
import '../../widgets/my_Trip/trip_details_section.dart';
import '../../widgets/my_Trip/driver_card_widget.dart';
// ignore: duplicate_import
import '../../widgets/my_Trip/vehicle_and_bill_details_widget.dart';

class PendingTripPage extends StatelessWidget {
  final String status;
  final String dateTime;
  final int passengerCount;
  final String pickupLocation;
  final String dropLocation;

  const PendingTripPage({
    super.key,
    this.status = 'Pending',
    required this.dateTime,
    required this.passengerCount,
    required this.pickupLocation,
    required this.dropLocation, required Map<String, dynamic> tripData, required bookingId, required String fareAmount, required String vehicleType, required String paymentmethod, required String paymentMethod, required String driverId, required String driverRating, required String driverName, required String rating,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Trip Details - Pending')),
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
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                "Cancel Ride",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
