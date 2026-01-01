// screens/auth/home_screen.dart
import 'package:cab_booking_user_mobile_app/screens/book.dart';
import 'package:cab_booking_user_mobile_app/screens/hourly.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/app_drawer.dart';
import '../rewards_screen.dart';
import '../notification_screen.dart';
import '../profile_screen.dart';
import '../my_Trip/my_trip_screen.dart';
import '../pickup_location_screen.dart';
import '../dropoff_location_screen.dart';
import '../../widgets/passenger_selector.dart';
import '../outstation_booking_widget.dart';
import '../airport_booking_widget.dart';
import '../../profile_state.dart';
import '../app_theme.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onToggleTheme;
  final int initialTabIndex;
  const HomeScreen({super.key, this.onToggleTheme, this.initialTabIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;
  int _selectedServiceIndex = 0;
  DateTime? _currentBackPressTime;

  final List<Widget> _screens = [
    const SizedBox(), // Placeholder - will be set in initState
    const MyTripScreen(),
    const ProfileScreen(),
    const RewardsScreen(),
    const NotificationScreen(),
  ];

  void _selectService(int index) {
    setState(() {
      _selectedServiceIndex = index;
      _screens[0] = HomeContentScreen(
        onToggleTheme: widget.onToggleTheme,
        selectedServiceIndex: _selectedServiceIndex,
        onSelectService: _selectService,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
    _screens[0] = HomeContentScreen(
      onToggleTheme: widget.onToggleTheme,
      selectedServiceIndex: _selectedServiceIndex,
      onSelectService: _selectService,
    );
  }

  Future<bool> _onWillPop() async {
    if (_currentIndex != 0) {
      setState(() => _currentIndex = 0);
      return false;
    }

    DateTime now = DateTime.now();
    if (_currentBackPressTime == null ||
        now.difference(_currentBackPressTime!) > const Duration(seconds: 2)) {
      _currentBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.appBarTheme.backgroundColor ?? Colors.black,
          title: const Text(''),
          centerTitle: true,
          elevation: 0,
          foregroundColor: theme.appBarTheme.foregroundColor ?? Colors.white,
        ),
        drawer: const AppDrawer(),
        body: _screens[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_car),
              label: 'My Trips',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            BottomNavigationBarItem(
              icon: Icon(Icons.card_giftcard),
              label: 'Rewards',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Notifications',
            ),
          ],
        ),
      ),
    );
  }
}

class HomeContentScreen extends StatefulWidget {
  final VoidCallback? onToggleTheme;
  final int selectedServiceIndex;
  final Function(int)? onSelectService;

  const HomeContentScreen({
    super.key,
    this.onToggleTheme,
    this.selectedServiceIndex = 0,
    this.onSelectService,
  });

  @override
  State<HomeContentScreen> createState() => _HomeContentScreenState();
}

class _HomeContentScreenState extends State<HomeContentScreen> {
  int passengerCount = 1;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String pickupLocation = '';
  String dropoffLocation = '';

  // Special Instructions state
  bool _showSpecialInstructions = false;
  int _luggageCount =0;
  bool _travelingWithPet = false;
  // ignore: unused_field
  String _additionalRequirements = '';

  @override
  void initState() {
    super.initState();
    // Set dynamic default values based on service type
    _resetLocationLabels();
  }

  @override
  void didUpdateWidget(HomeContentScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset location labels when service type changes
    if (widget.selectedServiceIndex != oldWidget.selectedServiceIndex) {
      _resetLocationLabels();
    }
  }

