// screens/my_Trip/book_hourly_rental_screen.dart
// // ignore_for_file: unused_element

// import 'package:cab_booking_user_mobile_app/models/booking_id.dart';
// import 'package:cab_booking_user_mobile_app/models/payment_method_model.dart'
//     show PaymentMethod;
// import 'package:cab_booking_user_mobile_app/models/ride_option_model.dart';
// import 'package:cab_booking_user_mobile_app/models/service_types.dart';
// import 'package:cab_booking_user_mobile_app/screens/booking_confirmed.dart';
// import 'package:cab_booking_user_mobile_app/screens/my_Trip/payment_screen.dart';
// import 'package:cab_booking_user_mobile_app/widgets/my_Trip/fare_details_card.dart';
// import 'package:cab_booking_user_mobile_app/widgets/my_Trip/proceed_button.dart';
// import 'package:cab_booking_user_mobile_app/widgets/my_Trip/schedule_section.dart';
// import 'package:cab_booking_user_mobile_app/widgets/my_Trip/vehicle_type_card.dart';
// import 'package:cab_booking_user_mobile_app/widgets/payment_method_section.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../widgets/my_Trip/payment_method_section.dart'
//     hide PaymentMethodSection;
// import 'booking_confirmed_page.dart' hide BookingConfirmedPage, BookingDetails;

// // Define custom colors for consistency with the design
// // ignore: duplicate_ignore
// // ignore: unused_element
// const Color _primaryGreen = Color(0xFF34A853);
// const Color _lightGreyBackground = Color(0xFFF5F5F5);
// const Color _darkGreyText = Color(0xFF424242);
// const Color _cardBorderColor = Color(0xFFE0E0E0);
// const Color _advancePaymentBoxColor = Color(0xFFEEEEEE);

// class BookHourlyRentalScreen extends StatefulWidget {
//   const BookHourlyRentalScreen({super.key});

//   @override
//   State<BookHourlyRentalScreen> createState() => _BookHourlyRentalScreenState();
// }

// class _BookHourlyRentalScreenState extends State<BookHourlyRentalScreen> {
//   bool _isNowSelected = true;
//   DateTime _selectedDate = DateTime.now();
//   TimeOfDay _selectedTime = TimeOfDay.now();
//   late PaymentMethod _selectedPaymentMethod;

//   final double baseFare = 200.00;
//   final int distanceKm = 10;
//   final double perKmRate = 8.00;

//   @override
//   void initState() {
//     super.initState();
//     _selectedPaymentMethod = PaymentMethod.allPaymentMethods.firstWhere(
//       (method) => method.id == 'upi',
//       orElse: () => PaymentMethod.allPaymentMethods.first,
//     );
//   }

//   void _onPaymentMethodChanged(PaymentMethod newMethod) {
//     setState(() => _selectedPaymentMethod = newMethod);
//   }

//   Future<PostgrestMap> _storeHourlyRentalToSupabase({
//     required String name,
//     required String vehicleType,
//     required int durationHours,
//     required int includedKilometers,
//     required double basePrice,
//     required double extraKmRate,
//     required double extraHourRate,
//     required double cancellationFee,
//     required double noShowFee,
//     required int waitingLimitMinutes,
//     required bool isActive,
//   }) async {
//     final supabase = Supabase.instance.client;
//     final now = DateTime.now().toUtc();

//     final data = {
//       'name': name,
//       'vehicle_type': vehicleType,
//       'duration_hours': durationHours,
//       'included_kilometers': includedKilometers,
//       'base_price': basePrice,
//       'extra_km_rate': extraKmRate,
//       'extra_hour_rate': extraHourRate,
//       'cancellation_fee': cancellationFee,
//       'no_show_fee': noShowFee,
//       'waiting_limit_minutes': waitingLimitMinutes,
//       'is_active': isActive,
//       'created_at': now.toIso8601String(),
//       'updated_at': now.toIso8601String(),
//     };

//     final response = await supabase
//         .from('rental_packages')
//         .insert(data)
//         .select()
//         .single();
//     return response;
//   }

//   // Example usage: call this function when booking is confirmed
//   void _onBookNowHourlyRental() async {
//     // Replace these with actual values from your UI/logic
//     final String name = "4 Hour Sedan Rental";
//     final String vehicleType = "sedan";
//     final int durationHours = 4;
//     final int includedKilometers = 40;
//     final double basePrice = 800.0;
//     final double extraKmRate = 10.0;
//     final double extraHourRate = 100.0;
//     final double cancellationFee = 50.0;
//     final double noShowFee = 100.0;
//     final int waitingLimitMinutes = 15;
//     final bool isActive = true;

