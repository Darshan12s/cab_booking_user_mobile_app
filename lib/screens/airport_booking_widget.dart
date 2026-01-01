// screens/airport_booking_widget.dart
import 'package:flutter/material.dart';
import '../widgets/passenger_selector.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pickup_location_screen.dart';
import 'dropoff_location_screen.dart';
import 'book.dart';

class AirportBookingWidget extends StatefulWidget {
  const AirportBookingWidget({super.key});

  @override
  State<AirportBookingWidget> createState() => _AirportBookingWidgetState();
}

class _AirportBookingWidgetState extends State<AirportBookingWidget> {
  int selectedTab = 0; // 0: To Airport, 1: From Airport
  DateTime pickUpDate = DateTime.now();
  TimeOfDay pickUpTime = TimeOfDay.now();
  int passengerCount = 1;
  String pickupLocation = 'Enter Pick-up location';
  String airportLocation = 'Enter Airport location';
  String dropoffLocation = 'Enter Drop-off location';

  // Special Instructions state
  bool _showSpecialInstructions = false;
  int _luggageCount = 0;
  bool _travelingWithPet = false;
  // ignore: unused_field
  String _additionalRequirements = '';

  void _incrementPassenger() {
    setState(() {
      if (passengerCount < 8) passengerCount++;
    });
  }

  void _decrementPassenger() {
    setState(() {
      if (passengerCount > 1) passengerCount--;
    });
  }