  void _resetLocationLabels() {
    setState(() {
      pickupLocation = _getDefaultPickup();
      dropoffLocation = _getDefaultDrop();
    });
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

  Future<void> _selectPickupLocation() async {
    final String? selectedLocation = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => PickupLocationScreen(
          initialLocation: pickupLocation == _getDefaultPickup()
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
          initialLocation: dropoffLocation == _getDefaultDrop()
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
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.isBefore(now) ? now : selectedDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        // If selected date is today and selectedTime is before now, reset time to now
        if (_isToday(picked) && !_isTimeAfterNow(selectedTime)) {
          selectedTime = TimeOfDay.now();
        }
      });
    }
  }

  Future<void> _selectTime() async {
    final bool isToday = _isToday(selectedDate);
    final TimeOfDay now = TimeOfDay.now();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return MediaQuery(data: MediaQuery.of(context), child: child!);
      },
    );
    if (picked != null) {
      // Only allow times after current time if today is selected
      if (isToday) {
        final pickedMinutes = picked.hour * 60 + picked.minute;
        final nowMinutes = now.hour * 60 + now.minute;
        if (pickedMinutes <= nowMinutes) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a time after the current time.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
      setState(() {
        selectedTime = picked;
      });
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isTimeAfterNow(TimeOfDay time) {
    final now = TimeOfDay.now();
    // Compare hour and minute
    if (time.hour > now.hour) return true;
    if (time.hour == now.hour && time.minute > now.minute) return true;
    return false;
  }

  void _handleSearch() {
    // Validate locations based on service type
    bool isValid = _validateLocations();

    if (isValid) {
      String bookingType = _getBookingType();
      _navigateToRideSelection(bookingType);
    }
  }

  bool _validateLocations() {
    String defaultPickup = _getDefaultPickup();
    String defaultDrop = _getDefaultDrop();

    switch (widget.selectedServiceIndex) {
      case 0: // City Ride

      case 2: // Outstation Car
        if (pickupLocation == defaultPickup ||
            dropoffLocation == defaultDrop ||
            pickupLocation.isEmpty ||
            dropoffLocation.isEmpty) {
          _showLocationError(
            'Please select both pickup and drop-off locations',
          );
          return false;
        }
        break;
      case 1: // Airport Taxi
        if (pickupLocation == defaultPickup ||
            dropoffLocation == defaultDrop ||
            pickupLocation.isEmpty ||
            dropoffLocation.isEmpty) {
          _showLocationError('Please select both pickup and airport locations');
          return false;
        }
        break;
      case 3: // Hourly Rental
        if (pickupLocation == defaultPickup || pickupLocation.isEmpty) {
          _showLocationError('Please select pickup location');
          return false;
        }
        break;
    }
    return true;
  }

  String _getBookingType() {
    switch (widget.selectedServiceIndex) {
      case 0: // City Ride
        return 'city';
      case 1: // Airport Taxi
        return 'airport';
      case 2: // Outstation Car
        return 'outstation';
      case 3: // Hourly Rental
        return 'hourly';
      default:
        return 'city';
    }
  }

  String _getPickupLabel() {
    switch (widget.selectedServiceIndex) {
      case 1: // Airport Taxi
        return 'Enter Pick-up location (Home/Hotel)';
      case 2: // Outstation Car
        return 'Enter Pick-up location (Start)';
      case 3: // Hourly Rental
        return 'Enter Pick-up location (Start)';
      default:
        return 'Enter Pick-up location';
    }
  }

  String _getDropLabel() {
    switch (widget.selectedServiceIndex) {
      case 1: // Airport Taxi
        return 'Select Airport';
      case 2: // Outstation Car
        return 'Enter Drop-off location (Destination)';
      default:
        return 'Enter Drop-off location';
    }
  }

  String _getDefaultPickup() {
    switch (widget.selectedServiceIndex) {
      case 1: // Airport Taxi
        return 'Enter Pick-up location (Home/Hotel)';
      case 2: // Outstation Car
        return 'Enter Pick-up location (Start)';
      case 3: // Hourly Rental
        return 'Enter Pick-up location (Start)';
      default:
        return 'Enter Pick-up location';
    }
  }

  String _getDefaultDrop() {
    switch (widget.selectedServiceIndex) {
      case 1: // Airport Taxi
        return 'Select Airport';
      case 2: // Outstation Car
        return 'Enter Drop-off location (Destination)';
      default:
        return 'Enter Drop-off location';
    }
  }

  void _navigateToRideSelection(String bookingType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RideSelectionPage(
          bookingType: bookingType,
          packageSelected: _additionalRequirements,
          pickupLocation: pickupLocation,
          selectedDate: selectedDate,
          selectedTime: selectedTime,
          passengerCount: passengerCount,
          dropoffLocation: dropoffLocation,
        ),
      ),
    );
  }

  void _showLocationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  LinearGradient _getBannerGradient(int index) {
    final List<LinearGradient> gradients = [
      const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
      ),
      const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
      ),
      const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
      ),
      const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
      ),
    ];
    return gradients[index % gradients.length];
  }

  IconData _getBannerIcon(int index) {
    final List<IconData> icons = [
      Icons.local_offer,
      Icons.star,
      Icons.security,
      Icons.speed,
    ];
    return icons[index % icons.length];
  }

  String _getBannerTitle(int index) {
    final List<String> titles = [
      'Special Offers',
      'Premium Service',
      'Safe & Secure',
      'Fast Booking',
    ];
    return titles[index % titles.length];
  }

  String _getBannerSubtitle(int index) {
    final List<String> subtitles = [
      'Get up to 50% off on your first ride',
      'Experience luxury with our premium cabs',
      'Your safety is our top priority',
      'Book your ride in just 30 seconds',
    ];
    return subtitles[index % subtitles.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.005),
            AnimatedBuilder(
              animation: userProfile,
              builder: (context, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello,',
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6FCF97),
                      ),
                    ),
                    Text(
                      userProfile.name.isNotEmpty ? userProfile.name : 'User',
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    if (userProfile.email.isNotEmpty)
                      Text(
                        userProfile.email,
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.045,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                  ],
                );
              },
            ),
            SizedBox(height: screenHeight * 0.003),
            SizedBox(height: screenHeight * 0.015),

            // Banner Carousel
            Container(
              height: screenHeight * 0.2,
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.9),
                itemCount: 4,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.02,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: _getBannerGradient(index),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -20,
                            top: -20,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 60,
                            bottom: -30,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.05),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(screenWidth * 0.04),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _getBannerIcon(index),
                                  color: Colors.white,
                                  size: screenWidth * 0.08,
                                ),
                                SizedBox(height: screenHeight * 0.015),
                                Text(
                                  _getBannerTitle(index),
                                  style: GoogleFonts.poppins(
                                    fontSize: screenWidth * 0.045,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.008),
                                Text(
                                  _getBannerSubtitle(index),
                                  style: GoogleFonts.poppins(
                                    fontSize: screenWidth * 0.032,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                                const Spacer(),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.03,
                                      vertical: screenHeight * 0.008,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      'Learn More',
                                      style: GoogleFonts.poppins(
                                        fontSize: screenWidth * 0.028,
                                        fontWeight: FontWeight.w500,
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
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: screenHeight * 0.02),

            Center(
              child: Text(
                'Your cab for all your travels!',
                style: GoogleFonts.poppins(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.01),

            // Service cards in a single row
            Container(
              height: screenHeight * 0.15,
              child: Row(
                children: [
                  Expanded(
                    child: _buildServiceCard(
                      context,
                      'City Ride',
                      'assets/images/city_ride.jpg',
                      widget.selectedServiceIndex == 0,
                      () => widget.onSelectService?.call(0),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.015),
                  Expanded(
                    child: _buildServiceCard(
                      context,
                      'Airport Taxi',
                      'assets/images/airport.jpg',
                      widget.selectedServiceIndex == 1,
                      () => widget.onSelectService?.call(1),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.015),
                  Expanded(
                    child: _buildServiceCard(
                      context,
                      'Outstation Car',
                      'assets/images/outstation.png',
                      widget.selectedServiceIndex == 2,
                      () => widget.onSelectService?.call(2),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.01),
                  Expanded(
                    child: _buildServiceCard(
                      context,
                      'Hourly Rental',
                      'assets/images/hourly.jpg',
                      widget.selectedServiceIndex == 3,
                      () => widget.onSelectService?.call(3),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.01),

            // Booking interface
            if (widget.selectedServiceIndex == 1)
              _buildAirportBookingInterface()
            else if (widget.selectedServiceIndex == 2)
              _buildOutstationBookingInterface()
            else if (widget.selectedServiceIndex == 3)
              _buildHourlyRentalInterface()
            else
              _buildRegularBookingInterface(context),
            SizedBox(height: screenHeight * 0.01),
          ],
        ),
      ),
    );
  }

  Widget _buildAirportBookingInterface() {
    return AirportBookingWidget();
  }

  Widget _buildOutstationBookingInterface() {
    return OutstationBookingWidget();
  }

  Widget _buildHourlyRentalInterface() {
    return HourlyRentalWidget();
  }

  Widget _buildRegularBookingInterface(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
          // Pick-up location
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
                        color: pickupLocation == _getDefaultPickup()
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

          // Drop-off location
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
                        color: dropoffLocation == _getDefaultDrop()
                            ? (isDark ? Colors.white60 : Colors.grey[600])
                            : (isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: screenHeight * 0.015),

          Text(
            'Pick-up Date & time',
            style: GoogleFonts.poppins(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),

          SizedBox(height: screenHeight * 0.01),

          isTablet
              ? Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildCityRideDateTimeField(
                        title: 'Date',
                        value:
                            '${selectedDate.day.toString().padLeft(2, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.year}',
                        icon: Icons.calendar_today,
                        onTap: _selectDate,
                        screenWidth: screenWidth,
                        isTablet: isTablet,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.015),
                    Expanded(
                      flex: 3,
                      child: _buildCityRideDateTimeField(
                        title: 'Time',
                        value: selectedTime.format(context),
                        icon: Icons.access_time,
                        onTap: _selectTime,
                        screenWidth: screenWidth,
                        isTablet: isTablet,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.015),
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
                    Row(
                      children: [
                        Expanded(
                          child: _buildCityRideDateTimeField(
                            title: 'Date',
                            value:
                                '${selectedDate.day.toString().padLeft(2, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.year}',
                            icon: Icons.calendar_today,
                            onTap: _selectDate,
                            screenWidth: screenWidth,
                            isTablet: isTablet,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.015),
                        Expanded(
                          child: _buildCityRideDateTimeField(
                            title: 'Time',
                            value: selectedTime.format(context),
                            icon: Icons.access_time,
                            onTap: _selectTime,
                            screenWidth: screenWidth,
                            isTablet: isTablet,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.015),
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

          SizedBox(height: screenHeight * 0.02),

          // Add Special Instructions (second image) below passenger selector
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

          // ...rest of your booking form and ride options...
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _handleSearch();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6FCF97),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 2,
              ),
              child: Text(
                'Search',
                style: GoogleFonts.poppins(
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

  Widget _buildServiceCard(
    BuildContext context,
    String title,
    String imagePath,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isSelected
              ? const Color(0xFF6FCF97)
              : AppTheme.getServiceCardBackground(context),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6FCF97)
                : AppTheme.getServiceCardBorder(context),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.getShadowColor(context),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 6,
              child: Container(
                margin: EdgeInsets.all(screenWidth * 0.005),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppTheme.getInputFieldColor(context),
                        child: Icon(
                          Icons.image_not_supported,
                          color: AppTheme.getSecondaryTextColor(context),
                          size: screenWidth * 0.06,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.005,
                  vertical: screenWidth * 0.005,
                ),
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: screenWidth * 0.025,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : AppTheme.getTextColor(context),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityRideDateTimeField({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
    required double screenWidth,
    required bool isTablet,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: isTablet ? screenWidth * 0.015 : screenWidth * 0.04,
            horizontal: isTablet ? screenWidth * 0.015 : screenWidth * 0.04,
          ),
          decoration: BoxDecoration(
            color: AppTheme.getBackgroundColor(context),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.getBorderColor(context)),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: isTablet ? screenWidth * 0.018 : screenWidth * 0.04,
                color: AppTheme.getSecondaryTextColor(context),
              ),
              SizedBox(width: screenWidth * 0.02),
              Expanded(
                child: Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: isTablet
                        ? screenWidth * 0.014
                        : screenWidth * 0.035,
                    color: AppTheme.getTextColor(context),
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
