// screens/airport.dart
import 'package:flutter/material.dart';
import '../widgets/passenger_selector.dart';
import 'pickup_location_screen.dart';
import 'dropoff_location_screen.dart';
import 'book.dart';

class AirportScreen extends StatefulWidget {
  const AirportScreen({super.key});

  @override
  State<AirportScreen> createState() => _AirportScreenState();
}

class _AirportScreenState extends State<AirportScreen> {
  int selectedTab = 0; // 0: To Airport, 1: From Airport
  DateTime pickUpDate = DateTime.now();
  TimeOfDay pickUpTime = TimeOfDay.now();
  int passengerCount = 1;

  // Text controllers for location fields
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _airportController = TextEditingController();
  final TextEditingController _dropoffController = TextEditingController();

  @override
  void dispose() {
    _pickupController.dispose();
    _airportController.dispose();
    _dropoffController.dispose();
    super.dispose();
  }

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Airport Taxi Service'),
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
                            'To Airport',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selectedTab == 1
                              ? const Color(0xFF6FCF97)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Center(
                          child: Text(
                            'From Airport',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Location Fields
            if (selectedTab == 0) ...[
              _buildLocationField('Enter Pick-up location', _pickupController),
              const SizedBox(height: 12),
              _buildLocationField('Enter Airport location', _airportController),
            ] else ...[
              _buildLocationField('Enter Airport location', _airportController),
              const SizedBox(height: 12),
              _buildLocationField(
                'Enter Drop-off location',
                _dropoffController,
              ),
            ],
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
            const SizedBox(height: 18),

            // Search Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Validate location fields based on selected tab
                  String fromLocation;
                  String toLocation;

                  if (selectedTab == 0) {
                    // To Airport: pickup -> airport
                    fromLocation = _pickupController.text.trim();
                    toLocation = _airportController.text.trim();
                  } else {
                    // From Airport: airport -> dropoff
                    fromLocation = _airportController.text.trim();
                    toLocation = _dropoffController.text.trim();
                  }

                  if (fromLocation.isEmpty || toLocation.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill in both location fields'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
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
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Search',
                  style: TextStyle(
                    fontSize: 18,
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

  Widget _buildLocationField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF6FCF97)),
        ),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF6FCF97)),
        ),
        prefixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF6FCF97)),
        ),
        prefixIcon: const Icon(Icons.access_time, color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
      ),
    );
  }
}
