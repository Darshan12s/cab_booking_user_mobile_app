import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/location_service.dart';

class LiveTrackingMapScreen extends StatefulWidget {
  final String title;
  final String? userId;
  final bool enableLiveTracking;
  final Function(String)? onLocationSelected;

  const LiveTrackingMapScreen({
    super.key,
    this.title = 'Live Tracking',
    this.userId,
    this.enableLiveTracking = true,
    this.onLocationSelected,
  });

  @override
  State<LiveTrackingMapScreen> createState() => _LiveTrackingMapScreenState();
}

class _LiveTrackingMapScreenState extends State<LiveTrackingMapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  String _currentAddress = 'Fetching location...';
  bool _isLoading = true;
  bool _isTracking = false;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<LatLng> _routePoints = [];
  Timer? _trackingTimer;
  StreamSubscription? _locationSubscription;
  StreamSubscription? _supabaseSubscription;

  static const LatLng _defaultLocation = LatLng(12.9716, 77.5946);

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    if (widget.enableLiveTracking && widget.userId != null) {
      _setupRealtimeTracking();
    }
  }

  @override
  void dispose() {
    _stopTracking();
    _mapController?.dispose();
    _trackingTimer?.cancel();
    _locationSubscription?.cancel();
    _supabaseSubscription?.cancel();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    final permission = await Permission.location.request();
    if (permission.isGranted) {
      await _getCurrentLocation();
    } else {
      setState(() {
        _currentAddress = 'Location permission denied';
        _isLoading = false;
      });
      _addMarker(_defaultLocation, 'Default Location');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _currentAddress = 'Location service disabled';
          _isLoading = false;
        });
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      LatLng currentLatLng = LatLng(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      await _getAddressFromLatLng(currentLatLng);
      _addMarker(currentLatLng, 'Current Location');

      setState(() {
        _isLoading = false;
      });

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(currentLatLng, 16.0),
        );
      }

      // Save to Supabase if user is logged in
      if (widget.userId != null) {
        try {
          await LocationService.updateLiveLocation(
            userId: widget.userId!,
            latitude: _currentPosition!.latitude,
            longitude: _currentPosition!.longitude,
          );
        } catch (e) {
          debugPrint('Failed to save location to Supabase: $e');
        }
      }
    } catch (e) {
      setState(() {
        _currentAddress = 'Error getting location: ${e.toString()}';
        _isLoading = false;
      });
      _addMarker(_defaultLocation, 'Default Location');
    }
  }

  Future<void> _getAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _currentAddress =
              '${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.postalCode ?? ''}';
        });
      }
    } catch (e) {
      setState(() {
        _currentAddress = 'Error getting address';
      });
    }
  }

  void _addMarker(LatLng position, String markerId, {String? infoWindow}) {
    setState(() {
      _markers.removeWhere((marker) => marker.markerId.value == markerId);
      _markers.add(
        Marker(
          markerId: MarkerId(markerId),
          position: position,
          infoWindow: InfoWindow(
            title: infoWindow ?? markerId,
            snippet: _currentAddress,
          ),
          icon: markerId == 'Current Location'
              ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)
              : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    });
  }

  void _startTracking() {
    if (_isTracking) return;

    setState(() {
      _isTracking = true;
      _routePoints.clear();
      _polylines.clear();
    });

    _locationSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10, // Update every 10 meters
          ),
        ).listen((Position position) {
          LatLng newPosition = LatLng(position.latitude, position.longitude);

          setState(() {
            _currentPosition = position;
            _routePoints.add(newPosition);

            // Update current location marker
            _addMarker(
              newPosition,
              'Current Location',
              infoWindow: 'Live Location',
            );

            // Create polyline for the route
            _polylines.clear();
            if (_routePoints.length > 1) {
              _polylines.add(
                Polyline(
                  polylineId: const PolylineId('tracking_route'),
                  points: _routePoints,
                  color: const Color(0xFF6FCF97),
                  width: 4,
                  patterns: [PatternItem.dash(20), PatternItem.gap(10)],
                ),
              );
            }
          });

          // Update address
          _getAddressFromLatLng(newPosition);

          // Move camera to follow user
          _mapController?.animateCamera(CameraUpdate.newLatLng(newPosition));

          // Save to Supabase
          if (widget.userId != null) {
            LocationService.updateLiveLocation(
              userId: widget.userId!,
              latitude: position.latitude,
              longitude: position.longitude,
            ).catchError((e) {
              debugPrint('Failed to save live location: $e');
            });
          }
        });
  }

  void _stopTracking() {
    setState(() {
      _isTracking = false;
    });
    _locationSubscription?.cancel();
    _trackingTimer?.cancel();
  }

  void _setupRealtimeTracking() {
    if (widget.userId == null) return;

    _supabaseSubscription = LocationService.trackUserLocation(widget.userId!)
        .listen((data) {
          if (data.isNotEmpty) {
            final locationData = data.first;
            final lat = locationData['latitude'] as double;
            final lng = locationData['longitude'] as double;
            final latLng = LatLng(lat, lng);

            _addMarker(
              latLng,
              'Tracked Location',
              infoWindow: 'Real-time Location',
            );

            if (_mapController != null) {
              _mapController!.animateCamera(CameraUpdate.newLatLng(latLng));
            }
          }
        });
  }

  void _confirmLocation() {
    if (_currentPosition != null) {
      widget.onLocationSelected?.call(_currentAddress);
      Navigator.pop(context, _currentAddress);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: GoogleFonts.poppins(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.my_location,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: _getCurrentLocation,
          ),
          if (widget.enableLiveTracking)
            IconButton(
              icon: Icon(
                _isTracking ? Icons.stop : Icons.play_arrow,
                color: _isTracking
                    ? Colors.red
                    : (isDark ? Colors.white : Colors.black),
              ),
              onPressed: _isTracking ? _stopTracking : _startTracking,
            ),
        ],
      ),
      body: Column(
        children: [
          // Tracking status bar
          if (widget.enableLiveTracking)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: _isTracking ? const Color(0xFF6FCF97) : Colors.grey[200],
              child: Row(
                children: [
                  Icon(
                    _isTracking
                        ? Icons.radio_button_on
                        : Icons.radio_button_off,
                    color: _isTracking ? Colors.white : Colors.grey[600],
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isTracking
                        ? 'Live tracking active'
                        : 'Tap play to start tracking',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _isTracking ? Colors.white : Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  if (_isTracking)
                    Text(
                      '${_routePoints.length} points',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                ],
              ),
            ),

          // Map
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF6FCF97)),
                  )
                : GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _currentPosition != null
                          ? LatLng(
                              _currentPosition!.latitude,
                              _currentPosition!.longitude,
                            )
                          : _defaultLocation,
                      zoom: 16.0,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                    },
                    markers: _markers,
                    polylines: _polylines,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapType: MapType.normal,
                    compassEnabled: true,
                    trafficEnabled: true,
                    buildingsEnabled: true,
                  ),
          ),

          // Bottom section
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _isTracking
                            ? const Color(0xFF6FCF97)
                            : Colors.grey[400],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isTracking ? Icons.location_on : Icons.location_off,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isTracking ? 'Live Location' : 'Current Location',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _currentAddress,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: isDark ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    if (widget.enableLiveTracking)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isTracking
                              ? _stopTracking
                              : _startTracking,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isTracking
                                ? Colors.red
                                : const Color(0xFF6FCF97),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            _isTracking ? 'Stop Tracking' : 'Start Tracking',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    if (widget.enableLiveTracking) const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _confirmLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6FCF97),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          'Confirm Location',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
