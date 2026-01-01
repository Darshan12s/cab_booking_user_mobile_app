// screens/my_Trip/completed_trip_page.dart
// ignore_for_file: duplicate_import

import 'package:cab_booking_user_mobile_app/widgets/my_Trip/driver_card_widget.dart';
import 'package:cab_booking_user_mobile_app/widgets/my_Trip/trip_details_section.dart';
import 'package:cab_booking_user_mobile_app/widgets/my_Trip/vehicle_and_bill_details_widget.dart';
import 'package:flutter/material.dart';
import '../../widgets/my_Trip/trip_details_section.dart';
import '../../widgets/my_Trip/driver_card_widget.dart';
import '../../widgets/my_Trip/vehicle_and_bill_details_widget.dart';

// Define custom colors for consistency with the design
// const Color _lightGreyBackground = Color(0xFFF5F5F5);
const Color _primaryGreen = Color(0xFF34A853);

class CompletedTripPage extends StatefulWidget {
  const CompletedTripPage({super.key, required String dateTime, required passengerCount, required pickupLocation, required dropLocation, required Map<String, dynamic> tripData, required bookingId, required String fareAmount, required String paymentmethod, required String vehicleType, required String paymentMethod, required String rating, required String driverName, required String driverRating, required String driverId});

  @override
  State<CompletedTripPage> createState() => _CompletedTripPageState();
}

class _CompletedTripPageState extends State<CompletedTripPage> {
  int _selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitRatingAndComment() {
    if (_selectedRating > 0 || _commentController.text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Submitted Rating: $_selectedRating stars, Comment: "${_commentController.text}"',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      setState(() {
        _selectedRating = 0;
        _commentController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rating or add a comment.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Trip Details - Completed')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            const TripDetailsSection('Completed', status: 'completed', dateTime: '', passengerCount: 0, pickupLocation: '', dropLocation: '',),
            const SizedBox(height: 16),
            const DriverCardWidget(),
            const SizedBox(height: 16),
            const VehicleAndBillDetailsWidget(),
            const Divider(),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Rate your Driver:",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(5, (int index) {
                return InkWell(
                  onTap: () => setState(() => _selectedRating = index + 1),
                  child: Icon(
                    index < _selectedRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: "Please add your Comment",
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              minLines: 1,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitRatingAndComment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  "Submit",
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text("Ride Successfully Completed. You Have Saved xxxxyyyy."),
          ],
        ),
      ),
    );
  }
}
