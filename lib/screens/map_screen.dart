// screens/map_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class MapScreen extends StatefulWidget {
  final String title;
  final bool isSelectMode;
  final LatLng? initialLocation;

  const MapScreen({
    super.key,
    this.title = 'Choose on Map',
    this.isSelectMode = true,
    this.initialLocation,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  String _currentAddress = 'Fetching location...';
  bool _isLoading = true;
  double _currentZoom = 16.0;
  final TextEditingController _searchController = TextEditingController();
  final Set<Marker> _markers = {};
  LatLng? _selectedLocation;
  Timer? _debounceTimer;
  bool _isNavigating = false;

  static const LatLng _defaultLocation = LatLng(12.9716, 77.5946); // Bangalore

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    final permission = await Permission.location.request();
    if (permission.isGranted) {
      await _getCurrentLocation();
    } else {
      _setDefaultLocation('Location permission denied');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setDefaultLocation('Location service disabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _setDefaultLocation('Location permission denied');
          return;
        }
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _selectedLocation = LatLng(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      await _updateLocation(_selectedLocation!);
    } catch (e) {
      _setDefaultLocation('Error getting location');
    }
  }

  void _setDefaultLocation(String message) {
    if (mounted) {
      setState(() {
        _selectedLocation = widget.initialLocation ?? _defaultLocation;
        _currentAddress = message;
        _isLoading = false;
      });
      _addMarker(_selectedLocation!);
    }
  }

  Future<void> _updateLocation(LatLng latLng) async {
    await _getAddressFromLatLng(latLng);
    _addMarker(latLng);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 16.0));
      setState(() {
        _currentZoom = 16.0;
      });
    }
  }

  Future<void> _getAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (mounted) {
        setState(() {
          _currentAddress = placemarks.isNotEmpty
              ? '${placemarks[0].street ?? ''}, ${placemarks[0].subLocality ?? ''}, '
                    '${placemarks[0].locality ?? ''}, ${placemarks[0].postalCode ?? ''}'
              : '${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)}';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentAddress =
              '${latLng.latitude.toStringAsFixed(4)}, ${latLng.longitude.toStringAsFixed(4)}';
        });
      }
    }
  }

  void _addMarker(LatLng position) {
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
          draggable: widget.isSelectMode,
          onDragEnd: (LatLng newPosition) {
            _selectedLocation = newPosition;
            _getAddressFromLatLng(newPosition);
          },
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    });
  }

  void _onMapTap(LatLng latLng) {
    if (!widget.isSelectMode) return;

    _selectedLocation = latLng;
    _addMarker(latLng);
    _getAddressFromLatLng(latLng);
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (value.isNotEmpty) {
        _searchLocation(value);
      }
    });
  }

  Future<void> _searchLocation(String query) async {
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Location not found. Please try a different search.',
              ),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      LatLng searchedLocation = LatLng(
        locations.first.latitude,
        locations.first.longitude,
      );

      _selectedLocation = searchedLocation;
      await _updateLocation(searchedLocation);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error searching location. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _confirmLocation() async {
    if (_selectedLocation == null || _isNavigating) return;

    setState(() {
      _isNavigating = true;
    });

    try {
      if (mounted) {
        // Return both address and coordinates as a String for text field
        Navigator.of(context).pop(_currentAddress);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isNavigating = false;
        });
      }
    }
  }

  // Zoom In functionality
  Future<void> _zoomIn() async {
    if (_mapController == null) return;

    try {
      final currentZoom = await _mapController!.getZoomLevel();
      if (currentZoom < 20.0) {
        // Max zoom level
        final newZoom = (currentZoom + 1.0).clamp(3.0, 20.0);
        await _mapController!.animateCamera(CameraUpdate.zoomTo(newZoom));
        setState(() {
          _currentZoom = newZoom;
        });

        // Provide haptic feedback for better UX
        _showZoomFeedback('Zoomed In');
      } else {
        _showZoomFeedback('Maximum zoom level reached');
      }
    } catch (e) {
      debugPrint('Error zooming in: $e');
    }
  }

  // Zoom Out functionality
  Future<void> _zoomOut() async {
    if (_mapController == null) return;

    try {
      final currentZoom = await _mapController!.getZoomLevel();
      if (currentZoom > 3.0) {
        // Min zoom level
        final newZoom = (currentZoom - 1.0).clamp(3.0, 20.0);
        await _mapController!.animateCamera(CameraUpdate.zoomTo(newZoom));
        setState(() {
          _currentZoom = newZoom;
        });

        _showZoomFeedback('Zoomed Out');
      } else {
        _showZoomFeedback('Minimum zoom level reached');
      }
    } catch (e) {
      debugPrint('Error zooming out: $e');
    }
  }

  // Show zoom feedback to user
  void _showZoomFeedback(String message) {
    // Only show feedback for zoom limits
    if (message.contains('Maximum') || message.contains('Minimum')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(milliseconds: 1000),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  // Go to current location with zoom
  Future<void> _goToCurrentLocation() async {
    if (_mapController == null) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final latLng = LatLng(position.latitude, position.longitude);

      // Animate to current location with optimal zoom level
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(latLng, 16.0),
      );

      setState(() {
        _currentZoom = 16.0;
      });

      _selectedLocation = latLng;
      await _updateLocation(latLng);
    } catch (e) {
      debugPrint('Error getting current location: $e');
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to get current location'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
          onPressed: () => Navigator.of(context).pop(),
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
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search for location',
                hintStyle: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
            ),
          ),

          // Map with zoom controls
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF6FCF97)),
                  )
                : Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _selectedLocation ?? _defaultLocation,
                          zoom: 16.0,
                        ),
                        onMapCreated: (GoogleMapController controller) {
                          _mapController = controller;
                        },
                        onTap: _onMapTap,
                        onCameraMove: (CameraPosition position) {
                          setState(() {
                            _currentZoom = position.zoom;
                          });
                        },
                        markers: _markers,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        mapType: MapType.normal,
                        compassEnabled: true,
                        trafficEnabled: false,
                        buildingsEnabled: true,
                        // Enhanced zoom gestures
                        zoomGesturesEnabled: true,
                        scrollGesturesEnabled: true,
                        tiltGesturesEnabled: true,
                        rotateGesturesEnabled: true,
                        // Set zoom bounds
                        minMaxZoomPreference: const MinMaxZoomPreference(
                          3.0,
                          20.0,
                        ),
                      ),
                      // Custom zoom controls
                      Positioned(
                        right: 16,
                        top: 20,
                        child: Column(
                          children: [
                            // Zoom In button
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: isDark ? Colors.grey[800] : Colors.white,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    spreadRadius: 2,
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                                border: Border.all(
                                  color: isDark
                                      ? Colors.grey[600]!
                                      : Colors.grey[200]!,
                                  width: 1.5,
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                  onTap: _zoomIn,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      color: const Color(0xFF6FCF97),
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Divider line
                            Container(
                              width: 50,
                              height: 2,
                              color: isDark
                                  ? Colors.grey[600]
                                  : Colors.grey[200],
                            ),
                            // Zoom Out button
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: isDark ? Colors.grey[800] : Colors.white,
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    spreadRadius: 2,
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                                border: Border.all(
                                  color: isDark
                                      ? Colors.grey[600]!
                                      : Colors.grey[200]!,
                                  width: 1.5,
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                  onTap: _zoomOut,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(12),
                                        bottomRight: Radius.circular(12),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.remove,
                                      color: const Color(0xFF6FCF97),
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // My Location button
                      Positioned(
                        right: 16,
                        bottom: 20,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[800] : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                spreadRadius: 2,
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: isDark
                                  ? Colors.grey[600]!
                                  : Colors.grey[200]!,
                              width: 1.5,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: _goToCurrentLocation,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Icons.my_location,
                                  color: const Color(0xFF6FCF97),
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Enhanced zoom level indicator
                      Positioned(
                        left: 16,
                        top: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[800] : Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: isDark
                                  ? Colors.grey[600]!
                                  : Colors.grey[200]!,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF6FCF97,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.zoom_in_map,
                                  size: 18,
                                  color: const Color(0xFF6FCF97),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${_currentZoom.toStringAsFixed(1)}x',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),

          // Bottom section with address and action button
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
                      decoration: const BoxDecoration(
                        color: Color(0xFF6FCF97),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on,
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
                            'Selected Location',
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
                SizedBox(
                  width: double.infinity,
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
          ),
        ],
      ),
    );
  }
}
