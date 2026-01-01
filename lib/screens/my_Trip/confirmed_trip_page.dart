// screens/my_Trip/confirmed_trip_page.dart
import 'package:cab_booking_user_mobile_app/screens/my_Trip/booking_confirmed_page.dart' as booking_confirmed;
import 'package:cab_booking_user_mobile_app/screens/my_Trip/track_ride_screen.dart' as booking_confirmed;
import 'package:cab_booking_user_mobile_app/widgets/my_Trip/driver_card_widget.dart';
import 'package:cab_booking_user_mobile_app/widgets/my_Trip/trip_details_section.dart';
import 'package:cab_booking_user_mobile_app/widgets/my_Trip/vehicle_and_bill_details_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'track_ride_screen.dart';
import 'feedback_page.dart';

// Define custom colors for consistency with the design
// ignore: unused_element
const Color _primaryGreen = Color(0xFF34A853);

class ConfirmedTripPage extends StatelessWidget {
  final String status;
  final String dateTime;
  final int passengerCount;
  final String pickupLocation;
  final String dropLocation;
  final Map<String, dynamic> tripData;
  final dynamic bookingId;
  final String fareAmount;
  final String paymentmethod;
  final String vehicleType;
  final String paymentMethod;
  final String rating;
  final String driverName;
  final String driverRating;
  final String driverId;

  const ConfirmedTripPage({
    super.key,
    this.status = 'Confirmed',
    required this.dateTime,
    required this.passengerCount,
    required this.pickupLocation,
    required this.dropLocation,
    required this.tripData,
    required this.bookingId,
    required this.fareAmount,
    required this.paymentmethod,
    required this.vehicleType,
    required this.paymentMethod,
    required this.rating,
    required this.driverName,
    required this.driverRating,
    required this.driverId,
  });

  Future<booking_confirmed.TrackRideDetails> _fetchTrackRideDetailsFromBackend() async {
    // Example: fetch from Supabase or your backend
    // Replace with your actual backend call and mapping logic
    // Here, tripData is assumed to have all required fields
    return booking_confirmed.TrackRideDetails(
      driverName: tripData['driver_name'] ?? '',
      driverRating: double.tryParse(tripData['driver_rating']?.toString() ?? '') ?? 0.0,
      driverRidesCount: int.tryParse(tripData['driver_rides_count']?.toString() ?? '0') ?? 0,
      driverImageUrl: tripData['driver_image_url'] ?? '',
      vehicleMakeModel: tripData['vehicle_make_model'] ?? '',
      vehicleColorType: tripData['vehicle_color_type'] ?? '',
      vehicleNumber: tripData['vehicle_number'] ?? '',
      otp: tripData['otp']?.toString() ?? '',
      totalFare:
          double.tryParse(tripData['fare_amount']?.toString() ?? '') ?? 0,
      paymentStatus: tripData['payment_status'] ?? '',
      showCompleteRideButton:
          tripData['status'] == 'started' ||
          tripData['status'] == 'in_progress',
      pickupLocation: tripData['pickup_address'] ?? pickupLocation,
      dropLocation: tripData['dropoff_address'] ?? dropLocation,
      estimatedArrivalTime: tripData['estimated_arrival_time'] ?? '',
      pickupLatLng: LatLng(
        double.tryParse(tripData['pickup_latitude']?.toString() ?? '0') ?? 0,
        double.tryParse(tripData['pickup_longitude']?.toString() ?? '0') ?? 0,
      ),
      dropLatLng: LatLng(
        double.tryParse(tripData['dropoff_latitude']?.toString() ?? '0') ?? 0,
        double.tryParse(tripData['dropoff_longitude']?.toString() ?? '0') ?? 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Trip Details - Confirmed')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TripDetailsSection(
              'confirmed',
              dateTime: dateTime,
              passengerCount: passengerCount,
              pickupLocation: pickupLocation,
              dropLocation: dropLocation,
              status: '',
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final trackRideDetails =
                      await _fetchTrackRideDetailsFromBackend();
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          TrackRideScreen(trackRideDetails: trackRideDetails),
                    ),
                  );
                },
                icon: const Icon(Icons.location_on),
                label: const Text('Track Your Ride'),
              ),
            ),
            const SizedBox(height: 16),
            DriverCardWidget(driverPhone: tripData['driver_phone']),
            const SizedBox(height: 16),
            VehicleAndBillDetailsWidget(
              vehicleMakeModel: tripData['vehicle_make_model'],
              vehicleNumber: tripData['vehicle_number'],
              vehicleSeats: tripData['vehicle_seats'] != null
                  ? int.tryParse(tripData['vehicle_seats'].toString())
                  : null,
              baseFare: tripData['base_fare'] != null
                  ? double.tryParse(tripData['base_fare'].toString())
                  : null,
              tax: tripData['tax'] != null
                  ? double.tryParse(tripData['tax'].toString())
                  : null,
              tollFee: tripData['toll_fee'] != null
                  ? double.tryParse(tripData['toll_fee'].toString())
                  : null,
              totalBilledAmount: tripData['total_billed_amount'] != null
                  ? double.tryParse(tripData['total_billed_amount'].toString())
                  : null,
              amountPaid: tripData['amount_paid'] != null
                  ? double.tryParse(tripData['amount_paid'].toString())
                  : null,
              balanceToBePaid: tripData['balance_to_be_paid'] != null
                  ? double.tryParse(tripData['balance_to_be_paid'].toString())
                  : null,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const FeedbackPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Report an Issue'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Cancel Ride'),
            ),
          ],
        ),
      ),
    );
  }
}
