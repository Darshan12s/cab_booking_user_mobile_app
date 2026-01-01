// screens/my_Trip/track_ride_screen.dart
import 'package:cab_booking_user_mobile_app/screens/my_Trip/booking_confirmed_page.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'payment_successful_screen.dart';
import 'package:url_launcher/url_launcher.dart';

// Define custom colors for consistency with the design
const Color _primaryGreen = Color(0xFF34A853);
const Color _lightGreyBackground = Color(0xFFF5F5F5);
const Color _otpBoxColor = Color(0xFFDCEDC8);
const Color _otpTextColor = Color(0xFF33691E);

// Add your Google Maps API Key here
const String googleMapsApiKey = 'AIzaSyAejqe2t4TAptcLnkpoFTTNMhm0SFHFJgQ';

class TrackRideScreen extends StatefulWidget {
  final TrackRideDetails trackRideDetails;

  const TrackRideScreen({super.key, required this.trackRideDetails});

  @override
  State<TrackRideScreen> createState() => _TrackRideScreenState();
}

class _TrackRideScreenState extends State<TrackRideScreen> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  List<LatLng> _routePoints = [];
  bool _isRouteLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRoute();
  }

  Future<void> _fetchRoute() async {
    setState(() => _isRouteLoading = true);

    final pickup = widget.trackRideDetails.pickupLatLng;
    final drop = widget.trackRideDetails.dropLatLng;

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json?'
      'origin=${pickup.latitude},${pickup.longitude}&'
      'destination=${drop.latitude},${drop.longitude}&'
      'key=$googleMapsApiKey',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final points = data['routes'][0]['overview_polyline']['points'];
          _routePoints = _decodePolyline(points);
        }
      }
    } catch (e) {
      debugPrint('Error fetching route: $e');
    } finally {
      setState(() => _isRouteLoading = false);
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_routePoints.isNotEmpty) {
      _mapController.animateCamera(
        CameraUpdate.newLatLngBounds(_boundsFromLatLngList(_routePoints), 50.0),
      );
    }
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
      southwest: LatLng(x0!, y0!),
      northeast: LatLng(x1!, y1!),
    );
  }

  void _callDriver() async {
    final phone = widget.trackRideDetails.driverPhone;
    if (phone != null && phone.isNotEmpty) {
      final uri = Uri(scheme: 'tel', path: phone);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot launch phone dialer')),
        );
      }
    }
  }

  void _messageDriver() async {
    final phone = widget.trackRideDetails.driverPhone;
    if (phone != null && phone.isNotEmpty) {
      final uri = Uri(scheme: 'sms', path: phone);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot launch messaging app')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _markers.clear();
    _markers.addAll({
      Marker(
        markerId: const MarkerId('pickup'),
        position: widget.trackRideDetails.pickupLatLng,
        infoWindow: InfoWindow(
          title: 'Pickup',
          snippet: widget.trackRideDetails.pickupLocation,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
      Marker(
        markerId: const MarkerId('drop'),
        position: widget.trackRideDetails.dropLatLng,
        infoWindow: InfoWindow(
          title: 'Drop',
          snippet: widget.trackRideDetails.dropLocation,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    });

    _polylines.clear();
    if (_routePoints.isNotEmpty) {
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          color: _primaryGreen,
          width: 5,
          points: _routePoints,
        ),
      );
    }

    return Scaffold(
      backgroundColor: _lightGreyBackground,
      appBar: AppBar(title: const Text('Track Ride')),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: widget.trackRideDetails.pickupLatLng,
              zoom: 14.0,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),
          if (_isRouteLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_primaryGreen),
              ),
            ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipOval(
                          child: Image.network(
                            widget.trackRideDetails.driverImageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.person, size: 60),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.trackRideDetails.driverName,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${widget.trackRideDetails.driverRating} • ${widget.trackRideDetails.driverRidesCount}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _callDriver,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _primaryGreen,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.all(8),
                                child: const Icon(
                                  Icons.call,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: _messageDriver,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _primaryGreen,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.all(8),
                                child: const Icon(
                                  Icons.chat_bubble_outline,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.trackRideDetails.vehicleMakeModel,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.trackRideDetails.vehicleColorType,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        Text(
                          widget.trackRideDetails.vehicleNumber,
                          style: Theme.of(context).textTheme.titleSmall!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    if (widget.trackRideDetails.showCompleteRideButton) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 20.0,
                          horizontal: 16.0,
                        ),
                        decoration: BoxDecoration(
                          color: _otpBoxColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          widget.trackRideDetails.otp,
                          style: Theme.of(context).textTheme.titleLarge!
                              .copyWith(
                                color: _otpTextColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                              ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Share this OTP with driver when they arrive',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (widget.trackRideDetails.showCompleteRideButton)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              left: 16,
              right: 16,
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PaymentSuccessfulScreen(),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Complete Ride',
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// --- Add driverPhone to TrackRideDetails model if not present ---
class TrackRideDetails {
  // ...existing fields...
  final String? driverPhone;
  final LatLng pickupLatLng;
  final LatLng dropLatLng;
  final String pickupLocation;
  final String dropLocation;
  final String driverImageUrl;
  final String driverName;
  final double driverRating;
  final int driverRidesCount;
  final String vehicleMakeModel;
  final String vehicleColorType;
  final String vehicleNumber;
  final bool showCompleteRideButton;
  final String otp;

  TrackRideDetails({
    required this.pickupLatLng,
    required this.dropLatLng,
    required this.pickupLocation,
    required this.dropLocation,
    required this.driverImageUrl,
    required this.driverName,
    required this.driverRating,
    required this.driverRidesCount,
    required this.vehicleMakeModel,
    required this.vehicleColorType,
    required this.vehicleNumber,
    required this.showCompleteRideButton,
    required this.otp,
    this.driverPhone, required double totalFare, required String paymentStatus, required String estimatedArrivalTime,
  });
}
