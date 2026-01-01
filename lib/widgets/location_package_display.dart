// widgets/location_package_display.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/app_theme.dart';

class LocationPackageDisplayWidget extends StatelessWidget {
  final String pickupLocation;
  final String dropoffLocation;
  final String packageSelected;
  final String bookingType;

  const LocationPackageDisplayWidget({
    super.key,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.packageSelected,
    required this.bookingType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Pickup Location
        Row(
          children: <Widget>[
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppTheme.getTextColor(context),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    pickupLocation,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextColor(context),
                    ),
                  ),
                  Text(
                    'Karnataka, India',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppTheme.getSecondaryTextColor(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Dotted line
        Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: Column(
            children: List<Widget>.generate(
              3,
              (int index) => Container(
                margin: const EdgeInsets.symmetric(vertical: 2.0),
                width: 2.0,
                height: 2.0,
                decoration: BoxDecoration(
                  color: AppTheme.getSecondaryTextColor(context),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),

        // Second Location/Package based on booking type
        Row(
          children: <Widget>[
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppTheme.getSecondaryTextColor(context),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    bookingType == 'Hourly Rental'
                        ? packageSelected
                        : dropoffLocation,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextColor(context),
                    ),
                  ),
                  Text(
                    'Karnataka, India',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppTheme.getSecondaryTextColor(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
