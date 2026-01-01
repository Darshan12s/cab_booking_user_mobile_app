// screens/book.dart
// screens/book.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/booking_model.dart';
import '../models/ride_option_model.dart';
import '../services/booking_service.dart';
import '../widgets/apply_coupon.dart';
import '../widgets/bill_details.dart';
import '../widgets/confirmation_message.dart';
import '../widgets/date_time_passengers.dart';
import '../widgets/location_package_display.dart';
import '../widgets/recipient_selection.dart';
import '../widgets/ride_option_card.dart';
import '../widgets/special_request_tile.dart';
import '../widgets/summary_ride_details.dart';
import 'app_theme.dart';
import 'my_trip/payment_screen.dart';
import '../models/booking_id.dart';
import '../../models/service_types.dart';

class RideSelectionPage extends StatefulWidget {
  final String bookingType;
  final String packageSelected;
  final String pickupLocation;
  final String? dropoffLocation;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final int passengerCount;
  final DateTime? returnDate;
  final TimeOfDay? returnTime;

  const RideSelectionPage({
    super.key,
    required this.bookingType,
    required this.packageSelected,
    required this.pickupLocation,
    this.dropoffLocation,
    required this.selectedDate,
    required this.selectedTime,
    required this.passengerCount,
    this.returnDate,
    this.returnTime,
  });

  @override
  State<RideSelectionPage> createState() => _RideSelectionPageState();
}

class _RideSelectionPageState extends State<RideSelectionPage> {
  String selectedRecipient = 'For me';
  final BookingService _bookingService = BookingService(
    Supabase.instance.client,
  );

  final List<VehicleType> _vehicleTypes = <VehicleType>[
    VehicleType(
      modelName: 'Tiago EV',
      bodyType: 'Hatchback',
      timeInfo: 'After 2 Hrs',
      extraInfo: 'Extra ₹20/Hr',
      price: '₹143',
      imageUrl:
          'https://stimg.cardekho.com/images/carexteriorimages/930x620/Tata/Tiago-EV/6279/1738145892793/front-left-side-47.jpg',
      perKmRate: 10.0,
      perMinuteRate: 2,
      capacity: '4',
      displayName: 'hatchback',
      basefare: '100.0',
    ),
    VehicleType(
      modelName: 'Tiago EV',
      bodyType: 'sedan',
      timeInfo: 'After 2 Hrs',
      extraInfo: 'Extra ₹20/Hr',
      price: '₹143',
      imageUrl:
          'https://stimg.cardekho.com/images/carexteriorimages/930x620/Tata/Tiago-EV/6279/1738145892793/front-left-side-47.jpg',
      perKmRate: 10.0,
      perMinuteRate: 2,
      capacity: '6',
      displayName: 'sedan',
      basefare: '100.0',
    ),
    VehicleType(
      modelName: 'Tiago EV',
      bodyType: 'suv',
      timeInfo: 'After 2 Hrs',
      extraInfo: 'Extra ₹20/Hr',
      price: '₹143',
      imageUrl:
          'https://stimg.cardekho.com/images/carexteriorimages/930x620/Tata/Tiago-EV/6279/1738145892793/front-left-side-47.jpg',
      perKmRate: 10.0,
      perMinuteRate: 2,
      capacity: '4',
      displayName: 'suv',
      basefare: '100.0',
    ),
    VehicleType(
      modelName: 'Tiago EV',
      bodyType: 'premium',
      timeInfo: 'After 2 Hrs',
      extraInfo: 'Extra ₹20/Hr',
      price: '₹143',
      imageUrl:
          'https://stimg.cardekho.com/images/carexteriorimages/930x620/Tata/Tiago-EV/6279/1738145892793/front-left-side-47.jpg',
      perKmRate: 10.0,
      perMinuteRate: 2,
      capacity: '',
      displayName: 'premium',
      basefare: '100.0',
    ),
  ];

