// screens/my_Trip/booking_confirmed_page.dart
import 'package:cab_booking_user_mobile_app/screens/booking_confirmed.dart';
import 'package:cab_booking_user_mobile_app/widgets/my_Trip/info_display_row.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'track_ride_screen.dart';

// --- BookingDetails class for all booking data ---
class BookingDetails {
  final String bookingId;
  final String userName;
  final String userContact;
  final String pickupLocation;
  final String dropLocation;
  final LatLng pickupLatLng;
  final LatLng dropLatLng;
  final DateTime scheduledDateTime;
  final String vehicleType;
  final String vehicleModel;
  final String vehicleNumber;
  final String driverName;
  final String driverContact;
  final double driverRating;
  final String driverImageUrl;
  final int driverRidesCount;
  final double fareAmount;
  final double tax;
  final double tollFee;
  final double totalAmount;
  final String paymentMethod;
  final String paymentStatus;
  final String bookingStatus;
  final LatLng? driverCurrentLatLng;
  final String? eta;
  final int passengerCount;
  final String otp;
  BookingDetails({
    required this.bookingId,
    required this.userName,
    required this.userContact,
    required this.pickupLocation,
    required this.dropLocation,
    required this.pickupLatLng,
    required this.dropLatLng,
    required this.scheduledDateTime,
    required this.vehicleType,
    required this.vehicleModel,
    required this.vehicleNumber,
    required this.driverName,
    required this.driverContact,
    required this.driverRating,
    required this.driverImageUrl,
    required this.driverRidesCount,
    required this.fareAmount,
    required this.tax,
    required this.tollFee,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.bookingStatus,
    required this.passengerCount,
    required this.otp,
    this.driverCurrentLatLng,
    this.eta,
  });
  }


// --- Booking Confirmation Page ---
class BookingConfirmedPage extends StatelessWidget {
  final BookingDetails bookingDetails;

  const BookingConfirmedPage({super.key, required this.bookingDetails});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color _primaryGreen = const Color(0xFF34A853);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Booking Confirmed'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF34A853),
                size: 80,
              ),
              const SizedBox(height: 24),
              Text(
                'Your Booking is Confirmed!',
                style: theme.textTheme.titleLarge!.copyWith(
                  color: _primaryGreen,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Thank you for using our service. Here are your booking details:',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: <Widget>[
                      InfoDisplayRow(
                        label: 'Booking ID',
                        value: bookingDetails.bookingId,
                        isValueBold: true,
                      ),
                      const Divider(height: 24, color: Color(0xFFE0E0E0)),
                      InfoDisplayRow(
                        label: 'Status',
                        value: bookingDetails.bookingStatus,
                      ),
                      InfoDisplayRow(
                        label: 'User',
                        value: bookingDetails.userName,
                      ),
                      InfoDisplayRow(
                        label: 'Contact',
                        value: bookingDetails.userContact,
                      ),
                      InfoDisplayRow(
                        label: 'Pickup',
                        value: bookingDetails.pickupLocation,
                      ),
                      InfoDisplayRow(
                        label: 'Drop',
                        value: bookingDetails.dropLocation,
                      ),
                      InfoDisplayRow(
                        label: 'Date & Time',
                        value: "${bookingDetails.scheduledDateTime.toLocal()}"
                            .split('.')
                            .first,
                      ),
                      InfoDisplayRow(
                        label: 'Passengers',
                        value: bookingDetails.passengerCount.toString(),
                      ),
                      const Divider(height: 24, color: Color(0xFFE0E0E0)),
                      InfoDisplayRow(
                        label: 'Vehicle',
                        value:
                            "${bookingDetails.vehicleType} - ${bookingDetails.vehicleModel}",
                      ),
                      InfoDisplayRow(
                        label: 'Vehicle Number',
                        value: bookingDetails.vehicleNumber,
                      ),
                      InfoDisplayRow(
                        label: 'Driver',
                        value: bookingDetails.driverName,
                      ),
                      InfoDisplayRow(
                        label: 'Driver Contact',
                        value: bookingDetails.driverContact,
                      ),
                      InfoDisplayRow(
                        label: 'Driver Rating',
                        value: bookingDetails.driverRating.toStringAsFixed(1),
                      ),
                      const Divider(height: 24, color: Color(0xFFE0E0E0)),
                      InfoDisplayRow(
                        label: 'Fare',
                        value:
                            '₹${bookingDetails.fareAmount.toStringAsFixed(2)}',
                      ),
                      InfoDisplayRow(
                        label: 'Tax',
                        value: '₹${bookingDetails.tax.toStringAsFixed(2)}',
                      ),
                      InfoDisplayRow(
                        label: 'Toll Fee',
                        value: '₹${bookingDetails.tollFee.toStringAsFixed(2)}',
                      ),
                      InfoDisplayRow(
                        label: 'Total Amount',
                        value:
                            '₹${bookingDetails.totalAmount.toStringAsFixed(2)}',
                        isValueBold: true,
                      ),
                      InfoDisplayRow(
                        label: 'Payment Method',
                        value: bookingDetails.paymentMethod,
                      ),
                      InfoDisplayRow(
                        label: 'Payment Status',
                        value: bookingDetails.paymentStatus,
                        valueColor: _primaryGreen,
                        isValueBold: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TrackRideScreen(
                          trackRideDetails: TrackRideDetails(
                            driverName: bookingDetails.driverName,
                            driverRating: bookingDetails.driverRating,
                            driverRidesCount:
                                bookingDetails.driverRidesCount,
                            driverImageUrl: bookingDetails.driverImageUrl,
                            vehicleMakeModel: bookingDetails.vehicleModel,
                            vehicleColorType: bookingDetails.vehicleType,
                            vehicleNumber: bookingDetails.vehicleNumber,
                            otp: bookingDetails.otp,
                            totalFare: bookingDetails.totalAmount,
                            paymentStatus: bookingDetails.paymentStatus,
                            showCompleteRideButton:
                                bookingDetails.bookingStatus == 'in_progress',
                            pickupLocation: bookingDetails.pickupLocation,
                            dropLocation: bookingDetails.dropLocation,
                            estimatedArrivalTime: bookingDetails.eta ?? '',
                            pickupLatLng: bookingDetails.pickupLatLng,
                            dropLatLng: bookingDetails.dropLatLng,
                          ),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGreen,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    'Track your ride',
                    style: theme.textTheme.titleSmall!.copyWith(
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

