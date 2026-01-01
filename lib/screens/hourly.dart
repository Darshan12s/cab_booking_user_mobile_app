// screens/hourly.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/passenger_selector.dart';
import 'pickup_location_screen.dart';
import 'book.dart';

class HourlyRentalWidget extends StatefulWidget {
  const HourlyRentalWidget({super.key});

  @override
  State<HourlyRentalWidget> createState() => _HourlyRentalWidgetState();
}

class _HourlyRentalWidgetState extends State<HourlyRentalWidget> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String pickupLocation = 'Kuvempu Nagar,Mysore';
  String selectedPackage = 'Select Package';
  int passengerCount = 1;

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

  final List<String> packageOptions = [
    '2Hr - 20Kms',
    '4Hr - 40Kms',
    '8Hr - 80Kms',
  ];

  Future<void> _selectPickupLocation() async {
    final String? selectedLocation = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => PickupLocationScreen(
          initialLocation: pickupLocation == 'Kuvempu Nagar,Mysore'
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  // Special Instructions state
  bool _showSpecialInstructions = false;
  int _luggageCount = 0;
  bool _travelingWithPet = false;
  // ignore: unused_field
  String _additionalRequirements = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
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
          // Pick-up location
          Row(
            children: [
              Container(
                width: screenWidth * 0.05,
                height: screenWidth * 0.05,
                decoration: const BoxDecoration(
                  color: Color(0xFF6FCF97),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: screenWidth * 0.03,
                ),
              ),
              SizedBox(width: screenWidth * 0.04),
              Expanded(
                child: GestureDetector(
                  onTap: _selectPickupLocation,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: screenWidth * 0.04,
                      horizontal: screenWidth * 0.04,
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
                        fontSize: screenWidth * 0.04,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: screenHeight * 0.02),

          // Package selection dropdown
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenWidth * 0.02,
            ),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? Colors.white30 : Colors.grey[300]!,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: packageOptions.contains(selectedPackage)
                    ? selectedPackage
                    : null,
                hint: Text(
                  'Select Package',
                  style: GoogleFonts.poppins(
                    fontSize: screenWidth * 0.04,
                    color: isDark ? Colors.white60 : Colors.grey[600],
                  ),
                ),
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: isDark ? Colors.white : Colors.black54,
                ),
                isExpanded: true,
                dropdownColor: isDark ? Colors.grey[800] : Colors.white,
                items: packageOptions.map((String package) {
                  return DropdownMenuItem<String>(
                    value: package,
                    child: Text(
                      package,
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.04,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedPackage = newValue ?? 'Select Package';
                  });
                },
              ),
            ),
          ),

          SizedBox(height: screenHeight * 0.02),

          // Pick-up Date & time section
          Text(
            'Pick-up Date & time',
            style: GoogleFonts.poppins(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),

          SizedBox(height: screenHeight * 0.01),

          // Date and Time row
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _selectDate,
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
                          Icons.calendar_today,
                          size: screenWidth * 0.04,
                          color: isDark ? Colors.white : Colors.black54,
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Text(
                          '${selectedDate.day.toString().padLeft(2, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.year}',
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.035,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Expanded(
                child: GestureDetector(
                  onTap: _selectTime,
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
                          Icons.access_time,
                          size: screenWidth * 0.04,
                          color: isDark ? Colors.white : Colors.black54,
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Text(
                          selectedTime.format(context),
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.035,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: screenHeight * 0.015),

          // Passenger selector on separate row
          Row(
            children: [
              Text(
                'Passengers:',
                style: GoogleFonts.poppins(
                  fontSize: screenWidth * 0.04,
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

          // Special Instructions toggle and card (only one instance, not duplicated)
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

          // Search button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to ride selection screen with hourly rental data
                if (packageOptions.contains(selectedPackage)) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RideSelectionPage(
                        bookingType: 'Hourly Rental',
                        packageSelected: selectedPackage,
                        pickupLocation: pickupLocation,
                        selectedDate: selectedDate,
                        selectedTime: selectedTime,
                        passengerCount: passengerCount,
                        dropoffLocation: '',
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select a package'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6FCF97),
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 2,
              ),
              child: Text(
                'Search',
                style: GoogleFonts.poppins(
                  fontSize: screenWidth * 0.045,
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
}
