// widgets/ride_option_card.dart
import 'package:cab_booking_user_mobile_app/models/ride_option_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/app_theme.dart';

class VehicleTypeCard extends StatelessWidget {
  final VehicleType vehicleType;
  final VoidCallback onBookNow;

  const VehicleTypeCard({
    required this.vehicleType,
    required this.onBookNow,
    super.key,
    required bool isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: AppTheme.getCardColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.getBorderColor(context), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Car Image
            Container(
              width: 80,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppTheme.isDarkMode(context)
                    ? Colors.grey[800]
                    : Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  vehicleType.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (
                        BuildContext context,
                        Object error,
                        StackTrace? stackTrace,
                      ) => const Icon(
                        Icons.electric_car,
                        size: 40,
                        color: Colors.grey,
                      ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Car Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    vehicleType.modelName,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.getTextColor(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    vehicleType.bodyType,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppTheme.getSecondaryTextColor(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          vehicleType.timeInfo,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppTheme.getTextColor(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          vehicleType.extraInfo,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppTheme.getTextColor(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Price and Book Button
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  vehicleType.price,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getTextColor(context),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 90,
                  child: ElevatedButton(
                    onPressed: onBookNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6FCF97),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minimumSize: Size.zero,
                    ),
                    child: Text(
                      'Book now',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
