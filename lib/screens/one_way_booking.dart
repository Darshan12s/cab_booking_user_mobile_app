// screens/one_way_booking.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/pickup_location_screen.dart';
import '../screens/dropoff_location_screen.dart';
import '../widgets/passenger_selector.dart';
import '../screens/book.dart';

class OneWayBooking extends StatefulWidget {
  const OneWayBooking({super.key});

  @override
  State<OneWayBooking> createState() => _OneWayBookingState();
}

class _OneWayBookingState extends State<OneWayBooking> {
  DateTime pickUpDate = DateTime.now();
  TimeOfDay pickUpTime = TimeOfDay.now();
  String pickupLocation = 'Enter Pick-up location';
  String dropoffLocation = 'Enter Drop-off location';
  List<String> stopLocations = []; // List to store stop locations
  int passengerCount = 1;

  // Special Instructions state
  bool _showSpecialInstructions = false;
  int _luggageCount = 0;
  bool _travelingWithPet = false;
  // ignore: unused_field
  String _additionalRequirements = '';

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

  Future<void> _addLocation() async {
    if (stopLocations.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 5 stops allowed'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final String? newStop = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => PickupLocationScreen(initialLocation: ''),
      ),
    );

    if (newStop != null && newStop.isNotEmpty) {
      setState(() {
        stopLocations.add(newStop);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stop ${stopLocations.length} added: $newStop'),
          backgroundColor: const Color(0xFF6FCF97),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _editStopLocation(int index) async {
    final String? editedStop = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PickupLocationScreen(initialLocation: stopLocations[index]),
      ),
    );

    if (editedStop != null && editedStop.isNotEmpty) {
      setState(() {
        stopLocations[index] = editedStop;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stop ${index + 1} updated: $editedStop'),
          backgroundColor: const Color(0xFF6FCF97),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _removeStopLocation(int index) {
    final String removedStop = stopLocations[index];
    setState(() {
      stopLocations.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Stop ${index + 1} removed: $removedStop'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              stopLocations.insert(index, removedStop);
            });
          },
        ),
      ),
    );
  }

  void _showStopOptions(int index) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Stop ${index + 1} Options',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.edit, color: Color(0xFF6FCF97)),
                title: Text(
                  'Edit Stop',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _editStopLocation(index);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(
                  'Remove Stop',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _removeStopLocation(index);
                },
              ),
            ],
          ),
        );
      },
    );
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

  void _incrementPassenger() {
    if (passengerCount < 8) {
      setState(() {
        passengerCount++;
      });
    }
  }

  void _decrementPassenger() {
    if (passengerCount > 1) {
      setState(() {
        passengerCount--;
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
    final double locationPadding = isTablet
        ? screenWidth * 0.025
        : screenWidth * 0.03;
    final double titleFontSize = isTablet
        ? screenWidth * 0.03
        : screenWidth * 0.04;
    final double locationFontSize = isTablet
        ? screenWidth * 0.03
        : screenWidth * 0.04;
    final double iconSize = isTablet
        ? screenWidth * 0.035
        : screenWidth * 0.045;
    final double dateTimeFontSize = isTablet
        ? screenWidth * 0.025
        : screenWidth * 0.032;
    final double buttonFontSize = isTablet
        ? screenWidth * 0.035
        : screenWidth * 0.045;
    final double addButtonSize = isTablet
        ? screenWidth * 0.06
        : screenWidth * 0.08;
    final double stopNumberSize = isTablet
        ? screenWidth * 0.04
        : screenWidth * 0.05;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Location fields with icons (Responsive)
        Container(
          padding: EdgeInsets.all(locationPadding),
          decoration: BoxDecoration(
            color: isDark ? theme.colorScheme.surface : Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white30 : Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Pick-up location
              _buildLocationRow(
                context,
                isDark,
                screenWidth,
                screenHeight,
                isTablet,
                icon: Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: const BoxDecoration(
                    color: Color(0xFF6FCF97),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: iconSize * 0.6,
                  ),
                ),
                location: pickupLocation,
                onTap: _selectPickupLocation,
                showAddButton: true,
                onAddTap: _addLocation,
                locationFontSize: locationFontSize,
                addButtonSize: addButtonSize,
              ),

              // Stop locations (if any)
              if (stopLocations.isNotEmpty) ...[
                ...List.generate(stopLocations.length, (index) {
                  return Column(
                    children: [
                      _buildDottedLine(screenWidth, screenHeight, isTablet),
                      _buildLocationRow(
                        context,
                        isDark,
                        screenWidth,
                        screenHeight,
                        isTablet,
                        icon: Container(
                          width: stopNumberSize,
                          height: stopNumberSize,
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: stopNumberSize * 0.6,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        location: stopLocations[index],
                        onTap: () => _showStopOptions(index),
                        showAddButton: false,
                        locationFontSize: locationFontSize,
                        addButtonSize: addButtonSize,
                      ),
                    ],
                  );
                }),
              ],

              // Dotted line before drop-off
              _buildDottedLine(screenWidth, screenHeight, isTablet),

              // Drop-off location
              _buildLocationRow(
                context,
                isDark,
                screenWidth,
                screenHeight,
                isTablet,
                icon: Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: iconSize * 0.6,
                  ),
                ),
                location: dropoffLocation,
                onTap: _selectDropoffLocation,
                showAddButton: false,
                locationFontSize: locationFontSize,
                addButtonSize: addButtonSize,
              ),
            ],
          ),
        ),

        SizedBox(height: screenHeight * 0.015),

        // Pick-up Date & time section (Responsive)
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
                    child: _buildDateTimeField(
                      context,
                      isDark,
                      screenWidth,
                      screenHeight,
                      isTablet,
                      icon: Icons.calendar_today,
                      text:
                          '${pickUpDate.day.toString().padLeft(2, '0')}-${pickUpDate.month.toString().padLeft(2, '0')}-${pickUpDate.year}',
                      onTap: _selectDate,
                      fontSize: dateTimeFontSize,
                      iconSize: iconSize,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.015),
                  // Time field
                  Expanded(
                    flex: 3,
                    child: _buildDateTimeField(
                      context,
                      isDark,
                      screenWidth,
                      screenHeight,
                      isTablet,
                      icon: Icons.access_time,
                      text: pickUpTime.format(context),
                      onTap: _selectTime,
                      fontSize: dateTimeFontSize,
                      iconSize: iconSize,
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
                        child: _buildDateTimeField(
                          context,
                          isDark,
                          screenWidth,
                          screenHeight,
                          isTablet,
                          icon: Icons.calendar_today,
                          text:
                              '${pickUpDate.day.toString().padLeft(2, '0')}-${pickUpDate.month.toString().padLeft(2, '0')}-${pickUpDate.year}',
                          onTap: _selectDate,
                          fontSize: dateTimeFontSize,
                          iconSize: iconSize,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.015),
                      Expanded(
                        child: _buildDateTimeField(
                          context,
                          isDark,
                          screenWidth,
                          screenHeight,
                          isTablet,
                          icon: Icons.access_time,
                          text: pickUpTime.format(context),
                          onTap: _selectTime,
                          fontSize: dateTimeFontSize,
                          iconSize: iconSize,
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

        // Special Instructions toggle and card
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

        // Search button (Responsive)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RideSelectionPage(
                    bookingType: 'OutStation',
                    packageSelected: 'One Way',
                    pickupLocation: pickupLocation,
                    dropoffLocation: dropoffLocation,
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
                vertical: isTablet ? screenHeight * 0.02 : screenHeight * 0.015,
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
    );
  }

  Widget _buildLocationRow(
    BuildContext context,
    bool isDark,
    double screenWidth,
    double screenHeight,
    bool isTablet, {
    required Widget icon,
    required String location,
    required VoidCallback onTap,
    required bool showAddButton,
    VoidCallback? onAddTap,
    required double locationFontSize,
    required double addButtonSize,
  }) {
    return Row(
      children: [
        SizedBox(
          width: isTablet ? screenWidth * 0.04 : screenWidth * 0.05,
          child: icon,
        ),
        SizedBox(width: isTablet ? screenWidth * 0.03 : screenWidth * 0.04),
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: isTablet ? screenWidth * 0.025 : screenWidth * 0.03,
                horizontal: isTablet ? screenWidth * 0.025 : screenWidth * 0.03,
              ),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? Colors.white30 : Colors.grey[300]!,
                ),
              ),
              child: Text(
                location,
                style: GoogleFonts.poppins(
                  fontSize: locationFontSize,
                  color: location.startsWith('Enter')
                      ? (isDark ? Colors.white60 : Colors.grey[600])
                      : (isDark ? Colors.white : Colors.black87),
                ),
              ),
            ),
          ),
        ),
        if (showAddButton) ...[
          SizedBox(width: isTablet ? screenWidth * 0.02 : screenWidth * 0.03),
          GestureDetector(
            onTap: onAddTap,
            child: Container(
              width: addButtonSize,
              height: addButtonSize,
              decoration: BoxDecoration(
                color: const Color(0xFF6FCF97),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: addButtonSize * 0.6,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDottedLine(
    double screenWidth,
    double screenHeight,
    bool isTablet,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: isTablet ? screenHeight * 0.008 : screenHeight * 0.01,
      ),
      child: Row(
        children: [
          SizedBox(width: isTablet ? screenWidth * 0.025 : screenWidth * 0.035),
          Expanded(
            child: Container(
              height: 1,
              child: CustomPaint(painter: DottedLinePainter()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeField(
    BuildContext context,
    bool isDark,
    double screenWidth,
    double screenHeight,
    bool isTablet, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    required double fontSize,
    required double iconSize,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: screenWidth * 0.04,
          horizontal: screenWidth * 0.04,
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
              color: isDark ? Colors.white : Colors.black54,
              size: iconSize,
            ),
            SizedBox(width: screenWidth * 0.02),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: fontSize,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashWidth = 3.0;
    const dashSpace = 3.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
