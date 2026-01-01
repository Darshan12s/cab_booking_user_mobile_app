// screens/pickup_location_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'map_screen.dart';
import 'live_tracking_map_screen.dart';

class PickupLocationScreen extends StatefulWidget {
  final String? initialLocation;

  const PickupLocationScreen({super.key, this.initialLocation});

  @override
  State<PickupLocationScreen> createState() => _PickupLocationScreenState();
}

class _PickupLocationScreenState extends State<PickupLocationScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _showSearchResults = false;
  String _currentLocation = 'Your Current Location';
  Position? _currentPosition;
  bool _isLoadingLocation = false;

  final List<Map<String, String>> _allLocations = [
    {
      'name': 'Kuvempu Nagar, Mysore',
      'address': 'Karnataka, India',
      'distance': '20Kms',
    },
    {
      'name': 'Vijayanagar, Mysore',
      'address': 'Karnataka, India',
      'distance': '15Kms',
    },
    {
      'name': 'Jayanagar, Mysore',
      'address': 'Karnataka, India',
      'distance': '10Kms',
    },
    {
      'name': 'MG Road, Mysore',
      'address': 'Karnataka, India',
      'distance': '5Kms',
    },
    {
      'name': 'Railway Station, Mysore',
      'address': 'Karnataka, India',
      'distance': '3Kms',
    },
  ];

  List<Map<String, String>> _filteredLocations = [];

  @override
  void initState() {
    super.initState();
    _filteredLocations = _allLocations;
    if (widget.initialLocation != null) {
      _searchController.text = widget.initialLocation!;
    }

    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus) {
        setState(() {
          _showSearchResults = true;
        });
      }
    });

    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Location services are disabled. Please enable them in settings.',
              ),
            ),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Location permission denied. Please allow location access.',
                ),
              ),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Location permission permanently denied. Please enable it in app settings.',
              ),
            ),
          );
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _currentPosition = position;
        _currentLocation = 'Your Current Location';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to get current location')),
        );
      }
      print("Error getting location: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  void _filterLocations(String query) {
    if (!mounted) return;
    setState(() {
      _filteredLocations = _allLocations.where((location) {
        final name = location['name']!.toLowerCase();
        final address = location['address']!.toLowerCase();
        final searchLower = query.toLowerCase();
        return name.contains(searchLower) || address.contains(searchLower);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? theme.scaffoldBackgroundColor : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark
            ? theme.appBarTheme.backgroundColor
            : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () {
            if (mounted) Navigator.pop(context);
          },
        ),
        title: Text(
          'Choose Pick up Location',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Choose on map button
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () async {
                final String? selectedLocation = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MapScreen(
                      title: 'Choose Pickup Location',
                      isSelectMode: true,
                    ),
                  ),
                );

                if (selectedLocation != null && mounted) {
                  // Set the selected pickup location in the text field
                  setState(() {
                    _searchController.text = selectedLocation;
                  });
                  // Optionally, pop and return the location to previous page
                  Navigator.pop(context, selectedLocation);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6FCF97),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              icon: const Icon(Icons.location_on, size: 20),
              label: Text(
                'Choose on map',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Live tracking option button
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () async {
                final String? liveLocation = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LiveTrackingMapScreen(
                      title: 'Live Location Tracking',
                      enableLiveTracking: true,
                    ),
                  ),
                );

                if (liveLocation != null && mounted) {
                  Navigator.pop(context, liveLocation);
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF6FCF97),
                side: const BorderSide(color: Color(0xFF6FCF97), width: 2),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              icon: const Icon(Icons.gps_fixed, size: 20),
              label: Text(
                'Live location tracking',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Search field
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.white,
              border: Border.all(color: const Color(0xFF6FCF97), width: 2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white : Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter Pick-up location',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white60 : Colors.grey[500],
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: _filterLocations,
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: isDark ? Colors.white60 : Colors.grey,
                    ),
                    onPressed: () {
                      if (!mounted) return;
                      setState(() {
                        _searchController.clear();
                        _filteredLocations = _allLocations;
                      });
                    },
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Location suggestions
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // Current location tile
                if (!_showSearchResults || _searchController.text.isEmpty)
                  InkWell(
                    onTap: () {
                      if (_currentPosition != null && mounted) {
                        Navigator.pop(context, _currentLocation);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isDark ? Colors.white24 : Colors.grey[300]!,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          _isLoadingLocation
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  Icons.my_location,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.grey[600],
                                  size: 20,
                                ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _currentPosition != null
                                      ? 'Your Current Location'
                                      : 'Enable Location',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _currentPosition != null
                                      ? 'Your current location'
                                      : 'Tap to enable location services',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.white60
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.gps_fixed,
                              color: const Color(0xFF6FCF97),
                              size: 20,
                            ),
                            onPressed: _getCurrentLocation,
                          ),
                        ],
                      ),
                    ),
                  ),

                // Search results or all locations
                ..._filteredLocations
                    .map(
                      (location) => InkWell(
                        onTap: () {
                          if (mounted) Navigator.pop(context, location['name']);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: isDark
                                    ? Colors.white24
                                    : Colors.grey[300]!,
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: isDark
                                    ? Colors.white70
                                    : Colors.grey[600],
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      location['name']!,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      location['address']!,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: isDark
                                            ? Colors.white60
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                location['distance']!,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.white60
                                      : Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),

                // Empty state
                if (_filteredLocations.isEmpty &&
                    _searchController.text.isNotEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'No locations found',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: isDark ? Colors.white60 : Colors.grey[600],
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

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}
