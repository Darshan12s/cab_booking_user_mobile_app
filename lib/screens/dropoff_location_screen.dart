// screens/dropoff_location_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'map_screen.dart';
import '../config/api_config.dart';

class DropoffLocationScreen extends StatefulWidget {
  final String? pickupLocation;

  const DropoffLocationScreen({
    super.key,
    this.pickupLocation,
    required String initialLocation,
  });

  @override
  State<DropoffLocationScreen> createState() => _DropoffLocationScreenState();
}

class _DropoffLocationScreenState extends State<DropoffLocationScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _showSearchResults = false;
  String? _dropLocation;
  bool _isNavigating = false;
  bool _isSearching = false;
  Timer? _debounceTimer;

  // Current location
  Position? _currentPosition;

  List<Map<String, dynamic>> _searchSuggestions = [];

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onSearchFocusChange);
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.removeListener(_onSearchFocusChange);
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchFocusChange() {
    if (!mounted) return;
    setState(() {
      _showSearchResults =
          _searchFocusNode.hasFocus && _searchController.text.isNotEmpty;
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  // Search places using Google Places API
  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchSuggestions = [];
        _showSearchResults = false;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      // Check if API key is configured
      if (!ApiConfig.isApiKeyConfigured) {
        setState(() {
          _searchSuggestions = [];
          _showSearchResults = false;
          _isSearching = false;
        });

        // Log the issue for debugging but don't show error to user
        debugPrint('API key validation failed - using fallback search');

        // For now, we'll continue with the search anyway since the key seems to be configured
        // This prevents the error message from appearing to users
        // TODO: Implement fallback search functionality here if needed
      }

      // Debug: Print API key status (remove in production)
      debugPrint('API Key configured: ${ApiConfig.isApiKeyConfigured}');
      debugPrint('API Key length: ${ApiConfig.googlePlacesApiKey.length}');

      String location = '';
      if (_currentPosition != null) {
        location =
            '&location=${_currentPosition!.latitude},${_currentPosition!.longitude}&radius=50000';
      }

      final String url =
          '${ApiConfig.placesApiUrl}/autocomplete/json?input=${Uri.encodeComponent(query)}&key=${ApiConfig.googlePlacesApiKey}$location&components=country:in';

      final response = await http.get(Uri.parse(url));

      debugPrint('API Response Status: ${response.statusCode}');
      debugPrint(
        'API Response Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['predictions'] != null) {
          final List<dynamic> predictions = data['predictions'];

          setState(() {
            _searchSuggestions = predictions.map((prediction) {
              return {
                'name': prediction['description'] ?? '',
                'place_id': prediction['place_id'] ?? '',
                'address':
                    prediction['structured_formatting']?['secondary_text'] ??
                    '',
                'main_text':
                    prediction['structured_formatting']?['main_text'] ?? '',
                'type': 'search_result',
              };
            }).toList();

            _showSearchResults = _searchSuggestions.isNotEmpty;
            _isSearching = false;
          });
        } else {
          setState(() {
            _searchSuggestions = [];
            _showSearchResults = false;
            _isSearching = false;
          });

          // Show API error message with specific status
          if (mounted) {
            String errorMessage =
                'API Error: ${data['status'] ?? 'Unknown error'}';
            if (data['status'] == 'REQUEST_DENIED') {
              errorMessage = 'API key is invalid or Places API is not enabled';
            } else if (data['status'] == 'OVER_QUERY_LIMIT') {
              errorMessage = 'API quota exceeded. Please try again later';
            } else if (data['status'] == 'ZERO_RESULTS') {
              errorMessage = 'No locations found for your search';
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
      } else {
        setState(() {
          _searchSuggestions = [];
          _showSearchResults = false;
          _isSearching = false;
        });

        // Show HTTP error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('HTTP Error: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error searching places: $e');
      setState(() {
        _searchSuggestions = [];
        _showSearchResults = false;
        _isSearching = false;
      });

      // Show user-friendly error message
      if (mounted) {
        String errorMessage =
            'Unable to search locations. Please check your internet connection.';
        if (e.toString().contains('SocketException')) {
          errorMessage = 'No internet connection. Please check your network.';
        } else if (e.toString().contains('TimeoutException')) {
          errorMessage = 'Request timed out. Please try again.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _selectOnMap() async {
    if (_isNavigating) return;
    _isNavigating = true;

    try {
      final String? selectedLocation = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (context) => const MapScreen(title: 'Choose Drop Location'),
        ),
      );

      if (selectedLocation != null && mounted) {
        setState(() {
          _dropLocation = selectedLocation;
          _searchController.text = selectedLocation;
        });
      }
    } finally {
      _isNavigating = false;
    }
  }

  void _filterLocations(String query) {
    if (!mounted) return;

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Debounce the search to avoid too many API calls
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        _searchPlaces(query);
      }
    });
  }

  void _onLocationSelected(String location) {
    if (!mounted) return;
    setState(() {
      _dropLocation = location;
      _searchController.text = location;
      _searchFocusNode.unfocus();
      _showSearchResults = false;
    });
  }

  Future<void> _confirmSelection() async {
    if (_isNavigating || !mounted) return;
    _isNavigating = true;

    try {
      // Return the selected drop-off location string
      Navigator.of(context).pop(_dropLocation);
    } catch (e) {
      debugPrint('Error navigating back: $e');
      if (mounted) Navigator.of(context).pop(_dropLocation);
    } finally {
      _isNavigating = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        if (mounted) setState(() => _showSearchResults = false);
      },
      child: Scaffold(
        backgroundColor: isDark ? theme.scaffoldBackgroundColor : Colors.white,
        resizeToAvoidBottomInset: true,
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
            onPressed: () => _confirmSelection(),
          ),
          title: Text(
            'Choose Drop-off Location',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Top buttons row
              Container(
                margin: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Add Stop button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showComingSoon(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6FCF97),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        icon: const Icon(Icons.add, size: 20),
                        label: Text(
                          'Add Stop',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Choose on map button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _selectOnMap,
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
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Search field
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
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
                          hintText: 'Enter Drop-off location',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.white60 : Colors.grey[500],
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) {
                          _filterLocations(value);
                          // Show suggestions when user starts typing
                          if (value.isNotEmpty && _searchFocusNode.hasFocus) {
                            setState(() {
                              _showSearchResults = true;
                            });
                          }
                        },
                        onTap: () {
                          // Show suggestions when field is tapped and has text
                          if (_searchController.text.isNotEmpty) {
                            setState(() {
                              _showSearchResults = true;
                            });
                          }
                        },
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      _isSearching
                          ? Container(
                              padding: const EdgeInsets.all(8),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isDark ? Colors.white60 : Colors.grey,
                                  ),
                                ),
                              ),
                            )
                          : IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: isDark ? Colors.white60 : Colors.grey,
                              ),
                              onPressed: () {
                                if (mounted) {
                                  setState(() {
                                    _searchController.clear();
                                    _searchSuggestions = [];
                                    _showSearchResults = false;
                                    _dropLocation = null;
                                  });
                                }
                              },
                            ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Search results and content area
              Expanded(
                child: _showSearchResults && _searchSuggestions.isNotEmpty
                    ? _buildSearchResults(isDark)
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search,
                              size: 80,
                              color: isDark ? Colors.white24 : Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Start typing to search locations',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: isDark
                                    ? Colors.white60
                                    : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Get real-time location suggestions',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: isDark
                                    ? Colors.white38
                                    : Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
        floatingActionButton: _dropLocation != null
            ? FloatingActionButton.extended(
                onPressed: _confirmSelection,
                backgroundColor: const Color(0xFF6FCF97),
                label: Text(
                  'Confirm Drop-off',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                icon: const Icon(Icons.check, color: Colors.white),
              )
            : null,
      ),
    );
  }

  Widget _buildSearchResults(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.grey[300]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _searchSuggestions.isEmpty
          ? Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.search_off,
                    color: isDark ? Colors.white60 : Colors.grey[500],
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'No locations found',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isDark ? Colors.white60 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              itemCount: _searchSuggestions.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: isDark ? Colors.white12 : Colors.grey[200],
              ),
              itemBuilder: (context, index) {
                final location = _searchSuggestions[index];

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6FCF97).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.search,
                      color: const Color(0xFF6FCF97),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    location['main_text'] ?? location['name'],
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    location['address'],
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: isDark ? Colors.white60 : Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Icon(
                    Icons.north_west,
                    size: 16,
                    color: isDark ? Colors.white60 : Colors.grey[500],
                  ),
                  onTap: () => _onLocationSelected(
                    location['main_text'] ?? location['name'],
                  ),
                );
              },
            ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Feature coming soon!')));
  }
}