  Future<PostgrestMap> _confirmBooking(VehicleType vehicleType) async {
    try {
      final startTime = DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        widget.selectedDate.day,
        widget.selectedTime.hour,
        widget.selectedTime.minute,
      );

      // Map bodyType to backend enum values
      String vehicleTypeEnum;
      switch (vehicleType.bodyType.toLowerCase()) {
        case 'hatchback':
          vehicleTypeEnum = 'city';
          break;
        case 'sedan':
          vehicleTypeEnum = 'sedan';
          break;
        case 'suv':
          vehicleTypeEnum = 'suv';
          break;
        case 'premium':
          vehicleTypeEnum = 'premium';
          break;
        default:
          vehicleTypeEnum = 'city';
      }

      // Calculate fare amount
      final baseFare = double.parse(
        vehicleType.price.replaceAll('₹', '').trim(),
      );
      final advanceAmount = baseFare * 0.25;
      final remainingAmount = baseFare * 0.75;

      // Determine if it's a round trip
      final isRoundTrip =
          widget.returnDate != null && widget.returnTime != null;

      // Calculate return scheduled time for round trips
      DateTime? returnScheduledTime;
      if (isRoundTrip) {
        returnScheduledTime = DateTime(
          widget.returnDate!.year,
          widget.returnDate!.month,
          widget.returnDate!.day,
          widget.returnTime!.hour,
          widget.returnTime!.minute,
        );
      }

      // Determine trip type based on booking type and package
      String tripType = 'one_way';
      if (isRoundTrip) {
        tripType = 'round_trip';
      } else if (widget.bookingType == 'hourly') {
        tripType = 'hourly';
      } else if (widget.bookingType == 'outstation') {
        tripType = 'outstation';
      }

      // Calculate package hours for hourly rentals
      int? packageHours;
      if (widget.bookingType == 'hourly') {
        final packageMatch = RegExp(
          r'(\d+)',
        ).firstMatch(widget.packageSelected);
        packageHours = packageMatch != null
            ? int.parse(packageMatch.group(1)!)
            : 4;
      }

      // --- Store hourly rental data in rental_packages table if hourly ---
      if (widget.bookingType == 'hourly') {
        final supabase = Supabase.instance.client;
        final now = DateTime.now().toUtc();
        final rentalData = {
          'name': '${packageHours ?? 4} Hour ${vehicleType.bodyType} Rental',
          'vehicle_type': vehicleType.bodyType,
          'duration_hours': packageHours ?? 4,
          'included_kilometers': 40, // Set as per your business logic
          'base_price': baseFare,
          'extra_km_rate': vehicleType.perKmRate,
          'extra_hour_rate': 100.0, // Set as per your business logic
          'cancellation_fee': 50.0, // Set as per your business logic
          'no_show_fee': 100.0, // Set as per your business logic
          'waiting_limit_minutes': 15, // Set as per your business logic
          'is_active': true,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        };
        final response = await supabase
            .from('rental_packages')
            .insert(rentalData)
            .select()
            .single();
        return response;
      }

      final booking = Booking(
        userId: Supabase.instance.client.auth.currentUser?.id ?? '',
        pickupAddress: widget.pickupLocation,
        dropoffAddress: widget.dropoffLocation ?? '',
        startTime: startTime,
        status: 'pending',
        rideType: 'single',
        paymentStatus: 'pending',
        paymentMethod: 'upi',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isScheduled: widget.bookingType == 'scheduled',
        isShared: widget.bookingType == 'shared',
        scheduledTime: DateTime(
          widget.selectedDate.year,
          widget.selectedDate.month,
          widget.selectedDate.day,
          widget.selectedTime.hour,
          widget.selectedTime.minute,
        ),
        tripType: tripType,
        vehicleType: vehicleTypeEnum,
        fareAmount: baseFare,
        advanceAmount: advanceAmount,
        remainingAmount: remainingAmount,
        isRoundTrip: isRoundTrip,
        returnScheduledTime: returnScheduledTime,
        packageHours: packageHours,
        totalStops: 0, // Will be updated when stops are added
        includedKm: null, // Will be calculated based on package
        extraKmUsed: 0.0,
        extraHoursUsed: 0.0,
        waitingTimeMinutes: 0,
        upgradeCharges: 0.0,
        specialInstructions: '', // Will be populated from special requests
      );

      final createdBooking = await _bookingService.createBooking(booking);
      if (createdBooking != null && mounted) {
        // Map bookingType to ServiceTypes (adjust mapping as needed)
        ServiceTypes mappedServiceType;
        switch (widget.bookingType.toLowerCase()) {
          case 'city':
            mappedServiceType = ServiceTypes(
              id: '1',
              name: 'city',
              displayName: 'City Ride',
            );
            break;
          case 'airport':
            mappedServiceType = ServiceTypes(
              id: '2',
              name: 'airport',
              displayName: 'Airport',
            );
            break;
          case 'outstation':
            mappedServiceType = ServiceTypes(
              id: '3',
              name: 'outstation',
              displayName: 'Outstation',
            );
            break;
          case 'hourly':
            mappedServiceType = ServiceTypes(
              id: '4',
              name: 'hourly',
              displayName: 'Hourly Rentals',
            );
            break;
          default:
            mappedServiceType = ServiceTypes(id: '', name: '', displayName: '');
        }
        // --- Change: Go directly to PaymentScreen instead of RideSummaryPage ---
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(
              totalAmount: baseFare,
              bookingId: BookingID.fromString(createdBooking.id!),
              serviceType: mappedServiceType,
              pickupLocation: widget.pickupLocation,
              dropLocation: widget.dropoffLocation ?? 'Enter Drop-off location',
              selectedDate: widget.selectedDate,
              selectedTime: widget.selectedTime,
              passengerCount: widget.passengerCount,
              vehicleModel: vehicleType.modelName,
              vehicleTypeDisplay: vehicleType.bodyType,
              vehicleServiceType: widget.bookingType,
              returnDate: widget.returnDate,
              returnTime: widget.returnTime,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating booking: $e')));
      }
      debugPrint('Error creating booking: $e');
      throw Exception('Error creating booking: $e');
    }
    throw Exception('Booking could not be completed.');
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: AppTheme.isDarkMode(context)
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarColor: AppTheme.getBackgroundColor(context),
        systemNavigationBarIconBrightness: AppTheme.isDarkMode(context)
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.getBackgroundColor(context),
        appBar: AppBar(
          backgroundColor: AppTheme.getBackgroundColor(context),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppTheme.getTextColor(context)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Pick a Ride',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.getTextColor(context),
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LocationPackageDisplayWidget(
                  pickupLocation: widget.pickupLocation,
                  dropoffLocation: widget.dropoffLocation ?? 'Enter Drop-off',
                  packageSelected: widget.packageSelected,
                  bookingType: widget.bookingType,
                ),
                const SizedBox(height: 24),
                ..._vehicleTypes.map(
                  (vehicleType) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: VehicleTypeCard(
                      vehicleType: vehicleType,
                      onBookNow: () => _confirmBooking(vehicleType),
                      isLoading: false,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
