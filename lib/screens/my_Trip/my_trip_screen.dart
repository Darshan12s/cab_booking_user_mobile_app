// screens/my_Trip/my_trip_screen.dart
import 'package:cab_booking_user_mobile_app/services/booking_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/my_Trip/trip_card.dart';
import 'confirmed_trip_page.dart';
import 'pending_trip_page.dart';
import 'cancelled_trip_page.dart';
import 'completed_trip_page.dart';

// Define custom colors for consistency with the design
// ignore: unused_element
const Color _primaryGreen = Color(0xFF34A853);

class MyTripScreen extends StatefulWidget {
  const MyTripScreen({super.key});

  @override
  State<MyTripScreen> createState() => _MyTripScreenState();
}

class _MyTripScreenState extends State<MyTripScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> currentTrips = [];
  List<Map<String, dynamic>> pastTrips = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        setState(() {
          errorMessage = "User not authenticated";
          isLoading = false;
        });
        return;
      }
      final alltrips = await Supabase.instance.client
          .from('bookings')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final now = DateTime.now();
      List<Map<String, dynamic>> current = [];
      List<Map<String, dynamic>> past = [];

      for (var trip in alltrips) {
        try {
          final tripDate = _parseTripDateTime(trip['date'], trip['time']);
          final status = (trip['status'] ?? '').toString().toLowerCase();
          if (status == 'completed' ||
              status == 'canceled' ||
              (tripDate != null && tripDate.isBefore(now))) {
            past.add(trip);
          } else {
            current.add(trip);
          }
        } catch (_) {
          past.add(trip);
        }
      }

      setState(() {
        currentTrips = current;
        pastTrips = past;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load trips";
        isLoading = false;
      });
    }
  }

  DateTime? _parseTripDateTime(String? dateStr, String? timeStr) {
    try {
      if (dateStr == null || timeStr == null) return null;
      final dateParts = dateStr.split('-');
      if (dateParts.length != 3) return null;
      final timeParts = timeStr.split(' ');
      if (timeParts.isEmpty) return null;
      final timeValue = timeParts[0].split(':');
      if (timeValue.length < 2) return null;
      int hour = int.parse(timeValue[0]);
      final minute = int.parse(timeValue[1]);
      if (timeParts.length > 1 &&
          timeParts[1].toUpperCase() == 'PM' &&
          hour < 12) {
        hour += 12;
      } else if (timeParts.length > 1 &&
          timeParts[1].toUpperCase() == 'AM' &&
          hour == 12) {
        hour = 0;
      }
      return DateTime(
        int.parse(dateParts[2]),
        int.parse(dateParts[1]),
        int.parse(dateParts[0]),
        hour,
        minute,
      );
    } catch (_) {
      return null;
    }
  }

  void _navigateToTripDetailPage(Map<String, dynamic> trip) {
    final String scheduledTime = trip['scheduled_time'] ?? '';
    final int passengerCount = trip['passengerCount'] ?? 1;
    final String pickupAddress = trip['pickup_address'] ?? 'pickup';
    final String dropoffAddress = trip['dropoff_address'] ?? 'dropoff';
    final String status = (trip['status'] ?? '').toString();
    final String bookingId = trip['id']?.toString() ?? '';
    final Map<String, dynamic> tripData = trip;
    final String fareAmount = trip['fare_amount']?.toString() ?? '';
    final String paymentMethod = trip['payment_method'] ?? '';
    final String rating = trip['rating']?.toString() ?? '';
    final String driverName = trip['driver_name'] ?? '';
    final String driverRating = trip['driver_rating']?.toString() ?? '';
    final String driverId = trip['driver_id']?.toString() ?? '';
    final String vehicleType = trip['vehicle_type'] ?? '';

    Widget page;
    switch (status) {
      case 'Confirmed':
        page = ConfirmedTripPage(
          dateTime: scheduledTime,
          passengerCount: passengerCount,
          pickupLocation: pickupAddress,
          dropLocation: dropoffAddress,
          bookingId: bookingId,
          tripData: tripData,
          fareAmount: fareAmount,
          paymentmethod: paymentMethod,
          vehicleType: vehicleType,
          paymentMethod: paymentMethod,
          rating: rating,
          driverName: driverName,
          driverRating: driverRating,
          driverId: driverId,
        );
        break;
      case 'Pending':
        page = PendingTripPage(
          dateTime: scheduledTime,
          passengerCount: passengerCount,
          pickupLocation: pickupAddress,
          dropLocation: dropoffAddress,
          bookingId: bookingId,
          fareAmount: fareAmount,
          tripData: {},
          vehicleType: vehicleType,
          paymentmethod: paymentMethod,
          paymentMethod: paymentMethod,
          driverId: driverId,
          driverRating: driverRating,
          driverName: driverName,
          rating: rating,
        );
        break;
      case 'Canceled':
        page = CancelledTripPage(
          dateTime: scheduledTime,
          passengerCount: passengerCount,
          pickupLocation: pickupAddress,
          dropLocation: dropoffAddress,
          bookingId: bookingId,
          tripData: {},
          fareAmount: fareAmount,
          paymentmethod: paymentMethod,
          vehicleType: vehicleType,
          paymentMethod: paymentMethod,
          rating: rating,
          driverName: driverName,
          driverRating: driverRating,
          driverId: driverId,
        );
        break;
      case 'Completed':
        page = CompletedTripPage(
          dateTime: scheduledTime,
          passengerCount: passengerCount,
          pickupLocation: pickupAddress,
          dropLocation: dropoffAddress,
          bookingId: bookingId,
          tripData: {},
          fareAmount: fareAmount,
          paymentmethod: paymentMethod,
          vehicleType: vehicleType,
          paymentMethod: paymentMethod,
          rating: rating,
          driverName: driverName,
          driverRating: driverRating,
          driverId: driverId,
        );
        break;
      default:
        page = ConfirmedTripPage(
          dateTime: scheduledTime,
          passengerCount: passengerCount,
          pickupLocation: pickupAddress,
          dropLocation: dropoffAddress,
          bookingId: bookingId,
          tripData: {},
          fareAmount: '',
          paymentmethod: paymentMethod,
          vehicleType: vehicleType,
          paymentMethod: paymentMethod,
          rating: rating,
          driverName: driverName,
          driverRating: driverRating,
          driverId: driverId,
        );
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
        systemNavigationBarIconBrightness:
            Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('My Trip'),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: TabBar(
            controller: _tabController,
            tabs: const <Tab>[
              Tab(text: 'Current Trips'),
              Tab(text: 'Past Trips'),
            ],
            labelColor: _primaryGreen,
            unselectedLabelColor: Colors.black,
            indicatorColor: _primaryGreen,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
            ? Center(child: Text(errorMessage!))
            : TabBarView(
                controller: _tabController,
                children: <Widget>[
                  _buildTripList(currentTrips, 'No current trips found'),
                  _buildTripList(pastTrips, 'No past trips found'),
                ],
              ),
      ),
    );
  }

  Widget _buildTripList(List<Map<String, dynamic>> trips, String emptyMsg) {
    if (trips.isEmpty) {
      return Center(child: Text(emptyMsg));
    }
    return RefreshIndicator(
      onRefresh: _loadTrips,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final trip = trips[index];
          return TripCard(
            status: trip['status'] ?? 'Unknown',
            date: trip['date'] ?? '',
            time: trip['time'] ?? '',
            pickup: trip['pickup'] ?? '',
            drop: trip['drop'] ?? '',
            rating: trip['rating'] ?? '',
            passengerCount: trip['passengerCount'] ?? 1,
            onTap: () => _navigateToTripDetailPage(trip),
          );
        },
      ),
    );
  }
}