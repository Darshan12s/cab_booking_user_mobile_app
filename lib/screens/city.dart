// screens/city.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../booking_theme.dart';
import '../widgets/passenger_selector.dart';
import '../screens/book.dart';

class CityScreen extends StatefulWidget {
  const CityScreen({super.key});

  @override
  State<CityScreen> createState() => _CityScreenState();
}

class _CityScreenState extends State<CityScreen> {
  int selectedTab = 0; // 0: One Way, 1: Round Trip
  DateTime pickUpDate = DateTime.now();
  TimeOfDay pickUpTime = TimeOfDay.now();
  int passengerCount = 1;

  // Location controllers
  String pickupLocation = '';
  String dropoffLocation = '';

  // Define package options and selected package
  final List<String> packageOptions = ['Standard', 'Premium', 'Luxury'];
  String? selectedPackage;

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

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('City Ride Service'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Tabs
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => selectedTab = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selectedTab == 0
                              ? const Color(0xFF6FCF97)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: Text(
                            'One Way',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => selectedTab = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selectedTab == 1
                              ? const Color(0xFF6FCF97)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: Text(
                            'Round Trip',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Location Fields
            _buildLocationField(
              'Enter Pick-up location',
              onChanged: (value) => setState(() => pickupLocation = value),
            ),
            const SizedBox(height: 12),
            _buildLocationField(
              'Enter Drop-off location',
              onChanged: (value) => setState(() => dropoffLocation = value),
            ),
            const SizedBox(height: 12),
            // Date & Time
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: _selectDate,
                    child: _buildDateField(
                      '${pickUpDate.day.toString().padLeft(2, '0')}-${pickUpDate.month.toString().padLeft(2, '0')}-${pickUpDate.year}',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: _selectTime,
                    child: _buildTimeField(pickUpTime.format(context)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: PassengerSelector(
                    count: passengerCount,
                    onIncrement: _incrementPassenger,
                    onDecrement: _decrementPassenger,
                    isMobile: true,
                  ),
                ),
              ],
            ),
            if (selectedTab == 1) ...[
              const SizedBox(height: 16),
              const Text(
                'Return Journey',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: _selectDate,
                      child: _buildDateField(
                        '${pickUpDate.day.toString().padLeft(2, '0')}-${pickUpDate.month.toString().padLeft(2, '0')}-${pickUpDate.year}',
                        label: 'Return Date',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: _selectTime,
                      child: _buildTimeField(
                        pickUpTime.format(context),
                        label: 'Return Time',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(flex: 1, child: Container()),
                ],
              ),
            ],
            const SizedBox(height: 18),
            // Search Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (pickupLocation.isEmpty || dropoffLocation.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please enter both pickup and dropoff locations',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  if (packageOptions.contains(selectedPackage)) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RideSelectionPage(
                          bookingType: 'city ',
                          packageSelected: selectedPackage ?? '',
                          pickupLocation: pickupLocation,
                          selectedDate: pickUpDate,
                          selectedTime: pickUpTime,
                          passengerCount: passengerCount,
                          dropoffLocation: dropoffLocation,
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
      ),
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

  Widget _buildLocationField(String label, {ValueChanged<String>? onChanged}) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
      ),
    );
  }

  Widget _buildDateField(String date, {String? label}) {
    return TextField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: label ?? 'Pick-up Date',
        hintText: date,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: const Icon(Icons.calendar_today),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
      ),
    );
  }

  Widget _buildTimeField(String time, {String? label}) {
    return TextField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: label ?? 'Time',
        hintText: time,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: const Icon(Icons.access_time),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
      ),
    );
  }
}