//     await _storeHourlyRentalToSupabase(
//       name: name,
//       vehicleType: vehicleType,
//       durationHours: durationHours,
//       includedKilometers: includedKilometers,
//       basePrice: basePrice,
//       extraKmRate: extraKmRate,
//       extraHourRate: extraHourRate,
//       cancellationFee: cancellationFee,
//       noShowFee: noShowFee,
//       waitingLimitMinutes: waitingLimitMinutes,
//       isActive: isActive,
//     );
//     // ...proceed with navigation or UI update...
//   }

//   @override
//   Widget build(BuildContext context) {
//     final double distanceCharge = perKmRate * distanceKm;
//     final double totalFare = baseFare + distanceCharge;
//     final double advancePayment = totalFare * 0.25;

//     return Scaffold(
//       backgroundColor: _lightGreyBackground,
//       appBar: AppBar(
//         leading: Builder(
//           builder: (context) => IconButton(
//             icon: const Icon(Icons.menu),
//             onPressed: () => Scaffold.of(context).openDrawer(),
//           ),
//         ),
//         title: const Text('Book Hourly Rental'),
//       ),
//       drawer: const Drawer(),
//       body: Stack(
//         children: <Widget>[
//           SingleChildScrollView(
//             padding: EdgeInsets.only(
//               bottom: MediaQuery.of(context).padding.bottom + 200,
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 VehicleTypeCard(
//                   vehicleType: VehicleType.sedan,
//                   perKmRate: 8.00,
//                   seats: 4,
//                   onBookNow: () async {
//                     _onBookNowHourlyRental();
//                     // Redirect to PaymentScreen directly (like other services)
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => PaymentScreen(
//                           totalAmount: totalFare,
//                           bookingId: BookingID.fromString(
//                             'SDM123456',
//                           ), // Replace with real bookingId if available
//                           serviceType: ServiceTypes(
//                             id: '4',
//                             name: 'hourly',
//                             displayName: 'Hourly Rentals',
//                           ),
//                           pickupLocation:
//                               'Pickup Location', // Replace with actual
//                           dropLocation: 'Drop Location', // Replace with actual
//                           selectedDate: _selectedDate,
//                           selectedTime: _selectedTime,
//                           passengerCount: 1, // Replace with actual
//                           vehicleModel: 'Sedan', // Replace with actual
//                           vehicleTypeDisplay: VehicleType.sedan.displayName,
//                           vehicleServiceType: 'hourly',
//                           returnDate: null,
//                           returnTime: null,
//                         ),
//                       ),
//                     );
//                   },
//                   isLoading: false,
//                   vehicleOption: VehicleType.sedan,
//                 ),
//                 const SizedBox(height: 24),
//                 ScheduleSection(
//                   isNowSelected: _isNowSelected,
//                   selectedDate: _selectedDate,
//                   selectedTime: _selectedTime,
//                   onSelectNow: () => setState(() {
//                     _isNowSelected = true;
//                     _selectedDate = DateTime.now();
//                     _selectedTime = TimeOfDay.now();
//                   }),
//                   onSelectLater: () => setState(() => _isNowSelected = false),
//                   onDateSelected: (newDate) =>
//                       setState(() => _selectedDate = newDate),
//                   onTimeSelected: (newTime) =>
//                       setState(() => _selectedTime = newTime),
//                 ),
//                 const SizedBox(height: 24),
//                 PaymentMethodSection(
//                   currentMethod: _selectedPaymentMethod,
//                   onPaymentMethodChanged: _onPaymentMethodChanged,
//                   onMethodSelected: (PaymentMethod value) {},
//                 ),
//                 const SizedBox(height: 24),
//                 FareDetailsCard(
//                   baseFare: 143.00,
//                   distanceKm: 10,
//                   perKmRate: 8.00,
//                   distanceCharge: distanceCharge,
//                   totalFare: totalFare,
//                 ),
//               ],
//             ),
//           ),
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: ProceedButton(
//               advancePayment: advancePayment,
//               onPressed: () {
//                 final DateTime finalBookingDateTime = _isNowSelected
//                     ? DateTime.now()
//                     : DateTime(
//                         _selectedDate.year,
//                         _selectedDate.month,
//                         _selectedDate.day,
//                         _selectedTime.hour,
//                         _selectedTime.minute,
//                       );

//                 final BookingDetails confirmedBookingDetails = BookingDetails(
//                   bookingId: 'SDM123456',
//                   serviceType: '',
//                   dateTime: DateFormat(
//                     'MMM dd, yyyy • h:mm a',
//                   ).format(finalBookingDateTime),
//                   paymentStatus: 'Advance Paid',
//                   totalAmount: totalFare,
//                 );

//                 Navigator.push(
//                   context,
//                   MaterialPageRoute<void>(
//                     builder: (context) => BookingConfirmedPage(
//                       bookingDetails: confirmedBookingDetails,
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