  Future<void> _selectPickupLocation() async {
    final String? selectedLocation = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => PickupLocationScreen(
          initialLocation: pickupLocation == 'Enter Pick-up location'
              ? ''
              : pickupLocation,
        ),
      ),
    );

    if (selectedLocation != null) {
      setState(() {
        pickupLocation = selectedLocation;
      });
    }
  }

  Future<void> _selectAirportLocation() async {
    final String? selectedLocation = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => DropoffLocationScreen(
          initialLocation: airportLocation == 'Enter Airport location'
              ? ''
              : airportLocation,
        ),
      ),
    );

    if (selectedLocation != null) {
      setState(() {
        airportLocation = selectedLocation;
      });
    }
  }

  Future<void> _selectDropoffLocation() async {
    final String? selectedLocation = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => DropoffLocationScreen(
          initialLocation: dropoffLocation == 'Enter Drop-off location'
              ? ''
              : dropoffLocation,
        ),
      ),
    );

    if (selectedLocation != null) {
      setState(() {
        dropoffLocation = selectedLocation;
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: pickUpDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != pickUpDate) {
      setState(() {
        pickUpDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: pickUpTime,
    );
    if (picked != null && picked != pickUpTime) {
      setState(() {
        pickUpTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive calculations for different screen sizes
    final bool isTablet = screenWidth > 600;
    final double containerPadding = isTablet
        ? screenWidth * 0.025
        : screenWidth * 0.03;
    final double titleFontSize = isTablet
        ? screenWidth * 0.03
        : screenWidth * 0.04;
    final double locationFontSize = isTablet
        ? screenWidth * 0.03
        : screenWidth * 0.04;
    final double buttonFontSize = isTablet
        ? screenWidth * 0.035
        : screenWidth * 0.045;

    return Container(
      padding: EdgeInsets.all(containerPadding),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service type tabs
          Container(
            decoration: BoxDecoration(
              color: isDark ? theme.colorScheme.surface : Colors.grey[100],
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedTab = 0),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: isTablet
                            ? screenWidth * 0.02
                            : screenWidth * 0.03,
                      ),
                      decoration: BoxDecoration(
                        color: selectedTab == 0
                            ? const Color(0xFF6FCF97)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          'To Airport',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: selectedTab == 0
                                ? Colors.white
                                : (isDark ? Colors.white70 : Colors.grey[600]),
                            fontSize: isTablet
                                ? screenWidth * 0.025
                                : screenWidth * 0.035,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedTab = 1),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: isTablet
                            ? screenWidth * 0.02
                            : screenWidth * 0.03,
                      ),
                      decoration: BoxDecoration(
                        color: selectedTab == 1
                            ? const Color(0xFF6FCF97)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          'From Airport',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: selectedTab == 1
                                ? Colors.white
                                : (isDark ? Colors.white70 : Colors.grey[600]),
                            fontSize: isTablet
                                ? screenWidth * 0.025
                                : screenWidth * 0.035,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: screenHeight * 0.02),

          // Location fields with icons
          if (selectedTab == 0) ...[
            // Pick-up location for "To Airport"
            Row(
              children: [
                Container(
                  width: isTablet ? screenWidth * 0.04 : screenWidth * 0.05,
                  height: isTablet ? screenWidth * 0.04 : screenWidth * 0.05,
                  decoration: const BoxDecoration(
                    color: Color(0xFF6FCF97),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: isTablet ? screenWidth * 0.024 : screenWidth * 0.03,
                  ),
                ),
                SizedBox(
                  width: isTablet ? screenWidth * 0.03 : screenWidth * 0.04,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: _selectPickupLocation,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: isTablet
                            ? screenWidth * 0.025
                            : screenWidth * 0.03,
                        horizontal: isTablet
                            ? screenWidth * 0.025
                            : screenWidth * 0.03,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? Colors.white30 : Colors.grey[300]!,
                        ),
                      ),
                      child: Text(
                        pickupLocation,
                        style: GoogleFonts.poppins(
                          fontSize: locationFontSize,
                          color: pickupLocation == 'Enter Pick-up location'
                              ? (isDark ? Colors.white60 : Colors.grey[600])
                              : (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: screenHeight * 0.02),

            // Airport location for "To Airport"
            Row(
              children: [
                Container(
                  width: isTablet ? screenWidth * 0.04 : screenWidth * 0.05,
                  height: isTablet ? screenWidth * 0.04 : screenWidth * 0.05,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.flight_takeoff,
                    color: Colors.white,
                    size: isTablet ? screenWidth * 0.024 : screenWidth * 0.03,
                  ),
                ),
                SizedBox(
                  width: isTablet ? screenWidth * 0.03 : screenWidth * 0.04,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: _selectAirportLocation,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: isTablet
                            ? screenWidth * 0.025
                            : screenWidth * 0.03,
                        horizontal: isTablet
                            ? screenWidth * 0.025
                            : screenWidth * 0.03,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? Colors.white30 : Colors.grey[300]!,
                        ),
                      ),
                      child: Text(
                        airportLocation,
                        style: GoogleFonts.poppins(
                          fontSize: locationFontSize,
                          color: airportLocation == 'Enter Airport location'
                              ? (isDark ? Colors.white60 : Colors.grey[600])
                              : (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // Airport location for "From Airport"
            Row(
              children: [
                Container(
                  width: isTablet ? screenWidth * 0.04 : screenWidth * 0.05,
                  height: isTablet ? screenWidth * 0.04 : screenWidth * 0.05,
                  decoration: const BoxDecoration(
                    color: Color(0xFF6FCF97),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.flight_land,
                    color: Colors.white,
                    size: isTablet ? screenWidth * 0.024 : screenWidth * 0.03,
                  ),
                ),
                SizedBox(
                  width: isTablet ? screenWidth * 0.03 : screenWidth * 0.04,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: _selectAirportLocation,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: isTablet
                            ? screenWidth * 0.025
                            : screenWidth * 0.03,
                        horizontal: isTablet
                            ? screenWidth * 0.025
                            : screenWidth * 0.03,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? Colors.white30 : Colors.grey[300]!,
                        ),
                      ),
                      child: Text(
                        airportLocation,
                        style: GoogleFonts.poppins(
                          fontSize: locationFontSize,
                          color: airportLocation == 'Enter Airport location'
                              ? (isDark ? Colors.white60 : Colors.grey[600])
                              : (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: screenHeight * 0.02),

            // Drop-off location for "From Airport"
            Row(
              children: [
                Container(
                  width: isTablet ? screenWidth * 0.04 : screenWidth * 0.05,
                  height: isTablet ? screenWidth * 0.04 : screenWidth * 0.05,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: isTablet ? screenWidth * 0.024 : screenWidth * 0.03,
                  ),
                ),
                SizedBox(
                  width: isTablet ? screenWidth * 0.03 : screenWidth * 0.04,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: _selectDropoffLocation,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: isTablet
                            ? screenWidth * 0.025
                            : screenWidth * 0.03,
                        horizontal: isTablet
                            ? screenWidth * 0.025
                            : screenWidth * 0.03,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? Colors.white30 : Colors.grey[300]!,
                        ),
                      ),
                      child: Text(
                        dropoffLocation,
                        style: GoogleFonts.poppins(
                          fontSize: locationFontSize,
                          color: dropoffLocation == 'Enter Drop-off location'
                              ? (isDark ? Colors.white60 : Colors.grey[600])
                              : (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],

          SizedBox(height: screenHeight * 0.015),

          // Pick-up Date & time section
          Text(
            'Pick-up Date & time',
            style: GoogleFonts.poppins(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),

          SizedBox(height: screenHeight * 0.01),

          // Date, Time, and Passenger count row (Responsive layout)
          isTablet
              ? Row(
                  children: [
                    // Date field
                    Expanded(
                      flex: 3,
                      child: _buildAirportDateTimeField(
                        title: 'Date',
                        value:
                            '${pickUpDate.day.toString().padLeft(2, '0')}-${pickUpDate.month.toString().padLeft(2, '0')}-${pickUpDate.year}',
                        icon: Icons.calendar_today,
                        onTap: _selectDate,
                        screenWidth: screenWidth,
                        isTablet: isTablet,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.015),
                    // Time field
                    Expanded(
                      flex: 3,
                      child: _buildAirportDateTimeField(
                        title: 'Time',
                        value: pickUpTime.format(context),
                        icon: Icons.access_time,
                        onTap: _selectTime,
                        screenWidth: screenWidth,
                        isTablet: isTablet,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.015),
                    // Passenger count
                    PassengerSelector(
                      count: passengerCount,
                      onIncrement: _incrementPassenger,
                      onDecrement: _decrementPassenger,
                      isMobile: false,
                    ),
                  ],
                )
              : Column(
                  children: [
                    // Date and Time row for mobile
                    Row(
                      children: [
                        Expanded(
                          child: _buildAirportDateTimeField(
                            title: 'Date',
                            value:
                                '${pickUpDate.day.toString().padLeft(2, '0')}-${pickUpDate.month.toString().padLeft(2, '0')}-${pickUpDate.year}',
                            icon: Icons.calendar_today,
                            onTap: _selectDate,
                            screenWidth: screenWidth,
                            isTablet: isTablet,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.015),
                        Expanded(
                          child: _buildAirportDateTimeField(
                            title: 'Time',
                            value: pickUpTime.format(context),
                            icon: Icons.access_time,
                            onTap: _selectTime,
                            screenWidth: screenWidth,
                            isTablet: isTablet,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    // Passenger selector on separate row for mobile
                    Row(
                      children: [
                        Text(
                          'Passengers:',
                          style: GoogleFonts.poppins(
                            fontSize: titleFontSize * 0.9,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        PassengerSelector(
                          count: passengerCount,
                          onIncrement: _incrementPassenger,
                          onDecrement: _decrementPassenger,
                          isMobile: true,
                        ),
                      ],
                    ),
                  ],
                ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              setState(() {
                _showSpecialInstructions = !_showSpecialInstructions;
              });
            },
            child: Row(
              children: [
                Icon(
                  _showSpecialInstructions
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: _showSpecialInstructions
                      ? Colors.green
                      : Colors.green[300],
                ),
                const SizedBox(width: 8),
                Text(
                  "Add Special Instructions",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: _showSpecialInstructions
                        ? Colors.green
                        : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),

          // Show Special Instructions Card (first image) when toggled
          if (_showSpecialInstructions)
            Container(
              margin: const EdgeInsets.only(top: 14, bottom: 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FCFA),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(color: const Color(0xFFE0F2F1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Luggage Items
                  Row(
                    children: [
                      const Icon(Icons.luggage, color: Color(0xFF26B67C)),
                      const SizedBox(width: 8),
                      const Text(
                        "Luggage Items",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF26B67C),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Color(0xFFBDBDBD),
                        ),
                        onPressed: _luggageCount > 0
                            ? () => setState(() => _luggageCount--)
                            : null,
                        splashRadius: 18,
                      ),
                      Text(
                        '$_luggageCount',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFF222B45),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: Color(0xFF26B67C),
                        ),
                        onPressed: () => setState(() => _luggageCount++),
                        splashRadius: 18,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Traveling with Pet
                  Row(
                    children: [
                      const Icon(Icons.pets, color: Color(0xFF26B67C)),
                      const SizedBox(width: 8),
                      const Text(
                        "Traveling with Pet",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF26B67C),
                        ),
                      ),
                      const Spacer(),
                      Switch(
                        value: _travelingWithPet,
                        onChanged: (val) =>
                            setState(() => _travelingWithPet = val),
                        activeColor: const Color(0xFF26B67C),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Additional Requirements
                  Row(
                    children: [
                      const Icon(Icons.chat, color: Color(0xFF26B67C)),
                      const SizedBox(width: 8),
                      const Text(
                        "Additional Requirements",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF222B45),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    minLines: 2,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Any other special requests or requirements...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE0F2F1)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 14,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (val) =>
                        setState(() => _additionalRequirements = val),
                  ),
                ],
              ),
            ),
          SizedBox(height: screenHeight * 0.02),

          // Search button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Validate location fields based on selected tab
                String fromLocation;
                String toLocation;

                if (selectedTab == 0) {
                  // To Airport: pickup -> airport
                  fromLocation = pickupLocation;
                  toLocation = airportLocation;

                  // Validate locations aren't default placeholders
                  if (fromLocation == 'Enter Pick-up location' ||
                      toLocation == 'Enter Airport location') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please select both pickup and airport locations',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                } else {
                  // From Airport: airport -> dropoff
                  fromLocation = airportLocation;
                  toLocation = dropoffLocation;

                  // Validate locations aren't default placeholders
                  if (fromLocation == 'Enter Airport location' ||
                      toLocation == 'Enter Drop-off location') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please select both airport and dropoff locations',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                }

                // Navigate to RideSelectionPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RideSelectionPage(
                      bookingType: 'Airport Taxi',
                      packageSelected: selectedTab == 0
                          ? 'To Airport'
                          : 'From Airport',
                      pickupLocation: fromLocation,
                      dropoffLocation: toLocation,
                      selectedDate: pickUpDate,
                      selectedTime: pickUpTime,
                      passengerCount: passengerCount,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6FCF97),
                padding: EdgeInsets.symmetric(
                  vertical: isTablet
                      ? screenHeight * 0.02
                      : screenHeight * 0.015,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 2,
              ),
              child: Text(
                'Search',
                style: GoogleFonts.poppins(
                  fontSize: buttonFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAirportDateTimeField({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
    required double screenWidth,
    required bool isTablet,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: isTablet ? screenWidth * 0.015 : screenWidth * 0.04,
            horizontal: isTablet ? screenWidth * 0.015 : screenWidth * 0.04,
          ),
          decoration: BoxDecoration(
            color: isDark ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? Colors.white30 : Colors.grey[300]!,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: isTablet ? screenWidth * 0.018 : screenWidth * 0.04,
                color: isDark ? Colors.white : Colors.black54,
              ),
              SizedBox(width: screenWidth * 0.02),
              Expanded(
                child: Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: isTablet
                        ? screenWidth * 0.014
                        : screenWidth * 0.035,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
