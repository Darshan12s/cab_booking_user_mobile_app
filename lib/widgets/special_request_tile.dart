// widgets/special_request_tile.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SpecialRequestTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final bool isSelected;
  final ValueChanged<bool?> onChanged;

  const SpecialRequestTile({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.isSelected,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          children: <Widget>[
            Checkbox(
              value: isSelected,
              onChanged: onChanged,
              activeColor: const Color(0xFF6FCF97),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFF6FCF97)
                    : (isDark ? Colors.grey[600]! : Colors.grey[400]!),
                width: 2.0,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
