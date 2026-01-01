// screens/outstation_booking_widget.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'one_way_booking.dart';
import 'round_trip_booking.dart';
import 'sharing_booking.dart';

class OutstationBookingWidget extends StatefulWidget {
  const OutstationBookingWidget({super.key});

  @override
  State<OutstationBookingWidget> createState() =>
      _OutstationBookingWidgetState();
}

class _OutstationBookingWidgetState extends State<OutstationBookingWidget> {
  int selectedTab = 0; // 0: One Way, 1: Round Trip, 2: Sharing

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive calculations for different screen sizes
    final bool isTablet = screenWidth > 600;
    final double tabPadding = isTablet
        ? screenWidth * 0.02
        : screenWidth * 0.03;
    final double tabFontSize = isTablet
        ? screenWidth * 0.025
        : screenWidth * 0.035;
    final double containerPadding = isTablet
        ? screenWidth * 0.025
        : screenWidth * 0.03;

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
          // Service Tabs - One Way, Round Trip, Sharing (Responsive)
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
                      padding: EdgeInsets.symmetric(vertical: tabPadding),
                      decoration: BoxDecoration(
                        color: selectedTab == 0
                            ? const Color(0xFF6FCF97)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          'One Way',
                          style: GoogleFonts.poppins(
                            fontSize: tabFontSize,
                            fontWeight: FontWeight.w600,
                            color: selectedTab == 0
                                ? Colors.white
                                : (isDark ? Colors.white70 : Colors.black54),
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
                      padding: EdgeInsets.symmetric(vertical: tabPadding),
                      decoration: BoxDecoration(
                        color: selectedTab == 1
                            ? const Color(0xFF6FCF97)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          'Round Trip',
                          style: GoogleFonts.poppins(
                            fontSize: tabFontSize,
                            fontWeight: FontWeight.w600,
                            color: selectedTab == 1
                                ? Colors.white
                                : (isDark ? Colors.white70 : Colors.black54),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedTab = 2),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: tabPadding),
                      decoration: BoxDecoration(
                        color: selectedTab == 2
                            ? const Color(0xFF6FCF97)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          'Sharing',
                          style: GoogleFonts.poppins(
                            fontSize: tabFontSize,
                            fontWeight: FontWeight.w600,
                            color: selectedTab == 2
                                ? Colors.white
                                : (isDark ? Colors.white70 : Colors.black54),
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

          // Dynamic content based on selected tab
          if (selectedTab == 0)
            const OneWayBooking()
          else if (selectedTab == 1)
            const RoundTripBooking()
          else
            const SharingBooking(),
        ],
      ),
    );
  }
}